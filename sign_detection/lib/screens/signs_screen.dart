import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

class SignsScreen extends StatefulWidget {
  @override
  _SignsScreenState createState() => _SignsScreenState();
}

class _SignsScreenState extends State<SignsScreen> {
  List<dynamic> signs = [];
  List<dynamic> filteredSigns = [];
  List<String> categories = [];
  String selectedCategory = 'All';
  bool isLoading = true;
  String searchText = '';

  @override
  void initState() {
    super.initState();
    fetchSigns();
    fetchCategories();
  }

  Future<void> fetchSigns() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.signsEndpoint}?per_page=100'),
        headers: ApiConfig.defaultHeaders,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          signs = data['signs'] ?? [];
          filteredSigns = signs;
          isLoading = false;
        });
      } else {
        print('Error: ${response.statusCode}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Error fetching signs: $e');
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error loading signs: $e')),
      );
    }
  }

  Future<void> fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.categoriesEndpoint),
        headers: ApiConfig.defaultHeaders,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rawCats = data['categories'] as List? ?? [];
        setState(() {
          categories = ['All', ...rawCats.map((e) => e.toString())];
        });
      }
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  void filterSigns() {
    setState(() {
      filteredSigns = signs.where((sign) {
        final matchesSearch = sign['name']
                .toString()
                .toLowerCase()
                .contains(searchText.toLowerCase()) ||
            sign['english_translation']
                .toString()
                .toLowerCase()
                .contains(searchText.toLowerCase()) ||
            sign['hindi_translation']
                .toString()
                .toLowerCase()
                .contains(searchText.toLowerCase());

        final matchesCategory = selectedCategory == 'All' ||
            sign['category'].toString() == selectedCategory;

        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🤟 Signs (${filteredSigns.length})'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search Bar
                Padding(
                  padding: EdgeInsets.all(15),
                  child: TextField(
                    onChanged: (value) {
                      searchText = value;
                      filterSigns();
                    },
                    decoration: InputDecoration(
                      hintText: 'Search signs...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),

                // Category Filter
                if (categories.isNotEmpty)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        children: categories.map((category) {
                          final isSelected = category == selectedCategory;
                          return Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: GestureDetector(
                              onTap: () {
                                selectedCategory = category;
                                filterSigns();
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.deepPurple
                                      : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  category,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                SizedBox(height: 15),

                // Signs List
                Expanded(
                  child: filteredSigns.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 50, color: Colors.grey),
                              SizedBox(height: 10),
                              Text('कोई signs नहीं मिले'),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredSigns.length,
                          itemBuilder: (context, index) {
                            final sign = filteredSigns[index];
                            return SignCard(sign: sign);
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

class SignCard extends StatelessWidget {
  final dynamic sign;

  SignCard({required this.sign});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SignDetailScreen(sign: sign),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                sign['name'] ?? 'Unknown',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              SizedBox(height: 8),

              // English Translation
              Text(
                '🇬🇧 ${sign['english_translation'] ?? 'N/A'}',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 5),

              // Hindi Translation
              Text(
                '🇮🇳 ${sign['hindi_translation'] ?? 'N/A'}',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 10),

              // Category & Difficulty
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      sign['category'] ?? 'General',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  SizedBox(width: 10),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: getDifficultyColor(sign['difficulty_level']),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      sign['difficulty_level'] ?? 'Medium',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              if (sign['confidence_score'] != null)
                Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Row(
                    children: [
                      Text('Confidence: '),
                      SizedBox(width: 8),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: sign['confidence_score'],
                          minHeight: 8,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.green,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '${(sign['confidence_score'] * 100).toStringAsFixed(0)}%',
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

  Color getDifficultyColor(String? level) {
    switch (level?.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}

class SignDetailScreen extends StatelessWidget {
  final dynamic sign;

  SignDetailScreen({required this.sign});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(sign['name'] ?? 'Sign Details'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sign['name'] ?? 'Unknown',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(
                      '🇬🇧 English',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      sign['english_translation'] ?? 'N/A',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '🇮🇳 Hindi',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      sign['hindi_translation'] ?? 'N/A',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Description
              if (sign['description'] != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      sign['description'],
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 20),
                  ],
                ),

              // Info Grid
              Row(
                children: [
                  Expanded(
                    child: InfoBox(
                      label: 'Category',
                      value: sign['category'] ?? 'N/A',
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: InfoBox(
                      label: 'Difficulty',
                      value: sign['difficulty_level'] ?? 'N/A',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: InfoBox(
                      label: 'Source',
                      value: sign['dataset_source'] ?? 'N/A',
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: InfoBox(
                      label: 'Confidence',
                      value: sign['confidence_score'] != null
                          ? '${(sign['confidence_score'] * 100).toStringAsFixed(0)}%'
                          : 'N/A',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Practice Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Practice mode coming soon...'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Text(
                    '🎯 Practice this Sign',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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

class InfoBox extends StatelessWidget {
  final String label;
  final String value;

  InfoBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.deepPurple),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
