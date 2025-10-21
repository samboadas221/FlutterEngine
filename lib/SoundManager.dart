
// lib/SoundManager.dart
import 'package:audioplayers/audioplayers.dart';

/// SoundManager robusto para proyectos Flutter usando audioplayers 6.x.
/// - _bgPlayer: reproductor persistente para música de fondo.
/// - _sfxPool: pool de reproductores para efectos (SFX), con marca de uso.
/// - playSfx crea reproductores temporales si el pool está lleno.
/// - Evita llamadas a APIs no disponibles en la versión 6.x.
class SoundManager {
  SoundManager._internal();
  static final SoundManager instance = SoundManager._internal();

  // --- Música de fondo ---
  AudioPlayer? _bgPlayer;

  // --- Pool de SFX ---
  final List<AudioPlayer> _sfxPool = [];
  final Set<AudioPlayer> _sfxInUse = {};
  final int _maxPoolSize = 6; // ajustable según necesidades

  // -----------------------
  // MÚSICA DE FONDO
  // -----------------------
  /// Reproduce o cambia la música de fondo.
  /// assetPath: ruta relativa dentro de assets/ (ej: "audio/music.mp3")
  Future<void> playBackground(String assetPath, {double volume = 1.0}) async {
    try {
      _bgPlayer ??= AudioPlayer();
      await _bgPlayer!.setReleaseMode(ReleaseMode.loop);
      await _bgPlayer!.setVolume(volume.clamp(0.0, 1.0));
      await _bgPlayer!.play(AssetSource(assetPath));
    } catch (e) {
      // No romper la app por fallos de audio
    }
  }

  Future<void> stopBackground() async {
    try {
      await _bgPlayer?.stop();
    } catch (e) {}
  }

  Future<void> pauseBackground() async {
    try {
      await _bgPlayer?.pause();
    } catch (e) {}
  }

  Future<void> resumeBackground() async {
    try {
      await _bgPlayer?.resume();
    } catch (e) {}
  }

  Future<void> setBackgroundVolume(double v) async {
    try {
      await _bgPlayer?.setVolume(v.clamp(0.0, 1.0));
    } catch (e) {}
  }

  // -----------------------
  // SFX (efectos), pool
  // -----------------------
  /// Reproduce un efecto de sonido (fire-and-forget).
  /// Usa un pool para evitar crear/destruir demasiados AudioPlayers.
  Future<void> playSfx(String assetPath) async {
    try {
      AudioPlayer? player;
      bool isTemporary = false;

      // Buscar un player disponible en el pool (no en uso)
      for (var p in _sfxPool) {
        if (!_sfxInUse.contains(p)) {
          player = p;
          break;
        }
      }

      if (player == null) {
        if (_sfxPool.length < _maxPoolSize) {
          // Crear y añadir al pool
          player = AudioPlayer();
          _sfxPool.add(player);
          // Registrar listener que marca libre cuando termine (solo una vez)
          player.onPlayerComplete.listen((_) {
            // marca como no en uso si estaba marcado
            try {
              _sfxInUse.remove(player);
              // aseguramos que no esté reproduciendo
              player?.stop();
            } catch (_) {}
          });
        } else {
          // Pool lleno -> crear player temporal que se destruirá al terminar
          player = AudioPlayer();
          isTemporary = true;
        }
      }

      // Marcar en uso si es parte del pool
      if (!isTemporary) {
        _sfxInUse.add(player!);
      }

      // Preparar y reproducir
      await player!.setReleaseMode(ReleaseMode.stop);
      await player.play(AssetSource(assetPath));

      if (isTemporary) {
        // Liberar cuando termine (para temporales)
        player.onPlayerComplete.listen((_) async {
          try {
            await player?.stop();
            await player?.dispose();
          } catch (_) {}
        });
      }
      // Si es del pool, el listener registrado previamente se encargará de
      // marcarlo como no en uso al terminar (no lo disposa para reutilizar).
    } catch (e) {
      // Ignorar errores de reproducción SFX
    }
  }

  // Opcional: libera todos los recursos
  Future<void> disposeAll() async {
    try {
      for (var p in _sfxPool) {
        try {
          await p.stop();
          await p.dispose();
        } catch (_) {}
      }
      _sfxPool.clear();
      _sfxInUse.clear();
      try {
        await _bgPlayer?.stop();
        await _bgPlayer?.dispose();
      } catch (_) {}
      _bgPlayer = null;
    } catch (_) {}
  }
}