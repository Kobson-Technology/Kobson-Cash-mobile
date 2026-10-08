class AppConfig {
  // Configured exclusively via compile-time environment: flutter run --dart-define=API_BASE_URL=https://...
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://apicash.runasp.net',
  );

  static const String appName = 'Kobson Cash';
  static const String appTagline = 'GÉREZ • PARRAINEZ • GAGNEZ';
  static const String currencySymbol = 'FCFA';

  static const String appVersion = '2.0.1';
  static const int appBuildNumber = 3;
  static const String fallbackDownloadUrl =
      'https://github.com/Kobson-Technology/Kobson-Cash-Versionnage/releases/download/v2.0.1/KobsonCash.apk';
}
