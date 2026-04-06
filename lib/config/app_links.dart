/// Public URLs for guest join links and QR codes.
///
/// `flutter build web --dart-define=PUBLIC_APP_URL=https://your-domain.com`
class AppLinks {
  AppLinks._();

  static String baseUrl() {
    const env = String.fromEnvironment('PUBLIC_APP_URL');
    if (env.isNotEmpty) {
      return env.replaceAll(RegExp(r'/+$'), '');
    }
    final o = Uri.base.origin;
    if (o.isEmpty) return 'https://eventcamshot.app';
    return o;
  }

  static String guestJoinUrl(String joinSlug) => '${baseUrl()}/e/$joinSlug';
}
