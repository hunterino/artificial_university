# Executive Summary: Artificial University

## Overview
Artificial University is an AI-powered educational platform that simulates a virtual university experience, allowing users to explore degree programs, take courses, complete quizzes and assignments, and receive AI-driven grading. The project contains both a primary Flutter cross-platform app and an alternative React/TypeScript web implementation.

## Technology Stack
- Flutter (Dart) with Provider state management (primary app)
- React, TypeScript, Vite (alternative web app)
- Claude API integration for AI-powered grading
- Google Fonts, Flutter Markdown, Lottie animations
- JSON-based curriculum data (university, courses, class details)

## Status
Development

## Key Features
- Browse degree programs and courses within a simulated university
- Take classes with structured syllabi and learning materials
- Complete quizzes and assignments with AI-powered grading
- Rich animations and modern UI with staggered animations
- Multiple UI iteration experiments (u_ui, u_ui_v2, u_ui_v3, u_react)
- Data generation and extraction tooling for curriculum content

## Architecture
Provider-based state management with DataService for curriculum data and AIService for grading, following a linear navigation flow from home through degrees, courses, and class activities. The React alternative uses React Router v6 with static JSON loading and direct Claude API integration.

## Target Users
Students or learners exploring an AI-driven educational experience; developers evaluating AI grading integration patterns.

## Dependencies & Infrastructure
- Local JSON assets for curriculum data (no external database)
- Claude API (Anthropic) for AI grading features
- Local path dependency on an `extractor` package
- VITE_CLAUDE_API_KEY environment variable for the React implementation
