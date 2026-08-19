import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../home/home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  final List<OnboardingPage> _pages = const [
    OnboardingPage(
      icon: '🤝',
      title: 'Communicate Without Barriers',
      description:
          'Break down communication barriers between Indian Sign Language users and non-signers. Connect with confidence.',
      color: Color(0xFF5B67CA),
      accentColor: Color(0xFFE8ECFF),
    ),
    OnboardingPage(
      icon: '✋',
      title: 'AI-Powered Recognition',
      description:
          'Advanced hand gesture recognition instantly translates ISL into text and speech. Real-time understanding at your fingertips.',
      color: Color(0xFF6ECB63),
      accentColor: Color(0xFFE8F5E9),
    ),
    OnboardingPage(
      icon: '📞',
      title: 'Connected Communication',
      description:
          'Enable ISL translation during online meetings, classes, and virtual communication. Accessibility for everyone.',
      color: Color(0xFF00D9FF),
      accentColor: Color(0xFFE0F7FA),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _skipToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() => _currentPage = page);
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return OnboardingPageView(page: _pages[index]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Animated dot indicators
                  FadeInUp(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pages.length,
                        (index) => Container(
                          width: _currentPage == index ? 36 : 10,
                          height: 10,
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: _currentPage == index
                                ? _pages[index].color
                                : _pages[index].color.withValues(alpha: 0.2),
                            boxShadow: _currentPage == index
                                ? [
                                    BoxShadow(
                                      color: _pages[index].color
                                          .withValues(alpha: 0.4),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : [],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Action buttons
                  Row(
                    children: [
                      TextButton(
                        onPressed: _skipToHome,
                        child: Text(
                          'Skip',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: const Color(0xFFAAADB5),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      const Spacer(),
                      if (_currentPage < _pages.length - 1)
                        ElevatedButton(
                          onPressed: () => _goToPage(_currentPage + 1),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _pages[_currentPage].color,
                            elevation: 4,
                            shadowColor:
                                _pages[_currentPage].color.withValues(alpha: 0.3),
                          ),
                          child: const Row(
                            children: [
                              Text('Next'),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, size: 18),
                            ],
                          ),
                        ),
                      if (_currentPage == _pages.length - 1)
                        ElevatedButton(
                          onPressed: _skipToHome,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _pages[_currentPage].color,
                            elevation: 4,
                            shadowColor:
                                _pages[_currentPage].color.withValues(alpha: 0.3),
                          ),
                          child: const Row(
                            children: [
                              Text('Get Started'),
                              SizedBox(width: 8),
                              Icon(Icons.check, size: 18),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingPage {
  final String icon;
  final String title;
  final String description;
  final Color color;
  final Color accentColor;

  const OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.accentColor,
  });
}

class OnboardingPageView extends StatefulWidget {
  final OnboardingPage page;

  const OnboardingPageView({Key? key, required this.page}) : super(key: key);

  @override
  State<OnboardingPageView> createState() => _OnboardingPageViewState();
}

class _OnboardingPageViewState extends State<OnboardingPageView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _rotateAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeInUp(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (_controller.isAnimating) {
                    _controller.stop();
                  } else {
                    _controller.repeat();
                  }
                });
              },
              child: AnimatedBuilder(
                animation: _rotateAnimation,
                builder: (context, child) {
                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(_rotateAnimation.value * 6.28)
                      ..rotateX((_rotateAnimation.value * 0.3).abs()),
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            widget.page.color,
                            widget.page.color.withValues(alpha: 0.5),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(48),
                        boxShadow: [
                          BoxShadow(
                            color: widget.page.color.withValues(alpha: 0.4),
                            blurRadius: 40,
                            offset: const Offset(0, 12),
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          widget.page.icon,
                          style: const TextStyle(fontSize: 90),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 48),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: Text(
              widget.page.title,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: widget.page.color,
                    letterSpacing: 0.5,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          FadeInUp(
            delay: const Duration(milliseconds: 300),
            child: Text(
              widget.page.description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                    color: const Color(0xFF666B7F),
                    letterSpacing: 0.3,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
