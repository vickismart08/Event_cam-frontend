import 'package:flutter/material.dart';

import '../models/event_record.dart';
import '../theme/app_colors.dart';
import 'soft_card.dart';

class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.event,
    required this.onOpen,
    this.onShare,
  });

  final EventRecord event;
  final VoidCallback onOpen;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    final date = event.startsAt;
    final dateStr = date != null ? '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}' : 'Date TBD';

    return SoftCard(
      onTap: onOpen,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  event.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (onShare != null)
                IconButton(
                  onPressed: onShare,
                  icon: const Icon(Icons.ios_share_rounded),
                  tooltip: 'Share',
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(dateStr, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          if (event.venue != null && event.venue!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(event.venue!, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ],
        ],
      ),
    );
  }
}
