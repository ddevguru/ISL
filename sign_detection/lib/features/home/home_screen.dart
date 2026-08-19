import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../translation/translation_screen.dart';
import '../video_call/video_call_screen.dart';
import '../history/history_screen.dart';
import '../dictionary/dictionary_screen.dart';
import '../profile/profile_screen.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/utils.dart';
import '../../data/mock/mock_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final _mockData = MockDataRepository();

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const _HomeView(),
      const TranslationScreen(),
      const VideoCallScreen(),
      const DictionaryScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => _selectedIndex == 0,
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() => _selectedIndex = index);
          },
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: 'Home',
              tooltip: 'Home',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.translate),
              label: 'Translate',
              tooltip: 'Translate',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.videocam),
              label: 'Calls',
              tooltip: 'Video Calls',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.menu_book),
              label: 'Learn',
              tooltip: 'Dictionary',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person),
              label: 'Profile',
              tooltip: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mockData = MockDataRepository();
    final user = mockData.currentUser;

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with greeting
              FadeInUp(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good Morning 👋',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.name,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ],
                    ),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.primary.withOpacity(0.6),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          user.name[0],
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Hero card
              FadeInUp(
                delay: const Duration(milliseconds: 100),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                        Theme.of(context).colorScheme.secondary.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '✨ Real-Time ISL Translation',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Translate Indian Sign Language into text and speech during live communication.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: PrimaryButton(
                              label: 'Start Translation',
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const TranslationScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SecondaryButton(
                              label: 'Join Call',
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const VideoCallScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // AI Engine Status
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: StatusCard(
                  title: 'AI Translation Engine',
                  description: 'Ready to translate',
                  isActive: true,
                  items: [
                    StatusItem(label: 'Recognition Accuracy', value: '94%'),
                    StatusItem(label: 'Response Time', value: '120 ms'),
                    StatusItem(label: 'Supported Signs', value: '500+'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Quick Actions Header
              FadeInUp(
                delay: const Duration(milliseconds: 300),
                child: SectionHeader(
                  title: 'Quick Actions',
                  subtitle: 'Get started with ISL translation',
                ),
              ),
              const SizedBox(height: 16),

              // Quick Actions Grid
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.9,
                  children: [
                    FeatureCard(
                      icon: Icons.touch_app,
                      title: 'Start Translation',
                      description: 'Begin ISL recognition',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const TranslationScreen(),
                          ),
                        );
                      },
                    ),
                    FeatureCard(
                      icon: Icons.videocam,
                      title: 'Video Call',
                      description: 'Join a video call',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const VideoCallScreen(),
                          ),
                        );
                      },
                    ),
                    FeatureCard(
                      icon: Icons.history,
                      title: 'History',
                      description: 'View past sessions',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const HistoryScreen(),
                          ),
                        );
                      },
                    ),
                    FeatureCard(
                      icon: Icons.menu_book,
                      title: 'Dictionary',
                      description: 'Browse ISL signs',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const DictionaryScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
