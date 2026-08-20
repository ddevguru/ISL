import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../config/api_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  String selectedLanguage = 'en';
  String selectedDifficulty = 'Easy';
  String selectedCategory = 'Greetings';
  List<Map<String, dynamic>> signs = [];
  Map<String, dynamic> learningStats = {};
  bool isLoading = false;
  int currentSignIndex = 0;

  final translations = {
    'en': {'title': 'Learn ISL', 'practiced': 'Practiced', 'accuracy': 'Accuracy', 'master': 'Master it!'},
    'hi': {'title': 'ISL सीखें', 'practiced': 'प्रशिक्षित', 'accuracy': 'सटीकता', 'master': 'इसे मास्टर करें!'},
    'mr': {'title': 'ISL शिका', 'practiced': 'सराव केले', 'accuracy': 'अचूकता', 'master': 'महारत मिळवा!'},
  };

  @override
  void initState() {
    super.initState();
    _loadSigns();
    _loadProgress();
  }

  Future<void> _loadSigns() async {
    final authService = context.read<AuthService>();
    setState(() => isLoading = true);

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/learning/signs?difficulty=$selectedDifficulty&category=$selectedCategory'),
        headers: {
          ...ApiConfig.defaultHeaders,
          'Authorization': 'Bearer ${authService.accessToken}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => signs = List<Map<String, dynamic>>.from(data['signs']));
      }
    } catch (e) {
      print('Error loading signs: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadProgress() async {
    final authService = context.read<AuthService>();

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/learning/progress'),
        headers: {
          ...ApiConfig.defaultHeaders,
          'Authorization': 'Bearer ${authService.accessToken}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => learningStats = data['stats'] ?? {});
      }
    } catch (e) {
      print('Error loading progress: $e');
    }
  }

  Future<void> _recordPractice(String signId, bool correct) async {
    final authService = context.read<AuthService>();

    try {
      await http.post(
        Uri.parse('${ApiConfig.baseUrl}/learning/progress/$signId'),
        headers: {
          ...ApiConfig.defaultHeaders,
          'Authorization': 'Bearer ${authService.accessToken}',
        },
        body: jsonEncode({'correct': correct}),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(correct ? 'Great! Correct!' : 'Keep practicing!'),
          backgroundColor: correct ? Colors.green : Colors.orange,
        ),
      );

      _loadProgress();
    } catch (e) {
      print('Error recording practice: $e');
    }
  }

  String _getTranslation(String key) {
    return translations[selectedLanguage]?[key] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTranslation('title')),
        backgroundColor: Colors.deepPurple,
        actions: [
          PopupMenuButton<String>(
            onSelected: (lang) => setState(() => selectedLanguage = lang),
            itemBuilder: (context) => [
              PopupMenuItem(value: 'en', child: Text('English')),
              PopupMenuItem(value: 'hi', child: Text('हिंदी')),
              PopupMenuItem(value: 'mr', child: Text('मराठी')),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Stats Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade700],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Progress',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard('${learningStats['total_signs_practiced'] ?? 0}', 'Signs Learned'),
                      _buildStatCard('${learningStats['mastered_signs'] ?? 0}', 'Mastered'),
                      _buildStatCard('${learningStats['total_practice_sessions'] ?? 0}', 'Sessions'),
                    ],
                  ),
                ],
              ),
            ),

            // Filters
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Difficulty', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Row(
                    children: ['Easy', 'Medium', 'Hard'].map((d) {
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() {
                            selectedDifficulty = d;
                            _loadSigns();
                          }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: selectedDifficulty == d
                                  ? Colors.deepPurple
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              d,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: selectedDifficulty == d
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            // Signs List
            if (isLoading)
              const Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              )
            else if (signs.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: signs.length,
                  itemBuilder: (context, index) {
                    final sign = signs[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.deepPurple.shade200),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sign['name'] ?? '',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (selectedLanguage == 'hi')
                            Text(
                              sign['hindi_translation'] ?? '',
                              style: const TextStyle(fontSize: 16),
                            )
                          else if (selectedLanguage == 'mr')
                            Text(
                              sign['english_translation'] ?? '',
                              style: const TextStyle(fontSize: 16),
                            )
                          else
                            Text(
                              sign['english_translation'] ?? '',
                              style: const TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          const SizedBox(height: 12),
                          Text(
                            sign['description'] ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _recordPractice(sign['id'], true),
                                  icon: const Icon(Icons.check),
                                  label: const Text('Got it!'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _recordPractice(sign['id'], false),
                                  icon: const Icon(Icons.repeat),
                                  label: const Text('Practice more'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(40),
                child: Center(
                  child: Text('No signs available for this level'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}
