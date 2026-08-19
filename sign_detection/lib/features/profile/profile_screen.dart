import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/utils.dart';
import '../../data/mock/mock_data.dart';
import '../settings/settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mockData = MockDataRepository();
    final user = mockData.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.settings,
                        size: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Settings',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInUp(
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.6),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            user.name[0],
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium
                                ?.copyWith(
                                  color: Colors.white,
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.name,
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.role,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              FadeInUp(
                delay: const Duration(milliseconds: 100),
                child: SectionHeader(
                  title: 'Your ISL Progress',
                ),
              ),
              const SizedBox(height: 16),
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.2,
                  children: [
                    StatCard(
                      label: 'Signs Learned',
                      value: '${user.signsLearned}',
                      icon: Icons.touch_app,
                      accentColor: Theme.of(context).colorScheme.primary,
                    ),
                    StatCard(
                      label: 'Practice Sessions',
                      value: '${user.practiceSessions}',
                      icon: Icons.school,
                      accentColor: const Color(0xFF6366F1),
                    ),
                    StatCard(
                      label: 'Video Calls',
                      value: '${user.videoCalls}',
                      icon: Icons.videocam,
                      accentColor: const Color(0xFFF59E0B),
                    ),
                    StatCard(
                      label: 'Avg Accuracy',
                      value: '${user.averageAccuracy.toStringAsFixed(0)}%',
                      icon: Icons.trending_up,
                      accentColor: const Color(0xFF22C55E),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              FadeInUp(
                delay: const Duration(milliseconds: 300),
                child: SectionHeader(
                  title: 'Streaks & Goals',
                ),
              ),
              const SizedBox(height: 16),
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.local_fire_department,
                              color: Color(0xFFF59E0B),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Current Streak',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${user.currentStreak} days',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: user.currentStreak / 30,
                          minHeight: 6,
                          backgroundColor: Colors.grey.withValues(alpha: 0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFFF59E0B),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${user.currentStreak} / 30 days to master level',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FadeInUp(
                delay: const Duration(milliseconds: 500),
                child: Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FadeInUp(
                delay: const Duration(milliseconds: 550),
                child: Row(
                  children: [
                    Expanded(
                      child: GlassCard(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('📊 Opening achievements...'),
                              duration: Duration(milliseconds: 1200),
                            ),
                          );
                        },
                        padding: const EdgeInsets.all(12),
                        child: Center(
                          child: Column(
                            children: [
                              const Icon(Icons.emoji_events, size: 28, color: Color(0xFFF59E0B)),
                              const SizedBox(height: 8),
                              Text(
                                'Achievements',
                                style: Theme.of(context).textTheme.labelSmall,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GlassCard(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('🎯 Opening goals...'),
                              duration: Duration(milliseconds: 1200),
                            ),
                          );
                        },
                        padding: const EdgeInsets.all(12),
                        child: Center(
                          child: Column(
                            children: [
                              const Icon(Icons.track_changes, size: 28, color: Color(0xFF6366F1)),
                              const SizedBox(height: 8),
                              Text(
                                'Goals',
                                style: Theme.of(context).textTheme.labelSmall,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GlassCard(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('👥 Opening leaderboard...'),
                              duration: Duration(milliseconds: 1200),
                            ),
                          );
                        },
                        padding: const EdgeInsets.all(12),
                        child: Center(
                          child: Column(
                            children: [
                              const Icon(Icons.trending_up, size: 28, color: Color(0xFF22C55E)),
                              const SizedBox(height: 8),
                              Text(
                                'Leaderboard',
                                style: Theme.of(context).textTheme.labelSmall,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
