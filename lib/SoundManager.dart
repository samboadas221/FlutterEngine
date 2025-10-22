
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart'; // Para debugPrint, opcional

// SoundManager incorporado directamente en este archivo para simplicidad
class SoundManager {
  // Lista de todos los jugadores activos
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal();

  final List<AudioPlayer> _activePlayers = [];

  /// Reproduce un sonido desde un asset local (ej: 'sounds/disparo.mp3').
  /// Crea una nueva instancia cada vez para permitir superposición.
  /// Si loop es true, no se libera automáticamente al terminar.
  Future<void> playAsset(String assetPath, {double volume = 1.0, bool loop = false}) async {
    try {
      // Crea un nuevo jugador siempre
      final AudioPlayer player = AudioPlayer();

      // Configura el modo de loop si es necesario
      if (loop) {
        await player.setReleaseMode(ReleaseMode.loop);
      }

      // Configura el volumen
      await player.setVolume(volume);

      // Listener para liberar recursos al completar (solo si no es loop)
      if (!loop) {
        player.onPlayerComplete.listen((_) {
          _disposePlayer(player);
        });
      }

      // Agrega a la lista de activos
      _activePlayers.add(player);

      // Reproduce
      await player.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint('Error reproduciendo asset $assetPath: $e');
    }
  }

  /// Reproduce un sonido desde una URL remota (ej: 'https://example.com/disparo.mp3').
  /// Similar a playAsset, crea nueva instancia cada vez.
  Future<void> playUrl(String url, {double volume = 1.0, bool loop = false}) async {
    try {
      final AudioPlayer player = AudioPlayer();

      if (loop) {
        await player.setReleaseMode(ReleaseMode.loop);
      }

      await player.setVolume(volume);

      if (!loop) {
        player.onPlayerComplete.listen((_) {
          _disposePlayer(player);
        });
      }

      _activePlayers.add(player);

      await player.play(UrlSource(url));
    } catch (e) {
      debugPrint('Error reproduciendo URL $url: $e');
    }
  }

  /// Detiene todos los sonidos y libera recursos.
  Future<void> stopAll() async {
    for (var player in List.from(_activePlayers)) { // Copia para evitar modificaciones concurrentes
      await player.stop();
      await player.dispose();
    }
    _activePlayers.clear();
  }

  // Método privado para liberar un jugador específico
  void _disposePlayer(AudioPlayer player) {
    player.dispose();
    _activePlayers.remove(player);
  }

  /// Libera todos los recursos cuando ya no necesites el manager (ej: en dispose de un widget).
  void dispose() {
    stopAll();
  }
}