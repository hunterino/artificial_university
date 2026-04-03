import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// flutter_staggered_animations removed — incompatible with current Flutter SDK
import '../services/data_service.dart';
import '../widgets/university_header.dart';
import 'degrees_screen.dart';
import 'take_class_screen.dart';
import '../models/university.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
  Future.microtask(() =>
      Provider.of<DataService>(context, listen: false).loadUniversityData()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<DataService>(
        builder: (context, dataService, child) {
          if (dataService.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading University Data...'),
                ],
              ),
            );
          }

          if (dataService.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to Load',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dataService.error!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => dataService.loadUniversityData(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final university = dataService.university;
          if (university == null) {
            return const Center(
              child: Text('Failed to load university data'),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: UniversityHeader(university: university),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildWelcomeSection(university),
                    const SizedBox(height: 24),
                    _buildFeaturesSection(),
                    const SizedBox(height: 24),
                    _buildQuickActions(context),
                    const SizedBox(height: 24),
                    _buildStatsSection(dataService),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWelcomeSection(University university) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to ${university.name}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              university.mission,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.verified, color: Colors.green[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    university.accreditation,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.green[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI-Powered Learning Experience',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            _buildFeatureCard(
              Icons.psychology,
              'AI Assessment',
              'Real-time grading with detailed feedback',
              Colors.blue,
            ),
            _buildFeatureCard(
              Icons.auto_graph,
              'Adaptive Learning',
              'Personalized learning pathways',
              Colors.green,
            ),
            _buildFeatureCard(
              Icons.analytics,
              'Progress Analytics',
              'Track your learning journey',
              Colors.orange,
            ),
            _buildFeatureCard(
              Icons.devices,
              '100% Online',
              'Learn anywhere, anytime',
              Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String description, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Column(
          children: [
            _buildActionButton(
              context,
              Icons.school,
              'Browse Degree Programs',
              'Explore our comprehensive degree offerings',
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DegreesScreen()),
              ),
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              context,
              Icons.play_circle_fill,
              'Take a Demo Class',
              'Experience AI-powered learning',
              () => _showDemoClassDialog(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Icon(icon, color: Theme.of(context).primaryColor),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  Widget _buildStatsSection(DataService dataService) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'University Statistics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  '${dataService.degreePrograms.length}',
                  'Degree Programs',
                ),
                _buildStatItem(
                  '${dataService.coursesBySubject.values.fold<int>(0, (sum, courses) => sum + courses.length)}',
                  'Total Courses',
                ),
                _buildStatItem(
                  '100%',
                  'Online Learning',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String number, String label) {
    return Column(
      children: [
        Text(
          number,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _showDemoClassDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Demo Class Available'),
        content: const Text(
          'Try our 3D Game Development class with AI-powered assessment!\n\n'
          'This demo showcases our innovative learning platform with real-time AI grading and personalized feedback.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Maybe Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TakeClassScreen(courseId: 'GD401')),
              );
            },
            child: const Text('Try Demo'),
          ),
        ],
      ),
    );
  }
}
