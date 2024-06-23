import 'package:flutter/material.dart';
import 'package:prototype_ss/provider/theme_provider.dart';
import 'package:provider/provider.dart';

class GeneratingTextAnimation extends StatefulWidget {
  @override
  const GeneratingTextAnimation(
    {
      super.key
    }
  );
  _GeneratingTextAnimationState createState() => _GeneratingTextAnimationState();
}

class _GeneratingTextAnimationState extends State<GeneratingTextAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).theme;
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, Widget? child) {
        final index = (_controller.value * 4).floor() % 4; // Four frames: 0, 1, 2, 3
        String text = 'Generating' + '.' * index;
        return Text(
          text, 
          textAlign: TextAlign.center,
        style: 
        TextStyle(
          fontSize: 24,
          color: theme.colorScheme.onPrimary
          ));
      },
    );
  }
}