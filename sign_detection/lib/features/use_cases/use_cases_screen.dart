import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/widgets/cards.dart';

class UseCasesScreen extends StatelessWidget {
  const UseCasesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final useCases = [
      _UseCase(
        icon: Icons.school,
        title: 'Education',
        description: 'Online classes and virtual classrooms',
        color: const Color(0xFF3B82F6),
      ),
      _UseCase(
        icon: Icons.business,
        title: 'Corporate Meetings',
        description: 'Virtual meetings and interviews',
        color: const Color(0xFF6366F1),
      ),
      _UseCase(
        icon: Icons.local_hospital,
        title: 'Healthcare',
        description: 'Telemedicine and doctor-patient communication',
        color: const Color(0xFFEF4444),
      ),
      _UseCase(
        icon: Icons.public,
        title: 'Government Services',
        description: 'Accessible public services',
        color: const Color(0xFFF59E0B),
      ),
      _UseCase(
        icon: Icons.support_agent,
        title: 'Customer Support',
        description: 'Accessible communication with businesses',
        color: const Color(0xFF22C55E),
      ),
      _UseCase(
        icon: Icons.location_city,
        title: 'Public Communication',
        description: 'Banks, railway stations, airports',
        color: const Color(0xFF8B5CF6),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Where ISL Translation Helps'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: List.generate(
              useCases.length,
              (index) {
                final useCase = useCases[index];
                return FadeInUp(
                  delay: Duration(milliseconds: index * 50),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: useCase.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              useCase.icon,
                              color: useCase.color,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  useCase.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  useCase.description,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _UseCase {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  _UseCase({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
