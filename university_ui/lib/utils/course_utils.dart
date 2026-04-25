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
