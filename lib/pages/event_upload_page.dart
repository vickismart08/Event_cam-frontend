import 'dart:async';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../api/api_client.dart';
import '../theme/app_colors.dart';
import '../widgets/app_buttons.dart';
import '../widgets/responsive_container.dart';
import '../widgets/soft_card.dart';

class EventUploadPage extends StatefulWidget {
  const EventUploadPage({
    super.key,
    this.slug,
    this.eventTitle = '',
    this.eventDateLabel,
    this.welcomeMessage,
  });

  final String? slug;
  final String eventTitle;
  final String? eventDateLabel;
  final String? welcomeMessage;

  @override
  State<EventUploadPage> createState() => _EventUploadPageState();
}

class _PreviewItem {
  _PreviewItem({required this.bytes, required this.name});
  final Uint8List bytes;
  final String name;
}

class _EventUploadPageState extends State<EventUploadPage> {
  final _guestName = TextEditingController();
  final _caption = TextEditingController();
  final List<_PreviewItem> _previews = [];
  var _dragging = false;
  var _uploading = false;
  var _progress = 0.0;
  var _showSuccess = false;
  Timer? _successTimer;

  String? _loadedTitle;
  String? _loadedDateLabel;
  String? _loadedWelcome;
  var _loadingMeta = false;
  var _loadError = false;

  @override
  void initState() {
    super.initState();
    if (widget.slug != null) {
      _loadingMeta = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadPublicEvent());
    } else {
      _loadedTitle = widget.eventTitle;
      _loadedDateLabel = widget.eventDateLabel;
      _loadedWelcome = widget.welcomeMessage;
    }
  }

  @override
  void dispose() {
    _guestName.dispose();
    _caption.dispose();
    _successTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadPublicEvent() async {
    final slug = widget.slug;
    if (slug == null) return;
    try {
      final raw = await ApiClient.get('/api/public/events/by-slug/$slug') as Map<String, dynamic>;
      _loadedTitle = raw['title'] as String?;
      final starts = raw['startsAt'] as String?;
      if (starts != null) {
        final d = DateTime.parse(starts);
        _loadedDateLabel = _formatEventDate(d);
      }
      _loadedWelcome = raw['description'] as String?;
    } catch (_) {
      _loadError = true;
    } finally {
      if (mounted) setState(() => _loadingMeta = false);
    }
  }

  String _formatEventDate(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  Future<void> _pickFiles() async {
    final r = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: kIsWeb,
    );
    if (r == null) return;
    await _addPlatformFiles(r.files);
  }

  Future<void> _addPlatformFiles(List<PlatformFile> files) async {
    for (final f in files) {
      final b = f.bytes;
      if (b == null) continue;
      setState(() {
        _previews.add(_PreviewItem(bytes: b, name: f.name));
      });
    }
  }

  Future<void> _onDrop(DropDoneDetails details) async {
    for (final f in details.files) {
      if (f is DropItemDirectory) continue;
      final b = await f.readAsBytes();
      setState(() => _previews.add(_PreviewItem(bytes: b, name: f.name)));
    }
  }

  Future<void> _upload() async {
    final slug = widget.slug;
    if (slug == null || _previews.isEmpty) return;

    setState(() {
      _uploading = true;
      _progress = 0;
    });

    try {
      final files = <http.MultipartFile>[];
      for (var i = 0; i < _previews.length; i++) {
        final p = _previews[i];
        files.add(
          http.MultipartFile.fromBytes(
            'files',
            p.bytes,
            filename: p.name,
          ),
        );
      }

      final fields = <String, String>{
        if (_guestName.text.trim().isNotEmpty) 'guestName': _guestName.text.trim(),
        if (_caption.text.trim().isNotEmpty) 'caption': _caption.text.trim(),
      };

      await ApiClient.postMultipartPublic(
        '/api/public/events/by-slug/$slug/upload',
        files: files,
        fields: fields,
      );

      if (!mounted) return;
      setState(() {
        _uploading = false;
        _progress = 1;
        _previews.clear();
        _showSuccess = true;
      });
      _successTimer?.cancel();
      _successTimer = Timer(const Duration(seconds: 4), () {
        if (mounted) setState(() => _showSuccess = false);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _uploading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingMeta) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (widget.slug != null && _loadError) {
      return Scaffold(
        appBar: AppBar(title: const Text('Event')),
        body: const Center(child: Text('Event not found or API unavailable.')),
      );
    }

    final title = _loadedTitle ?? widget.eventTitle;
    final dateLabel = _loadedDateLabel ?? widget.eventDateLabel;
    final welcome = _loadedWelcome ?? widget.welcomeMessage;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(title.isEmpty ? 'Upload photos' : title),
      ),
      body: ResponsiveContainer(
        maxWidth: 560,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 40),
          children: [
            if (dateLabel != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(dateLabel, style: TextStyle(color: AppColors.textSecondary)),
              ),
            if (welcome != null && welcome.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(welcome),
              ),
            TextField(
              controller: _guestName,
              decoration: const InputDecoration(
                labelText: 'Your name (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _caption,
              decoration: const InputDecoration(
                labelText: 'Caption (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            DropTarget(
              onDragEntered: (_) => setState(() => _dragging = true),
              onDragExited: (_) => setState(() => _dragging = false),
              onDragDone: (d) {
                setState(() => _dragging = false);
                _onDrop(d);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _dragging ? AppColors.primary : AppColors.border,
                    width: 2,
                  ),
                  color: _dragging ? AppColors.primary.withValues(alpha: 0.05) : AppColors.surface,
                ),
                child: Column(
                  children: [
                    const Icon(Icons.cloud_upload_outlined, size: 40),
                    const SizedBox(height: 8),
                    const Text('Drop photos here or pick files'),
                    const SizedBox(height: 12),
                    SecondaryOutlinedButton(
                      label: 'Choose files',
                      icon: Icons.folder_open,
                      onPressed: _pickFiles,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_previews.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _previews.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final p = _previews[i];
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(p.bytes, width: 100, height: 100, fit: BoxFit.cover),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () => setState(() => _previews.removeAt(i)),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            if (_uploading) LinearProgressIndicator(value: _progress > 0 ? _progress : null),
            const SizedBox(height: 20),
            PrimaryAppButton(
              label: _uploading ? 'Uploading…' : 'Upload',
              onPressed: (_uploading || _previews.isEmpty || widget.slug == null) ? null : _upload,
              minimumSize: const Size(double.infinity, 48),
            ),
            if (_showSuccess)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: SoftCard(
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green.shade700),
                      const SizedBox(width: 12),
                      const Expanded(child: Text('Thanks! Your photos were submitted.')),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
