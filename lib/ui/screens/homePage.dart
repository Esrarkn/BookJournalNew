import 'package:book_journal/core/theme.dart/appPalette.dart';
import 'package:book_journal/data/bloc/book_bloc/book_bloc.dart';
import 'package:book_journal/data/bloc/book_bloc/book_state.dart';
import 'package:book_journal/data/services/firestore_service.dart';
import 'package:book_journal/ui/models/user.dart';
import 'package:book_journal/ui/screens/bookGoalsPage.dart';
import 'package:book_journal/ui/screens/bookPage.dart';
import 'package:book_journal/ui/screens/profilePage.dart';
import 'package:book_journal/ui/screens/readingStatsPage.dart';
import 'package:book_journal/ui/screens/timerPage.dart';
import 'package:book_journal/ui/widgets/fabButton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

class HomePage extends StatefulWidget {
  final AppUser user;

  const HomePage({super.key, required this.user});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final FirestoreService _firestoreService;
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Map<String, int> getCategoryStats(BookLoaded state) {
    final books = state.books;
    final Map<String, int> categoryStats = {};

    for (var book in books) {
      final category = book.category ?? 'Belirsiz';
      categoryStats[category] = (categoryStats[category] ?? 0) + 1;
    }

    return categoryStats;
  }

  @override
  void initState() {
    super.initState();
    _firestoreService = FirestoreService();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final pages = [
      BookPage(userId: widget.user.id),
      BlocBuilder<BookBloc, BookState>(
        builder: (context, state) {
          if (state is BookLoaded) {
            final categoryStats = getCategoryStats(state);
            return CategoryStatisticsPage(categoryStats: categoryStats);
          } else if (state is BookLoading) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return const Center(child: Text('Veri yüklenemedi'));
          }
        },
      ),
      const BookGoalsPage(),
      ProfilePage(user: widget.user),
    ];

    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.grey.shade900,
                    Colors.grey.shade800,
                  ],
                )
              : const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFFDF6FF),
                    Color(0xFFF8F0FF),
                  ],
                ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: pages[_selectedIndex],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(theme),
      floatingActionButton: _selectedIndex == 0 ? Fabbutton() : null,

    );
  }

  Widget _buildBottomNavigationBar(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark
        ? Colors.grey.shade900.withOpacity(0.95)
        : Colors.white.withOpacity(0.95);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(
              color: isDark
                  ? Colors.grey.shade800
                  : Colors.purple.shade100.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            backgroundColor: Colors.transparent,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            selectedItemColor: AppPalette.appGradient.colors.first,
            unselectedItemColor: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            items: [
              _buildBottomNavItem(LucideIcons.bookOpen, LucideIcons.bookOpen, 'Kitaplar', theme),
              _buildBottomNavItem(LucideIcons.barChartBig, LucideIcons.barChartBig, 'İstatistik', theme),
              _buildBottomNavItem(LucideIcons.target, LucideIcons.target, 'Hedefler', theme),
              _buildBottomNavItem(LucideIcons.user2, LucideIcons.user2, 'Profil', theme),
            ],
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildBottomNavItem(
      IconData icon, IconData selectedIcon, String label, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final inactiveColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return BottomNavigationBarItem(
      icon: Icon(icon, color: inactiveColor, size: 24),
      activeIcon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => AppPalette.appGradient.createShader(
              Rect.fromLTWH(0, 0, 200, 100),
            ),
            child: Icon(selectedIcon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppPalette.primary,
            ),
          ),
        ],
      ),
      label: '',
    );
  }
}
