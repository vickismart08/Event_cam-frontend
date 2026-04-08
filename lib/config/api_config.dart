/// Base URL for the Event Camshot API (Express + Firebase Admin).
///
/// Production (Render): `https://event-cam-backend.onrender.com`
///
/// Local backend override:
/// `flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:3000`
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://event-cam-backend.onrender.com',
  );
}
