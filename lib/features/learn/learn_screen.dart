import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  int _selectedCategoryIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> _categories = ['All', 'Cycle basics', 'PCOS', 'Nutrition', 'Fitness', 'Teen guide'];

  final List<Map<String, dynamic>> _articles = [
    {
      'title': 'Understanding your menstrual cycle',
      'duration': '5 min read',
      'icon': '🩸',
      'color': AppColors.periodLight,
      'category': 'Cycle basics',
      'summary': 'The menstrual cycle is a monthly sequence of hormonal events coordinated between your brain and ovaries. It is divided into 4 primary phases: Menstrual, Follicular, Ovulation, and Luteal.',
    },
    {
      'title': 'What is ovulation and fertile window?',
      'duration': '4 min read',
      'icon': '✨',
      'color': AppColors.fertileLight,
      'category': 'Cycle basics',
      'summary': 'Ovulation occurs once per cycle when a mature ovarian follicle releases an egg. The fertile window spans 5 days prior to ovulation plus ovulation day itself.',
    },
    {
      'title': 'Nutrition for hormonal balance',
      'duration': '6 min read',
      'icon': '🥑',
      'color': AppColors.ovulationLight,
      'category': 'Nutrition',
      'summary': 'How whole foods, seeds, and healthy fats support progesterone and estrogen cycles. Focus on leafy greens, magnesium, and omega-3 fatty acids.',
    },
    {
      'title': 'Exercise and your cycle',
      'duration': '5 min read',
      'icon': '🏃‍♀️',
      'color': AppColors.primaryLight,
      'category': 'Fitness',
      'summary': 'Syncing strength training, cardio, and restorative yoga with your natural energy shifts across follicular and luteal phases.',
    },
    {
      'title': 'Managing period pain naturally',
      'duration': '5 min read',
      'icon': '🌿',
      'color': AppColors.periodLight,
      'category': 'Cycle basics',
      'summary': 'Heat therapy, magnesium, anti-inflammatory teas, and gentle mobility work can significantly relieve dysmenorrhea without heavy medication.',
    },
    {
      'title': 'Understanding PCOS & Irregular Cycles',
      'duration': '7 min read',
      'icon': '🩺',
      'color': AppColors.ovulationLight,
      'category': 'PCOS',
      'summary': 'Polycystic Ovary Syndrome causes hormonal imbalances that affect ovulation frequency, insulin sensitivity, and cycle duration.',
    },
    {
      'title': 'First periods: A Guide for Teens',
      'duration': '4 min read',
      'icon': '🌸',
      'color': AppColors.primaryLight,
      'category': 'Teen guide',
      'summary': 'What to expect during menarche, how cycle patterns normalize over the first 2-3 years, and healthy hygiene tips.',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchQuery.trim().toLowerCase();
    final filteredArticles = _articles.where((a) {
      final matchesCategory = _selectedCategoryIndex == 0 ||
          a['category'] == _categories[_selectedCategoryIndex];
      final matchesSearch = query.isEmpty ||
          (a['title'] as String).toLowerCase().contains(query) ||
          (a['summary'] as String).toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            const Text(
              'Learn',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            // Search Bar with Active Filter Controller
            TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search articles...',
                hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.divider, width: 0.8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.divider, width: 0.8),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Category Filter Pills
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_categories.length, (index) {
                  final isSelected = _selectedCategoryIndex == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(_categories[index]),
                      selected: isSelected,
                      onSelected: (val) => setState(() => _selectedCategoryIndex = index),
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                      backgroundColor: AppColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : AppColors.divider,
                          width: 0.8,
                        ),
                      ),
                      showCheckmark: false,
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),

            // Article List or Empty State
            if (filteredArticles.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    const Text('🔍', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 12),
                    const Text(
                      'No articles found',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _searchQuery.isNotEmpty
                          ? 'No results matching "$_searchQuery"'
                          : 'No articles currently in this category.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                          _selectedCategoryIndex = 0;
                        });
                      },
                      child: const Text('Reset filters'),
                    ),
                  ],
                ),
              )
            else
              ...filteredArticles.map((article) => _buildArticleCard(context, article)),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleCard(BuildContext context, Map<String, dynamic> article) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _openArticleDetail(context, article),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.divider, width: 0.8),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: article['color'] as Color,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(article['icon'] as String, style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article['title'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      article['duration'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textTertiary, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _openArticleDetail(BuildContext context, Map<String, dynamic> article) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              article['title'] as String,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              article['duration'] as String,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.divider),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  article['summary'] as String,
                  style: const TextStyle(fontSize: 15, color: AppColors.textPrimary, height: 1.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
