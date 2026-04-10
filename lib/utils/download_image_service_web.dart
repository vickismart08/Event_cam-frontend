// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:http/http.dart' as http;

import '../models/event_record.dart';
import 'download_image_service.dart';

DownloadImageService createDownloadImageService() => _WebDownloadImageService();

class _WebDownloadImageService implements DownloadImageService {
  @override
  Future<DownloadOutcome> downloadSingle(ApprovedPhoto photo, {String? eventTitle}) async {
    final fileName = _photoFileName(photo, eventTitle: eventTitle, index: 1);
    _triggerBrowserDownload(photo.imageUrl, fileName);
    return const DownloadOutcome(requestedCount: 1, successCount: 1);
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
        final name = _photoFileName(p, eventTitle: eventTitle, index: i + 1);
        archive.addFile(ArchiveFile(name, bytes.length, Uint8List.fromList(bytes)));
        success++;
      } catch (_) {
        // Continue with other files.
      }
    }

    if (success == 0) {
      return DownloadOutcome(
        requestedCount: photos.length,
        successCount: 0,
        message: 'Could not fetch images for ZIP (check CORS/public access).',
      );
    }

    final zipBytes = ZipEncoder().encode(archive);

    final safeEvent = _sanitizeBase(eventTitle ?? 'event');
    final timestamp = DateTime.now().toIso8601String().split('T').first;
    final finalZipName = zipName ?? '${safeEvent}_gallery_$timestamp.zip';
    final blob = html.Blob([zipBytes], 'application/zip');
    final blobUrl = html.Url.createObjectUrlFromBlob(blob);
    _triggerBrowserDownload(blobUrl, finalZipName, revokeUrlAfter: true);

    return DownloadOutcome(requestedCount: photos.length, successCount: success);
  }

  void _triggerBrowserDownload(String href, String downloadName, {bool revokeUrlAfter = false}) {
    final anchor = html.AnchorElement(href: href)
      ..download = downloadName
      ..style.display = 'none';
    html.document.body?.append(anchor);
    anchor.click();
    anchor.remove();
    if (revokeUrlAfter) {
      html.Url.revokeObjectUrl(href);
    }
  }

  static String _photoFileName(
    ApprovedPhoto photo, {
    String? eventTitle,
    required int index,
  }) {
    final fromUrl = _lastSegment(photo.imageUrl);
    var ext = '.jpg';
    if (fromUrl.contains('.')) {
      ext = '.${fromUrl.split('.').last.toLowerCase()}';
    }
    final baseEvent = _sanitizeBase(eventTitle ?? 'event');
    final idx = index.toString().padLeft(3, '0');
    return '${baseEvent}_$idx$ext';
  }

  static String _lastSegment(String url) {
    try {
      final u = Uri.parse(url);
      if (u.pathSegments.isNotEmpty) return Uri.decodeComponent(u.pathSegments.last);
    } catch (_) {}
    return 'photo.jpg';
  }

  static String _sanitizeBase(String value) {
    final lower = value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '-');
    final safe = lower.replaceAll(RegExp(r'[^a-z0-9._-]'), '');
    return safe.isEmpty ? 'event' : safe;
  }
}
