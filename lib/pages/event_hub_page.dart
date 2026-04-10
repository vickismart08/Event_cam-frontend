import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../config/app_links.dart';
import '../data/event_api_store.dart';
import '../models/event_record.dart';
import '../theme/app_colors.dart';
import '../utils/download_image_service.dart';
import '../widgets/app_buttons.dart';
import '../widgets/copy_link_field.dart';
import '../widgets/event_gallery_grid.dart';
import '../widgets/guest_qr_card.dart';
import '../widgets/responsive_container.dart';
import '../widgets/soft_card.dart';
import 'event_editor_page.dart';

class EventHubPage extends StatefulWidget {
  const EventHubPage({
    super.key,
    required this.ownerEmail,
    required this.eventId,
    this.initialTab = 0,
  });

  final String ownerEmail;
  final String eventId;
  final int initialTab;

  @override
  State<EventHubPage> createState() => _EventHubPageState();
}

class _EventHubPageState extends State<EventHubPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  var _loading = true;

  @override
  void initState() {
    super.initState();
    final i = widget.initialTab.clamp(0, 4);
    _tabController = TabController(length: 5, vsync: this, initialIndex: i);
    _load();
  }

  Future<void> _load() async {
    await eventApiStore.loadEvent(widget.eventId);
    if (!mounted) return;
    setState(() => _loading = false);
    final e = eventApiStore.event(widget.ownerEmail, widget.eventId);
    if (e == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).maybePop();
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _guestUrl(EventRecord e) => AppLinks.guestJoinUrl(e.joinSlug);

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return ListenableBuilder(
      listenable: eventApiStore,
      builder: (context, _) {
        final e = eventApiStore.event(widget.ownerEmail, widget.eventId);
        if (e == null) {
          return const Scaffold(body: Center(child: Text('Event not found.')));
        }

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(e.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            actions: [
              IconButton(
                tooltip: 'Edit event',
                onPressed: () {
                  Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (_) => EventEditorPage(eventId: e.id),
                    ),
                  );
                },
                icon: const Icon(Icons.edit_outlined),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Gallery'),
                Tab(text: 'Review'),
                Tab(text: 'Share'),
                Tab(text: 'Settings'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _OverviewTab(event: e, guestUrl: _guestUrl(e)),
              _GalleryTab(event: e),
              _ReviewTab(event: e),
              _ShareTab(event: e, guestUrl: _guestUrl(e)),
              _SettingsTab(event: e),
            ],
          ),
        );
      },
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.event, required this.guestUrl});

  final EventRecord event;
  final String guestUrl;

  @override
  Widget build(BuildContext context) {
    return ResponsiveContainer(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          Text('Overview', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title, style: Theme.of(context).textTheme.titleLarge),
                if (event.eventType != null && event.eventType!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    event.eventType!,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
                if (event.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(event.description, style: TextStyle(color: AppColors.textSecondary)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          CopyLinkField(label: 'Guest upload link', value: guestUrl),
        ],
      ),
    );
  }
}

class _GalleryTab extends StatefulWidget {
  const _GalleryTab({required this.event});

  final EventRecord event;

  @override
  State<_GalleryTab> createState() => _GalleryTabState();
}

class _GalleryTabState extends State<_GalleryTab> {
  final Set<String> _selected = <String>{};
  var _selectionMode = false;
  var _downloading = false;

  void _toggleSelected(ApprovedPhoto photo) {
    setState(() {
      if (_selected.contains(photo.id)) {
        _selected.remove(photo.id);
      } else {
        _selected.add(photo.id);
      }
    });
  }

  Future<void> _downloadAll() async {
    await _downloadPhotos(widget.event.approvedPhotos, zipName: '${widget.event.joinSlug}_all.zip');
  }

  Future<void> _downloadSelected() async {
    final chosen = widget.event.approvedPhotos.where((p) => _selected.contains(p.id)).toList();
    if (chosen.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select photos first.')),
      );
      return;
    }
    await _downloadPhotos(chosen, zipName: '${widget.event.joinSlug}_selected.zip');
  }

  Future<void> _downloadPhotos(List<ApprovedPhoto> photos, {String? zipName}) async {
    if (_downloading) return;
    setState(() => _downloading = true);
    final outcome = await downloadImageService.downloadMany(
      photos,
      eventTitle: widget.event.title,
      zipName: zipName,
    );
    if (!mounted) return;
    setState(() => _downloading = false);
    final messenger = ScaffoldMessenger.of(context);
    if (outcome.successCount > 0) {
      final suffix = outcome.allSucceeded ? '' : ' (${outcome.successCount}/${outcome.requestedCount})';
      messenger.showSnackBar(SnackBar(content: Text('Download started$suffix.')));
      return;
    }
    messenger.showSnackBar(
      SnackBar(content: Text(outcome.message ?? 'Download failed.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveContainer(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          Text('Gallery', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.tonalIcon(
                onPressed: _downloading ? null : _downloadAll,
                icon: _downloading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.download_rounded),
                label: const Text('Download all'),
              ),
              FilledButton.tonalIcon(
                onPressed: _downloading
                    ? null
                    : () => setState(() {
                          _selectionMode = !_selectionMode;
                          if (!_selectionMode) _selected.clear();
                        }),
                icon: Icon(_selectionMode ? Icons.close_rounded : Icons.checklist_rounded),
                label: Text(_selectionMode ? 'Cancel selection' : 'Select photos'),
              ),
              if (_selectionMode)
                FilledButton.tonalIcon(
                  onPressed: _downloading ? null : _downloadSelected,
                  icon: const Icon(Icons.download_for_offline_rounded),
                  label: Text('Download selected (${_selected.length})'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          EventGalleryGrid(
            photos: widget.event.approvedPhotos,
            eventTitle: widget.event.title,
            selectionMode: _selectionMode,
            selectedPhotoIds: _selected,
            onToggleSelection: _toggleSelected,
          ),
        ],
      ),
    );
  }
}

class _ReviewTab extends StatelessWidget {
  const _ReviewTab({required this.event});

  final EventRecord event;

  @override
  Widget build(BuildContext context) {
    final pending = event.pendingUploads;
    if (pending.isEmpty) {
      return const Center(child: Text('Nothing to review.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pending.length,
      itemBuilder: (context, i) {
        final p = pending[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    p.imageUrl,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox(height: 100, child: Icon(Icons.broken_image)),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: () async {
                          await eventApiStore.approvePending(event.id, p.id);
                        },
                        child: const Text('Approve'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          await eventApiStore.rejectPending(event.id, p.id);
                        },
                        child: const Text('Reject'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ShareTab extends StatelessWidget {
  const _ShareTab({required this.event, required this.guestUrl});

  final EventRecord event;
  final String guestUrl;

  @override
  Widget build(BuildContext context) {
    return ResponsiveContainer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Share with guests', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Each event has a unique guest link. Print the QR or share the URL.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            SoftCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.link_rounded, color: AppColors.primary, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Join code', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        SelectableText(
                          event.joinSlug,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: GuestQrCard(
                  data: guestUrl,
                  size: 220,
                  subtitle: 'Guests scan and upload instantly',
                ),
              ),
            ),
            const SizedBox(height: 28),
            CopyLinkField(label: 'Guest upload URL', value: guestUrl),
            const SizedBox(height: 20),
            CopyLinkField(label: 'Short path', value: event.guestUploadPath),
            const SizedBox(height: 24),
            SecondaryOutlinedButton(
              minimumSize: const Size(double.infinity, 48),
              label: 'Share guest link',
              icon: Icons.ios_share_rounded,
              onPressed: () async {
                await SharePlus.instance.share(
                  ShareParams(
                    text: guestUrl,
                    subject: 'Join ${event.title} — upload photos',
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTab extends StatelessWidget {
  const _SettingsTab({required this.event});

  final EventRecord event;

  @override
  Widget build(BuildContext context) {
    return ResponsiveContainer(
      maxWidth: 520,
      child: ListView(
        children: [
          Text('Event settings', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Moderation'),
            subtitle: Text(event.moderationEnabled ? 'On' : 'Off'),
          ),
        ],
      ),
    );
  }
}
