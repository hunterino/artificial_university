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
  final Map<String, List<Course>> _coursesBySubject = {};
  final Map<String, ClassDetail> _classDetails = {};

  University? get university => _university;
  GeneralEducationRequirement? get generalEducation => _generalEducation;
  List<DegreeProgram> get degreePrograms => _degreePrograms;
  Map<String, List<Course>> get coursesBySubject => _coursesBySubject;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  final Map<String, String> _classLoadErrors = {};
  Map<String, String> get classLoadErrors => Map.unmodifiable(_classLoadErrors);

  Future<void> loadUniversityData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load university and degree data
      final universityData = await rootBundle.loadString('assets/degrees.json');
      final universityJson = json.decode(universityData) as Map<String, dynamic>;

      _university = University.fromJson(universityJson['university'] as Map<String, dynamic>);
      _generalEducation = GeneralEducationRequirement.fromJson(universityJson['general_education_requirements'] as Map<String, dynamic>);
      _degreePrograms = (universityJson['degree_programs'] as List)
          .map((degree) => DegreeProgram.fromJson(degree as Map<String, dynamic>))
          .toList();

      // Load course descriptions
      final coursesData = await rootBundle.loadString('assets/data/courses.json');
      final coursesJson = json.decode(coursesData) as Map<String, dynamic>;

      (coursesJson['courses'] as Map<String, dynamic>).forEach((subject, courses) {
        _coursesBySubject[subject] = (courses as List)
            .map((course) => Course.fromJson(course as Map<String, dynamic>))
            .toList();
      });

      // Load all available class details
      await _loadAllClassDetails();

    } catch (e) {
      _error = 'Failed to load university data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadAllClassDetails() async {
    // Collect all unique course IDs from degree programs and gen ed
    final courseIds = <String>{};
    for (final degree in _degreePrograms) {
      for (final course in degree.requiredCourses) {
        courseIds.add(course.courseId);
      }
    }
    if (_generalEducation != null) {
      for (final category in _generalEducation!.categories) {
        for (final course in category.courses) {
          courseIds.add(course.courseId);
        }
      }
    }

    // Try loading class details for each known course ID
    for (final courseId in courseIds) {
      await _loadClassDetail(courseId);
    }
  }

  Future<void> _loadClassDetail(String classId) async {
    try {
      final classData = await rootBundle.loadString('assets/courses/$classId.json');
      final classJson = json.decode(classData);
      _classDetails[classId] = ClassDetail.fromJson(classJson);
    } catch (e) {
      _classLoadErrors[classId] = 'Failed to load class detail for $classId: $e';
    }
  }

  ClassDetail? getClassDetail(String classId) {
    return _classDetails[classId];
  }

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
