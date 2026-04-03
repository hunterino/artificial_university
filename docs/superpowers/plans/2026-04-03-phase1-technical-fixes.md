# Phase 1: Technical Fixes — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix all production-standard violations in the Artificial University Flutter app and add a pluggable LLM service interface backed by local Ollama.

**Architecture:** Abstract `LlmService` interface with `OllamaLlmService` implementation. `GradingService` (renamed from `AIService`) owns prompt construction and response parsing. Shared utility files eliminate duplicated logic. Safe JSON parsing across all models.

**Tech Stack:** Flutter/Dart, Provider, Ollama REST API (`localhost:11434`), `sam860/granite-4.0:7b`

**Spec:** `docs/superpowers/specs/2026-04-03-university-fixes-and-curriculum-design.md`

---

### Task 1: Remove Broken `extractor` Dependency and Clean Up pubspec.yaml

**Files:**
- Modify: `pubspec.yaml:34-35` (remove extractor), lines 47-48 (remove lottie, shared_preferences, args)
- Move: `lib/extract.dart` → `tools/extract.dart`
- Move: `lib/genSyllabus.dart` → `tools/genSyllabus.dart`
- Move: `lib/one_classes.dart` → `tools/one_classes.dart`

- [ ] **Step 1: Remove `extractor` dependency from pubspec.yaml**

Remove lines 34-35:
```yaml
  extractor:
    path: ../../extractor
```

- [ ] **Step 2: Remove unused dependencies from pubspec.yaml**

Remove these lines:
```yaml
  args: ^2.4.2
```
```yaml
  shared_preferences: ^2.2.2
```
```yaml
  lottie: ^2.7.0
```

Keep `http` (will be used by Ollama service) and `flutter_markdown` (will be used by AI Tutor).

- [ ] **Step 3: Move utility scripts out of lib/**

```bash
mkdir -p tools
mv lib/extract.dart tools/
mv lib/genSyllabus.dart tools/
mv lib/one_classes.dart tools/
```

- [ ] **Step 4: Run flutter pub get**

```bash
cd university_ui && flutter pub get
```

Expected: Resolves without errors.

- [ ] **Step 5: Run flutter analyze**

```bash
cd university_ui && flutter analyze
```

Expected: May have warnings (we'll fix those in later tasks), but no errors related to missing extractor package.

---

### Task 2: Create Safe JSON Parsing Utilities

**Files:**
- Create: `lib/utils/json_utils.dart`

- [ ] **Step 1: Create `lib/utils/json_utils.dart`**

```dart
/// Safe JSON field extraction helpers.
/// Throws [FormatException] with descriptive messages on type mismatches
/// instead of silent null assignment or runtime cast errors.

String extractString(Map<String, dynamic> json, String key, {String? fallback}) {
  final value = json[key];
  if (value is String) return value;
  if (fallback != null && value == null) return fallback;
  throw FormatException('Expected String for "$key", got ${value.runtimeType}: $value');
}

int extractInt(Map<String, dynamic> json, String key, {int? fallback}) {
  final value = json[key];
  if (value is int) return value;
  if (fallback != null && value == null) return fallback;
  throw FormatException('Expected int for "$key", got ${value.runtimeType}: $value');
}

double extractDouble(Map<String, dynamic> json, String key, {double? fallback}) {
  final value = json[key];
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (fallback != null && value == null) return fallback;
  throw FormatException('Expected double for "$key", got ${value.runtimeType}: $value');
}

List<String> extractStringList(Map<String, dynamic> json, String key, {List<String>? fallback}) {
  final value = json[key];
  if (value is List) return value.cast<String>();
  if (fallback != null && value == null) return fallback;
  throw FormatException('Expected List for "$key", got ${value.runtimeType}');
}

List<dynamic> extractList(Map<String, dynamic> json, String key, {List<dynamic>? fallback}) {
  final value = json[key];
  if (value is List) return value;
  if (fallback != null && value == null) return fallback;
  throw FormatException('Expected List for "$key", got ${value.runtimeType}');
}

Map<String, dynamic> extractMap(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is Map<String, dynamic>) return value;
  throw FormatException('Expected Map for "$key", got ${value.runtimeType}');
}

String? extractStringOrNull(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is String) return value;
  throw FormatException('Expected String? for "$key", got ${value.runtimeType}');
}

List<String>? extractStringListOrNull(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is List) return value.cast<String>();
  throw FormatException('Expected List? for "$key", got ${value.runtimeType}');
}
```

---

### Task 3: Update All Models to Use Safe JSON Parsing

**Files:**
- Modify: `lib/models/university.dart`
- Modify: `lib/models/degree.dart`
- Modify: `lib/models/course.dart`
- Modify: `lib/models/class_detail.dart`

- [ ] **Step 1: Update `lib/models/university.dart`**

Add import and update all `fromJson` factories:

```dart
import '../utils/json_utils.dart';
import './course.dart';

class University {
  final String name;
  final String mission;
  final String accreditation;
  final int established;
  final String learningModel;
  final String assessmentMethod;

  University({
    required this.name,
    required this.mission,
    required this.accreditation,
    required this.established,
    required this.learningModel,
    required this.assessmentMethod,
  });

  factory University.fromJson(Map<String, dynamic> json) {
    return University(
      name: extractString(json, 'name'),
      mission: extractString(json, 'mission'),
      accreditation: extractString(json, 'accreditation'),
      established: extractInt(json, 'established'),
      learningModel: extractString(json, 'learning_model'),
      assessmentMethod: extractString(json, 'assessment_method'),
    );
  }
}

class GeneralEducationRequirement {
  final int totalCredits;
  final List<CourseCategory> categories;

  GeneralEducationRequirement({
    required this.totalCredits,
    required this.categories,
  });

  factory GeneralEducationRequirement.fromJson(Map<String, dynamic> json) {
    return GeneralEducationRequirement(
      totalCredits: extractInt(json, 'total_credits'),
      categories: extractList(json, 'categories')
          .map((cat) => CourseCategory.fromJson(cat as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CourseCategory {
  final String category;
  final int credits;
  final List<Course> courses;

  CourseCategory({
    required this.category,
    required this.credits,
    required this.courses,
  });

  factory CourseCategory.fromJson(Map<String, dynamic> json) {
    return CourseCategory(
      category: extractString(json, 'category'),
      credits: extractInt(json, 'credits'),
      courses: extractList(json, 'courses')
          .map((course) => Course.fromJson(course as Map<String, dynamic>))
          .toList(),
    );
  }
}
```

- [ ] **Step 2: Update `lib/models/degree.dart`**

```dart
import '../utils/json_utils.dart';
import 'course.dart';

class DegreeProgram {
  final String degreeId;
  final String title;
  final String duration;
  final int totalCredits;
  final String description;
  final int majorCredits;
  final List<Course> requiredCourses;

  DegreeProgram({
    required this.degreeId,
    required this.title,
    required this.duration,
    required this.totalCredits,
    required this.description,
    required this.majorCredits,
    required this.requiredCourses,
  });

  factory DegreeProgram.fromJson(Map<String, dynamic> json) {
    return DegreeProgram(
      degreeId: extractString(json, 'degree_id'),
      title: extractString(json, 'title'),
      duration: extractString(json, 'duration'),
      totalCredits: extractInt(json, 'total_credits'),
      description: extractString(json, 'description'),
      majorCredits: extractInt(json, 'major_credits'),
      requiredCourses: extractList(json, 'required_courses')
          .map((course) => Course.fromJson(course as Map<String, dynamic>))
          .toList(),
    );
  }
}
```

- [ ] **Step 3: Update `lib/models/course.dart`**

```dart
import '../utils/json_utils.dart';

class Course {
  final String courseId;
  final String title;
  final int creditHours;
  final String? description;
  final List<String>? learningObjectives;
  final List<String>? coveredMaterials;

  Course({
    required this.courseId,
    required this.title,
    required this.creditHours,
    this.description,
    this.learningObjectives,
    this.coveredMaterials,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      courseId: extractString(json, 'course_id'),
      title: extractString(json, 'title'),
      creditHours: extractInt(json, 'credit_hours'),
      description: extractStringOrNull(json, 'description'),
      learningObjectives: extractStringListOrNull(json, 'learning_objectives'),
      coveredMaterials: extractStringListOrNull(json, 'covered_materials'),
    );
  }
}
```

- [ ] **Step 4: Update `lib/models/class_detail.dart`**

Add `import '../utils/json_utils.dart';` at top. Update every `fromJson` factory to use `extractString`, `extractInt`, `extractList`, `extractStringList`, `extractMap` instead of bare `json['field']` access. There are 11 classes in this file: `ClassDetail`, `CourseInfo`, `ClassSession`, `LectureNotes`, `Assessments`, `Quiz`, `QuizQuestion`, `Assignment`, `GradingBreakdown`, `GradingComponent`, `CoursePolicies`.

For each class, replace patterns like:
```dart
// Before
courseId: json['course_id'],
// After
courseId: extractString(json, 'course_id'),
```

```dart
// Before
(json['prerequisites'] as List).cast<String>(),
// After
extractStringList(json, 'prerequisites'),
```

```dart
// Before
(json['quizzes'] as List).map(...)
// After
extractList(json, 'quizzes').map(...)
```

For `Assessments.fromJson`, handle the nullable `major_assignments`:
```dart
factory Assessments.fromJson(Map<String, dynamic> json) {
  return Assessments(
    quizzes: extractList(json, 'quizzes')
        .map((quiz) => Quiz.fromJson(quiz as Map<String, dynamic>))
        .toList(),
    majorAssignments: (json['major_assignments'] as List?)
        ?.map((a) => Assignment.fromJson(a as Map<String, dynamic>))
        .toList() ?? [],
  );
}
```

- [ ] **Step 5: Run flutter analyze**

```bash
cd university_ui && flutter analyze
```

Expected: No errors from model files.

---

### Task 4: Create Shared Utility Files

**Files:**
- Create: `lib/utils/grade_utils.dart`
- Create: `lib/utils/degree_utils.dart`
- Create: `lib/utils/course_utils.dart`

- [ ] **Step 1: Create `lib/utils/grade_utils.dart`**

```dart
import 'package:flutter/material.dart';

Color getGradeColor(double percentage) {
  if (percentage >= 90) return Colors.green;
  if (percentage >= 80) return Colors.blue;
  if (percentage >= 70) return Colors.orange;
  if (percentage >= 60) return Colors.deepOrange;
  return Colors.red;
}

String getLetterGrade(double percentage) {
  if (percentage >= 97) return 'A+';
  if (percentage >= 93) return 'A';
  if (percentage >= 90) return 'A-';
  if (percentage >= 87) return 'B+';
  if (percentage >= 83) return 'B';
  if (percentage >= 80) return 'B-';
  if (percentage >= 77) return 'C+';
  if (percentage >= 73) return 'C';
  if (percentage >= 70) return 'C-';
  if (percentage >= 67) return 'D+';
  if (percentage >= 63) return 'D';
  if (percentage >= 60) return 'D-';
  return 'F';
}
```

- [ ] **Step 2: Create `lib/utils/degree_utils.dart`**

```dart
import 'package:flutter/material.dart';

IconData getDegreeIcon(String degreeId) {
  switch (degreeId) {
    case 'BSCS001': return Icons.computer;
    case 'BSBA001': return Icons.business_center;
    case 'BSHI001': return Icons.health_and_safety;
    case 'BSCY001': return Icons.security;
    case 'BSPM001': return Icons.assignment;
    case 'BAPS001': return Icons.psychology;
    case 'BAEL001': return Icons.menu_book;
    case 'BAGD001': return Icons.games;
    case 'BAED001': return Icons.cast_for_education;
    case 'BADC001': return Icons.campaign;
    case 'BAIS001': return Icons.public;
    case 'BAUX001': return Icons.design_services;
    default: return Icons.school;
  }
}

Color getDegreeColor(String degreeId) {
  switch (degreeId) {
    case 'BSCS001': return Colors.blue;
    case 'BSBA001': return Colors.green;
    case 'BSHI001': return Colors.red;
    case 'BSCY001': return Colors.deepPurple;
    case 'BSPM001': return Colors.orange;
    case 'BAPS001': return Colors.purple;
    case 'BAEL001': return Colors.indigo;
    case 'BAGD001': return Colors.pink;
    case 'BAED001': return Colors.teal;
    case 'BADC001': return Colors.cyan;
    case 'BAIS001': return Colors.amber;
    case 'BAUX001': return Colors.deepOrange;
    default: return Colors.grey;
  }
}
```

- [ ] **Step 3: Create `lib/utils/course_utils.dart`**

```dart
import 'package:flutter/material.dart';

IconData getCourseIcon(String courseId) {
  if (courseId.startsWith('CS')) return Icons.code;
  if (courseId.startsWith('BA')) return Icons.business;
  if (courseId.startsWith('HI')) return Icons.health_and_safety;
  if (courseId.startsWith('CY')) return Icons.security;
  if (courseId.startsWith('PM')) return Icons.assignment;
  if (courseId.startsWith('PSY')) return Icons.psychology;
  if (courseId.startsWith('ENG')) return Icons.menu_book;
  if (courseId.startsWith('GD')) return Icons.games;
  if (courseId.startsWith('ED')) return Icons.school;
  if (courseId.startsWith('DC')) return Icons.campaign;
  if (courseId.startsWith('IS')) return Icons.public;
  if (courseId.startsWith('UX')) return Icons.design_services;
  if (courseId.startsWith('MATH')) return Icons.calculate;
  if (courseId.startsWith('GEN')) return Icons.library_books;
  if (courseId.startsWith('ART')) return Icons.palette;
  if (courseId.startsWith('COMM')) return Icons.forum;
  return Icons.subject;
}

Color getCourseColor(String courseId) {
  if (courseId.startsWith('CS')) return Colors.blue;
  if (courseId.startsWith('BA')) return Colors.green;
  if (courseId.startsWith('HI')) return Colors.red;
  if (courseId.startsWith('CY')) return Colors.deepPurple;
  if (courseId.startsWith('PM')) return Colors.orange;
  if (courseId.startsWith('PSY')) return Colors.purple;
  if (courseId.startsWith('ENG')) return Colors.indigo;
  if (courseId.startsWith('GD')) return Colors.pink;
  if (courseId.startsWith('ED')) return Colors.teal;
  if (courseId.startsWith('DC')) return Colors.cyan;
  if (courseId.startsWith('IS')) return Colors.amber;
  if (courseId.startsWith('UX')) return Colors.deepOrange;
  if (courseId.startsWith('MATH')) return Colors.brown;
  if (courseId.startsWith('GEN')) return Colors.grey;
  if (courseId.startsWith('ART')) return Colors.pink;
  if (courseId.startsWith('COMM')) return Colors.teal;
  return Colors.blueGrey;
}
```

---

### Task 5: Create GradingResult Model

**Files:**
- Create: `lib/models/grading_result.dart`

- [ ] **Step 1: Create `lib/models/grading_result.dart`**

This is the single source of truth for grade calculation — replaces `AIGradingResult` from `ai_service.dart`.

```dart
import '../utils/grade_utils.dart';
import 'package:flutter/material.dart';

class GradingResult {
  final int score;
  final int maxScore;
  final String feedback;
  final List<RubricScore> rubricBreakdown;

  GradingResult({
    required this.score,
    required this.maxScore,
    required this.feedback,
    required this.rubricBreakdown,
  });

  double get percentage => maxScore > 0 ? (score / maxScore) * 100 : 0;
  String get letterGrade => getLetterGrade(percentage);
  Color get gradeColor => getGradeColor(percentage);

  factory GradingResult.fromLlmResponse(Map<String, dynamic> json, int maxScore) {
    final rubricScores = (json['rubric_scores'] as List?)
        ?.map((r) => RubricScore(
              criterion: r['criterion'] as String? ?? 'Unknown',
              score: r['score'] as int? ?? 0,
              maxScore: r['max_score'] as int? ?? 0,
              feedback: r['feedback'] as String? ?? '',
            ))
        .toList() ?? [];

    return GradingResult(
      score: json['total_score'] as int? ?? 0,
      maxScore: maxScore,
      feedback: json['overall_feedback'] as String? ?? 'No feedback available.',
      rubricBreakdown: rubricScores,
    );
  }
}

class RubricScore {
  final String criterion;
  final int score;
  final int maxScore;
  final String feedback;

  RubricScore({
    required this.criterion,
    required this.score,
    required this.maxScore,
    required this.feedback,
  });

  double get percentage => maxScore > 0 ? (score / maxScore) * 100 : 0;
  Color get gradeColor => getGradeColor(percentage);
}
```

---

### Task 6: Create LLM Service Interface

**Files:**
- Create: `lib/services/llm_service.dart`

- [ ] **Step 1: Create `lib/services/llm_service.dart`**

```dart
enum LlmProvider { ollama, claude, openai }

class LlmConfig {
  final LlmProvider provider;
  final String model;
  final String baseUrl;
  final String? apiKey;

  const LlmConfig({
    required this.provider,
    required this.model,
    required this.baseUrl,
    this.apiKey,
  });

  factory LlmConfig.ollama({String model = 'sam860/granite-4.0:7b'}) {
    return LlmConfig(
      provider: LlmProvider.ollama,
      model: model,
      baseUrl: 'http://localhost:11434',
    );
  }

  factory LlmConfig.claude({required String apiKey, String model = 'claude-sonnet-4-20250514'}) {
    return LlmConfig(
      provider: LlmProvider.claude,
      model: model,
      baseUrl: 'https://api.anthropic.com',
      apiKey: apiKey,
    );
  }
}

/// Abstract interface for LLM communication.
/// Implementations handle only transport — prompt construction lives in GradingService.
abstract class LlmService {
  LlmConfig get config;

  /// Send a prompt and return the raw text response.
  Future<String> complete(String prompt);

  /// Send a chat conversation and return the assistant's response.
  Future<String> chat(List<Map<String, String>> messages);

  /// Check if the LLM service is reachable.
  Future<bool> isAvailable();
}
```

---

### Task 7: Create Ollama LLM Service Implementation

**Files:**
- Create: `lib/services/ollama_llm_service.dart`

- [ ] **Step 1: Create `lib/services/ollama_llm_service.dart`**

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'llm_service.dart';

class OllamaLlmService implements LlmService {
  @override
  final LlmConfig config;

  final http.Client _client;

  OllamaLlmService({required this.config, http.Client? client})
      : _client = client ?? http.Client();

  @override
  Future<String> complete(String prompt) async {
    final response = await _client.post(
      Uri.parse('${config.baseUrl}/api/generate'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'model': config.model,
        'prompt': prompt,
        'stream': false,
        'options': {
          'temperature': 0.3,
          'num_predict': 2048,
        },
      }),
    );

    if (response.statusCode != 200) {
      throw LlmServiceException(
        'Ollama returned status ${response.statusCode}: ${response.body}',
      );
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    final text = data['response'] as String?;
    if (text == null || text.isEmpty) {
      throw LlmServiceException('Ollama returned empty response');
    }
    return text;
  }

  @override
  Future<String> chat(List<Map<String, String>> messages) async {
    final ollamaMessages = messages.map((m) => {
      'role': m['role'] ?? 'user',
      'content': m['content'] ?? '',
    }).toList();

    final response = await _client.post(
      Uri.parse('${config.baseUrl}/api/chat'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'model': config.model,
        'messages': ollamaMessages,
        'stream': false,
        'options': {
          'temperature': 0.5,
          'num_predict': 2048,
        },
      }),
    );

    if (response.statusCode != 200) {
      throw LlmServiceException(
        'Ollama chat returned status ${response.statusCode}: ${response.body}',
      );
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    final message = data['message'] as Map<String, dynamic>?;
    final content = message?['content'] as String?;
    if (content == null || content.isEmpty) {
      throw LlmServiceException('Ollama chat returned empty response');
    }
    return content;
  }

  @override
  Future<bool> isAvailable() async {
    try {
      final response = await _client
          .get(Uri.parse('${config.baseUrl}/api/tags'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}

class LlmServiceException implements Exception {
  final String message;
  LlmServiceException(this.message);

  @override
  String toString() => 'LlmServiceException: $message';
}
```

---

### Task 8: Create GradingService (Replace AIService)

**Files:**
- Create: `lib/services/grading_service.dart`
- Delete: `lib/services/ai_service.dart`

- [ ] **Step 1: Create `lib/services/grading_service.dart`**

```dart
import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/grading_result.dart';
import '../models/class_detail.dart';
import 'llm_service.dart';
import 'ollama_llm_service.dart';

class GradingService extends ChangeNotifier {
  final LlmService _llmService;

  GradingService({required LlmService llmService}) : _llmService = llmService;

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  String? _error;
  String? get error => _error;

  Future<bool> checkLlmAvailability() => _llmService.isAvailable();

  Future<GradingResult> gradeQuizAnswer(
    QuizQuestion question,
    String studentAnswer,
  ) async {
    _isProcessing = true;
    _error = null;
    notifyListeners();

    try {
      final prompt = _buildQuizGradingPrompt(question, studentAnswer);
      final responseText = await _llmService.complete(prompt);
      final result = _parseGradingResponse(responseText, question.points);
      return result;
    } catch (e) {
      _error = 'Failed to grade answer: $e';
      notifyListeners();
      return GradingResult(
        score: 0,
        maxScore: question.points,
        feedback: 'Grading failed: $e. Please try again.',
        rubricBreakdown: [],
      );
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<GradingResult> gradeAssignment(
    Assignment assignment,
    String studentSubmission,
  ) async {
    _isProcessing = true;
    _error = null;
    notifyListeners();

    try {
      final prompt = _buildAssignmentGradingPrompt(assignment, studentSubmission);
      final responseText = await _llmService.complete(prompt);
      final result = _parseGradingResponse(responseText, assignment.points);
      return result;
    } catch (e) {
      _error = 'Failed to grade assignment: $e';
      notifyListeners();
      return GradingResult(
        score: 0,
        maxScore: assignment.points,
        feedback: 'Grading failed: $e. Please try again.',
        rubricBreakdown: [],
      );
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<String> chat({
    required List<Map<String, String>> messages,
    required String courseContext,
  }) async {
    try {
      final systemMessage = {
        'role': 'system',
        'content': 'You are an AI tutor for a university course. '
            'Course context: $courseContext. '
            'Help the student understand concepts, answer questions, and provide guidance. '
            'Be encouraging but accurate. Do not give direct answers to quiz or assignment questions.',
      };

      final allMessages = [systemMessage, ...messages];
      return await _llmService.chat(allMessages);
    } catch (e) {
      throw Exception('AI Tutor unavailable: $e');
    }
  }

  String _buildQuizGradingPrompt(QuizQuestion question, String studentAnswer) {
    final rubricText = question.rubric
        .map((r) => '- ${r['key']}: ${r['value']} points')
        .join('\n');

    return '''Grade this student's answer. Respond ONLY with valid JSON, no other text.

Question: ${question.question}
Question Type: ${question.type}
Expected Answer: ${question.answer}
Student Answer: $studentAnswer

Grading Rubric:
$rubricText

Total Points: ${question.points}

Respond with this exact JSON structure:
{
  "rubric_scores": [
    {"criterion": "criterion name", "score": earned_points, "max_score": max_points, "feedback": "specific feedback"}
  ],
  "total_score": total_earned,
  "overall_feedback": "overall feedback paragraph"
}''';
  }

  String _buildAssignmentGradingPrompt(Assignment assignment, String submission) {
    final objectivesText = assignment.objectives.map((o) => '- $o').join('\n');
    final deliverablesText = assignment.deliverables.map((d) => '- $d').join('\n');

    return '''Grade this student's assignment submission. Respond ONLY with valid JSON, no other text.

Assignment: ${assignment.title}
Description: ${assignment.description}

Learning Objectives:
$objectivesText

Expected Deliverables:
$deliverablesText

Student Submission:
$submission

Total Points: ${assignment.points}

Respond with this exact JSON structure:
{
  "rubric_scores": [
    {"criterion": "criterion name", "score": earned_points, "max_score": max_points, "feedback": "specific feedback"}
  ],
  "total_score": total_earned,
  "overall_feedback": "overall feedback paragraph"
}''';
  }

  GradingResult _parseGradingResponse(String responseText, int maxScore) {
    // Extract JSON from the response — LLMs sometimes wrap JSON in markdown code blocks
    var jsonText = responseText.trim();
    if (jsonText.contains('```json')) {
      jsonText = jsonText.split('```json').last.split('```').first.trim();
    } else if (jsonText.contains('```')) {
      jsonText = jsonText.split('```')[1].trim();
    }

    try {
      final data = json.decode(jsonText) as Map<String, dynamic>;
      return GradingResult.fromLlmResponse(data, maxScore);
    } catch (e) {
      // If JSON parsing fails, return a basic result with the raw feedback
      return GradingResult(
        score: 0,
        maxScore: maxScore,
        feedback: 'AI provided feedback but structured grading failed. Raw response:\n\n$responseText',
        rubricBreakdown: [],
      );
    }
  }
}
```

- [ ] **Step 2: Delete `lib/services/ai_service.dart`**

```bash
rm lib/services/ai_service.dart
```

---

### Task 9: Fix DataService — Error Handling + Dynamic Class Loading

**Files:**
- Modify: `lib/services/data_service.dart`

- [ ] **Step 1: Rewrite `lib/services/data_service.dart`**

```dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/university.dart';
import '../models/degree.dart';
import '../models/course.dart';
import '../models/class_detail.dart';

class DataService extends ChangeNotifier {
  University? _university;
  GeneralEducationRequirement? _generalEducation;
  List<DegreeProgram> _degreePrograms = [];
  Map<String, List<Course>> _coursesBySubject = {};
  Map<String, ClassDetail> _classDetails = {};

  University? get university => _university;
  GeneralEducationRequirement? get generalEducation => _generalEducation;
  List<DegreeProgram> get degreePrograms => _degreePrograms;
  Map<String, List<Course>> get coursesBySubject => _coursesBySubject;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  /// IDs of classes that failed to load, with their error messages.
  final Map<String, String> _classLoadErrors = {};
  Map<String, String> get classLoadErrors => Map.unmodifiable(_classLoadErrors);

  Future<void> loadUniversityData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final universityData = await rootBundle.loadString('assets/degrees.json');
      final universityJson = json.decode(universityData) as Map<String, dynamic>;

      _university = University.fromJson(universityJson['university'] as Map<String, dynamic>);
      _generalEducation = GeneralEducationRequirement.fromJson(
        universityJson['general_education_requirements'] as Map<String, dynamic>,
      );
      _degreePrograms = (universityJson['degree_programs'] as List)
          .map((degree) => DegreeProgram.fromJson(degree as Map<String, dynamic>))
          .toList();

      final coursesData = await rootBundle.loadString('assets/data/courses.json');
      final coursesJson = json.decode(coursesData) as Map<String, dynamic>;

      (coursesJson['courses'] as Map<String, dynamic>).forEach((subject, courses) {
        _coursesBySubject[subject] = (courses as List)
            .map((course) => Course.fromJson(course as Map<String, dynamic>))
            .toList();
      });

      await _loadAllClassDetails();
    } catch (e) {
      _error = 'Failed to load university data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadAllClassDetails() async {
    // Discover all available class JSON files via the asset manifest
    final manifestString = await rootBundle.loadString('AssetManifest.json');
    final manifest = json.decode(manifestString) as Map<String, dynamic>;
    final classFiles = manifest.keys
        .where((key) =>
            key.startsWith('assets/courses/') &&
            key.endsWith('.json') &&
            !key.contains('schema'))
        .toList();

    for (final file in classFiles) {
      final classId = file.split('/').last.replaceAll('.json', '');
      await _loadClassDetail(classId);
    }
  }

  Future<void> _loadClassDetail(String classId) async {
    try {
      final classData = await rootBundle.loadString('assets/courses/$classId.json');
      final classJson = json.decode(classData) as Map<String, dynamic>;
      _classDetails[classId] = ClassDetail.fromJson(classJson);
    } catch (e) {
      _classLoadErrors[classId] = 'Failed to load class detail for $classId: $e';
    }
  }

  ClassDetail? getClassDetail(String classId) {
    return _classDetails[classId];
  }

  /// Returns all course IDs that have class details available.
  List<String> get availableClassIds => _classDetails.keys.toList();

  DegreeProgram? getDegreeById(String degreeId) {
    for (final degree in _degreePrograms) {
      if (degree.degreeId == degreeId) return degree;
    }
    return null;
  }

  List<Course> getCoursesForSubject(String subject) {
    return _coursesBySubject[subject] ?? [];
  }
}
```

---

### Task 10: Update main.dart — New Provider Registration

**Files:**
- Modify: `lib/main.dart`

- [ ] **Step 1: Rewrite `lib/main.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';
import 'services/data_service.dart';
import 'services/grading_service.dart';
import 'services/llm_service.dart';
import 'services/ollama_llm_service.dart';

void main() {
  runApp(const ArtificialUniversityApp());
}

class ArtificialUniversityApp extends StatelessWidget {
  const ArtificialUniversityApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Change this one line to switch LLM providers
    final llmConfig = LlmConfig.ollama();
    final llmService = OllamaLlmService(config: llmConfig);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DataService()),
        ChangeNotifierProvider(create: (_) => GradingService(llmService: llmService)),
      ],
      child: MaterialApp(
        title: 'Artificial University',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          textTheme: GoogleFonts.interTextTheme(),
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.light,
          ),
        ),
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
```

---

### Task 11: Fix HomeScreen — Icons, Error Display, Navigation

**Files:**
- Modify: `lib/screens/home_screen.dart`

- [ ] **Step 1: Update imports**

Replace `import '../services/ai_service.dart';` (if present) and add:
```dart
import 'take_class_screen.dart';
```

- [ ] **Step 2: Fix Icons.mic → Icons.auto_graph at line 169**

```dart
// Before
Icons.mic,
// After
Icons.auto_graph,
```

- [ ] **Step 3: Remove "Course Catalog" action button (lines 254-264)**

Delete the entire `_buildActionButton` call for "Course Catalog" and its preceding `const SizedBox(height: 12)`.

- [ ] **Step 4: Fix _showDemoClassDialog to navigate directly to TakeClassScreen**

Replace the `Navigator.push` inside "Try Demo" onPressed (line 389-392):

```dart
// Before
MaterialPageRoute(builder: (_) => const DegreesScreen()),
// After
MaterialPageRoute(builder: (_) => const TakeClassScreen(courseId: 'GD401')),
```

- [ ] **Step 5: Add error display in the Consumer builder**

After the `isLoading` check and before the `university == null` check, add error handling:

```dart
if (dataService.error != null) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Failed to Load',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            dataService.error!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => dataService.loadUniversityData(),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    ),
  );
}
```

---

### Task 12: Fix CourseDetailScreen — Wrong Icon

**Files:**
- Modify: `lib/screens/course_detail_screen.dart:165`

- [ ] **Step 1: Fix Icons.phone → Icons.flag**

```dart
// Before
Icon(Icons.phone, color: Theme.of(context).primaryColor),
// After
Icon(Icons.flag, color: Theme.of(context).primaryColor),
```

---

### Task 13: Fix TakeClassScreen — Render All 5 Policy Fields

**Files:**
- Modify: `lib/screens/take_class_screen.dart:301-323`

- [ ] **Step 1: Add missing policy sections**

In `_buildCoursePoliciesCard`, add after `_buildPolicySection('Academic Integrity', ...)`:

```dart
_buildPolicySection('Collaboration', policies.collaboration),
_buildPolicySection('Technology Requirements', policies.technologyRequirements),
```

---

### Task 14: Update Widgets to Use Shared Utilities

**Files:**
- Modify: `lib/widgets/degree_card.dart`
- Modify: `lib/screens/degree_detail_screen.dart`
- Modify: `lib/widgets/course_card.dart`
- Modify: `lib/widgets/ai_grading_widget.dart`
- Modify: `lib/screens/quiz_screen.dart`

- [ ] **Step 1: Update `degree_card.dart`**

Add import: `import '../utils/degree_utils.dart';`

Delete local `_getDegreeIcon` method (lines 139-168) and `_getDegreeColor` method (lines 170-199). Replace all calls:
```dart
// Before
_getDegreeIcon(degree.degreeId)
_getDegreeColor(degree.degreeId)
// After
getDegreeIcon(degree.degreeId)
getDegreeColor(degree.degreeId)
```

- [ ] **Step 2: Update `degree_detail_screen.dart`**

Add import: `import '../utils/degree_utils.dart';`

Delete local `_getDegreeIcon` method (lines 262-291). Replace call:
```dart
// Before
_getDegreeIcon(degree.degreeId)
// After
getDegreeIcon(degree.degreeId)
```

- [ ] **Step 3: Update `course_card.dart`**

Add import: `import '../utils/course_utils.dart';`

Delete local `_getCourseIcon` (lines 138-154) and `_getCourseColor` (lines 156-172) methods. Replace all calls:
```dart
// Before
_getCourseIcon(course.courseId)
_getCourseColor(course.courseId)
// After
getCourseIcon(course.courseId)
getCourseColor(course.courseId)
```

- [ ] **Step 4: Update `ai_grading_widget.dart`**

Replace import: `import '../services/ai_service.dart';` with `import '../models/grading_result.dart';`

Add import: `import '../utils/grade_utils.dart';`

Delete local `_getGradeColor` method (lines 241-247). Replace all calls with `getGradeColor(...)`. Also reference `gradingResult.gradeColor` where appropriate.

- [ ] **Step 5: Update `quiz_screen.dart`**

Replace import: `import '../services/ai_service.dart';` with:
```dart
import '../models/grading_result.dart';
import '../services/grading_service.dart';
import '../utils/grade_utils.dart';
```

Delete local `_getGradeColor` method (lines 480-486) and `_getLetterGrade` method (lines 488-502). Replace all calls:
```dart
// Before
_getGradeColor(percentage) → getGradeColor(percentage)
_getLetterGrade(percentage) → getLetterGrade(percentage)
```

Update `_submitAnswer` to use `GradingService` instead of `AIService`:
```dart
final gradingService = Provider.of<GradingService>(context, listen: false);
final result = await gradingService.gradeQuizAnswer(question, controller.text);
```

---

### Task 15: Refactor AssignmentScreen — Real Submission + AI Tutor

**Files:**
- Modify: `lib/screens/assignment_screen.dart`
- Create: `lib/screens/ai_tutor_screen.dart`

- [ ] **Step 1: Create `lib/screens/ai_tutor_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../services/grading_service.dart';

class AiTutorScreen extends StatefulWidget {
  final String courseContext;

  const AiTutorScreen({super.key, required this.courseContext});

  @override
  State<AiTutorScreen> createState() => _AiTutorScreenState();
}

class _AiTutorScreenState extends State<AiTutorScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Tutor'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.psychology, size: 64, color: Colors.blue[200]),
                          const SizedBox(height: 16),
                          Text(
                            'Ask me anything about this course!',
                            style: Theme.of(context).textTheme.titleLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'I can help explain concepts, guide you through problems, and answer questions.',
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isUser = message['role'] == 'user';
                      return _buildMessageBubble(context, message['content'] ?? '', isUser);
                    },
                  ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                  SizedBox(width: 8),
                  Text('Thinking...'),
                ],
              ),
            ),
          if (_error != null)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.red[50],
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red[700], size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_error!, style: TextStyle(color: Colors.red[700], fontSize: 12))),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () => setState(() => _error = null),
                  ),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha(77),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Ask a question...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    maxLines: 3,
                    minLines: 1,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _isLoading ? null : _sendMessage,
                  icon: const Icon(Icons.send),
                  color: Colors.blue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, String content, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue[100] : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: isUser
            ? Text(content)
            : MarkdownBody(data: content),
      ),
    );
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isLoading) return;

    _messageController.clear();
    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _isLoading = true;
      _error = null;
    });
    _scrollToBottom();

    try {
      final gradingService = Provider.of<GradingService>(context, listen: false);
      final response = await gradingService.chat(
        messages: _messages,
        courseContext: widget.courseContext,
      );
      setState(() {
        _messages.add({'role': 'assistant', 'content': response});
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}
```

- [ ] **Step 2: Refactor `assignment_screen.dart`**

Add imports:
```dart
import 'package:provider/provider.dart';
import '../services/grading_service.dart';
import '../models/grading_result.dart';
import '../widgets/ai_grading_widget.dart';
import 'ai_tutor_screen.dart';
```

Convert from `StatelessWidget` to `StatefulWidget`. Add state for submission text and grading result:

```dart
class AssignmentScreen extends StatefulWidget {
  final Assignment assignment;
  const AssignmentScreen({super.key, required this.assignment});

  @override
  State<AssignmentScreen> createState() => _AssignmentScreenState();
}

class _AssignmentScreenState extends State<AssignmentScreen> {
  final TextEditingController _submissionController = TextEditingController();
  GradingResult? _gradingResult;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _submissionController.dispose();
    super.dispose();
  }
  // ... (rest of build method uses widget.assignment instead of assignment)
}
```

Replace `_buildSubmissionCard` to include a real text input and grading display:

```dart
Widget _buildSubmissionCard(BuildContext context) {
  return Card(
    elevation: 2,
    color: Colors.blue.withAlpha(13),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.upload, color: Colors.blue[700]),
              const SizedBox(width: 8),
              Text(
                'Submit Your Work',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _submissionController,
            maxLines: 10,
            decoration: const InputDecoration(
              hintText: 'Write your assignment submission here...',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting || _gradingResult != null
                      ? null
                      : () => _submitAssignment(context),
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Icon(_gradingResult != null ? Icons.check : Icons.upload_file),
                  label: Text(_isSubmitting
                      ? 'Grading...'
                      : _gradingResult != null
                          ? 'Submitted'
                          : 'Submit Assignment'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _gradingResult != null ? Colors.green : Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AiTutorScreen(
                      courseContext: '${widget.assignment.title}: ${widget.assignment.description}',
                    ),
                  ),
                ),
                icon: const Icon(Icons.psychology),
                label: const Text('AI Tutor'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          ),
          if (_gradingResult != null) ...[
            const SizedBox(height: 20),
            AIGradingWidget(gradingResult: _gradingResult!),
          ],
        ],
      ),
    ),
  );
}
```

Add `_submitAssignment` method:

```dart
Future<void> _submitAssignment(BuildContext context) async {
  final text = _submissionController.text.trim();
  if (text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please write your submission before submitting')),
    );
    return;
  }

  setState(() => _isSubmitting = true);

  try {
    final gradingService = Provider.of<GradingService>(context, listen: false);
    final result = await gradingService.gradeAssignment(widget.assignment, text);
    setState(() => _gradingResult = result);
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  } finally {
    if (mounted) setState(() => _isSubmitting = false);
  }
}
```

Remove `_showSubmissionDialog` and `_showHelpDialog` methods entirely.

---

### Task 16: Replace Default Test File

**Files:**
- Rewrite: `test/widget_test.dart`

- [ ] **Step 1: Rewrite `test/widget_test.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:university_ui/models/course.dart';
import 'package:university_ui/models/university.dart';
import 'package:university_ui/models/grading_result.dart';
import 'package:university_ui/utils/grade_utils.dart';
import 'package:university_ui/utils/json_utils.dart';

void main() {
  group('JSON Utils', () {
    test('extractString returns value for valid string field', () {
      final json = {'name': 'Test University'};
      expect(extractString(json, 'name'), 'Test University');
    });

    test('extractString throws FormatException for missing field', () {
      final json = <String, dynamic>{};
      expect(() => extractString(json, 'name'), throwsFormatException);
    });

    test('extractString returns fallback when field is null', () {
      final json = <String, dynamic>{'name': null};
      expect(extractString(json, 'name', fallback: 'default'), 'default');
    });

    test('extractInt returns value for valid int field', () {
      final json = {'credits': 3};
      expect(extractInt(json, 'credits'), 3);
    });

    test('extractStringList returns list for valid list field', () {
      final json = {'items': ['a', 'b', 'c']};
      expect(extractStringList(json, 'items'), ['a', 'b', 'c']);
    });
  });

  group('Course model', () {
    test('fromJson parses valid course data', () {
      final json = {
        'course_id': 'GD101',
        'title': 'Intro to Game Design',
        'credit_hours': 3,
        'description': 'A great course',
        'learning_objectives': ['Learn games'],
      };
      final course = Course.fromJson(json);
      expect(course.courseId, 'GD101');
      expect(course.title, 'Intro to Game Design');
      expect(course.creditHours, 3);
      expect(course.description, 'A great course');
      expect(course.learningObjectives, ['Learn games']);
    });

    test('fromJson handles missing optional fields', () {
      final json = {
        'course_id': 'GD101',
        'title': 'Intro to Game Design',
        'credit_hours': 3,
      };
      final course = Course.fromJson(json);
      expect(course.description, isNull);
      expect(course.learningObjectives, isNull);
      expect(course.coveredMaterials, isNull);
    });

    test('fromJson throws on missing required field', () {
      final json = {'title': 'Test', 'credit_hours': 3};
      expect(() => Course.fromJson(json), throwsFormatException);
    });
  });

  group('University model', () {
    test('fromJson parses valid university data', () {
      final json = {
        'name': 'Test University',
        'mission': 'To teach',
        'accreditation': 'Accredited',
        'established': 2024,
        'learning_model': 'Online',
        'assessment_method': 'AI',
      };
      final uni = University.fromJson(json);
      expect(uni.name, 'Test University');
      expect(uni.established, 2024);
    });
  });

  group('GradingResult', () {
    test('percentage calculation is correct', () {
      final result = GradingResult(
        score: 85,
        maxScore: 100,
        feedback: 'Good',
        rubricBreakdown: [],
      );
      expect(result.percentage, 85.0);
      expect(result.letterGrade, 'B');
    });

    test('handles zero maxScore without division error', () {
      final result = GradingResult(
        score: 0,
        maxScore: 0,
        feedback: 'N/A',
        rubricBreakdown: [],
      );
      expect(result.percentage, 0.0);
      expect(result.letterGrade, 'F');
    });

    test('letterGrade boundaries are correct', () {
      expect(GradingResult(score: 97, maxScore: 100, feedback: '', rubricBreakdown: []).letterGrade, 'A+');
      expect(GradingResult(score: 93, maxScore: 100, feedback: '', rubricBreakdown: []).letterGrade, 'A');
      expect(GradingResult(score: 90, maxScore: 100, feedback: '', rubricBreakdown: []).letterGrade, 'A-');
      expect(GradingResult(score: 59, maxScore: 100, feedback: '', rubricBreakdown: []).letterGrade, 'F');
    });
  });

  group('Grade Utils', () {
    test('getGradeColor returns correct colors', () {
      expect(getGradeColor(95), Colors.green);
      expect(getGradeColor(85), Colors.blue);
      expect(getGradeColor(75), Colors.orange);
      expect(getGradeColor(65), Colors.deepOrange);
      expect(getGradeColor(50), Colors.red);
    });

    test('getLetterGrade returns correct grades', () {
      expect(getLetterGrade(97), 'A+');
      expect(getLetterGrade(85), 'B');
      expect(getLetterGrade(73), 'C');
      expect(getLetterGrade(55), 'F');
    });
  });
}
```

- [ ] **Step 2: Run tests**

```bash
cd university_ui && flutter test
```

Expected: All tests pass.

---

### Task 17: Verify Full Build

- [ ] **Step 1: Run flutter pub get**

```bash
cd university_ui && flutter pub get
```

- [ ] **Step 2: Run flutter analyze**

```bash
cd university_ui && flutter analyze
```

Expected: No errors. Warnings about deprecated `withOpacity` are acceptable (out of scope for this plan).

- [ ] **Step 3: Run flutter test**

```bash
cd university_ui && flutter test
```

Expected: All tests pass.

- [ ] **Step 4: Smoke test the app** (if device available)

```bash
cd university_ui && flutter run
```

Verify: Home screen loads, degree programs display, GD401 class detail is accessible, quiz grading calls Ollama (requires Ollama running).
