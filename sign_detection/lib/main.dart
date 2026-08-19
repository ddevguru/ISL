import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app/app.dart';
import 'app/theme.dart';

void main() {
  runApp(const ISLTranslateApp());
}

class ISLTranslateApp extends StatelessWidget {
  const ISLTranslateApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ISL Translate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: const App(),
    );
  }
}
