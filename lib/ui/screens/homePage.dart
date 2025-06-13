import 'package:book_journal/core/theme.dart/appPalette.dart';
import 'package:book_journal/data/bloc/book_bloc/book_bloc.dart';
import 'package:book_journal/data/bloc/book_bloc/book_state.dart';
import 'package:book_journal/ui/screens/bookGoalsPage.dart';
import 'package:book_journal/ui/screens/bookPage.dart';
import 'package:book_journal/ui/screens/profilePage.dart';
import 'package:book_journal/ui/screens/readingStatsPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          BookPage(),
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
          BookGoalsPage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        height: 70,
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        indicatorColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        destinations: [
          NavigationDestination(
            icon: Icon(LucideIcons.bookOpen, color: AppPallete.gradient1),
            selectedIcon: Icon(LucideIcons.bookOpenCheck),
            label: 'Kitaplar',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.barChart3, color: AppPallete.gradient1),
            selectedIcon: Icon(LucideIcons.barChartBig),
            label: 'İstatistik',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.target, color: AppPallete.gradient1),
            selectedIcon: Icon(LucideIcons.target),
            label: 'Hedefler',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.user, color: AppPallete.gradient1),
            selectedIcon: Icon(LucideIcons.userCheck),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
