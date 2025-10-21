
import 'package:audioplayers/audioplayers.dart';

class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;

  late final AudioPlayer _bgPlayer;
  late final AudioPlayer _sfxPlayer;
  bool _isBgPlaying = false;

  SoundManager._internal() {
    _bgPlayer = AudioPlayer();
    _sfxPlayer = AudioPlayer();
  }

  /// Reproduce música de fondo en loop
  Future<void> playBackgroundMusic(String assetPath) async {
    if (_isBgPlaying) return;

    try {
      await _bgPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgPlayer.play(AssetSource(assetPath));
      _isBgPlaying = true;
    } catch (e) {
      print('Error al reproducir música de fondo: $e');
    }
  }

  /// Detiene la música de fondo
  Future<void> stopBackgroundMusic() async {
    await _bgPlayer.stop();
    _isBgPlaying = false;
  }

  /// Reproduce un sonido corto encima de la música
  Future<void> playSoundEffect(String assetPath) async {
    try {
      await _sfxPlayer.play(AssetSource(assetPath));
    } catch (e) {
      print('Error al reproducir efecto de sonido: $e');
    }
  }

  /// Libera recursos (llamar al cerrar la app)
  Future<void> dispose() async {
    await _bgPlayer.dispose();
    await _sfxPlayer.dispose();
  }
}