class AppConfig {
  static const String baseUrl =
  String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://10.73.72.144:8000/api',
  );
}