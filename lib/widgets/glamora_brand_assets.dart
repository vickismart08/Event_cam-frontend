import 'package:flutter/material.dart';

import '../config/app_brand.dart';
import '../theme/app_colors.dart';

/// Full wordmark for nav / hero (default PNG [AppBrand.logoWordmarkAsset]).
///
/// Uses height-driven scaling so the artwork fills the bar (no tiny mark inside
/// an oversized box). [maxWidth] caps horizontal space; the image keeps aspect ratio.
///
/// Pass [asset] to override the default wordmark PNG.
///
/// Web: always pass a positive [maxWidth] so layout stays stable before decode.
class GlamoraWordmark extends StatelessWidget {
  const GlamoraWordmark({
    super.key,
    this.height = 44,
    this.maxWidth = 340,
    this.asset,
  });

  final double height;
  final double maxWidth;

  /// PNG path under `assets/branding/`. Defaults to [AppBrand.logoWordmarkAsset].
  final String? asset;

  @override
  Widget build(BuildContext context) {
    final path = asset ?? AppBrand.logoWordmarkAsset;
    return Semantics(
      label: AppBrand.displayName,
      child: SizedBox(
        height: height,
        width: maxWidth,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Image.asset(
            path,
            height: height,
            fit: BoxFit.fitHeight,
            alignment: Alignment.centerLeft,
            filterQuality: FilterQuality.high,
            gaplessPlayback: true,
            errorBuilder: (context, error, stackTrace) => _TextFallback(height: height),
          ),
        ),
      ),
    );
  }
}

/// Compact circular icon (transparent PNG — no background, no crop).
class GlamoraIconMark extends StatelessWidget {
  const GlamoraIconMark({super.key, this.size = 32});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppBrand.displayName,
      child: Image.asset(
        AppBrand.logoIconAsset,
        width: size,
        height: size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        isAntiAlias: true,
        gaplessPlayback: true,
        errorBuilder: (context, error, stackTrace) =>
            Icon(Icons.photo_camera_rounded, size: size, color: AppColors.primary),
      ),
    );
  }
}

/// App bar row: icon + title (short labels or long text like event names).
class GlamoraAppBarTitle extends StatelessWidget {
  const GlamoraAppBarTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const GlamoraIconMark(size: 32),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _TextFallback extends StatelessWidget {
  const _TextFallback({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          AppBrand.displayName,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
        ),
      ),
    );
  }
}
