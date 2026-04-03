import 'package:flutter/material.dart';
// flutter_staggered_animations removed — incompatible with current Flutter SDK
import '../models/degree.dart';
import '../utils/degree_utils.dart';
import '../widgets/course_card.dart';
import 'course_detail_screen.dart';

class DegreeDetailScreen extends StatelessWidget {
  final DegreeProgram degree;

  const DegreeDetailScreen({super.key, required this.degree});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                degree.title.replaceAll('Bachelor of Science in ', 'BS ').replaceAll('Bachelor of Arts in ', 'BA '),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 60),
                      Icon(
                        getDegreeIcon(degree.degreeId),
                        size: 80,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${degree.totalCredits} Credits • ${degree.duration}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildDescriptionSection(context),
                const SizedBox(height: 24),
                _buildRequirementsSection(context),
                const SizedBox(height: 24),
                _buildCoursesSection(context),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(BuildContext context) {
    return Column(
      children: [
        Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Program Overview',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  degree.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRequirementsSection(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Degree Requirements',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildRequirementItem(
                    context,
                    'Total Credits',
                    '${degree.totalCredits}',
                    Icons.school,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildRequirementItem(
                    context,
                    'Major Credits',
                    '${degree.majorCredits}',
                    Icons.bookmark,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildRequirementItem(
                    context,
                    'Duration',
                    degree.duration,
                    Icons.schedule,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirementItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Required Courses (${degree.requiredCourses.length})',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: degree.requiredCourses.length,
          itemBuilder: (context, index) {
            final course = degree.requiredCourses[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: CourseCard(
                course: course,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CourseDetailScreen(course: course),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

}
