import 'package:flutter/material.dart';

class PulsingMarker extends StatefulWidget {
  @override
  _PulsingMarkerState createState() => _PulsingMarkerState();
}

class _PulsingMarkerState extends State<PulsingMarker> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // vẽ vòng tròn pulse ngoài, vòng tròn chính và chấm ở giữa (use AnimatedBuilder)
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Vòng tròn pulse ngoài
            Container(
              width: 20 * (1 + _controller.value),
              height: 20 * (1 + _controller.value),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withOpacity(0.8 * (1 - _controller.value)),
              ),
            ),
            // Vòng tròn chính
            Container(
              width: 15,
              height: 15,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: Colors.blue,
                  width: 2,
                ),
              ),
            ),
            // Chấm ở giữa
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
              ),
            ),
          ],
        );
      },
    );
  }
}