
import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers_platform_interface/api/player_state.dart';

class SoundManager {
  SoundManager._internal();
  static final SoundManager instance = SoundManager._internal();
  
  // Configuración específica para música de fondo
  static final AudioContext bgContext = AudioContext(
    iOS: AudioContextIOS(
      category: AVAudioSessionCategory.playback,
      options: [],
    ),
    android: AudioContextAndroid(
      isSpeakerphoneOn: false,
      stayAwake: true,
      contentType: AndroidContentType.music,
      usageType: AndroidUsageType.media,
      audioFocus: AndroidAudioFocus.gain,
    ),
  );

  // Configuración específica para efectos (SFX)
  static final AudioContext sfxContext = AudioContext(
    iOS: AudioContextIOS(
      category: AVAudioSessionCategory.ambient,
      options: [AVAudioSessionCategoryOptions.mixWithOthers],
    ),
    android: AudioContextAndroid(
      isSpeakerphoneOn: false,
      stayAwake: false,
      contentType: AndroidContentType.sonification,
      usageType: AndroidUsageType.assistanceSonification,
      audioFocus: AndroidAudioFocus.gainTransientMayDuck,
    ),
  );

  AudioPlayer? _bgPlayer;
  // Opcional: pool simple para SFX (no imprescindible ahora)
  // final List<AudioPlayer> _sfxPool = [];

  Future<void> playBackground(String assetPath, {double volume = 1.0}) async {
  try {
    // Crear el player si aún no existe
    _bgPlayer ??= AudioPlayer();

    // Aplicar contexto de audio para música de fondo (muy importante)
    await _bgPlayer!.setAudioContext(bgContext);

    // Configurar modo de reproducción y volumen
    await _bgPlayer!.setReleaseMode(ReleaseMode.loop);
    await _bgPlayer!.setVolume(volume);

    // Reproducir la música (ruta relativa a assets/)
    await _bgPlayer!.play(AssetSource(assetPath));
  } catch (e) {
    // Ignorar errores de audio
  }
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
      await p.setAudioContext(sfxContext);
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