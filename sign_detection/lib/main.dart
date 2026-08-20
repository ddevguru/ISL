import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'app/app.dart';
import 'app/theme.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize AuthService
  final authService = AuthService();
  await authService.initialize();

  runApp(ISLTranslateApp(authService: authService));
}

class ISLTranslateApp extends StatelessWidget {
  final AuthService authService;

  const ISLTranslateApp({Key? key, required this.authService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthService>.value(
      value: authService,
      child: MaterialApp(
        title: 'ISL Translate',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        home: const App(),
      ),
    );
  }
}
