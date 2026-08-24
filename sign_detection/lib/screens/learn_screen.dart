import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../config/api_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/widgets/hand_skeleton.dart';
import 'practice_screen.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  String selectedLanguage = 'en';
  String selectedCategory = 'ALL';
  List<Map<String, dynamic>> signs = [];
  List<String> categories = ['ALL', 'Greetings', 'Response', 'Emotions', 'Actions', 'Objects', 'Adjectives', 'Family', 'Requests', 'Time', 'Numbers'];
  Map<String, dynamic> learningStats = {};
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadProgress();
  }

  Future<void> _loadCategories() async {
    final authService = context.read<AuthService>();
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.categoriesEndpoint),
        headers: {
          ...ApiConfig.defaultHeaders,
          'Authorization': 'Bearer ${authService.accessToken}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final catsList = data['categories'] as List?;
        if (catsList != null && catsList.isNotEmpty) {
          setState(() {
            categories = ['ALL', ...List<String>.from(catsList)];
          });
        }
      }
    } catch (e) {
      print('Error loading categories: $e');
    } finally {
      _loadSigns();
    }
  }

  Future<void> _loadSigns() async {
    final authService = context.read<AuthService>();
    setState(() => isLoading = true);

    try {
      final String url = selectedCategory == 'ALL'
          ? '${ApiConfig.signsEndpoint}?per_page=100'
          : '${ApiConfig.signsEndpoint}?category=$selectedCategory&per_page=100';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          ...ApiConfig.defaultHeaders,
          'Authorization': 'Bearer ${authService.accessToken}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final signsList = data['signs'] as List?;
        if (signsList != null) {
          setState(() => signs = List<Map<String, dynamic>>.from(signsList));
        }
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
        Uri.parse('${ApiConfig.learningProgressEndpoint}/summary'),
        headers: {
          ...ApiConfig.defaultHeaders,
          'Authorization': 'Bearer ${authService.accessToken}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => learningStats = data['summary'] ?? data['stats'] ?? {});
      }
    } catch (e) {
      print('Error loading progress: $e');
    }
  }

  void _showSignDetails(Map<String, dynamic> sign) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Grab handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      sign['name'] ?? '',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      (sign['difficulty_level'] ?? 'easy').toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                selectedLanguage == 'hi'
                    ? '🇮🇳 अनुवाद: ${sign['hindi_translation'] ?? 'N/A'}'
                    : '🇬🇧 English: ${sign['english_translation'] ?? 'N/A'}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              
              // Skeleton Hand Drawing
              Center(
                child: HandSkeletonWidget(
                  keypoints: sign['keypoints_data'],
                  width: 180,
                  height: 180,
                ),
              ),
              
              const SizedBox(height: 20),
              const Text(
                'How to perform gesture:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 6),
              Text(
                sign['description'] ?? 'Position your hand as illustrated in the vector diagram.',
                style: const TextStyle(fontSize: 15, color: Colors.black87),
              ),
              const SizedBox(height: 24),
              
              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.of(context).pop(); // Close bottom sheet
                    final success = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PracticeScreen(sign: sign),
                      ),
                    );
                    if (success == true) {
                      _loadProgress();
                    }
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Practice Sign with Camera'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final practicedCount = learningStats['total_signs_practiced'] ?? learningStats['practiced_signs'] ?? 0;
    final masteredCount = learningStats['mastered_signs'] ?? learningStats['total_mastered'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ISL Learning Module'),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Interactive Learning Stats Header
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple.shade600, Colors.deepPurple.shade900],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Practice Progress 🎯',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Total Signs: ${signs.length}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('Signs Practiced', '$practicedCount', Colors.blue.shade100),
                      Container(width: 1, height: 40, color: Colors.white30),
                      _buildStatItem('Mastered Signs', '$masteredCount', Colors.green.shade100),
                    ],
                  ),
                ],
              ),
            ),

            // Language Selector Tab
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text('Language: '),
                  TextButton(
                    onPressed: () => setState(() => selectedLanguage = 'en'),
                    child: Text(
                      'English',
                      style: TextStyle(
                        fontWeight: selectedLanguage == 'en' ? FontWeight.bold : FontWeight.normal,
                        color: selectedLanguage == 'en' ? Colors.deepPurple : Colors.grey,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => selectedLanguage = 'hi'),
                    child: Text(
                      'हिन्दी',
                      style: TextStyle(
                        fontWeight: selectedLanguage == 'hi' ? FontWeight.bold : FontWeight.normal,
                        color: selectedLanguage == 'hi' ? Colors.deepPurple : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Categories Selector Slider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categories.map((cat) {
                    final isSelected = selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ElevatedButton(
                        onPressed: () => setState(() {
                          selectedCategory = cat;
                          _loadSigns();
                        }),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSelected ? Colors.deepPurple : Colors.white,
                          foregroundColor: isSelected ? Colors.white : Colors.black,
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          side: BorderSide(
                            color: isSelected ? Colors.deepPurple : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(cat),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Signs Grid
            if (isLoading)
              const Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              )
            else if (signs.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.78,
                  ),
                  itemCount: signs.length,
                  itemBuilder: (context, index) {
                    final sign = signs[index];
                    return GestureDetector(
                      onTap: () => _showSignDetails(sign),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.deepPurple.shade100, width: 1.5),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade100,
                              blurRadius: 6,
                              spreadRadius: 1,
                            )
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Visual skeleton representation inside card
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                                width: double.infinity,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: HandSkeletonWidget(
                                    keypoints: sign['keypoints_data'],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              child: Column(
                                children: [
                                  Text(
                                    sign['name'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepPurple,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    selectedLanguage == 'hi'
                                        ? (sign['hindi_translation'] ?? '')
                                        : (sign['english_translation'] ?? ''),
                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.deepPurple.shade50,
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(14),
                                  bottomRight: Radius.circular(14),
                                ),
                              ),
                              child: Text(
                                (sign['category'] ?? '').replaceAll('_', ' '),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.deepPurple,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(50),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.school_outlined, size: 60, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      const Text(
                        'No signs found in this category',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color textColor) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}
