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
