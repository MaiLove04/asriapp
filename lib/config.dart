class AppConfig {
  static const String baseUrl =
  String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://pht.my.id/api', // Tambahkan /api di sini
  );
}