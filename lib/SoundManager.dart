
import 'package:audioplayers/audioplayers.dart';

class SoundManager {
  static late AudioPlayer _musicPlayer;
  static final List<AudioPlayer> _effectPool = [];
  static int _nextEffect = 0;
  static bool _initialized = false;

  /// Initialize the SoundManager once at startup.
  static Future<void> init({int poolSize = 10}) async {
    if (_initialized) return;
    _initialized = true;
    
    final config = AudioContextConfig(
      focus: AudioContextConfigFocus.mixWithOthers,
      respectSilence: false,  // Play even if device is silent
    );
    final audioContext = config.build();
    
    _musicPlayer = AudioPlayer(); // Dedicated player for background music
    await _musicPlayer.setAudioContext(audioContext);
    // Create a pool of players for simultaneous sound effects
    for (int i = 0; i < poolSize; i++) {
      final player = AudioPlayer();
      await player.setAudioContext(audioContext);
      _effectPool.add(player);
    }
  }

  /// Play background music (loop optional)
  static Future<void> playMusic(String path, {bool loop = true, double volume = 1.0}) async {
    await _musicPlayer.stop();
    await _musicPlayer.setVolume(volume);
    await _musicPlayer.setReleaseMode(loop ? ReleaseMode.loop : ReleaseMode.stop);
    await _musicPlayer.play(AssetSource(path));
  }

  /// Stop background music
  static Future<void> stopMusic() async {
    await _musicPlayer.stop();
  }

  /// Play a short sound effect (non-blocking)
  static Future<void> playFastEffect(String path, {double volume = 1.0}) async {
    if (_effectPool.isEmpty) return;
    
    final config = AudioContextConfig(
      focus: AudioContextConfigFocus.mixWithOthers,
      respectSilence: false,  // Play even if device is silent
    );
    final audioContext = config.build();
    
    // Pick next player in pool (round robin)
    final player = _effectPool[_nextEffect];
    await player.setAudioContext(audioContext);
    _nextEffect = (_nextEffect + 1) % _effectPool.length;

    // Reuse safely: stop any previous sound before replay
    await player.stop();
    await player.setVolume(volume);

    // Fire the new sound
    await player.play(AssetSource(path));
  }

  /// Optionally preload an effect by playing silently once (for faster next play)
  static Future<void> preloadFastEffect(String path) async {
    if (_effectPool.isEmpty) return;
    final player = _effectPool.first;
    
    final config = AudioContextConfig(
      focus: AudioContextConfigFocus.mixWithOthers,
      respectSilence: false,  // Play even if device is silent
    );
    final audioContext = config.build();
    
    await player.setAudioContext(audioContext);
    
    await player.setVolume(0);
    await player.play(AssetSource(path));
    await player.stop();
    await player.setVolume(1);
  }

  /// Dispose everything on app exit
  static Future<void> dispose() async {
    for (var p in _effectPool) {
      await p.stop();
      await p.release();
    }
    await _musicPlayer.stop();
    await _musicPlayer.release();
    _initialized = false;
  }
}