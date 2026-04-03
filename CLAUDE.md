# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Artificial University is an AI-powered educational platform simulating a virtual university experience. Contains two implementations:
- **Flutter app** (`university_ui/`) - Primary cross-platform application
- **React web app** (`university_ui/gen/u_react/`) - Alternative TypeScript/Vite web implementation
- Additional UI iteration experiments in `university_ui/gen/` (`u_ui`, `u_ui_v2`, `u_ui_v3`)

## Flutter Development (`university_ui/`)

### Commands

```bash
cd university_ui/

flutter pub get
flutter run
flutter analyze
flutter test
```

### Architecture

Provider-based state management (ChangeNotifier) with two services:
- `DataService` - Loads and manages university data (degrees, courses, class details)
- `AIService` - AI-powered grading (ready for Claude API integration)

**Navigation Flow:**
```
HomeScreen → DegreesScreen → DegreeDetailScreen → CourseDetailScreen → TakeClassScreen
                                                                      ├── QuizScreen
                                                                      └── AssignmentScreen
```

**Models:** `University`, `DegreeProgram` (`degree.dart`), `Course`, `ClassDetail`

**Widgets:** `AIGradingWidget`, `CourseCard`, `DegreeCard`, `UniversityHeader`

**Key Dependencies:** provider, google_fonts, flutter_markdown, lottie, flutter_staggered_animations, extractor (local path dependency at `../../extractor`)

**Asset Organization:**
```
assets/
├── data/
│   ├── university.json
│   ├── courses.json
│   └── classes/        # Class detail JSON files
├── courses/            # Individual course JSON (e.g., GD401.json)
├── images/
└── animations/
```

**Utility scripts** in `lib/`: `extract.dart`, `genSyllabus.dart`, `one_classes.dart` (data generation/extraction tools)

## React Development (`university_ui/gen/u_react/`)

### Commands

```bash
cd university_ui/gen/u_react/

npm install
npm run dev       # Vite dev server
npm run build     # tsc && vite build
npm run lint
npm run preview
```

### Architecture

React Router v6, TypeScript, Vite. Services: `dataLoader.ts` (static JSON loading), `claudeApi.ts` (Claude AI grading via `@anthropic-ai/sdk`). Requires `VITE_CLAUDE_API_KEY` environment variable for AI features.