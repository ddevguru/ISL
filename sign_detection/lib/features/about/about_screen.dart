import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/widgets/cards.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About ISL Translate'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInUp(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
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
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '🤟',
                        style:
                            Theme.of(context).textTheme.displayLarge?.copyWith(
                                  fontSize: 64,
                                ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'ISL Translate',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              color: Colors.white,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Real-Time Indian Sign Language Translation',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white70,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              FadeInUp(
                delay: const Duration(milliseconds: 100),
                child: Text(
                  'Project Overview',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              const SizedBox(height: 12),
              FadeInUp(
                delay: const Duration(milliseconds: 150),
                child: Text(
                  'This project aims to provide an AI-based real-time Indian Sign Language (ISL) translation solution for digital communication and video calls.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.6,
                      ),
                ),
              ),
              const SizedBox(height: 24),
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: Text(
                  'Key Features',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              const SizedBox(height: 12),
              FadeInUp(
                delay: const Duration(milliseconds: 250),
                child: Column(
                  children: [
                    _FeatureItem(
                      title: 'Real-Time Translation',
                      description: 'Instant ISL to text conversion',
                      icon: Icons.speed,
                    ),
                    const SizedBox(height: 12),
                    _FeatureItem(
                      title: 'Hand Gesture Recognition',
                      description: 'AI-powered gesture detection',
                      icon: Icons.touch_app,
                    ),
                    const SizedBox(height: 12),
                    _FeatureItem(
                      title: 'Text-to-Speech',
                      description: 'Automatic voice output',
                      icon: Icons.volume_up,
                    ),
                    const SizedBox(height: 12),
                    _FeatureItem(
                      title: 'Video Call Integration',
                      description: 'Translation during calls',
                      icon: Icons.videocam,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              FadeInUp(
                delay: const Duration(milliseconds: 300),
                child: Text(
                  'Technology Stack',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              const SizedBox(height: 12),
              FadeInUp(
                delay: const Duration(milliseconds: 350),
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _TechBadge(label: 'Flutter'),
                      _TechBadge(label: 'MediaPipe'),
                      _TechBadge(label: 'OpenCV'),
                      _TechBadge(label: 'TensorFlow'),
                      _TechBadge(label: 'PyTorch'),
                      _TechBadge(label: 'NLP'),
                      _TechBadge(label: 'Text-to-Speech'),
                      _TechBadge(label: 'WebRTC'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: Text(
                  'Target Applications',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              const SizedBox(height: 12),
              FadeInUp(
                delay: const Duration(milliseconds: 450),
                child: Column(
                  children: [
                    _ApplicationItem(title: 'Education', icon: Icons.school),
                    const SizedBox(height: 8),
                    _ApplicationItem(title: 'Healthcare', icon: Icons.local_hospital),
                    const SizedBox(height: 8),
                    _ApplicationItem(title: 'Corporate', icon: Icons.business),
                    const SizedBox(height: 8),
                    _ApplicationItem(title: 'Government Services', icon: Icons.public),
                    const SizedBox(height: 8),
                    _ApplicationItem(title: 'Customer Support', icon: Icons.support_agent),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              FadeInUp(
                delay: const Duration(milliseconds: 500),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        'Version 1.0.0',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '© 2024 ISL Translate Project',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const _FeatureItem({
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TechBadge extends StatelessWidget {
  final String label;

  const _TechBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}

class _ApplicationItem extends StatelessWidget {
  final String title;
  final IconData icon;

  const _ApplicationItem({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.secondary,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
