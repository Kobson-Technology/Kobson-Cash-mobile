import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

import '../config/app_config.dart';

/// Informations renvoyées par la connexion Google native.
class GoogleAccountInfo {
  final String? idToken;
  final String email;
  final String? displayName;

  const GoogleAccountInfo({
    required this.email,
    this.idToken,
    this.displayName,
  });
}

/// Connexion Google réelle (google_sign_in).
///
/// L'application ne collecte plus aucun mot de passe Google : le flux natif
/// Google Play Services renvoie un ID token OpenID Connect, que le backend
/// vérifie cryptographiquement (signature, audience, expiration).
class GoogleSignInService {
  static bool _initialized = false;

  static Future<void> _ensureInitialized() async {
    if (_initialized) return;

    // Le web (PWA) n'utilise pas Google : l'authentification y est e-mail / mot de passe.
    // Cette garde évite toute tentative d'initialisation sur le web.
    if (kIsWeb) {
      throw UnsupportedError(
        'La connexion Google n\'est pas disponible sur le web. '
        'Utilisez votre adresse e-mail et votre mot de passe.',
      );
    }

    final serverClientId = AppConfig.googleServerClientId.trim();
    if (serverClientId.isEmpty) {
      throw Exception(
        'GOOGLE_SERVER_CLIENT_ID non configuré. '
        'Recompilez avec --dart-define=GOOGLE_SERVER_CLIENT_ID=<Web Client ID>.',
      );
    }

    await GoogleSignIn.instance.initialize(serverClientId: serverClientId);
    _initialized = true;
  }

  /// Lance le sélecteur de compte Google natif et retourne le compte choisi.
  static Future<GoogleAccountInfo> signIn() async {
    await _ensureInitialized();

    final account = await GoogleSignIn.instance.authenticate();

    return GoogleAccountInfo(
      idToken: account.authentication.idToken,
      email: account.email,
      displayName: account.displayName,
    );
  }

  /// Lance la connexion Google et retourne uniquement l'ID token (pour le login).
  static Future<String?> signInAndGetIdToken() async {
    final info = await signIn();
    return info.idToken;
  }
}
