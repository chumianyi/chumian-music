import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song.dart';

class MusicAudioHandler extends BaseAudioHandler {
  final AudioPlayer _player = AudioPlayer();
  final List<Song> _queue = [];
  int _currentIndex = -1;
  MusicAudioHandler() {
    _player.playbackEventStream.listen((_) => _broadcastState());
    _player.playerStateStream.listen((state) { if (state.processingState == ProcessingState.completed) skipToNext(); });
  }
  @override Future<void> play() => _player.play();
  @override Future<void> pause() => _player.pause();
  @override Future<void> seek(Duration position) => _player.seek(position);
  @override Future<void> stop() => _player.stop();
  @override Future<void> skipToNext() async { if (_queue.isEmpty) return; _currentIndex = (_currentIndex + 1) % _queue.length; await _playCurrent(); }
  @override Future<void> skipToPrevious() async { if (_queue.isEmpty) return; _currentIndex = (_currentIndex - 1 + _queue.length) % _queue.length; await _playCurrent(); }
  Future<void> playSong(Song song, {List<Song>? playlist}) async {
    if (playlist != null && playlist.isNotEmpty) { _queue.clear(); _queue.addAll(playlist); _currentIndex = playlist.indexWhere((s) => s.id == song.id); if (_currentIndex < 0) _currentIndex = 0; }
    else { final e = _queue.indexWhere((s) => s.id == song.id); if (e >= 0) _currentIndex = e; else { _queue.add(song); _currentIndex = _queue.length - 1; } }
    await _playCurrent();
  }
  Future<void> _playCurrent() async {
    if (_currentIndex < 0 || _currentIndex >= _queue.length) return;
    final song = _queue[_currentIndex];
    try { if (song.url.isNotEmpty) { await _player.setUrl(song.url); await _player.play(); } } catch (_) {}
  }
  Future<void> seekRelative(int seconds) async {
    final pos = _player.position + Duration(seconds: seconds);
    final dur = _player.duration ?? Duration.zero;
    if (pos < Duration.zero) await _player.seek(Duration.zero);
    else if (dur > Duration.zero && pos > dur) await _player.seek(dur);
    else await _player.seek(pos);
  }
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<bool> get playingStream => _player.playingStream;
  bool get isPlaying => _player.playing;
  Song? get currentSong => (_currentIndex >= 0 && _currentIndex < _queue.length) ? _queue[_currentIndex] : null;
  void _broadcastState() {
    final state = _player.playerState;
    playbackState.add(playbackState.value.copyWith(
      controls: [MediaControl.skipToPrevious, if (state.playing) MediaControl.pause else MediaControl.play, MediaControl.skipToNext],
      systemActions: const {MediaAction.seek, MediaAction.seekForward, MediaAction.seekBackward},
      processingState: const {ProcessingState.idle: AudioProcessingState.idle, ProcessingState.loading: AudioProcessingState.loading, ProcessingState.buffering: AudioProcessingState.buffering, ProcessingState.ready: AudioProcessingState.ready, ProcessingState.completed: AudioProcessingState.completed}[state.processingState]!,
      playing: state.playing, position: _player.position, bufferedPosition: _player.bufferedPosition, speed: _player.speed,
    ));
  }
}
