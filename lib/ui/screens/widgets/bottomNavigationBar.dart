/*import 'package:book_journal/core/theme.dart/appPalette.dart';
import 'package:book_journal/ui/screens/bookGoalsPage.dart';
import 'package:book_journal/ui/screens/bookPage.dart';
import 'package:book_journal/ui/screens/profilePage.dart';
import 'package:book_journal/ui/screens/readingStatsPage.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart'; // Modern ikonlar için

class BottomNavigaitonBar extends StatefulWidget {
  @override
  _BottomNavigaitonBarState createState() => _BottomNavigaitonBarState();
}

class _BottomNavigaitonBarState extends State<BottomNavigaitonBar> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    BookPage(),
    CategoryStatisticsPage(categoryStats: {}),
    BookGoalsPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        height: 70,
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        indicatorColor: AppPallete.gradient1,
        destinations: [
          NavigationDestination(
            icon: Icon(LucideIcons.bookOpen),
            selectedIcon: const Icon(LucideIcons.bookOpenCheck),
            label: 'Kitaplar',
          ),
          const NavigationDestination(
            icon: Icon(LucideIcons.barChart3),
            selectedIcon: Icon(LucideIcons.barChartBig),
            label: 'İstatistik',
          ),
          const NavigationDestination(
            icon: Icon(LucideIcons.target),
            selectedIcon: Icon(LucideIcons.target),
            label: 'Hedefler',
          ),
          const NavigationDestination(
            icon: Icon(LucideIcons.user),
            selectedIcon: Icon(LucideIcons.userCheck),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
*/