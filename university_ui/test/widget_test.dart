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

    test('extractInt throws FormatException for wrong type', () {
      final json = {'credits': 'three'};
      expect(() => extractInt(json, 'credits'), throwsFormatException);
    });

    test('extractStringList returns list for valid list field', () {
      final json = {'items': ['a', 'b', 'c']};
      expect(extractStringList(json, 'items'), ['a', 'b', 'c']);
    });

    test('extractStringOrNull returns null for missing field', () {
      final json = <String, dynamic>{};
      expect(extractStringOrNull(json, 'name'), isNull);
    });

    test('extractStringOrNull returns value for present field', () {
      final json = {'name': 'Test'};
      expect(extractStringOrNull(json, 'name'), 'Test');
    });

    test('extractDouble handles int to double conversion', () {
      final json = {'value': 42};
      expect(extractDouble(json, 'value'), 42.0);
    });

    test('extractMap returns map for valid map field', () {
      final json = {'nested': {'key': 'val'}};
      final result = extractMap(json, 'nested');
      expect(result['key'], 'val');
    });

    test('extractMap throws for non-map field', () {
      final json = {'nested': 'not a map'};
      expect(() => extractMap(json, 'nested'), throwsFormatException);
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
      final json = <String, dynamic>{'title': 'Test', 'credit_hours': 3};
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

    test('fromJson throws on missing field', () {
      final json = <String, dynamic>{'name': 'Test'};
      expect(() => University.fromJson(json), throwsFormatException);
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
      expect(GradingResult(score: 87, maxScore: 100, feedback: '', rubricBreakdown: []).letterGrade, 'B+');
      expect(GradingResult(score: 73, maxScore: 100, feedback: '', rubricBreakdown: []).letterGrade, 'C');
      expect(GradingResult(score: 59, maxScore: 100, feedback: '', rubricBreakdown: []).letterGrade, 'F');
    });

    test('fromLlmResponse parses valid response', () {
      final json = {
        'rubric_scores': [
          {'criterion': 'Accuracy', 'score': 8, 'max_score': 10, 'feedback': 'Good work'},
        ],
        'total_score': 8,
        'overall_feedback': 'Well done',
      };
      final result = GradingResult.fromLlmResponse(json, 10);
      expect(result.score, 8);
      expect(result.maxScore, 10);
      expect(result.feedback, 'Well done');
      expect(result.rubricBreakdown.length, 1);
      expect(result.rubricBreakdown[0].criterion, 'Accuracy');
    });

    test('fromLlmResponse handles missing fields gracefully', () {
      final json = <String, dynamic>{};
      final result = GradingResult.fromLlmResponse(json, 100);
      expect(result.score, 0);
      expect(result.maxScore, 100);
      expect(result.feedback, 'No feedback available.');
      expect(result.rubricBreakdown, isEmpty);
    });

    test('RubricScore percentage calculation', () {
      final rubric = RubricScore(
        criterion: 'Test',
        score: 7,
        maxScore: 10,
        feedback: 'OK',
      );
      expect(rubric.percentage, 70.0);
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
      expect(getLetterGrade(100), 'A+');
      expect(getLetterGrade(97), 'A+');
      expect(getLetterGrade(96), 'A');
      expect(getLetterGrade(93), 'A');
      expect(getLetterGrade(85), 'B');
      expect(getLetterGrade(73), 'C');
      expect(getLetterGrade(55), 'F');
    });
  });
}
