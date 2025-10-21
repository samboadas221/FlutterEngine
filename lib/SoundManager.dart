
// lib/SoundManager.dart
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:soundpool/soundpool.dart';

/// SoundManager híbrido:
/// - Usa AudioPlayer (audioplayers) para la música de fondo (persistent player).
/// - Usa Soundpool para SFX (baja latencia, no roba audio focus).
///
/// Requisitos:
/// - Dependencia en pubspec.yaml: soundpool: ^2.1.0
///
/// API:
///   SoundManager.instance.playBackground('audio/music.mp3');
///   SoundManager.instance.playSfx('audio/click.wav');
///   SoundManager.instance.pauseBackground();
///   SoundManager.instance.stopBackground();
///   SoundManager.instance.setBackgroundVolume(0.5);
///   SoundManager.instance.disposeAll();

class SoundManager {
  SoundManager._internal();
  static final SoundManager instance = SoundManager._internal();

  // --- BG music player (audioplayers) ---
  AudioPlayer? _bgPlayer;

  // --- SoundPool for SFX ---
  final Soundpool _soundpool = Soundpool(streamType: StreamType.notification);
  final Map<String, int> _soundIdCache = {}; // assetPath -> soundId

  /// Reproduce o cambia la música de fondo.
  /// assetPath: ruta relativa en assets/ (ej. 'audio/music.mp3' o 'audio/song1.m4a')
  Future<void> playBackground(String assetPath, {double volume = 1.0}) async {
    try {
      _bgPlayer ??= AudioPlayer();
      await _bgPlayer!.setReleaseMode(ReleaseMode.loop);
      await _bgPlayer!.setVolume(volume.clamp(0.0, 1.0));
      // En audioplayers, AssetSource espera "audio/file.ext" si assets/ fue declarado.
      await _bgPlayer!.play(AssetSource(assetPath));
    } catch (e) {
      // No romper la app por errores de audio
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
  // SFX (usando Soundpool)
  // -----------------------
  /// Reproduce un efecto de sonido. Usa Soundpool (baja latencia,
  /// no roba audio focus en Android en la mayoría de dispositivos).
  ///
  /// assetPath: ruta relativa dentro de assets/, por ejemplo 'audio/click.mp3'
  Future<void> playSfx(String assetPath, {int? loop = 0, double? rate}) async {
    try {
      if (assetPath.isEmpty) return;

      // Si ya cargamos ese asset, usamos el id cached
      int? soundId = _soundIdCache[assetPath];
      if (soundId == null) {
        // Cargar bytes desde assets
        final bytes = await rootBundle.load('assets/$assetPath');
        final uint8list = bytes.buffer.asUint8List();
        soundId = await _soundpool.loadUint8List(uint8list);
        _soundIdCache[assetPath] = soundId;
      }

      if (soundId != null) {
        // loop: 0 => play once, -1 => loop forever (Soundpool behavior)
        // rate: playback rate (1.0 normal). Soundpool expects int sample rate speed 0..100?
        // soundpool uses 'play' with optional 'repeat' and 'rate' in some implementations
        await _soundpool.play(soundId, repeat: loop ?? 0, rate: rate ?? 1.0);
      }
    } catch (e) {
      // no romper por fallos de SFX
    }
  }

  /// Opcional: libera recursos cargados de SFX (no hace stop de bg)
  Future<void> unloadAllSfx() async {
    try {
      for (var entry in _soundIdCache.entries) {
        try {
          await _soundpool.release(entry.value);
        } catch (_) {}
      }
      _soundIdCache.clear();
    } catch (_) {}
  }

  /// Libera todos los recursos (SFX + background).
  Future<void> disposeAll() async {
    try {
      await unloadAllSfx();
      try {
        await _bgPlayer?.stop();
        await _bgPlayer?.dispose();
      } catch (_) {}
      _bgPlayer = null;
      try {
        await _soundpool.release();
      } catch (_) {}
    } catch (_) {}
  }
}