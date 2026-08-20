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
  String selectedCategory = 'Greetings';
  List<Map<String, dynamic>> signs = [];
  List<String> categories = ['Greetings', 'Common Words', 'Places', 'Adjectives', 'Verbs', 'Emotions', 'People'];
  Map<String, dynamic> learningStats = {};
  bool isLoading = false;

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
        Uri.parse('${ApiConfig.baseUrl}/learning/signs'),
        headers: {
          ...ApiConfig.defaultHeaders,
          'Authorization': 'Bearer ${authService.accessToken}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final signsList = data['signs'] as List?;
        if (signsList != null) {
          final filtered = signsList.where((s) => s['category'] == selectedCategory).toList();
          setState(() => signs = List<Map<String, dynamic>>.from(filtered));
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
      _loadProgress();
    } catch (e) {
      print('Error recording practice: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ISL Dictionary'),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search signs...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
              ),
            ),

            // Category buttons
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
                          side: BorderSide(
                            color: isSelected ? Colors.deepPurple : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Signs grid
            if (isLoading)
              const Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              )
            else if (signs.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: signs.length,
                  itemBuilder: (context, index) {
                    final sign = signs[index];
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.deepPurple.shade200),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              children: [
                                Text(
                                  sign['name'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  selectedLanguage == 'hi'
                                      ? (sign['hindi_translation'] ?? '')
                                      : (sign['english_translation'] ?? ''),
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.shade100,
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                            ),
                            child: Text(
                              sign['category'] ?? '',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
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
                child: Text('No signs in this category'),
              ),
          ],
        ),
      ),
    );
  }
}
