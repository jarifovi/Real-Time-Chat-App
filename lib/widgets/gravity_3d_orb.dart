import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class Gravity3DOrb extends StatefulWidget {
  final double size;
  final Gradient gradient;
  final Offset offset;

  const Gravity3DOrb({
    super.key,
    required this.size,
    required this.gradient,
    required this.offset,
  });

  @override
  State<Gravity3DOrb> createState() => _Gravity3DOrbState();
}

class _Gravity3DOrbState extends State<Gravity3DOrb>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: -15.0, end: 15.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(widget.offset.dx, widget.offset.dy + _animation.value),
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: widget.gradient,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.35),
                  blurRadius: 60,
                  spreadRadius: 20,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
