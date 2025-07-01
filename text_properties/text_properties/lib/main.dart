import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Text Animation ',
      home: TextAnimationScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TextAnimationScreen extends StatefulWidget {
  const TextAnimationScreen({super.key});

  @override
  State<TextAnimationScreen> createState() => _TextAnimationScreenState();
}

class _TextAnimationScreenState extends State<TextAnimationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _sizeAnimation;
  late Animation<Color?> _colorAnimation;

  double _fontSize = 24.0;
  Color _textColor = Colors.blue;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    // Size animation (scaling)
    _sizeAnimation = Tween<double>(
      begin: 1.0,
      end: 1.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Color animation (optional)
    _colorAnimation = ColorTween(
      begin: Colors.blue,
      end: Colors.red,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Text Animation & Properties')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // **Animated Text**
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: _sizeAnimation.value,
                  child: Text(
                    'Flutter is Awesome!',
                    style: TextStyle(
                      fontSize: _fontSize,
                      color: _textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 40),

            // **Font Size Slider**
            Slider(
              value: _fontSize,
              min: 16,
              max: 48,
              onChanged: (value) {
                setState(() {
                  _fontSize = value;
                });
              },
            ),
            const Text('Adjust Font Size'),

            const SizedBox(height: 20),

            // **Color Selection Buttons**
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildColorButton(Colors.red),
                _buildColorButton(Colors.blue),
                _buildColorButton(Colors.green),
                _buildColorButton(Colors.purple),
              ],
            ),
            const Text('Change Text Color'),
          ],
        ),
      ),
    );
  }

  // Helper function for color selection buttons
  Widget _buildColorButton(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _textColor = color;
        });
      },
      child: Container(
        width: 40,
        height: 40,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: _textColor == color
              ? Border.all(color: Colors.black, width: 2)
              : null,
        ),
      ),
    );
  }
}
