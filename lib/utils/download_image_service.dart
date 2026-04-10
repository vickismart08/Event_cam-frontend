import '../models/event_record.dart';
import 'download_image_service_stub.dart'
    if (dart.library.html) 'download_image_service_web.dart'
    if (dart.library.io) 'download_image_service_io.dart';

class DownloadOutcome {
  const DownloadOutcome({
    required this.requestedCount,
    required this.successCount,
    this.message,
  });

  final int requestedCount;
  final int successCount;
  final String? message;

  bool get allSucceeded => successCount == requestedCount;
}

abstract class DownloadImageService {
  Future<DownloadOutcome> downloadSingle(ApprovedPhoto photo, {String? eventTitle});

  Future<DownloadOutcome> downloadMany(
    List<ApprovedPhoto> photos, {
    String? eventTitle,
    String? zipName,
  });
}

final DownloadImageService downloadImageService = createDownloadImageService();
