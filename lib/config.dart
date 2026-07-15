class AppConfig {
  static const String baseUrl =
  String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://simpasdaa.one-babel.my.id/api',
  );
}