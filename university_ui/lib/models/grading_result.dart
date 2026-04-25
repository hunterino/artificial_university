import 'package:flutter/material.dart';
import '../utils/grade_utils.dart';

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
