
import 'package:audioplayers/audioplayers.dart';

class SoundManager {
  SoundManager._internal();
  static final SoundManager instance = SoundManager._internal();

  final AudioPlayer _bgPlayer = AudioPlayer();
  // Opcional: pool simple para SFX (no imprescindible ahora)
  // final List<AudioPlayer> _sfxPool = [];

  Future<void> playBackground(String assetPath, {double volume = 1.0}) async {
    try {
      await _bgPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgPlayer.setVolume(volume);
      // assetPath debe ser relativo a assets/ (por ejemplo "audio/music.mp3")
      await _bgPlayer.play(AssetSource(assetPath));
    } catch (e) {}
  }

  Future<void> stopBackground() async {
    try {
      await _bgPlayer.stop();
    } catch (e) {}
  }

  Future<void> pauseBackground() async {
    try {
      await _bgPlayer.pause();
    } catch (e) {}
  }

  Future<void> setBackgroundVolume(double v) async {
    try {
      await _bgPlayer.setVolume(v.clamp(0.0, 1.0));
    } catch (e) {}
  }

  // Reproducir sfx corto (fire-and-forget, crea un player temporal)
  Future<void> playSfx(String assetPath) async {
    try {
      final p = AudioPlayer();
      p.onPlayerComplete.listen((_) {
        try {
          p.dispose();
        } catch (_) {}
      });
      await p.setReleaseMode(ReleaseMode.stop);
      await p.play(AssetSource(assetPath));
    } catch (e) {}
  }
}