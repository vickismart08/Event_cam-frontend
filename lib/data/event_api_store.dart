import 'package:flutter/foundation.dart';

import '../api/api_client.dart';
import '../models/event_record.dart';

final EventApiStore eventApiStore = EventApiStore();

class EventApiStore extends ChangeNotifier {
  List<EventRecord> _events = [];
  final Map<String, EventRecord> _byId = {};

  List<EventRecord> eventsFor(String? ownerEmail) {
    if (ownerEmail == null) return [];
    return List.unmodifiable(_events);
  }

  EventRecord? event(String ownerEmail, String eventId) {
    return _byId[eventId] ?? _tryFind(eventId);
  }

  EventRecord? _tryFind(String id) {
    for (final e in _events) {
      if (e.id == id) return e;
    }
    return null;
  }

  void _put(EventRecord e) {
    _byId[e.id] = e;
    final i = _events.indexWhere((x) => x.id == e.id);
    if (i >= 0) {
      _events[i] = e;
    } else {
      _events.insert(0, e);
    }
    _events.sort((a, b) {
      final ta = a.startsAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final tb = b.startsAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return tb.compareTo(ta);
    });
    notifyListeners();
  }

  void _remove(String id) {
    _events.removeWhere((e) => e.id == id);
    _byId.remove(id);
    notifyListeners();
  }

  Future<void> loadDashboard() async {
    final raw = await ApiClient.get('/api/events') as List<dynamic>;
    _events = raw
        .map((e) => EventRecord.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    _byId
      ..clear()
      ..addEntries(_events.map((e) => MapEntry(e.id, e)));
    notifyListeners();
  }

  Future<EventRecord?> loadEvent(String eventId) async {
    try {
      final raw = await ApiClient.get('/api/events/$eventId') as Map<String, dynamic>;
      final e = EventRecord.fromJson(raw);
      _put(e);
      return e;
    } catch (_) {
      return null;
    }
  }

  Future<EventRecord?> createEvent({
    required String title,
    DateTime? startsAt,
    String? venue,
    String description = '',
    bool moderationEnabled = true,
  }) async {
    final raw = await ApiClient.postJson('/api/events', {
      'title': title,
      if (startsAt != null) 'startsAt': startsAt.toIso8601String(),
      if (venue != null && venue.isNotEmpty) 'venue': venue,
      'description': description,
      'moderationEnabled': moderationEnabled,
    }) as Map<String, dynamic>;
    final e = EventRecord.fromJson(raw);
    _put(e);
    return e;
  }

  Future<void> updateEventPatch(String eventId, Map<String, dynamic> patch) async {
    final raw = await ApiClient.patchJson('/api/events/$eventId', patch) as Map<String, dynamic>;
    _put(EventRecord.fromJson(raw));
  }

  Future<void> deleteEvent(String eventId) async {
    await ApiClient.delete('/api/events/$eventId');
    _remove(eventId);
  }

  Future<void> approvePending(String eventId, String pendingId) async {
    final raw = await ApiClient.postJson(
      '/api/events/$eventId/photos/$pendingId/approve',
      <String, dynamic>{},
    ) as Map<String, dynamic>;
    _put(EventRecord.fromJson(raw));
  }

  Future<void> rejectPending(String eventId, String pendingId) async {
    final raw = await ApiClient.postJson(
      '/api/events/$eventId/photos/$pendingId/reject',
      <String, dynamic>{},
    ) as Map<String, dynamic>;
    _put(EventRecord.fromJson(raw));
  }

  Future<void> removeApprovedPhoto(String eventId, String photoId) async {
    final raw = await ApiClient.deleteJson('/api/events/$eventId/photos/$photoId') as Map<String, dynamic>;
    _put(EventRecord.fromJson(raw));
  }
}
