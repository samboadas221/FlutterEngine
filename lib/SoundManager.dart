
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

/// SoundManager - Singleton utility for music + low-latency game effects.
///
/// Notes / caveats:
/// - Uses AssetSource by default (paths relative to your assets). If you pass
///   a full URL (startsWith 'http') it will use UrlSource.
/// - Low-latency PlayerMode is used for fast effects; some platforms/backends
///   have quirks re-playing the exact same asset repeatedly. See package issues.
/// - Creating a small pool of low-latency players helps avoid "busy" player errors.
class SoundManager {
  SoundManager._();

  static bool _initialized = false;

  /// Music players keyed by user name/path (keeps alive for control)
  static final Map<String, AudioPlayer> _musicPlayers = {};

  /// Pool of low-latency players for short effects
  static final List<AudioPlayer> _effectPool = [];

  /// Index for round-robin allocation from the pool
  static int _effectPoolIndex = 0;

  /// How many low-latency players to create (tune this for your game)
  static int effectPoolSize = 6;

  /// Initialize SoundManager. Call once before usage (await).
  static Future<void> init({int? poolSize}) async {
    if (_initialized) return;
    if (poolSize != null) effectPoolSize = poolSize;

    // Create low-latency pool
    for (var i = 0; i < effectPoolSize; i++) {
      final player = AudioPlayer();
      await player.setPlayerMode(PlayerMode.lowLatency);
      // optionally setReleaseMode if you want (beware of some issues with lowLatency + releaseMode)
      _effectPool.add(player);
    }

    _initialized = true;
  }

  /// Dispose all players and clear caches.
  static Future<void> dispose() async {
    for (final p in _musicPlayers.values) {
      try {
        await p.stop();
      } catch (_) {}
      await p.dispose();
    }
    _musicPlayers.clear();

    for (final p in _effectPool) {
      try {
        await p.stop();
      } catch (_) {}
      await p.dispose();
    }
    _effectPool.clear();

    _initialized = false;
  }

  /// Play background music.
  /// - [path]: asset path (e.g. 'audio/mySong.mp3') or URL.
  /// - [id]: optional identifier to control the player later. If null, uses path.
  /// - [loop]: if true, uses ReleaseMode.loop
  /// - [volume]: 0.0..1.0
  /// - [asAsset]: if false and path looks like a URL (startsWith 'http'), a UrlSource is used.
  static Future<AudioPlayer> playMusic(
    String path, {
    String? id,
    bool loop = false,
    double volume = 1.0,
    bool asAsset = true,
  }) async {
    if (!_initialized) await init();

    final key = id ?? path;
    // Reuse existing player if present
    var player = _musicPlayers[key];
    if (player == null) {
      player = AudioPlayer(); // default PlayerMode (media)
      _musicPlayers[key] = player;
    }

    // configure volume and release mode
    await player.setVolume(volume.clamp(0.0, 1.0));
    await player.setReleaseMode(loop ? ReleaseMode.loop : ReleaseMode.stop);

    // set source depending on asset/url
    if (!asAsset && _looksLikeUrl(path)) {
      await player.setSource(UrlSource(path));
    } else {
      // AssetSource expects a relative path inside assets, e.g. 'audio/song.mp3'
      // Note: audioplayers might apply a prefix, ensure pubspec.yaml configured.
      await player.setSource(AssetSource(path));
    }

    // Start playing. We do NOT await start finishing; resume() returns Future but
    // waiting is optional. Starting three music tracks without awaiting gives near-concurrent start.
    await player.resume();
    return player;
  }

  /// Stop a music track by id/path. If no id provided will try to stop player keyed by path.
  static Future<void> stopMusic(String pathOrId) async {
    final player = _musicPlayers[pathOrId];
    if (player != null) {
      await player.stop();
      // do not dispose unless user asks to unload
    }
  }

  /// Unload and remove a music player (stops and disposes it).
  static Future<void> unloadMusic(String pathOrId) async {
    final player = _musicPlayers.remove(pathOrId);
    if (player != null) {
      await player.stop();
      await player.dispose();
    }
  }

  /// Convenience to play multiple music tracks at once (does not await each start;
  /// they will start almost simultaneously).
  static Future<List<AudioPlayer>> playMultipleMusic(
    List<String> paths, {
    bool loop = false,
    double volume = 1.0,
    bool asAsset = true,
  }) async {
    if (!_initialized) await init();
    final List<AudioPlayer> started = [];
    for (final p in paths) {
      // fire-and-forget start (we await setSource + resume to ensure it's playing)
      final playerFuture = playMusic(p, id: p, loop: loop, volume: volume, asAsset: asAsset);
      // collect promises but don't await sequentially
      started.add(await playerFuture);
    }
    return started;
  }

  /// Play a short, low-latency effect (good for game SFX).
  /// Uses a small pool of AudioPlayers created with PlayerMode.lowLatency.
  static Future<void> playFastEffect(
    String path, {
    double volume = 1.0,
    bool asAsset = true,
  }) async {
    if (!_initialized) await init();

    // round-robin from pool
    final player = _effectPool[_effectPoolIndex % _effectPool.length];
    _effectPoolIndex++;

    // set volume (low-latency players also support setVolume)
    await player.setVolume(volume.clamp(0.0, 1.0));

    // Set source and play. We do not await long — start quickly.
    if (!asAsset && _looksLikeUrl(path)) {
      await player.setSource(UrlSource(path));
    } else {
      await player.setSource(AssetSource(path));
    }

    // For low-latency, use resume() to start if setSource() was awaited.
    // Note: some backends/platforms expose quirks re-playing the same asset repeatedly;
    // in that case using a pool helps avoid conflicts. See docs/issues.
    await player.resume();
  }

  /// Preload a fast effect into one pool player (best effort).
  /// This will call setSource on one of the low-latency players so the OS backend may cache it.
  static Future<void> preloadFastEffect(String path, {bool asAsset = true}) async {
    if (!_initialized) await init();
    final player = _effectPool[_effectPoolIndex % _effectPool.length];
    _effectPoolIndex++;
    if (!asAsset && _looksLikeUrl(path)) {
      await player.setSource(UrlSource(path));
    } else {
      await player.setSource(AssetSource(path));
    }
    // do NOT call resume() here; we just set the source so it might be cached.
  }

  /// Stop all music players
  static Future<void> stopAllMusic() async {
    for (final p in _musicPlayers.values) {
      await p.stop();
    }
  }

  /// Stop all effects (pool)
  static Future<void> stopAllEffects() async {
    for (final p in _effectPool) {
      await p.stop();
    }
  }

  /// Utility: detect if string looks like a URL
  static bool _looksLikeUrl(String s) {
    final low = s.toLowerCase();
    return low.startsWith('http://') || low.startsWith('https://');
  }
}