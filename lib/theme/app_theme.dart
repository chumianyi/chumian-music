import 'package:flutter/material.dart';

class AppTheme {
  static const Color bgColor = Color(0xFFE0E5EC);
  static const Color accentMint = Color(0xFFA8D8B9);
  static const Color accentBlue = Color(0xFFB8D4E8);
  static const Color textPrimary = Color(0xFF4A4A4A);
  static const Color textSecondary = Color(0xFF8A8A8A);

  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: bgColor,
    primaryColor: accentMint,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: textPrimary),
      bodyMedium: TextStyle(color: textPrimary),
      titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
    ),
    colorScheme: ColorScheme.fromSeed(seedColor: accentMint, brightness: Brightness.light),
    useMaterial3: true,
  );
}

class NeuBox extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool pressed;
  final Color? color;
  const NeuBox({super.key, required this.child, this.borderRadius = 16, this.padding, this.pressed = false, this.color});
  @override
  Widget build(BuildContext context) {
    final baseColor = color ?? AppTheme.bgColor;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: pressed
            ? [BoxShadow(color: Colors.white.withOpacity(0.8), offset: const Offset(-2, -2), blurRadius: 6),
               BoxShadow(color: Colors.black.withOpacity(0.1), offset: const Offset(2, 2), blurRadius: 6)]
            : [BoxShadow(color: Colors.white.withOpacity(0.9), offset: const Offset(-4, -4), blurRadius: 10),
               BoxShadow(color: Colors.black.withOpacity(0.15), offset: const Offset(4, 4), blurRadius: 10)],
      ),
      child: child,
    );
  }
}

class NeuButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Color? color;
  const NeuButton({super.key, required this.child, required this.onPressed, this.borderRadius = 12, this.padding = const EdgeInsets.all(12), this.color});
  @override
  State<NeuButton> createState() => _NeuButtonState();
}

class _NeuButtonState extends State<NeuButton> {
  bool _isPressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) { setState(() => _isPressed = false); widget.onPressed(); },
      onTapCancel: () => setState(() => _isPressed = false),
      child: NeuBox(pressed: _isPressed, borderRadius: widget.borderRadius, padding: widget.padding, color: widget.color, child: widget.child),
    );
  }
}
