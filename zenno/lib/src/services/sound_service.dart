import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final _player = AudioPlayer();
  static bool _playing = false;

  static Future<void> toggle(bool enabled) async {
    if (enabled && !_playing) {
      await _play();
    } else if (!enabled && _playing) {
      await stop();
    }
  }

  static Future<void> _play() async {
    try {
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.play(AssetSource('sounds/ambient.mp3'));
      _playing = true;
    } catch (_) {
      // No sound file present — silently ignore.
    }
  }

  static Future<void> stop() async {
    try {
      await _player.stop();
      _playing = false;
    } catch (_) {}
  }
}
