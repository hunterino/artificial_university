import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:args/args.dart';

// Configuration constants
const int maxRetries = 3;
const int retryDelay = 5; // seconds between retries
const int rateLimitDelay = 1; // seconds between API calls
const int apiTimeout = 60; // seconds for API call timeout

void main(List<String> arguments) async {
  // Parse command line arguments
  final parser = ArgParser()
    ..addOption('department', abbr: 'd', help: 'Filter courses by department code')
    ..addOption('system-prompt', abbr: 's', help: 'System prompt file path', defaultsTo: 'system_prompt.txt')
    ..addOption('user-prompt', abbr: 'u', help: 'User prompt file path', defaultsTo: 'user_prompt.txt')
    ..addOption('batch-size', abbr: 'b', help: 'Number of courses to process in parallel', defaultsTo: '1')
    ..addFlag('dry-run', help: 'Preview without making API calls', negatable: false)
    ..addFlag('help', abbr: 'h', help: 'Show usage information', negatable: false);

  try {
    final results = parser.parse(arguments);

    if (results['help']) {
      printUsage(parser);
      exit(0);
    }

    final departmentFilter = results['department'] as String?;
    final systemPromptFile = results['system-prompt'] as String;
    final userPromptFile = results['user-prompt'] as String;
    final batchSize = int.tryParse(results['batch-size']) ?? 1;
    final dryRun = results['dry-run'] as bool;

    // Validate API key if not doing a dry run
    if (!dryRun) {
      final apiKey = Platform.environment['ANTHROPIC_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        print('Error: ANTHROPIC_API_KEY environment variable not set');
        exit(1);
      }
    }

    // Read system and user prompts
    final systemPrompt = await readFile(systemPromptFile);
    final userPrompt = await readFile(userPromptFile);

    // Read and parse university degrees data
    final jsonContent = await readFile('assets/university_degrees.json');
    final Map<String, dynamic> data = json.decode(jsonContent);

    // Extract all courses from the data
    final allCourses = <Map<String, dynamic>>[];
    extractAllCourses(data, allCourses);

    // Filter courses by department code if specified
    final coursesToProcess = departmentFilter != null
        ? allCourses.where((course) => course['course_id'].toString().startsWith(departmentFilter)).toList()
        : allCourses;

    if (coursesToProcess.isEmpty) {
      print('No courses found${departmentFilter != null ? ' matching the department filter: $departmentFilter' : ''}');
      exit(0);
    }

    print('Found ${coursesToProcess.length} courses to process');

    if (dryRun) {
      print('\nDRY RUN MODE - No API calls will be made\n');
      for (var course in coursesToProcess) {
        print('Would process: ${course['course_id']} - ${course['title']}');
      }
      exit(0);
    }

    // Create output directory
    final outputDir = Directory('output');
    if (!await outputDir.exists()) {
      await outputDir.create();
    }

    // Process courses in batches
    int completed = 0;
    for (var i = 0; i < coursesToProcess.length; i += batchSize) {
      final end = (i + batchSize < coursesToProcess.length) ? i + batchSize : coursesToProcess.length;
      final batch = coursesToProcess.sublist(i, end);

      print('\nProcessing batch ${(i ~/ batchSize) + 1}/${(coursesToProcess.length / batchSize).ceil()}');

      // Process courses in this batch
      final futures = batch.map((course) => processCourse(
          course,
          systemPrompt,
          userPrompt,
          Platform.environment['ANTHROPIC_API_KEY']!
      )).toList();

      // Wait for all courses in this batch to complete
      await Future.wait(futures);

      completed += batch.length;
      print('Progress: $completed/${coursesToProcess.length} courses processed');
    }

    print('\nAll courses processed successfully!');

  } catch (e) {
    print('Error: $e');
    exit(1);
  }
}

Future<String> readFile(String path) async {
  final file = File(path);
  if (!await file.exists()) {
    throw Exception('File not found: $path');
  }
  return await file.readAsString();
}

void printUsage(ArgParser parser) {
  print('Course Processing Application');
  print('\nThis application processes course data through Claude AI and saves the responses.');
  print('\nUsage: dart run course_processor.dart [options]');
  print('\nOptions:');
  print(parser.usage);
  print('\nEnvironment variables:');
  print('  ANTHROPIC_API_KEY - Your Claude API key (required unless using --dry-run)');
}

// Recursive function to extract all courses from the JSON structure
void extractAllCourses(dynamic data, List<Map<String, dynamic>> courses) {
  if (data is Map<String, dynamic>) {
    // If this is a course object with course_id and title, add it
    if (data.containsKey('course_id') && data.containsKey('title')) {
      courses.add(data);
    } else {
      // Otherwise, process each value in the map recursively
      for (var value in data.values) {
        extractAllCourses(value, courses);
      }
    }
  } else if (data is List) {
    // Process each item in a list
    for (var item in data) {
      extractAllCourses(item, courses);
    }
  }
}

Future<void> processCourse(
    Map<String, dynamic> course,
    String systemPrompt,
    String userPrompt,
    String apiKey
    ) async {
  final courseId = course['course_id'];
  print('Processing course: $courseId - ${course['title']}');

  // Create customized prompts for this specific course
  final customizedSystemPrompt = systemPrompt.replaceAll('{{COURSE_DATA}}', json.encode(course));
  final customizedUserPrompt = userPrompt.replaceAll('{{COURSE_DATA}}', json.encode(course));

  // Check if output file already exists
  final outputFile = File('output/$courseId.json');
  if (await outputFile.exists()) {
    print('Output file already exists for $courseId, skipping');
    return;
  }

  // Process the course with retries
  for (var attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      final response = await callClaudeApi(customizedSystemPrompt, customizedUserPrompt, apiKey);

      // Save response to file
      await outputFile.writeAsString(response);

      print('Successfully processed $courseId');
      break;
    } catch (e) {
      if (attempt < maxRetries) {
        print('Error processing $courseId (attempt $attempt/$maxRetries): $e');
        print('Retrying in ${retryDelay * attempt} seconds...');
        await Future.delayed(Duration(seconds: retryDelay * attempt));
      } else {
        print('Failed to process $courseId after $maxRetries attempts: $e');
        // Create an error file to indicate failure
        final errorFile = File('output/${courseId}_error.txt');
        await errorFile.writeAsString('Failed after $maxRetries attempts: $e');
      }
    }
  }

  // Add delay to avoid rate limits
  await Future.delayed(Duration(seconds: rateLimitDelay));
}

Future<String> callClaudeApi(String systemPrompt, String userPrompt, String apiKey) async {
  // Claude API endpoint
  final url = Uri.parse('https://api.anthropic.com/v1/messages');

  final headers = {
    'Content-Type': 'application/json',
    'x-api-key': apiKey,
    'anthropic-version': '2023-06-01'
  };

  final body = json.encode({
    'model': 'claude-3-sonnet-20240229',
    'max_tokens': 4000,
    'system': systemPrompt,
    'messages': [
      {
        'role': 'user',
        'content': userPrompt
      }
    ]
  });

  final response = await http.post(
      url,
      headers: headers,
      body: body
  ).timeout(Duration(seconds: apiTimeout));

  if (response.statusCode == 200) {
    final responseData = json.decode(response.body);
    return json.encode(responseData);
  } else {
    throw Exception('Claude API error (${response.statusCode}): ${response.body}');
  }
}
