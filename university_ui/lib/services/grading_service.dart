import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/grading_result.dart';
import '../models/class_detail.dart';
import 'llm_service.dart';

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
      return GradingResult(
        score: 0,
        maxScore: maxScore,
        feedback: 'AI provided feedback but structured grading failed. Raw response:\n\n$responseText',
        rubricBreakdown: [],
      );
    }
  }
}
