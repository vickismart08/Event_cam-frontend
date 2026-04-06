import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class PrimaryAppButton extends StatelessWidget {
  const PrimaryAppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.minimumSize = const Size(120, 48),
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Size minimumSize;

  @override
  Widget build(BuildContext context) {
    final style = FilledButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      minimumSize: minimumSize,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
    if (icon != null) {
      return FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(label),
        style: style,
      );
    }
    return FilledButton(
      onPressed: onPressed,
      style: style,
      child: Text(label),
    );
  }
}

class SecondaryOutlinedButton extends StatelessWidget {
  const SecondaryOutlinedButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.minimumSize = const Size(120, 48),
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Size minimumSize;

  @override
  Widget build(BuildContext context) {
    final style = OutlinedButton.styleFrom(
      minimumSize: minimumSize,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
    if (icon != null) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(label),
        style: style,
      );
    }
    return OutlinedButton(
      onPressed: onPressed,
      style: style,
      child: Text(label),
    );
  }
}
