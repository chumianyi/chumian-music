import 'package:just_audio/just_audio.dart';
import '../models/song.dart';

class MusicAudioHandler {
  final AudioPlayer _player = AudioPlayer();
  final List<Song> _queue = [];
  int _currentIndex = -1;

  MusicAudioHandler() {
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        skipToNext();
      }
    });
  }

  Future<void> play() => _player.play();
  Future<void> pause() => _player.pause();
  Future<void> seek(Duration position) => _player.seek(position);
  Future<void> stop() => _player.stop();

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
    try {
      final url = song.url ?? song.filePath;
      if (url != null && url.isNotEmpty) {
        await _player.setUrl(url);
        await _player.play();
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

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<bool> get playingStream => _player.playingStream;
  bool get isPlaying => _player.playing;
  Song? get currentSong =>
      (_currentIndex >= 0 && _currentIndex < _queue.length)
          ? _queue[_currentIndex]
          : null;

  Future<void> dispose() => _player.dispose();
}
