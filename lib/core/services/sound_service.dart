import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class SoundService {
  static final AudioPlayer _player = AudioPlayer();

  /// Joue le carillon triomphal d'or et déclenche le retour haptique
  static Future<void> playUnlockChime() async {
    try {
      // 1. Retour haptique énergique (vibrations de succès)
      await HapticFeedback.heavyImpact();
      Future.delayed(const Duration(milliseconds: 140), () {
        HapticFeedback.mediumImpact();
      });
      Future.delayed(const Duration(milliseconds: 280), () {
        HapticFeedback.heavyImpact();
      });

      // 2. Lecture du son de célébration officiel Kobson Cash
      await _player.stop();
      await _player.play(AssetSource('sounds/gold_unlock.wav'), volume: 1.0);
    } catch (_) {
      // En cas de restriction matérielle ou mode silencieux strict, repli sur le son système
      try {
        await SystemSound.play(SystemSoundType.alert);
      } catch (_) {}
    }
  }

  static void dispose() {
    _player.dispose();
  }
}
