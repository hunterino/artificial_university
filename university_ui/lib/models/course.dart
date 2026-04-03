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
      learningObjectives:
          extractStringListOrNull(json, 'learning_objectives'),
      coveredMaterials: extractStringListOrNull(json, 'covered_materials'),
    );
  }
}
