class AppConfig {
  // Configured exclusively via compile-time environment: flutter run --dart-define=API_BASE_URL=https://...
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://apicash.runasp.net',
  );

  static const String appName = 'Kobson Cash';
  static const String appTagline = 'GÉREZ • PARRAINEZ • GAGNEZ';
  static const String currencySymbol = 'FCFA';
}
