import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
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
    } catch (e) {
      debugPrint('audio_session init error: $e');
    }

    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        debugPrint('playback completed, skipping to next');
        skipToNext();
      }
    });

    _player.playingStream.listen((playing) {
      debugPrint('playing state: $playing');
      _updateNotification();
    });

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

  Future<void> play() async {
    debugPrint('play() called');
    try {
      await _player.play();
    } catch (e) {
      debugPrint('play error: $e');
    }
  }

  Future<void> pause() async {
    debugPrint('pause() called');
    await _player.pause();
  }

  Future<void> seek(Duration position) => _player.seek(position);

  Future<void> stop() async {
    await _player.stop();
    _stopForeground();
  }

  Future<void> skipToNext() async {
    if (_queue.isEmpty) return;
    _currentIndex = (_currentIndex + 1) % _queue.length;
    debugPrint('skipToNext: index=$_currentIndex, song=${_queue[_currentIndex].title}');
    await _playCurrent();
  }

  Future<void> skipToPrevious() async {
    if (_queue.isEmpty) return;
    _currentIndex = (_currentIndex - 1 + _queue.length) % _queue.length;
    debugPrint('skipToPrevious: index=$_currentIndex, song=${_queue[_currentIndex].title}');
    await _playCurrent();
  }

  Future<void> playSong(Song song, {List<Song>? playlist}) async {
    debugPrint('playSong: ${song.title}, playlist=${playlist?.length}');
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
    debugPrint('_playCurrent: ${song.title}, url=${song.url ?? song.filePath}');
    _currentSongController.add(song);

    final url = song.url ?? song.filePath;
    if (url == null || url.isEmpty) {
      debugPrint('ERROR: empty url for song ${song.title}');
      return;
    }

    try {
      // 关键：先停止当前，再设置新源，再播放
      await _player.stop();
      debugPrint('stopped previous, setting new source...');
      await _player.setAudioSource(AudioSource.uri(Uri.parse(url)));
      debugPrint('source set, starting playback...');
      await _player.play();
      debugPrint('playback started for ${song.title}');
      _startForeground(song);
    } catch (e) {
      debugPrint('ERROR playing ${song.title}: $e');
    }
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

  Future<void> _startForeground(Song song) async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('startForeground', {
        'title': song.title,
        'artist': song.artist,
        'coverUrl': song.coverUrl,
        'isPlaying': true,
      });
    } catch (e) {
      debugPrint('startForeground error: $e');
    }
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
