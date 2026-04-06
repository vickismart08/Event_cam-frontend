/// Extracts event [joinSlug] from pasted guest URLs or raw codes.
class GuestLinkParser {
  GuestLinkParser._();

  static final _slug = RegExp(r'^[a-zA-Z0-9_-]+$');

  /// Returns slug if [input] is a valid guest link, path `/e/slug`, or raw slug.
  static String? parseSlug(String input) {
    final t = input.trim();
    if (t.isEmpty) return null;

    if (_slug.hasMatch(t) && !t.contains('/')) {
      return t;
    }

    Uri? uri = Uri.tryParse(t);
    if (uri != null && uri.hasScheme && uri.host.isNotEmpty) {
      final fromPath = _slugFromPathSegments(uri.pathSegments);
      if (fromPath != null) return fromPath;
    }

    if (t.contains('/')) {
      final normalized = t.startsWith('/') ? t : '/$t';
      uri = Uri.tryParse('https://placeholder.com$normalized');
      if (uri != null) {
        final fromPath = _slugFromPathSegments(uri.pathSegments);
        if (fromPath != null) return fromPath;
      }
    }

    return null;
  }

  static String? _slugFromPathSegments(List<String> segments) {
    final segs = segments.where((s) => s.isNotEmpty).toList();
    final i = segs.indexOf('e');
    if (i < 0 || i + 1 >= segs.length) return null;
    final s = segs[i + 1];
    return _slug.hasMatch(s) ? s : null;
  }
}
