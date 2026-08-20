import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/api_config.dart';
import '../features/splash/splash_screen.dart';
import '../features/home/home_screen.dart';
import '../screens/auth_screen.dart';
import '../services/auth_service.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        final authService = context.read<AuthService>();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                authService.isAuthenticated ? const HomeScreen() : AuthScreen(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}
