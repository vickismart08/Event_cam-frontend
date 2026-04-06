// Domain models for events (API-backed).

class ApprovedPhoto {
  const ApprovedPhoto({required this.id, required this.imageUrl});

  final String id;
  final String imageUrl;

  factory ApprovedPhoto.fromJson(Map<String, dynamic> j) {
    return ApprovedPhoto(
      id: j['id'] as String,
      imageUrl: j['imageUrl'] as String,
    );
  }
}

class PendingUpload {
  PendingUpload({
    required this.id,
    required this.imageUrl,
    required this.submittedAt,
    this.caption,
    this.guestName,
  });

  final String id;
  final String imageUrl;
  final DateTime submittedAt;
  final String? caption;
  final String? guestName;

  factory PendingUpload.fromJson(Map<String, dynamic> j) {
    return PendingUpload(
      id: j['id'] as String,
      imageUrl: j['imageUrl'] as String,
      submittedAt: DateTime.parse(j['submittedAt'] as String),
      caption: j['caption'] as String?,
      guestName: j['guestName'] as String?,
    );
  }
}

class EventRecord {
  EventRecord({
    required this.id,
    required this.title,
    required this.joinSlug,
    this.startsAt,
    this.venue,
    this.description = '',
    this.moderationEnabled = true,
    List<ApprovedPhoto>? approvedPhotos,
    List<PendingUpload>? pendingUploads,
    this.guestLinkClicks = 0,
    this.qrScans = 0,
  })  : approvedPhotos = approvedPhotos ?? [],
        pendingUploads = pendingUploads ?? [];

  final String id;
  String title;
  DateTime? startsAt;
  String? venue;
  String description;
  bool moderationEnabled;
  final String joinSlug;
  List<ApprovedPhoto> approvedPhotos;
  final List<PendingUpload> pendingUploads;

  List<String> get approvedImageUrls =>
      approvedPhotos.map((e) => e.imageUrl).toList(growable: false);

  int get approvedCount => approvedPhotos.length;
  int get pendingCount => pendingUploads.length;

  String get guestUploadPath => '/e/$joinSlug';

  int guestLinkClicks;
  int qrScans;

  factory EventRecord.fromJson(Map<String, dynamic> j) {
    final List<ApprovedPhoto> approved;
    if (j['approvedPhotos'] != null) {
      approved = (j['approvedPhotos'] as List<dynamic>)
          .map((e) => ApprovedPhoto.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } else if (j['approvedImageUrls'] != null) {
      final urls = (j['approvedImageUrls'] as List<dynamic>).map((e) => e as String).toList();
      approved = [
        for (var i = 0; i < urls.length; i++)
          ApprovedPhoto(id: 'legacy_$i', imageUrl: urls[i]),
      ];
    } else {
      approved = [];
    }

    final pendingRaw = j['pendingUploads'] as List<dynamic>? ?? [];
    final pending = pendingRaw
        .map((e) => PendingUpload.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    return EventRecord(
      id: j['id'] as String,
      title: j['title'] as String,
      joinSlug: j['joinSlug'] as String,
      startsAt: j['startsAt'] != null ? DateTime.parse(j['startsAt'] as String) : null,
      venue: j['venue'] as String?,
      description: j['description'] as String? ?? '',
      moderationEnabled: j['moderationEnabled'] as bool? ?? true,
      approvedPhotos: approved,
      pendingUploads: pending,
      guestLinkClicks: (j['guestLinkClicks'] as num?)?.toInt() ?? 0,
      qrScans: (j['qrScans'] as num?)?.toInt() ?? 0,
    );
  }
}
