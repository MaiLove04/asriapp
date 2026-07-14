class AppConfig {
  static const String baseUrl =
  String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://simpasdaa.one-babel.my.id/api',
  );
}