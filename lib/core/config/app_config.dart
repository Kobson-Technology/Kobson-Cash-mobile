class AppConfig {
  // Configured exclusively via compile-time environment: flutter run --dart-define=API_BASE_URL=https://...
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://apicash.runasp.net',
  );

  static const String appName = 'Kobson Cash';
  static const String appTagline = 'GÉREZ • PARRAINEZ • GAGNEZ';
  static const String currencySymbol = 'FCFA';

  /// Identifiant OAuth 2.0 « Web » (serverClientId) requis par Google Sign-In.
  /// Injecté à la compilation : --dart-define=GOOGLE_SERVER_CLIENT_ID=xxxx.apps.googleusercontent.com
  static const String googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue: '',
  );

  static const String appVersion = '2.3.4';
  static const int appBuildNumber = 16;
  static const String fallbackDownloadUrl =
      'https://github.com/Kobson-Technology/Kobson-Cash-Versionnage/releases/download/v2.3.4/KobsonCash.apk';
}
