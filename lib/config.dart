class AppConfig {
  static const String baseUrl =
  String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://simpasda.one-babel.my.id/api',
  );
}