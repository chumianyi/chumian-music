import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import '../models/song.dart';

class MusicAudioHandler {
  final AudioPlayer _player = AudioPlayer();
  final List<Song> _queue = [];
  int _currentIndex = -1;

  static const _channel = MethodChannel('com.chumian.music/player');
  final _currentSongController = StreamController<Song?>.broadcast();
  Stream<Song?> get currentSongStream => _currentSongController.stream;

  MusicAudioHandler() {
    _init();
  }

  Future<void> _init() async {
    // 音频会话配置：处理音频焦点、耳机拔出等
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
      session.interruptionEventStream.listen((event) {
        if (event.begin) {
          if (event.type == AudioInterruptionType.duck) {
            _player.setVolume(0.5);
          } else {
            _player.pause();
          }
        } else {
          if (event.type == AudioInterruptionType.duck) {
            _player.setVolume(1.0);
          } else {
            _player.play();
          }
        }
      });
      session.becomingNoisyEventStream.listen((_) {
        _player.pause();
      });
    } catch (_) {}

    // 播放完成自动下一首
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        skipToNext();
      }
    });

    // 播放状态变化时更新通知
    _player.playingStream.listen((_) {
      _updateNotification();
    });

    // 原生通知按钮 → Dart
    if (Platform.isAndroid) {
      _channel.setMethodCallHandler((call) async {
        switch (call.method) {
          case 'onPlay':
            play();
            break;
          case 'onPause':
            pause();
            break;
          case 'onNext':
            skipToNext();
            break;
          case 'onPrevious':
            skipToPrevious();
            break;
        }
      });
    }
  }

  Future<void> play() => _player.play();
  Future<void> pause() => _player.pause();
  Future<void> seek(Duration position) => _player.seek(position);

  Future<void> stop() async {
    await _player.stop();
    _stopForeground();
  }

  Future<void> skipToNext() async {
    if (_queue.isEmpty) return;
    _currentIndex = (_currentIndex + 1) % _queue.length;
    await _playCurrent();
  }

  Future<void> skipToPrevious() async {
    if (_queue.isEmpty) return;
    _currentIndex = (_currentIndex - 1 + _queue.length) % _queue.length;
    await _playCurrent();
  }

  Future<void> playSong(Song song, {List<Song>? playlist}) async {
    if (playlist != null && playlist.isNotEmpty) {
      _queue.clear();
      _queue.addAll(playlist);
      _currentIndex = playlist.indexWhere((s) => s.id == song.id);
      if (_currentIndex < 0) _currentIndex = 0;
    } else {
      final e = _queue.indexWhere((s) => s.id == song.id);
      if (e >= 0) {
        _currentIndex = e;
      } else {
        _queue.add(song);
        _currentIndex = _queue.length - 1;
      }
    }
    await _playCurrent();
  }

  Future<void> _playCurrent() async {
    if (_currentIndex < 0 || _currentIndex >= _queue.length) return;
    final song = _queue[_currentIndex];
    _currentSongController.add(song);
    try {
      final url = song.url ?? song.filePath;
      if (url != null && url.isNotEmpty) {
        await _player.setUrl(url);
        await _player.play();
        _startForeground(song);
      }
    } catch (_) {}
  }

  Future<void> seekRelative(int seconds) async {
    final pos = _player.position + Duration(seconds: seconds);
    final dur = _player.duration ?? Duration.zero;
    if (pos < Duration.zero) {
      await _player.seek(Duration.zero);
    } else if (dur > Duration.zero && pos > dur) {
      await _player.seek(dur);
    } else {
      await _player.seek(pos);
    }
  }

  // === 原生前台服务 ===
  Future<void> _startForeground(Song song) async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('startForeground', {
        'title': song.title,
        'artist': song.artist,
        'coverUrl': song.coverUrl,
        'isPlaying': true,
      });
    } catch (_) {}
  }

  Future<void> _updateNotification() async {
    if (!Platform.isAndroid) return;
    final song = currentSong;
    if (song == null) return;
    try {
      await _channel.invokeMethod('updateNotification', {
        'title': song.title,
        'artist': song.artist,
        'coverUrl': song.coverUrl,
        'isPlaying': _player.playing,
      });
    } catch (_) {}
  }

  Future<void> _stopForeground() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('stopForeground');
    } catch (_) {}
  }

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<bool> get playingStream => _player.playingStream;
  bool get isPlaying => _player.playing;

  Song? get currentSong =>
      (_currentIndex >= 0 && _currentIndex < _queue.length)
          ? _queue[_currentIndex]
          : null;

  Future<void> dispose() async {
    await _stopForeground();
    await _player.dispose();
    await _currentSongController.close();
  }
}
