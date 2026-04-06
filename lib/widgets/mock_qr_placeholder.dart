import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Decorative QR-style block for marketing (landing) — framed like a real signage card.
class MockQrPlaceholder extends StatelessWidget {
  const MockQrPlaceholder({
    super.key,
    this.size = 180,
    this.showFrame = true,
    this.showCaption = true,
  });

  final double size;
  final bool showFrame;
  final bool showCaption;

  @override
  Widget build(BuildContext context) {
    final qr = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(
        Icons.qr_code_2_rounded,
        size: size * 0.48,
        color: AppColors.textSecondary.withValues(alpha: 0.85),
      ),
    );

    if (!showFrame) return qr;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          qr,
          if (showCaption) ...[
            const SizedBox(height: 14),
            Text(
              'Guests scan and upload instantly',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
