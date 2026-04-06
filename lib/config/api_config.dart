/// Base URL for the Event Camshot API (Express + Firebase Admin).
///
/// Override at build time:
/// `flutter run -d chrome --dart-define=API_BASE_URL=https://api.example.com`
class ApiConfig {
  ApiConfig._();

  /// Use 127.0.0.1 by default — on some systems `localhost` hits IPv6 first and misses Node.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:3000',
  );
}
