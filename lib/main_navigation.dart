import 'package:flutter/material.dart';
import 'alerts_page.dart'; // AlertsPage 추가 import
import 'home_page.dart';
import 'map_page.dart';
import 'history_page.dart';
import 'stats_page.dart';
import 'settings_page.dart';
import 'l10n/app_localizations.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    MapPage(),
    HistoryPage(),
    StatisticsPage(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI APIS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AlertsPage()),
              );
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFFFFBEB),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFFFCBF02),
        unselectedItemColor: const Color(0xFF0C2461),
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: [
          BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: AppLocalizations.of(context)?.home ?? 'Home'),
          BottomNavigationBarItem(
              icon: const Icon(Icons.map),
              label: AppLocalizations.of(context)?.map ?? 'Map'),
          BottomNavigationBarItem(
              icon: const Icon(Icons.history),
              label: AppLocalizations.of(context)?.history ?? 'History'),
          BottomNavigationBarItem(
              icon: const Icon(Icons.bar_chart),
              label: AppLocalizations.of(context)?.stats ?? 'Statistics'),
          BottomNavigationBarItem(
              icon: const Icon(Icons.settings),
              label: AppLocalizations.of(context)?.settings ?? 'Settings'),
        ],
      ),
    );
  }
}
