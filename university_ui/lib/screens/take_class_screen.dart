import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// flutter_staggered_animations removed — incompatible with current Flutter SDK
import '../services/data_service.dart';
import '../models/class_detail.dart';
import 'quiz_screen.dart';
import 'assignment_screen.dart';

class TakeClassScreen extends StatefulWidget {
  final String courseId;

  const TakeClassScreen({super.key, required this.courseId});

  @override
  State<TakeClassScreen> createState() => _TakeClassScreenState();
}

class _TakeClassScreenState extends State<TakeClassScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataService>(
      builder: (context, dataService, child) {
        final classDetail = dataService.getClassDetail(widget.courseId);

        if (classDetail == null) {
          return Scaffold(
            appBar: AppBar(title: Text(widget.courseId)),
            body: const Center(
              child: Text('Class details not available'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(classDetail.courseInfo.title),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            bottom: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: Colors.white,
              tabs: const [
                Tab(icon: Icon(Icons.info), text: 'Overview'),
                Tab(icon: Icon(Icons.schedule), text: 'Schedule'),
                Tab(icon: Icon(Icons.quiz), text: 'Quizzes'),
                Tab(icon: Icon(Icons.assignment), text: 'Assignments'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(context, classDetail),
              _buildScheduleTab(context, classDetail),
              _buildQuizzesTab(context, classDetail),
              _buildAssignmentsTab(context, classDetail),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOverviewTab(BuildContext context, ClassDetail classDetail) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildCourseInfoCard(context, classDetail.courseInfo),
          const SizedBox(height: 16),
          _buildGradingBreakdownCard(context, classDetail.gradingBreakdown),
          const SizedBox(height: 16),
          _buildCoursePoliciesCard(context, classDetail.coursePolicies),
        ],
      ),
    );
  }

  Widget _buildScheduleTab(BuildContext context, ClassDetail classDetail) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: classDetail.classSchedule.length,
      itemBuilder: (context, index) {
        final session = classDetail.classSchedule[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildSessionCard(context, session),
        );
      },
    );
  }

  Widget _buildQuizzesTab(BuildContext context, ClassDetail classDetail) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: classDetail.assessments.quizzes.length,
      itemBuilder: (context, index) {
        final quiz = classDetail.assessments.quizzes[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildQuizCard(context, quiz),
        );
      },
    );
  }

  Widget _buildAssignmentsTab(BuildContext context, ClassDetail classDetail) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: classDetail.assessments.majorAssignments.length,
      itemBuilder: (context, index) {
        final assignment = classDetail.assessments.majorAssignments[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildAssignmentCard(context, assignment),
        );
      },
    );
  }

  Widget _buildCourseInfoCard(BuildContext context, CourseInfo courseInfo) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Course Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Course ID', courseInfo.courseId),
            _buildInfoRow('Credit Hours', '${courseInfo.creditHours}'),
            _buildInfoRow('Duration', courseInfo.duration),
            _buildInfoRow('Schedule', courseInfo.meetingSchedule),
            if (courseInfo.prerequisites.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Prerequisites:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...courseInfo.prerequisites.map((prereq) => Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 4),
                child: Text('• $prereq'),
              )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildGradingBreakdownCard(BuildContext context, GradingBreakdown grading) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Grading Breakdown',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...grading.components.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${entry.value.percentage}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key.replaceAll('_', ' ').toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          entry.value.description,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildCoursePoliciesCard(BuildContext context, CoursePolicies policies) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Course Policies',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildPolicySection('Attendance', policies.attendance),
            _buildPolicySection('Late Submissions', policies.lateSubmissions),
            _buildPolicySection('Academic Integrity', policies.academicIntegrity),
            _buildPolicySection('Collaboration', policies.collaboration),
            _buildPolicySection('Technology Requirements', policies.technologyRequirements),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicySection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(BuildContext context, ClassSession session) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Week ${session.weekNumber}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'Session ${session.sessionNumber}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              session.topic,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              session.lectureNotes.introduction,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizCard(BuildContext context, Quiz quiz) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Quiz ${quiz.quiz}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${quiz.totalPoints} pts',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              quiz.topic,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Duration: ${quiz.duration} • ${quiz.questions.length} questions',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => QuizScreen(quiz: quiz),
                ),
              ),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Take Quiz'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentCard(BuildContext context, Assignment assignment) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Assignment ${assignment.assignment}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${assignment.points} pts',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              assignment.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              assignment.description,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              'Due: Week ${assignment.weekDue}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.orange[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AssignmentScreen(assignment: assignment),
                ),
              ),
              icon: const Icon(Icons.assignment),
              label: const Text('View Assignment'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
