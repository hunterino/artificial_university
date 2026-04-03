import 'course.dart';
import '../utils/json_utils.dart';

class DegreeProgram {
  final String degreeId;
  final String title;
  final String duration;
  final int totalCredits;
  final String description;
  final int majorCredits;
  final List<Course> requiredCourses;

  DegreeProgram({
    required this.degreeId,
    required this.title,
    required this.duration,
    required this.totalCredits,
    required this.description,
    required this.majorCredits,
    required this.requiredCourses,
  });

  factory DegreeProgram.fromJson(Map<String, dynamic> json) {
    return DegreeProgram(
      degreeId: extractString(json, 'degree_id'),
      title: extractString(json, 'title'),
      duration: extractString(json, 'duration'),
      totalCredits: extractInt(json, 'total_credits'),
      description: extractString(json, 'description'),
      majorCredits: extractInt(json, 'major_credits'),
      requiredCourses: extractList(json, 'required_courses')
          .map((course) => Course.fromJson(course as Map<String, dynamic>))
          .toList(),
    );
  }
}
