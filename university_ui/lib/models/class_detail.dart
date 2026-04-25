import '../utils/json_utils.dart';

class ClassDetail {
  final CourseInfo courseInfo;
  final List<ClassSession> classSchedule;
  final Assessments assessments;
  final GradingBreakdown gradingBreakdown;
  final CoursePolicies coursePolicies;

  ClassDetail({
    required this.courseInfo,
    required this.classSchedule,
    required this.assessments,
    required this.gradingBreakdown,
    required this.coursePolicies,
  });

  factory ClassDetail.fromJson(Map<String, dynamic> json) {
    return ClassDetail(
      courseInfo: CourseInfo.fromJson(extractMap(json, 'course_info')),
      classSchedule: extractList(json, 'class_schedule')
          .map((session) =>
              ClassSession.fromJson(session as Map<String, dynamic>))
          .toList(),
      assessments: Assessments.fromJson(extractMap(json, 'assessments')),
      gradingBreakdown:
          GradingBreakdown.fromJson(extractMap(json, 'grading_breakdown')),
      coursePolicies:
          CoursePolicies.fromJson(extractMap(json, 'course_policies')),
    );
  }
}

class CourseInfo {
  final String courseId;
  final String title;
  final int creditHours;
  final String duration;
  final String meetingSchedule;
  final List<String> prerequisites;

  CourseInfo({
    required this.courseId,
    required this.title,
    required this.creditHours,
    required this.duration,
    required this.meetingSchedule,
    required this.prerequisites,
  });

  factory CourseInfo.fromJson(Map<String, dynamic> json) {
    return CourseInfo(
      courseId: extractString(json, 'course_id'),
      title: extractString(json, 'title'),
      creditHours: extractInt(json, 'credit_hours'),
      duration: extractString(json, 'duration'),
      meetingSchedule: extractString(json, 'meeting_schedule'),
      prerequisites: extractStringList(json, 'prerequisites'),
    );
  }
}

class ClassSession {
  final int weekNumber;
  final int sessionNumber;
  final String topic;
  final String duration;
  final List<String> learningObjectives;
  final List<String> readings;
  final LectureNotes lectureNotes;

  ClassSession({
    required this.weekNumber,
    required this.sessionNumber,
    required this.topic,
    required this.duration,
    required this.learningObjectives,
    required this.readings,
    required this.lectureNotes,
  });

  factory ClassSession.fromJson(Map<String, dynamic> json) {
    return ClassSession(
      weekNumber: extractInt(json, 'week_number'),
      sessionNumber: extractInt(json, 'session_number'),
      topic: extractString(json, 'topic'),
      duration: extractString(json, 'duration'),
      learningObjectives: extractStringList(json, 'learning_objectives'),
      readings: extractStringList(json, 'readings'),
      lectureNotes:
          LectureNotes.fromJson(extractMap(json, 'lecture_notes')),
    );
  }
}

class LectureNotes {
  final String introduction;
  final List<String> keyConcepts;
  final String demonstration;
  final List<String> setupRequirements;
  final List<Map<String, String>> review;

  LectureNotes({
    required this.introduction,
    required this.keyConcepts,
    required this.demonstration,
    required this.setupRequirements,
    required this.review,
  });

  factory LectureNotes.fromJson(Map<String, dynamic> json) {
    return LectureNotes(
      introduction: extractString(json, 'introduction'),
      keyConcepts: extractStringList(json, 'key_concepts'),
      demonstration: extractString(json, 'demonstration'),
      setupRequirements: extractStringList(json, 'setup_requirements'),
      review: extractList(json, 'review')
          .map((item) => Map<String, String>.from(item as Map))
          .toList(),
    );
  }
}

class Assessments {
  final List<Quiz> quizzes;
  final List<Assignment> majorAssignments;

  Assessments({
    required this.quizzes,
    required this.majorAssignments,
  });

  factory Assessments.fromJson(Map<String, dynamic> json) {
    return Assessments(
      quizzes: extractList(json, 'quizzes')
          .map((quiz) => Quiz.fromJson(quiz as Map<String, dynamic>))
          .toList(),
      majorAssignments: (json['major_assignments'] as List?)
          ?.map((a) => Assignment.fromJson(a as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

class Quiz {
  final int quiz;
  final int week;
  final String topic;
  final String duration;
  final List<QuizQuestion> questions;
  final int totalPoints;

  Quiz({
    required this.quiz,
    required this.week,
    required this.topic,
    required this.duration,
    required this.questions,
    required this.totalPoints,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      quiz: extractInt(json, 'quiz'),
      week: extractInt(json, 'week'),
      topic: extractString(json, 'topic'),
      duration: extractString(json, 'duration'),
      questions: extractList(json, 'questions')
          .map((q) => QuizQuestion.fromJson(q as Map<String, dynamic>))
          .toList(),
      totalPoints: extractInt(json, 'total_points'),
    );
  }
}

class QuizQuestion {
  final String question;
  final String type;
  final int points;
  final String answer;
  final List<Map<String, dynamic>> rubric;

  QuizQuestion({
    required this.question,
    required this.type,
    required this.points,
    required this.answer,
    required this.rubric,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      question: extractString(json, 'question'),
      type: extractString(json, 'type'),
      points: extractInt(json, 'points'),
      answer: extractString(json, 'answer'),
      rubric: extractList(json, 'rubric')
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList(),
    );
  }
}

class Assignment {
  final int assignment;
  final String title;
  final int weekAssigned;
  final int weekDue;
  final int points;
  final String description;
  final List<String> objectives;
  final List<String> deliverables;

  Assignment({
    required this.assignment,
    required this.title,
    required this.weekAssigned,
    required this.weekDue,
    required this.points,
    required this.description,
    required this.objectives,
    required this.deliverables,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      assignment: extractInt(json, 'assignment'),
      title: extractString(json, 'title'),
      weekAssigned: extractInt(json, 'week_assigned'),
      weekDue: extractInt(json, 'week_due'),
      points: extractInt(json, 'points'),
      description: extractString(json, 'description'),
      objectives: extractStringList(json, 'objectives'),
      deliverables: extractStringList(json, 'deliverables'),
    );
  }
}

class GradingBreakdown {
  final Map<String, GradingComponent> components;

  GradingBreakdown({required this.components});

  factory GradingBreakdown.fromJson(Map<String, dynamic> json) {
    Map<String, GradingComponent> components = {};
    json.forEach((key, value) {
      components[key] =
          GradingComponent.fromJson(value as Map<String, dynamic>);
    });
    return GradingBreakdown(components: components);
  }
}

class GradingComponent {
  final int percentage;
  final String description;

  GradingComponent({
    required this.percentage,
    required this.description,
  });

  factory GradingComponent.fromJson(Map<String, dynamic> json) {
    return GradingComponent(
      percentage: extractInt(json, 'percentage'),
      description: extractString(json, 'description'),
    );
  }
}

class CoursePolicies {
  final String attendance;
  final String lateSubmissions;
  final String collaboration;
  final String academicIntegrity;
  final String technologyRequirements;

  CoursePolicies({
    required this.attendance,
    required this.lateSubmissions,
    required this.collaboration,
    required this.academicIntegrity,
    required this.technologyRequirements,
  });

  factory CoursePolicies.fromJson(Map<String, dynamic> json) {
    return CoursePolicies(
      attendance: extractString(json, 'attendance'),
      lateSubmissions: extractString(json, 'late_submissions'),
      collaboration: extractString(json, 'collaboration'),
      academicIntegrity: extractString(json, 'academic_integrity'),
      technologyRequirements: extractString(json, 'technology_requirements'),
    );
  }
}
