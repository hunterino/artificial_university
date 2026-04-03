# Artificial University — Technical Fixes & Curriculum Expansion

**Date:** 2026-04-03
**Status:** Draft
**Scope:** Phase 1 (code fixes) + Phase 2 (BAGD001 curriculum content)

---

## Phase 1: Technical Fixes

### 1.1 Remove Broken `extractor` Dependency

Remove `extractor: path: ../../extractor` from `pubspec.yaml`. The package does not exist and prevents `flutter pub get`. The utility scripts that import it (`lib/extract.dart`, `lib/genSyllabus.dart`, `lib/one_classes.dart`) should be moved to a `tools/` directory outside `lib/` since they are not part of the app runtime.

### 1.2 LLM Service Interface

Create an abstract `LlmService` interface with concrete implementations, injected via Provider.

**Interface:**

```dart
abstract class LlmService {
  Future<GradingResult> gradeQuizAnswer({
    required String question,
    required String expectedAnswer,
    required String studentAnswer,
    required List<Map<String, dynamic>> rubric,
    required int maxPoints,
  });

  Future<GradingResult> gradeAssignment({
    required String title,
    required String description,
    required List<String> objectives,
    required List<String> deliverables,
    required String studentSubmission,
    required int maxPoints,
  });

  Future<String> chat({
    required List<Map<String, String>> messages,
    required String courseContext,
  });
}
```

**`GradingResult`** replaces the current `AIGradingResult` and lives in its own file (shared between service and UI):

```dart
class GradingResult {
  final int score;
  final int maxScore;
  final String feedback;
  final List<RubricScore> rubricBreakdown;
  // letterGrade and percentage computed here (single source of truth)
}
```

**Implementations:**

- `OllamaLlmService` — connects to local Ollama at `http://localhost:11434/api/chat`. Default model: `sam860/granite-4.0:7b`. Uses `http` package for requests.
- Future implementations: `ClaudeLlmService`, `OpenAiLlmService`, etc.

**Configuration:**

```dart
class LlmConfig {
  final LlmProvider provider; // enum: ollama, claude, openai
  final String model;
  final String baseUrl;
  final String? apiKey; // only needed for cloud providers

  // Factory constructors for common configs
  factory LlmConfig.ollama({String model = 'sam860/granite-4.0:7b'})
  factory LlmConfig.claude({required String apiKey})
}
```

Provider registration in `main.dart`:

```dart
final llmConfig = LlmConfig.ollama();
// ...
ChangeNotifierProvider(create: (_) => GradingService(llmService: OllamaLlmService(config: llmConfig))),
```

Switching LLMs means changing one line (the config factory).

**Prompt engineering** lives in `GradingService` (the existing `AIService` renamed), not in the LLM implementations. The LLM implementations only handle transport: send prompt, return response text. `GradingService` constructs prompts and parses structured responses.

### 1.3 Refactor AIService → GradingService

- Rename `AIService` to `GradingService`
- Remove all simulation/stub code (`_simulateAIGrading`, `_evaluateAnswerComponent`, `_checkForKeywords`, etc.)
- Remove hardcoded `_apiKey` and `_apiUrl` constants
- Remove unused `dart:math` import and `Random` variable
- `GradingService` takes an `LlmService` in its constructor
- `gradeQuizAnswer()` builds a grading prompt, sends to `LlmService`, parses the JSON response into `GradingResult`
- Add `chat()` method that delegates to `LlmService.chat()` for AI Tutor
- Add `gradeAssignment()` method for assignment submissions

### 1.4 Fix DataService Error Handling

Add error state that the UI can read:

```dart
String? _error;
String? get error => _error;
```

In `loadUniversityData()`:
- Set `_error = null` at start
- On catch: set `_error = 'Failed to load university data: $e'`
- `notifyListeners()` so UI rebuilds with error state

In `_loadClassDetail()`:
- Surface errors to a list or log that the UI can query
- Don't silently swallow

Update `HomeScreen` to check `dataService.error` and display it.

### 1.5 Dynamic Class Detail Loading

Replace hardcoded `_loadClassDetail('GD401')` with dynamic discovery:

```dart
// Load all available class detail files
final manifestString = await rootBundle.loadString('AssetManifest.json');
final manifest = json.decode(manifestString) as Map<String, dynamic>;
final classFiles = manifest.keys
    .where((key) => key.startsWith('assets/courses/') && key.endsWith('.json') && !key.contains('schema'))
    .toList();

for (final file in classFiles) {
  final classId = file.split('/').last.replaceAll('.json', '');
  await _loadClassDetail(classId);
}
```

This way, as new course JSON files are added (Phase 2), they are automatically discovered and loaded.

### 1.6 Fix No-Op Handlers

**Assignment submission (`assignment_screen.dart`):**
- Replace the demo dialog with a real submission flow
- Add a `TextEditingController` for student work input (text area)
- On submit: call `GradingService.gradeAssignment()` with the student's text
- Display the `GradingResult` using the existing `AIGradingWidget`

**AI Tutor (`assignment_screen.dart`):**
- Replace the demo snackbar with navigation to a simple chat screen
- New `AiTutorScreen` that uses `GradingService.chat()` with course context
- Simple message list UI with text input

### 1.7 Replace Default Test File

Delete the counter test. Replace with:

1. **Model tests** — verify `fromJson` parsing with sample data
2. **DataService test** — mock `rootBundle`, verify data loads and error state works
3. **Home screen widget test** — pump with provider overrides, verify loading → loaded states
4. **Quiz screen widget test** — verify question display, answer submission flow

### 1.8 Fix Wrong Icons

- `course_detail_screen.dart:165` — change `Icons.phone` to `Icons.flag` (Learning Objectives)
- `home_screen.dart:169` — change `Icons.mic` to `Icons.auto_graph` (Adaptive Learning)

### 1.9 Deduplicate Shared Logic

Create `lib/utils/` with:

- `grade_utils.dart` — shared `getGradeColor(double percentage)` and `getLetterGrade(double percentage)`. Remove duplicates from `quiz_screen.dart`, `ai_grading_widget.dart`.
- `degree_utils.dart` — shared `getDegreeIcon(String degreeId)` and `getDegreeColor(String degreeId)`. Remove duplicates from `degree_card.dart`, `degree_detail_screen.dart`.
- `course_utils.dart` — shared `getCourseIcon(String courseId)` and `getCourseColor(String courseId)`. Extracted from `course_card.dart`.

### 1.10 Remove Unused Dependencies

Remove from `pubspec.yaml`:
- `lottie` — never imported
- `shared_preferences` — never imported
- `args` — only used in utility scripts (moved to `tools/`)

Keep:
- `http` — now used by `OllamaLlmService`
- `flutter_markdown` — will be used in AI Tutor chat for rendering LLM responses

### 1.11 Safe JSON Parsing

Add a `lib/utils/json_utils.dart` with safe extraction helpers:

```dart
String extractString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is String) return value;
  throw FormatException('Expected String for "$key", got ${value.runtimeType}');
}

int extractInt(Map<String, dynamic> json, String key) { ... }
List<T> extractList<T>(Map<String, dynamic> json, String key) { ... }
```

Update all model `fromJson` methods to use these helpers instead of bare `json['field']` access.

### 1.12 Fix "Course Catalog" Duplicate Navigation

Either:
- Remove the "Course Catalog" quick action (since it duplicates "Browse Degree Programs"), or
- Create a distinct `CourseCatalogScreen` that lists all courses across all degrees, searchable/filterable

Decision: Remove it. YAGNI — the degree-based navigation already surfaces all courses. Can add a catalog later if needed.

### 1.13 Fix "Take a Demo Class" Navigation

Change the dialog's "Try Demo" button to navigate directly to `TakeClassScreen(courseId: 'GD401')` instead of `DegreesScreen`.

---

## Phase 2: BAGD001 Curriculum Content Generation

### 2.1 Scope

Generate complete content for all 24 remaining courses in the Game Design and Media degree (GD401 already exists). Plus update `assets/data/courses.json` with full descriptions for all 25 BAGD001 courses and the 3 supporting courses (ART201, CS115, COMM201).

### 2.2 Content Structure Per Course

Each course gets a JSON file at `assets/courses/{COURSE_ID}.json` following the GD401 template:

```json
{
  "course_info": {
    "course_id": "...",
    "title": "...",
    "credit_hours": N,
    "duration": "15 weeks",
    "meeting_schedule": "...",
    "prerequisites": ["..."]
  },
  "class_schedule": [
    // 15 weeks x 2-3 sessions = 30-45 sessions
    {
      "week_number": 1,
      "session_number": 1,
      "date": "2024-01-15",
      "topic": "...",
      "duration": "50 minutes",
      "learning_objectives": ["..."],
      "readings": ["..."],
      "lecture_notes": {
        "introduction": "...",
        "key_concepts": ["..."],
        "demonstration": "...",
        "setup_requirements": ["..."],
        "review": [{"key": "...", "value": "..."}]
      }
    }
  ],
  "assessments": {
    "quizzes": [
      {
        "quiz": 1,
        "week": 3,
        "topic": "...",
        "duration": "30 minutes",
        "questions": [
          {
            "question": "...",
            "type": "short_answer|essay|calculation|code",
            "points": N,
            "answer": "...",
            "rubric": [
              {"key": "...", "value": N}
            ]
          }
        ],
        "total_points": N
      }
    ],
    "major_assignments": [
      {
        "assignment": 1,
        "title": "...",
        "week_assigned": N,
        "week_due": N,
        "points": N,
        "description": "...",
        "objectives": ["..."],
        "deliverables": ["..."]
      }
    ]
  },
  "grading_breakdown": {
    "quizzes": {"percentage": 25, "description": "..."},
    "assignments": {"percentage": 35, "description": "..."},
    "participation": {"percentage": 15, "description": "..."},
    "final_project": {"percentage": 25, "description": "..."}
  },
  "course_policies": {
    "attendance": "...",
    "late_submissions": "...",
    "collaboration": "...",
    "academic_integrity": "...",
    "technology_requirements": "..."
  }
}
```

### 2.3 Content Quality Guidelines

- **Prerequisites** must form a coherent dependency chain (100-level has none, 200-level may require 100-level, etc.)
- **Quiz questions** must have real expected answers and meaningful rubrics (not just keyword lists)
- **Assignments** must have concrete deliverables appropriate to the course level
- **Lecture notes** should include domain-specific key concepts, not generic filler
- **Dates** follow a consistent academic calendar starting January 2024
- **Consistency**: courses within the degree should reference each other's concepts where appropriate

### 2.4 Course Generation Order

Follow the prerequisite chain — generate foundational courses first so later courses can reference them:

**Year 1 (100-level):**
1. GD101 — Introduction to Game Design
2. GD102 — Game Theory and Mechanics
3. GD103 — Digital Art Fundamentals
4. CS115 — Programming for Games
5. ART201 — Digital Design Principles
6. COMM201 — Media Studies

**Year 2 (200-level):**
7. GD201 — 2D Game Development
8. GD202 — 3D Modeling and Animation
9. GD203 — Interactive Storytelling

**Year 3 (300-level):**
10. GD301 — Game Programming
11. GD302 — Level Design
12. GD303 — Character Design and Development
13. GD304 — Game Audio and Sound Design

**Year 4 (400-level):**
14. GD401 — already exists
15. GD402 — Mobile Game Development
16. GD403 — Virtual Reality and Augmented Reality
17. GD404 — Game Testing and Quality Assurance
18. GD405 — Game Marketing and Publishing
19. GD406 — Multiplayer Game Design
20. GD407 — Indie Game Development
21. GD408 — Game Analytics and Monetization
22. GD409 — Serious Games and Gamification
23. GD410 — Game Industry Professional Practices
24. GD490 — Game Design Capstone Project
25. GD491 — Game Industry Internship

### 2.5 Update courses.json

After generating all class detail files, update `assets/data/courses.json` to include full descriptions (description, learning_objectives, covered_materials) for all 25+3 BAGD001 courses under a "Game Design and Media" subject key.

### 2.6 Update pubspec.yaml Assets

No change needed — `assets/courses/` is already declared as an asset directory, so new JSON files are automatically included.

---

## File Changes Summary

### New Files
- `lib/services/llm_service.dart` — abstract interface + LlmConfig + LlmProvider enum
- `lib/services/ollama_llm_service.dart` — Ollama implementation
- `lib/services/grading_service.dart` — refactored from ai_service.dart
- `lib/models/grading_result.dart` — shared grading result model
- `lib/utils/grade_utils.dart` — shared grade color/letter functions
- `lib/utils/degree_utils.dart` — shared degree icon/color functions
- `lib/utils/course_utils.dart` — shared course icon/color functions
- `lib/utils/json_utils.dart` — safe JSON parsing helpers
- `lib/screens/ai_tutor_screen.dart` — chat interface for AI tutoring
- `tools/extract.dart` — moved from lib/
- `tools/genSyllabus.dart` — moved from lib/
- `tools/one_classes.dart` — moved from lib/
- `assets/courses/*.json` — 24 new course detail files

### Modified Files
- `pubspec.yaml` — remove extractor, lottie, shared_preferences, args
- `lib/main.dart` — update provider registration (GradingService + LlmConfig)
- `lib/services/data_service.dart` — error state, dynamic class loading
- `lib/screens/home_screen.dart` — error display, fix icons, fix demo navigation, remove Course Catalog
- `lib/screens/course_detail_screen.dart` — fix phone icon
- `lib/screens/assignment_screen.dart` — real submission + AI tutor navigation
- `lib/screens/quiz_screen.dart` — use shared grade utils
- `lib/widgets/ai_grading_widget.dart` — use shared grade utils, update import
- `lib/widgets/degree_card.dart` — use shared degree utils
- `lib/screens/degree_detail_screen.dart` — use shared degree utils
- `lib/widgets/course_card.dart` — use shared course utils
- `lib/screens/take_class_screen.dart` — render all 5 policy fields
- All model files — use safe JSON parsing
- `assets/data/courses.json` — add BAGD001 course descriptions
- `test/widget_test.dart` — replace with real tests

### Deleted Files
- `lib/services/ai_service.dart` — replaced by grading_service.dart + llm_service.dart
- `lib/extract.dart`, `lib/genSyllabus.dart`, `lib/one_classes.dart` — moved to tools/

---

## Out of Scope

- Other degree programs (BSCS001, BSBA001, etc.) — future work
- User authentication / student accounts
- Progress persistence (can be added later with shared_preferences or a backend)
- Deployment / CI configuration
- React web app updates (university_ui/gen/u_react/)
- Gen UI iterations (u_ui, u_ui_v2, u_ui_v3)
