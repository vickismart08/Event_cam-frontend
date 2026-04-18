import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Brand (always the same) ──────────────────────────────────────────────
  static const Color primary = Color(0xFFE53935);
  static const Color accent = Color(0xFFFFC107);

  // ── Light palette ────────────────────────────────────────────────────────
  static const Color surface = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF5F6FA);
  static const Color border = Color(0xFFE5E7EB);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);

  // ── Dark palette ─────────────────────────────────────────────────────────
  static const Color darkSurface = Color(0xFF1E1E2A);
  static const Color darkBackground = Color(0xFF13131C);
  static const Color darkBorder = Color(0xFF2E2E3E);
  static const Color darkTextPrimary = Color(0xFFF1F1F3);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);

  // ── Context-aware accessor ───────────────────────────────────────────────
  /// Returns the colour set appropriate for the current [Brightness].
  static _AppColorSet of(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return dark ? _AppColorSet.dark() : _AppColorSet.light();
  }
}

/// Convenience bundle so callers can write `AppColors.of(context).surface`.
class _AppColorSet {
  const _AppColorSet({
    required this.surface,
    required this.background,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
  });

  factory _AppColorSet.light() => const _AppColorSet(
        surface: AppColors.surface,
        background: AppColors.background,
        border: AppColors.border,
        textPrimary: AppColors.textPrimary,
        textSecondary: AppColors.textSecondary,
      );

  factory _AppColorSet.dark() => const _AppColorSet(
        surface: AppColors.darkSurface,
        background: AppColors.darkBackground,
        border: AppColors.darkBorder,
        textPrimary: AppColors.darkTextPrimary,
        textSecondary: AppColors.darkTextSecondary,
      );

  final Color surface;
  final Color background;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
}
