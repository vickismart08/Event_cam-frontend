import '../models/event_record.dart';
import 'download_image_service.dart';

DownloadImageService createDownloadImageService() => _UnsupportedDownloadService();

class _UnsupportedDownloadService implements DownloadImageService {
  @override
  Future<DownloadOutcome> downloadMany(
    List<ApprovedPhoto> photos, {
    String? eventTitle,
    String? zipName,
  }) async {
    return DownloadOutcome(
      requestedCount: photos.length,
      successCount: 0,
      message: 'Downloads are not supported on this platform yet.',
    );
  }

  @override
  Future<DownloadOutcome> downloadSingle(ApprovedPhoto photo, {String? eventTitle}) async {
    return const DownloadOutcome(
      requestedCount: 1,
      successCount: 0,
      message: 'Downloads are not supported on this platform yet.',
    );
  }
}
