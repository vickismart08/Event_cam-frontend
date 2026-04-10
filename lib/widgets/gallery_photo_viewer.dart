import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../models/event_record.dart';
import '../utils/download_image_service.dart';

/// Full-screen gallery: swipe between photos, pinch-zoom. Details live behind the info action.
class GalleryPhotoViewer extends StatefulWidget {
  const GalleryPhotoViewer({
    super.key,
    required this.photos,
    required this.initialIndex,
    this.eventTitle,
  });

  final List<ApprovedPhoto> photos;
  final int initialIndex;
  final String? eventTitle;

  @override
  State<GalleryPhotoViewer> createState() => _GalleryPhotoViewerState();
}

class _GalleryPhotoViewerState extends State<GalleryPhotoViewer> {
  late final PageController _pageController;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, widget.photos.length - 1);
    _pageController = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  ApprovedPhoto get _current => widget.photos[_index];

  Future<void> _downloadCurrent() async {
    final outcome = await downloadImageService.downloadSingle(
      _current,
      eventTitle: widget.eventTitle,
    );
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    if (outcome.successCount > 0) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Download started.')),
      );
      return;
    }
    messenger.showSnackBar(
      SnackBar(content: Text(outcome.message ?? 'Download failed.')),
    );
  }

  Future<void> _showInfoSheet() async {
    final photos = widget.photos;
    final total = photos.length;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: _PhotoInfoContent(
              photo: _current,
              index: _index,
              total: total,
              eventTitle: widget.eventTitle,
              onDownload: () async {
                Navigator.of(ctx).pop();
                await _downloadCurrent();
              },
              onShare: () async {
                Navigator.of(ctx).pop();
                await SharePlus.instance.share(
                  ShareParams(
                    text: _current.imageUrl,
                    subject: widget.eventTitle ?? 'Photo',
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final photos = widget.photos;
    final total = photos.length;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: total,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) {
              final url = photos[i].imageUrl;
              return InteractiveViewer(
                minScale: 0.5,
                maxScale: 4,
                child: Center(
                  child: Image.network(
                    url,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return SizedBox(
                        height: 200,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            color: Colors.white70,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => const Padding(
                      padding: EdgeInsets.all(32),
                      child: Icon(Icons.broken_image_outlined, color: Colors.white54, size: 64),
                    ),
                  ),
                ),
              );
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ViewerIconButton(
                    icon: Icons.close_rounded,
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  _ViewerIconButton(
                    icon: Icons.info_outline_rounded,
                    tooltip: 'Photo details',
                    onPressed: _showInfoSheet,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Subtle circular hit target so controls stay readable on any photo.
class _ViewerIconButton extends StatelessWidget {
  const _ViewerIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.35),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: IconButton(
        tooltip: tooltip,
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }
}

class _PhotoInfoContent extends StatelessWidget {
  const _PhotoInfoContent({
    required this.photo,
    required this.index,
    required this.total,
    required this.onDownload,
    required this.onShare,
    this.eventTitle,
  });

  final ApprovedPhoto photo;
  final int index;
  final int total;
  final VoidCallback onDownload;
  final VoidCallback onShare;
  final String? eventTitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (eventTitle != null && eventTitle!.isNotEmpty) ...[
          Text(
            eventTitle!,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
        ],
        Text(
          'Photo ${index + 1} of $total',
          style: theme.textTheme.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
        ),
        if (photo.caption != null && photo.caption!.trim().isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Caption', style: theme.textTheme.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text(photo.caption!.trim(), style: theme.textTheme.bodyLarge),
        ],
        if (photo.uploadedAt != null) ...[
          const SizedBox(height: 12),
          Text(
            _formatDate(photo.uploadedAt!),
            style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
        ..._fileNameSection(theme, cs),
        const SizedBox(height: 20),
        FilledButton.tonalIcon(
          onPressed: onDownload,
          icon: const Icon(Icons.download_rounded),
          label: const Text('Download'),
        ),
        const SizedBox(height: 10),
        FilledButton.tonalIcon(
          onPressed: onShare,
          icon: const Icon(Icons.ios_share_rounded),
          label: const Text('Share'),
        ),
      ],
    );
  }

  static String _formatDate(DateTime d) {
    final local = d.toLocal();
    final y = local.year;
    final mo = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final h = local.hour.toString().padLeft(2, '0');
    final mi = local.minute.toString().padLeft(2, '0');
    return 'Added $y-$mo-$day · $h:$mi';
  }

  /// Last path segment (e.g. `photo_abc.jpg`), not the full URL.
  static String _storedImageName(String imageUrl) {
    try {
      final uri = Uri.parse(imageUrl);
      if (uri.pathSegments.isNotEmpty) {
        return Uri.decodeComponent(uri.pathSegments.last);
      }
    } catch (_) {}
    final trimmed = imageUrl.trim();
    if (trimmed.isEmpty) return '—';
    final slash = trimmed.lastIndexOf('/');
    if (slash >= 0 && slash < trimmed.length - 1) {
      return Uri.decodeComponent(trimmed.substring(slash + 1));
    }
    return trimmed;
  }

  List<Widget> _fileNameSection(ThemeData theme, ColorScheme cs) {
    var name = _storedImageName(photo.imageUrl);
    if (name == '—' || name.isEmpty) {
      name = photo.id;
    }
    if (name.isEmpty) return [];
    return [
      const SizedBox(height: 16),
      Text('Image', style: theme.textTheme.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
      const SizedBox(height: 4),
      SelectableText(
        name,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
      ),
    ];
  }
}
