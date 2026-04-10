import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';

import '../models/event_record.dart';
import 'download_image_service.dart';

DownloadImageService createDownloadImageService() => _IoDownloadImageService();

class _IoDownloadImageService implements DownloadImageService {
  @override
  Future<DownloadOutcome> downloadSingle(ApprovedPhoto photo, {String? eventTitle}) async {
    try {
      final resp = await http.get(Uri.parse(photo.imageUrl));
      if (resp.statusCode >= 400) {
        return const DownloadOutcome(
          requestedCount: 1,
          successCount: 0,
          message: 'Failed to fetch image.',
        );
      }
      final fileName = _fileName(photo, eventTitle: eventTitle, index: 1);
      await SharePlus.instance.share(
        ShareParams(
          text: 'Save image',
          files: [
            XFile.fromData(
              resp.bodyBytes,
              mimeType: 'image/jpeg',
              name: fileName,
            ),
          ],
        ),
      );
      return const DownloadOutcome(requestedCount: 1, successCount: 1);
    } catch (_) {
      return const DownloadOutcome(
        requestedCount: 1,
        successCount: 0,
        message: 'Could not download image.',
      );
    }
  }

  @override
  Future<DownloadOutcome> downloadMany(
    List<ApprovedPhoto> photos, {
    String? eventTitle,
    String? zipName,
  }) async {
    if (photos.isEmpty) {
      return const DownloadOutcome(requestedCount: 0, successCount: 0, message: 'No photos selected.');
    }
    if (photos.length == 1) {
      return downloadSingle(photos.first, eventTitle: eventTitle);
    }

    final archive = Archive();
    var success = 0;
    for (var i = 0; i < photos.length; i++) {
      final p = photos[i];
      try {
        final resp = await http.get(Uri.parse(p.imageUrl));
        if (resp.statusCode >= 400) continue;
        final bytes = resp.bodyBytes;
        archive.addFile(ArchiveFile(_fileName(p, eventTitle: eventTitle, index: i + 1), bytes.length, Uint8List.fromList(bytes)));
        success++;
      } catch (_) {}
    }
    if (success == 0) {
      return DownloadOutcome(
        requestedCount: photos.length,
        successCount: 0,
        message: 'Could not fetch images.',
      );
    }
    final zip = ZipEncoder().encode(archive);
    final safe = _sanitize(eventTitle ?? 'event');
    final ts = DateTime.now().toIso8601String().split('T').first;
    final archiveName = zipName ?? '${safe}_gallery_$ts.zip';
    await SharePlus.instance.share(
      ShareParams(
        text: 'Gallery export',
        files: [XFile.fromData(Uint8List.fromList(zip), mimeType: 'application/zip', name: archiveName)],
      ),
    );
    return DownloadOutcome(requestedCount: photos.length, successCount: success);
  }

  String _fileName(ApprovedPhoto p, {String? eventTitle, required int index}) {
    final safe = _sanitize(eventTitle ?? 'event');
    final ext = _extensionFromUrl(p.imageUrl);
    return '${safe}_${index.toString().padLeft(3, '0')}$ext';
  }

  String _extensionFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      if (uri.pathSegments.isNotEmpty) {
        final name = uri.pathSegments.last.toLowerCase();
        if (name.contains('.')) {
          return '.${name.split('.').last}';
        }
      }
    } catch (_) {}
    return '.jpg';
  }

  String _sanitize(String v) {
    final lower = v.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '-');
    final safe = lower.replaceAll(RegExp(r'[^a-z0-9._-]'), '');
    return safe.isEmpty ? 'event' : safe;
  }
}
