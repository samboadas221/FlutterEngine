
// lib/SoundManager.dart
import 'package:audioplayers/audioplayers.dart';

/// SoundManager simple y robusto.
/// - Reproductor persistente para música de fondo (_bgPlayer).
/// - Pool sencillo para SFX (permite reproducir varios efectos simultáneos).
/// - APIs: playBackground, stopBackground, pauseBackground, resumeBackground,
///   setBackgroundVolume, playSfx.
///
/// Nota: evita importar APIs internas de audioplayers_platform_interface para
/// evitar incompatibilidades en distintos entornos y versiones.
class SoundManager {
  SoundManager._internal();
  static final SoundManager instance = SoundManager._internal();

  // Player para la música de fondo (nullable hasta inicialización)
  AudioPlayer? _bgPlayer;

  // Pool para SFX: reusar players si hay disponibles, evitar crear/destruir demasiado.
  final List<AudioPlayer> _sfxPool = [];
  final int _maxPoolSize = 6; // puedes ajustar según necesidades

  // -----------------------
  // MÚSICA DE FONDO
  // -----------------------
  /// Reproduce o cambia la música de fondo (assetPath relativo a assets/, ej "audio/music.mp3").
  Future<void> playBackground(String assetPath, {double volume = 1.0}) async {
    try {
      // Crear el player si no existe
      _bgPlayer ??= AudioPlayer();
      // Configs: loop y volumen
      await _bgPlayer!.setReleaseMode(ReleaseMode.loop);
      await _bgPlayer!.setVolume(volume.clamp(0.0, 1.0));
      // Reproducir (AssetSource espera ruta relativa a assets/)
      await _bgPlayer!.play(AssetSource(assetPath));
    } catch (e) {
      // No rompemos la app por fallos de audio
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
  /// Reproduce un efecto de sonido (fire-and-forget). Usa un pool para permitir
  /// varios efectos simultáneos sin crear/destruir cientos de AudioPlayers.
  Future<void> playSfx(String assetPath) async {
    try {
      // Buscar un player libre en el pool
      AudioPlayer? player;
      for (var p in _sfxPool) {
        // comprobamos estado; si está detenido o completado lo podemos reutilizar
        final state = await p.getState();
        if (state == PlayerState.stopped || state == PlayerState.completed) {
          player = p;
          break;
        }
      }

      if (player == null) {
        if (_sfxPool.length < _maxPoolSize) {
          player = AudioPlayer();
          _sfxPool.add(player);
        } else {
          // Si pool lleno, creamos uno temporal (no lo añadimos al pool)
          player = AudioPlayer();
        }
      }

      // Aseguramos que el player libere recursos cuando termine (solo para los temporales o si queremos)
      // Si es parte del pool, lo mantenemos para reutilizarlo.
      bool isTemporary = !_sfxPool.contains(player);

      // Preparar y reproducir
      await player.setReleaseMode(ReleaseMode.stop);
      // no await para no bloquear la UI; pero aseguramos que la llamada a play se realice
      await player.play(AssetSource(assetPath));

      if (isTemporary) {
        // Liberar cuando termine
        player.onPlayerComplete.listen((_) async {
          try {
            await player.stop();
            await player.dispose();
          } catch (_) {}
        });
      } else {
        // Si es del pool, dejamos que quede para reutilización; opcionalmente
        // podemos limpiar listeners para evitar duplicados.
        player.onPlayerComplete.listen((_) async {
          try {
            await player.stop();
            // No hacemos dispose para poder reutilizar
          } catch (_) {}
        });
      }
    } catch (e) {
      // no romper la app por errores de audio
    }
  }

  // Opcional: liberar todos los recursos de audio (si necesitas cerrar la app)
  Future<void> disposeAll() async {
    try {
      for (var p in _sfxPool) {
        try {
          await p.stop();
          await p.dispose();
        } catch (_) {}
      }
      _sfxPool.clear();
      try {
        await _bgPlayer?.stop();
        await _bgPlayer?.dispose();
      } catch (_) {}
      _bgPlayer = null;
    } catch (_) {}
  }
}