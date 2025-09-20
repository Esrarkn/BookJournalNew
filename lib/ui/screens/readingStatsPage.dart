import 'package:book_journal/core/theme.dart/appPalette.dart';
import 'package:book_journal/ui/widgets/appBackground.dart';
import 'package:book_journal/ui/widgets/appHeader.dart';
import 'package:flutter/material.dart';

class CategoryStatisticsPage extends StatefulWidget {
  final Map<String, int> categoryStats;

  const CategoryStatisticsPage({Key? key, required this.categoryStats}) : super(key: key);

  @override
  State<CategoryStatisticsPage> createState() => _CategoryStatisticsPageState();
}

class _CategoryStatisticsPageState extends State<CategoryStatisticsPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _barAnimations;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _initializeAnimations();
    _animationController.forward();
  }
  
  void _initializeAnimations() {
    final categories = widget.categoryStats.keys.toList();
    _barAnimations = List.generate(
      categories.length,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index * 0.1,
            0.5 + (index * 0.1),
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getCategoryColor(String category) {
    final Map<String, Color> categoryColors = {
      'Roman': Colors.blue.shade600,
      'Bilim Kurgu': Colors.purple.shade600,
      'Fantastik': Colors.pink.shade500,
      'Polisiye': Colors.orange.shade600,
      'Biyografi': Colors.green.shade600,
      'Tarih': Colors.brown.shade600,
      'Felsefe': Colors.indigo.shade600,
      'Bilim': Colors.teal.shade600,
      'Sanat': Colors.red.shade600,
      'Kişisel Gelişim': Colors.amber.shade700,
      'Çocuk': Colors.cyan.shade600,
      'Genel': Colors.grey.shade600,
    };
    return categoryColors[category] ?? Colors.grey.shade600;
  }

  IconData _getCategoryIcon(String category) {
    final Map<String, IconData> categoryIcons = {
      'Roman': Icons.auto_stories,
      'Bilim Kurgu': Icons.rocket_launch,
      'Fantastik': Icons.auto_fix_high,
      'Polisiye': Icons.search,
      'Biyografi': Icons.person,
      'Tarih': Icons.history_edu,
      'Felsefe': Icons.psychology,
      'Bilim': Icons.science,
      'Sanat': Icons.palette,
      'Kişisel Gelişim': Icons.trending_up,
      'Çocuk': Icons.child_care,
      'Genel': Icons.book,
    };
    return categoryIcons[category] ?? Icons.book;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.categoryStats.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: AppBackground(
          child: Column(
            children: [
              _buildModernHeader(),
              Expanded(child: _buildEmptyState()),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: AppBackground(
        child: Column(
          children: [
            _buildModernHeader(),
            Expanded(child: _buildStatisticsContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildModernHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.purple.shade600,
                    Colors.purple.shade500,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.bar_chart, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kategori İstatistikleri',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Okuma alışkanlıklarını keşfet',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsContent() {
    final categories = widget.categoryStats.keys.toList();
    final values = widget.categoryStats.values.toList();
    final totalBooks = values.fold(0, (sum, value) => sum + value);
    final maxValue = values.reduce((a, b) => a > b ? a : b);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(totalBooks, categories.length),
          const SizedBox(height: 32),
          const Text(
            'Kategori Dağılımı',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(categories.length, (index) {
            final category = categories[index];
            final value = values[index];
            final color = _getCategoryColor(category);
            final icon = _getCategoryIcon(category);
            final percentage = totalBooks > 0 ? (value / totalBooks * 100) : 0;
            
            return AnimatedBuilder(
              animation: _barAnimations[index],
              builder: (context, child) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: _buildCategoryCard(
                    category: category,
                    value: value,
                    color: color,
                    icon: icon,
                    percentage: percentage as double,
                    maxValue: maxValue,
                    animation: _barAnimations[index].value,
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(int totalBooks, int categoryCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade50,
            Colors.purple.shade50,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryItem(
              'Toplam Kitap',
              totalBooks.toString(),
              Icons.library_books,
              Colors.blue.shade600,
            ),
          ),
          Container(
            width: 1,
            height: 50,
            color: Colors.grey.withOpacity(0.3),
          ),
          Expanded(
            child: _buildSummaryItem(
              'Kategori Sayısı',
              categoryCount.toString(),
              Icons.category,
              Colors.purple.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard({
    required String category,
    required int value,
    required Color color,
    required IconData icon,
    required double percentage,
    required int maxValue,
    required double animation,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  category,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    value.toString(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Stack(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 800),
                  height: 8,
                  width: MediaQuery.of(context).size.width * 0.8 * (value / maxValue) * animation,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color.withOpacity(0.7), color],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.bar_chart,
              size: 60,
              color: Colors.purple.shade600,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Henüz İstatistik Yok',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Kitap eklemeye başladığınızda kategorilere göre istatistiklerinizi burada görebileceksiniz.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}