import 'package:flutter/material.dart';
class AnimationCustom extends StatefulWidget {
  @override
  _AnimationCustomState createState() => _AnimationCustomState();
}

class _AnimationCustomState extends State<AnimationCustom> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
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
      builder: (context, child) {
        return Container(
          width: 200 * (1 + _controller.value),
          height: 200 * (1 + _controller.value),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red.withOpacity(0.5 * (1 - _controller.value)),
          ),
        );
      },
    );
  }

}