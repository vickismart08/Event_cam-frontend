import 'package:flutter/material.dart';

import '../models/event_record.dart';
import '../theme/app_colors.dart';
import 'responsive_container.dart';

class EventGalleryGrid extends StatelessWidget {
  const EventGalleryGrid({
    super.key,
    required this.photos,
    this.crossAxisCount,
  });

  final List<ApprovedPhoto> photos;
  final int? crossAxisCount;

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
        childAspectRatio: 1,
      ),
      itemCount: photos.length,
      itemBuilder: (context, i) {
        final url = photos[i].imageUrl;
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: AppColors.border,
              child: const Icon(Icons.broken_image_outlined),
            ),
          ),
        );
      },
    );
  }
}
