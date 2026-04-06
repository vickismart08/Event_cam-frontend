import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class ApiException implements Exception {
  ApiException(this.statusCode, this.body);

  final int statusCode;
  final String body;

  @override
  String toString() => 'ApiException($statusCode): $body';
}

/// Thrown when the device cannot open a TCP connection to [baseUrl] (backend down, wrong host, etc.).
class ApiConnectionException implements Exception {
  ApiConnectionException(this.baseUrl, {this.underlying});

  final String baseUrl;
  final Object? underlying;

  @override
  String toString() =>
      'Cannot reach API at $baseUrl${underlying != null ? ' ($underlying)' : ''}';
}

class ApiClient {
  ApiClient._();

  static Future<T> _guard<T>(Future<T> Function() run) async {
    try {
      return await run();
    } on http.ClientException catch (e, st) {
      Error.throwWithStackTrace(
        ApiConnectionException(ApiConfig.baseUrl, underlying: e),
        st,
      );
    }
  }

  static Future<Map<String, String>> _jsonHeaders() async {
    final h = <String, String>{'Content-Type': 'application/json'};
    final u = FirebaseAuth.instance.currentUser;
    if (u != null) {
      final t = await u.getIdToken();
      h['Authorization'] = 'Bearer $t';
    }
    return h;
  }

  static dynamic _decode(http.Response r) {
    if (r.statusCode >= 400) {
      throw ApiException(r.statusCode, r.body);
    }
    if (r.statusCode == 204 || r.body.isEmpty) {
      return null;
    }
    return jsonDecode(r.body) as Object?;
  }

  static Future<Object?> get(String path) async {
    return _guard(() async {
      final r = await http.get(
        Uri.parse('${ApiConfig.baseUrl}$path'),
        headers: await _jsonHeaders(),
      );
      return _decode(r);
    });
  }

  static Future<Object?> postJson(String path, [Object? body]) async {
    return _guard(() async {
      final r = await http.post(
        Uri.parse('${ApiConfig.baseUrl}$path'),
        headers: await _jsonHeaders(),
        body: body == null ? null : jsonEncode(body),
      );
      return _decode(r);
    });
  }

  static Future<Object?> patchJson(String path, Object body) async {
    return _guard(() async {
      final r = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}$path'),
        headers: await _jsonHeaders(),
        body: jsonEncode(body),
      );
      return _decode(r);
    });
  }

  static Future<void> delete(String path) async {
    await _guard(() async {
      final r = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}$path'),
        headers: await _jsonHeaders(),
      );
      _decode(r);
    });
  }

  /// DELETE that returns a JSON body (e.g. updated event).
  static Future<Object?> deleteJson(String path) async {
    return _guard(() async {
      final r = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}$path'),
        headers: await _jsonHeaders(),
      );
      return _decode(r);
    });
  }

  /// Guest upload (no Firebase session required).
  static Future<Object?> postMultipartPublic(
    String path, {
    required List<http.MultipartFile> files,
    Map<String, String> fields = const {},
  }) async {
    return _guard(() async {
      final req = http.MultipartRequest('POST', Uri.parse('${ApiConfig.baseUrl}$path'));
      req.files.addAll(files);
      req.fields.addAll(fields);
      final streamed = await req.send();
      final resp = await http.Response.fromStream(streamed);
      return _decode(resp);
    });
  }

  static Future<void> postStats(String path, {required String type}) async {
    await postJson(path, {'type': type});
  }
}
