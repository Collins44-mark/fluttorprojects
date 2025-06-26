import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Enhanced Bottom Nav',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const BottomNavBar(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _currentIndex = 0;

  // Enhanced screens with rows
  final List<Widget> _screens = [
    // Home Screen
    SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Text('Home Content', style: TextStyle(fontSize: 24)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: 100,
                height: 100,
                color: Colors.blue,
                child: const Icon(Icons.star, color: Colors.white),
              ),
              Container(
                width: 100,
                height: 100,
                color: Colors.green,
                child: const Icon(Icons.favorite, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: () {}, child: const Text('Action 1')),
              const SizedBox(width: 20),
              ElevatedButton(onPressed: () {}, child: const Text('Action 2')),
            ],
          ),
        ],
      ),
    ),

    // Search Screen
    SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Text('Search Content', style: TextStyle(fontSize: 24)),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const SizedBox(width: 10),
                Chip(label: const Text('Flutter')),
                const SizedBox(width: 10),
                Chip(label: const Text('Dart')),
                const SizedBox(width: 10),
                Chip(label: const Text('UI')),
                const SizedBox(width: 10),
                Chip(label: const Text('Mobile')),
              ],
            ),
          ),
        ],
      ),
    ),

    // Profile Screen
    Column(
      children: [
        const SizedBox(height: 40),
        const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
        const SizedBox(height: 20),
        const Text('User Profile', style: TextStyle(fontSize: 24)),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                const Text(
                  'Posts',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Text('42'),
                ),
              ],
            ),
            const SizedBox(width: 30),
            Column(
              children: [
                const Text(
                  'Following',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Text('128'),
                ),
              ],
            ),
            const SizedBox(width: 30),
            Column(
              children: [
                const Text(
                  'Followers',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple[100],
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Text('89'),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enhanced Bottom Nav')),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
