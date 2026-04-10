import 'package:flutter/material.dart';

import '../models/event_record.dart';
import '../theme/app_colors.dart';
import 'gallery_photo_viewer.dart';
import 'responsive_container.dart';

class EventGalleryGrid extends StatelessWidget {
  const EventGalleryGrid({
    super.key,
    required this.photos,
    this.eventTitle,
    this.crossAxisCount,
    this.selectionMode = false,
    this.selectedPhotoIds = const <String>{},
    this.onToggleSelection,
  });

  final List<ApprovedPhoto> photos;
  final String? eventTitle;

  /// Defaults to a classic gallery: up to 4 columns on wider screens.
  final int? crossAxisCount;
  final bool selectionMode;
  final Set<String> selectedPhotoIds;
  final ValueChanged<ApprovedPhoto>? onToggleSelection;

  void _openViewer(BuildContext context, int index) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => GalleryPhotoViewer(
          photos: photos,
          initialIndex: index,
          eventTitle: eventTitle,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final count = crossAxisCount ?? ResponsiveContainer.galleryCrossAxisCount(w);

    if (photos.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Text('No photos yet.', style: TextStyle(color: AppColors.textSecondary)),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: count,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        // Slightly taller than wide — typical photo-thumb proportion in album grids.
        childAspectRatio: 0.92,
      ),
      itemCount: photos.length,
      itemBuilder: (context, i) {
        final photo = photos[i];
        final url = photo.imageUrl;
        return Material(
          color: AppColors.border.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(10),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              if (selectionMode) {
                onToggleSelection?.call(photo);
                return;
              }
              _openViewer(context, i);
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  url,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          value: progress.expectedTotalBytes != null
                              ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.border,
                    child: const Icon(Icons.broken_image_outlined, color: AppColors.textSecondary),
                  ),
                ),
                // Tap affordance (gallery-style overlay)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.45),
                          ],
                        ),
                      ),
                      child: const SizedBox(height: 36),
                    ),
                  ),
                ),
                if (selectionMode)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Icon(
                          selectedPhotoIds.contains(photo.id)
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked_rounded,
                          color: selectedPhotoIds.contains(photo.id)
                              ? AppColors.primary
                              : Colors.white70,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
