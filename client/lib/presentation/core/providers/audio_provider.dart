import 'package:flutter/material.dart';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final audioProvider = ChangeNotifierProvider<AudioController>((ref) {
  return AudioController();
});

class AudioController extends ChangeNotifier with WidgetsBindingObserver {
  final AudioPlayer _bgmPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isDisposed = false;
  bool _isMuted = false;

  bool get isMuted => _isMuted;

  AudioController() {
    _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      if (_isPlaying) {
        _bgmPlayer.pause();
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_isPlaying) {
        _bgmPlayer.resume();
      }
    }
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    _bgmPlayer.setVolume(_isMuted ? 0.0 : 0.5);
    notifyListeners();
  }

  Future<void> playMenuMusic() async {
    if (_isPlaying || _isDisposed) return;

    try {
      await _bgmPlayer.play(
        AssetSource('audio/splode_theme.mp3'),
        volume: _isMuted ? 0.0 : 0.5,
      );
      await _bgmPlayer.seek(Duration.zero);
      _isPlaying = true;
    } catch (e) {
      debugPrint('Failed to play menu BGM: $e');
    }
  }

  Future<void> stopMusic() async {
    if (!_isPlaying || _isDisposed) return;

    try {
      await _bgmPlayer.stop();
      _isPlaying = false;
    } catch (e) {
      debugPrint('Failed to stop BGM: $e');
    }
  }

  Future<void> resumeMenuMusic() async {
    if (_isPlaying || _isDisposed) return;

    try {
      await _bgmPlayer.resume();
      _isPlaying = true;
    } catch (e) {
      await playMenuMusic();
    }
  }

  @override
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _bgmPlayer.dispose();
    super.dispose();
  }
}
