import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Layout Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LayoutDemoScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LayoutDemoScreen extends StatelessWidget {
  const LayoutDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Layout Widgets Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Example 1: Row with Expanded widgets
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: ColoredBox(
                      color: Colors.red,
                      child: SizedBox(
                        height: 100,
                        child: Center(child: Text('Expanded (flex: 2)')),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: ColoredBox(
                      color: Colors.green,
                      child: SizedBox(
                        height: 100,
                        child: Center(child: Text('Expanded (flex: 3)')),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: ColoredBox(
                      color: Colors.blue,
                      child: SizedBox(
                        height: 100,
                        child: Center(child: Text('Expanded (flex: 1)')),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Example 2: Column with Containers
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Container(
                    height: 60,
                    color: Colors.amber[100],
                    alignment: Alignment.center,
                    child: const Text('Container 1'),
                  ),
                  Container(
                    height: 80,
                    color: Colors.amber[200],
                    alignment: Alignment.center,
                    child: const Text('Container 2'),
                  ),
                  Container(
                    height: 40,
                    color: Colors.amber[300],
                    alignment: Alignment.center,
                    child: const Text('Container 3'),
                  ),
                ],
              ),
            ),

            // Example 3: Nested Row and Column
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.purple),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Nested Layout'),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 120,
                          color: Colors.purple[100],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                color: Colors.white,
                              ),
                              const Text('Column in Row'),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 120,
                          color: Colors.purple[200],
                          child: const Center(child: Text('Expanded in Row')),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
