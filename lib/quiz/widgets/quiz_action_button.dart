import 'package:flutter/material.dart';

class QuizActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final bool isPrimary;

  const QuizActionButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    this.isPrimary = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    );
    const padding = EdgeInsets.symmetric(vertical: 16, horizontal: 20);

    if (isPrimary) {
      return FilledButton.icon(
        style: FilledButton.styleFrom(
          padding: padding,
          shape: shape,
        ),
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      );
    }

    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white70,
        padding: padding,
        side: const BorderSide(color: Colors.white24),
        shape: shape,
      ),
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}
