import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BottomNav + Tabs Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int _currentBottomIndex = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentBottomIndex == 0
          ? AppBar(
              title: const Text('Home with Tabs'),
              bottom: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(icon: Icon(Icons.star), text: 'Featured'),
                  Tab(icon: Icon(Icons.favorite), text: 'Favorites'),
                  Tab(icon: Icon(Icons.notifications), text: 'Alerts'),
                ],
              ),
            )
          : null,

      body: _getCurrentScreen(),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentBottomIndex,
        onTap: (index) => setState(() => _currentBottomIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _getCurrentScreen() {
    switch (_currentBottomIndex) {
      case 0:
        return TabBarView(
          controller: _tabController,
          children: const [
            Center(child: Text('Featured Content')),
            Center(child: Text('Your Favorites')),
            Center(child: Text('Notification Alerts')),
          ],
        );
      case 1:
        return const Center(child: Text('Search Screen'));
      case 2:
        return const Center(child: Text('Profile Screen'));
      default:
        return const Center(child: Text('Home Screen'));
    }
  }
}
