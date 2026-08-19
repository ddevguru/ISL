import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/utils.dart';
import '../../data/mock/mock_data.dart';

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({Key? key}) : super(key: key);

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  final _mockData = MockDataRepository();
  late final _allSigns = _mockData.getAllSigns();
  late final _categories = _mockData.getCategories();

  String _selectedCategory = '';
  String _searchQuery = '';
  final Set<dynamic> _favoriteSigns = {};

  @override
  void initState() {
    super.initState();
    if (_categories.isNotEmpty) {
      _selectedCategory = _categories[0];
    }
  }

  List<dynamic> _getFilteredSigns() {
    var signs = _allSigns;

    if (_selectedCategory.isNotEmpty) {
      signs = signs.where((s) => s.category == _selectedCategory).toList();
    }

    if (_searchQuery.isNotEmpty) {
      signs = signs
          .where((s) =>
              s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              s.englishMeaning
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return signs;
  }

  @override
  Widget build(BuildContext context) {
    final filteredSigns = _getFilteredSigns();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ISL Dictionary'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  onChanged: (query) {
                    setState(() => _searchQuery = query);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search signs...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.2),
                      ),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((category) {
                      final isSelected = _selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() => _selectedCategory =
                                selected ? category : '');
                          },
                          selectedColor: Theme.of(context).colorScheme.primary,
                          backgroundColor: Colors.transparent,
                          side: BorderSide(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey.withOpacity(0.3),
                          ),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredSigns.isEmpty
                ? EmptyState(
                    icon: Icons.search_off,
                    title: 'No Signs Found',
                    description: 'Try adjusting your search or filter criteria.',
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: filteredSigns.length,
                    itemBuilder: (context, index) {
                      final sign = filteredSigns[index];
                      final isFavorited = _favoriteSigns.contains(sign);
                      return FadeInUp(
                        delay: Duration(milliseconds: index * 50),
                        child: GlassCard(
                          onTap: () => _showSignDetails(sign),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          sign.name,
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          sign.englishMeaning,
                                          style: Theme.of(context).textTheme.bodySmall,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (isFavorited) {
                                          _favoriteSigns.remove(sign);
                                        } else {
                                          _favoriteSigns.add(sign);
                                        }
                                      });
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(isFavorited ? '💔 Removed from favorites' : '❤️ Added to favorites'),
                                          duration: const Duration(milliseconds: 1200),
                                        ),
                                      );
                                    },
                                    child: Icon(
                                      isFavorited ? Icons.favorite : Icons.favorite_border,
                                      color: isFavorited ? const Color(0xFFEF4444) : Colors.grey,
                                      size: 24,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    sign.category,
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showSignDetails(dynamic sign) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    '✋',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                sign.name,
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 16),
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SignDetailRow(label: 'English', value: sign.englishMeaning),
                    const SizedBox(height: 12),
                    _SignDetailRow(label: 'Hindi', value: sign.hindiMeaning),
                    const SizedBox(height: 12),
                    _SignDetailRow(label: 'Category', value: sign.category),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      sign.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _SignDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _SignDetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
