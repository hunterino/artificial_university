import './course.dart';
import '../utils/json_utils.dart';

class University {
  final String name;
  final String mission;
  final String accreditation;
  final int established;
  final String learningModel;
  final String assessmentMethod;

  University({
    required this.name,
    required this.mission,
    required this.accreditation,
    required this.established,
    required this.learningModel,
    required this.assessmentMethod,
  });

  factory University.fromJson(Map<String, dynamic> json) {
    return University(
      name: extractString(json, 'name'),
      mission: extractString(json, 'mission'),
      accreditation: extractString(json, 'accreditation'),
      established: extractInt(json, 'established'),
      learningModel: extractString(json, 'learning_model'),
      assessmentMethod: extractString(json, 'assessment_method'),
    );
  }
}

class GeneralEducationRequirement {
  final int totalCredits;
  final List<CourseCategory> categories;

  GeneralEducationRequirement({
    required this.totalCredits,
    required this.categories,
  });

  factory GeneralEducationRequirement.fromJson(Map<String, dynamic> json) {
    return GeneralEducationRequirement(
      totalCredits: extractInt(json, 'total_credits'),
      categories: extractList(json, 'categories')
          .map((cat) => CourseCategory.fromJson(cat as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CourseCategory {
  final String category;
  final int credits;
  final List<Course> courses;

  CourseCategory({
    required this.category,
    required this.credits,
    required this.courses,
  });

  factory CourseCategory.fromJson(Map<String, dynamic> json) {
    return CourseCategory(
      category: extractString(json, 'category'),
      credits: extractInt(json, 'credits'),
      courses: extractList(json, 'courses')
          .map((course) => Course.fromJson(course as Map<String, dynamic>))
          .toList(),
    );
  }
}
