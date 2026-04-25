import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// flutter_staggered_animations removed — incompatible with current Flutter SDK
import '../services/data_service.dart';
import '../widgets/degree_card.dart';
import 'degree_detail_screen.dart';

class DegreesScreen extends StatelessWidget {
  const DegreesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Degree Programs'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<DataService>(
        builder: (context, dataService, child) {
          if (dataService.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose Your Path',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Explore our AI-powered degree programs designed for the digital age',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: dataService.degreePrograms.length,
                  itemBuilder: (context, index) {
                    final degree = dataService.degreePrograms[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: DegreeCard(
                        degree: degree,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DegreeDetailScreen(degree: degree),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
