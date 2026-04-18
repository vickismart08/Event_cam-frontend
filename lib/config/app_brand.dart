/// User-visible product name (stores, browser tab, in-app chrome).
class AppBrand {
  AppBrand._();

  static const String displayName = 'Glamora';

  /// Horizontal lockup (PNG uses transparency; no white plate behind the mark).
  static const String logoWordmarkAsset = 'assets/branding/logobg.png';

  /// Square mark for app bars, favicons, small UI (no separate bg asset).
  static const String logoIconAsset = 'assets/branding/glamora_logo_icon.png';

  static String get copyrightLine => '© ${DateTime.now().year} $displayName';
}
