import 'package:flutter/material.dart';

class NeuTheme {
  static const Color background = Color(0xFFE0E5EC);
  static const Color accent = Color(0xFF6B8E7F);
  static const Color accentLight = Color(0xFFA8C5B8);
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF7C8BA0);

  static const List<BoxShadow> raisedShadows = [
    BoxShadow(color: Color(0xFFFFFFFF), blurRadius: 10, offset: Offset(-5, -5)),
    BoxShadow(color: Color(0xFFA3B1C6), blurRadius: 10, offset: Offset(5, 5)),
  ];

  static const List<BoxShadow> insetShadows = [
    BoxShadow(color: Color(0xFFA3B1C6), blurRadius: 6, offset: Offset(3, 3), spreadRadius: 1),
    BoxShadow(color: Color(0xFFFFFFFF), blurRadius: 6, offset: Offset(-3, -3), spreadRadius: 1),
  ];
}

class NeuCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final bool inset;

  const NeuCard({super.key, required this.child, this.onTap, this.padding, this.borderRadius, this.inset = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: NeuTheme.background,
          borderRadius: borderRadius ?? BorderRadius.circular(16),
          boxShadow: inset ? NeuTheme.insetShadows : NeuTheme.raisedShadows,
        ),
        child: child,
      ),
    );
  }
}

class NeuButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double size;
  final bool pressed;

  const NeuButton({super.key, required this.child, this.onPressed, this.size = 48, this.pressed = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(
          color: NeuTheme.background,
          shape: BoxShape.circle,
          boxShadow: pressed ? NeuTheme.insetShadows : NeuTheme.raisedShadows,
        ),
        child: Center(child: child),
      ),
    );
  }
}
