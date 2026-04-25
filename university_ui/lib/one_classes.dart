import 'dart:io';
import 'dart:convert';

void main() async {
  // Directory containing the class JSON files
  final directory = Directory('gen');
  final outputFile = File('gen/all_classes.json');

  // Map to store all courses by department
  final Map<String, List<Map<String, dynamic>>> allCourses = {};

  try {
    // Get all files matching the pattern classes*.json
    final List<FileSystemEntity> files = await directory
        .list()
        .where((entity) =>
    entity is File &&
        entity.path.contains('classes') &&
        entity.path.endsWith('.json'))
        .toList();

    print('Found ${files.length} class files to process');

    // Process each file
    for (var file in files) {
      if (file is File) {
        try {
          final content = await file.readAsString();
          final jsonData = jsonDecode(content);

          print('Processing ${file.path}');

          // Extract courses from various JSON structures
          extractCourses(jsonData, allCourses);
        } catch (e) {
          print('Error processing ${file.path}: $e');
        }
      }
    }

    // Create the final combined JSON structure
    final Map<String, dynamic> combinedData = {
      'courses': allCourses,
    };

    // Write the combined JSON to output file
    await outputFile.writeAsString(
      JsonEncoder.withIndent('  ').convert(combinedData),
    );

    print('Successfully created combined class file: ${outputFile.path}');
    print('Total courses by department:');
    allCourses.forEach((dept, courses) {
      print('- $dept: ${courses.length} courses');
    });

  } catch (e) {
    print('Error: $e');
  }
}

// Function to extract courses from various JSON structures
void extractCourses(dynamic jsonData, Map<String, List<Map<String, dynamic>>> allCourses) {
  if (jsonData is Map) {
    jsonData.forEach((key, value) {
      if (key.toString().contains('courses') ||
          key.toString().contains('missing') ||
          key.toString().contains('remaining')) {

        // Determine department from the key name
        String department = extractDepartment(key);

        if (value is List) {
          // Initialize department list if not exists
          allCourses[department] ??= [];

          // Add courses to the department
          for (var course in value) {
            if (course is Map) {
              allCourses[department]!.add(Map<String, dynamic>.from(course));
            }
          }
        } else if (value is Map) {
          // Handle nested structures like missing_course_descriptions
          extractCourses(value, allCourses);
        }
      } else if (value is Map || value is List) {
        // Recursively process nested structures
        extractCourses(value, allCourses);
      }
    });
  }
}

// Extract department name from key
String extractDepartment(String key) {
  if (key.contains('psychology')) return 'Psychology';
  if (key.contains('english') || key.contains('literature')) return 'English Literature';
  if (key.contains('computer_science')) return 'Computer Science';
  if (key.contains('mathematics')) return 'Mathematics';
  if (key.contains('business')) return 'Business Administration';
  if (key.contains('additional_business')) return 'Business Administration';

  // Get prefix from course IDs if available
  if (key.contains('courses')) {
    // Default to the key itself as a fallback
    return key.split('_').map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  return 'Other';
}
