import 'package:flutter/material.dart';

class ThinkingDots extends StatefulWidget {
  const ThinkingDots({super.key});

  @override
  State<ThinkingDots> createState() => ThinkingDotsState();
}

class ThinkingDotsState extends State<ThinkingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? _) {
        final int dots = (_controller.value * 3).floor() + 1;
        return Text(
          '正在思考中${'.' * dots}',
          style: const TextStyle(
            color: Color(0xFF9FA5B3),
            fontSize: 15,
            height: 1.55,
            fontStyle: FontStyle.italic,
          ),
        );
      },
    );
  }
}
