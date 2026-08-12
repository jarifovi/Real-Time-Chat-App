import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class Gravity3DCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final Color? backgroundColor;

  const Gravity3DCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.onTap,
    this.backgroundColor,
  });

  @override
  State<Gravity3DCard> createState() => _Gravity3DCardState();
}

class _Gravity3DCardState extends State<Gravity3DCard> {
  double _rotateX = 0.0;
  double _rotateY = 0.0;
  bool _isHovered = false;

  void _onPointerMove(PointerEvent details, Size cardSize) {
    final dx = details.localPosition.dx - cardSize.width / 2;
    final dy = details.localPosition.dy - cardSize.height / 2;

    setState(() {
      _rotateX = (-dy / (cardSize.height / 2)) * 0.12; // 3D tilt max ~7 degrees
      _rotateY = (dx / (cardSize.width / 2)) * 0.12;
      _isHovered = true;
    });
  }

  void _resetTilt() {
    setState(() {
      _rotateX = 0.0;
      _rotateY = 0.0;
      _isHovered = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = widget.borderRadius ?? BorderRadius.circular(26);

    return Container(
      margin: widget.margin ?? const EdgeInsets.only(bottom: 14),
      child: MouseRegion(
        onExit: (_) => _resetTilt(),
        child: Listener(
          onPointerMove: (event) {
            final renderBox = context.findRenderObject() as RenderBox?;
            if (renderBox != null) {
              _onPointerMove(event, renderBox.size);
            }
          },
          onPointerUp: (_) => _resetTilt(),
          child: GestureDetector(
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001) // 3D perspective
                ..rotateX(_rotateX)
                ..rotateY(_rotateY)
                ..scaleByDouble(_isHovered ? 1.025 : 1.0, _isHovered ? 1.025 : 1.0, 1.0, 1.0),
              transformAlignment: Alignment.center,
              padding: widget.padding ?? const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: widget.backgroundColor ??
                    AppTheme.surfaceColor.withValues(alpha: 0.88),
                borderRadius: effectiveRadius,
                border: Border.all(
                  color: _isHovered
                      ? AppTheme.primaryColor.withValues(alpha: 0.85)
                      : Colors.white.withValues(alpha: 0.1),
                  width: _isHovered ? 1.8 : 1.0,
                ),
                boxShadow: _isHovered
                    ? AppTheme.glowingOrbShadows
                    : AppTheme.gravity3dShadows,
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
