import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/widgets/cards.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _highContrast = false;
  bool _largeText = false;
  bool _reduceMotion = false;
  bool _captionsEnabled = true;
  bool _voiceOutputEnabled = true;
  bool _hapticFeedbackEnabled = true;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
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
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.blue.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info, color: Colors.blue, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Customize your experience with accessibility features',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _SectionHeader(title: 'Accessibility'),
              const SizedBox(height: 12),
              FadeInUp(
                child: _SettingsTile(
                  title: 'High Contrast',
                  description: 'Increase visual contrast for better readability',
                  trailing: Switch(
                    value: _highContrast,
                    onChanged: (value) {
                      setState(() => _highContrast = value);
                    },
                  ),
                ),
              ),
              FadeInUp(
                delay: const Duration(milliseconds: 50),
                child: _SettingsTile(
                  title: 'Large Text',
                  description: 'Increase text size throughout the app',
                  trailing: Switch(
                    value: _largeText,
                    onChanged: (value) {
                      setState(() => _largeText = value);
                    },
                  ),
                ),
              ),
              FadeInUp(
                delay: const Duration(milliseconds: 100),
                child: _SettingsTile(
                  title: 'Reduce Motion',
                  description: 'Minimize animations and transitions',
                  trailing: Switch(
                    value: _reduceMotion,
                    onChanged: (value) {
                      setState(() => _reduceMotion = value);
                    },
                  ),
                ),
              ),
              FadeInUp(
                delay: const Duration(milliseconds: 150),
                child: _SettingsTile(
                  title: 'Captions',
                  description: 'Show captions for audio content',
                  trailing: Switch(
                    value: _captionsEnabled,
                    onChanged: (value) {
                      setState(() => _captionsEnabled = value);
                    },
                  ),
                ),
              ),
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: _SettingsTile(
                  title: 'Voice Output',
                  description: 'Enable text-to-speech for translations',
                  trailing: Switch(
                    value: _voiceOutputEnabled,
                    onChanged: (value) {
                      setState(() => _voiceOutputEnabled = value);
                    },
                  ),
                ),
              ),
              FadeInUp(
                delay: const Duration(milliseconds: 250),
                child: _SettingsTile(
                  title: 'Haptic Feedback',
                  description: 'Vibration feedback on interactions',
                  trailing: Switch(
                    value: _hapticFeedbackEnabled,
                    onChanged: (value) {
                      setState(() => _hapticFeedbackEnabled = value);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _SectionHeader(title: 'Display'),
              const SizedBox(height: 12),
              FadeInUp(
                delay: const Duration(milliseconds: 300),
                child: _SettingsTile(
                  title: 'Dark Mode',
                  description: 'Use dark theme for reduced eye strain',
                  trailing: Switch(
                    value: _darkMode,
                    onChanged: (value) {
                      setState(() => _darkMode = value);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _SectionHeader(title: 'About'),
              const SizedBox(height: 12),
              FadeInUp(
                delay: const Duration(milliseconds: 350),
                child: _SettingsTile(
                  title: 'App Version',
                  description: '1.0.0',
                ),
              ),
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: _SettingsTile(
                  title: 'Privacy Policy',
                  description: 'View our privacy policy',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Opening privacy policy...')),
                    );
                  },
                ),
              ),
              FadeInUp(
                delay: const Duration(milliseconds: 450),
                child: _SettingsTile(
                  title: 'Terms of Service',
                  description: 'View our terms and conditions',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Opening terms of service...')),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.primary,
          ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String description;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.title,
    required this.description,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.white.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 16),
              trailing!,
            ] else if (onTap != null)
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}
