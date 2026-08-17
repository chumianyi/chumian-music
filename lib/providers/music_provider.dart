import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/audio_player_service.dart';
import '../services/online_music_service.dart';
import '../services/local_music_service.dart';

class MusicProvider extends ChangeNotifier {
  final OnlineMusicService _onlineService = OnlineMusicService();
  final LocalMusicService _localService = LocalMusicService();
  late final MusicAudioHandler audioHandler;

  List<Song> onlineSongs = [];
  List<Song> localSongs = [];
  List<Song> searchOnlineResults = [];
  List<Song> searchLocalResults = [];
  Set<String> favorites = {};

  // 歌单状态
  int currentPlaylistId = 3778678;
  String currentPlaylistName = '热歌榜';

  // 歌词状态
  List<MapEntry<Duration, String>> lyrics = [];
  bool isLoadingLyrics = false;
  int currentLyricIndex = -1;

  bool isLoadingOnline = false;
  bool isLoadingLocal = false;
  bool isSearching = false;
  bool hasPermission = false;
  String? onlineError;

  Song? get currentSong => audioHandler.currentSong;
  bool get isPlaying => audioHandler.isPlaying;
  Stream<Duration> get positionStream => audioHandler.positionStream;
  Stream<Duration?> get durationStream => audioHandler.durationStream;
  Stream<bool> get playingStream => audioHandler.playingStream;

  Future<void> init(MusicAudioHandler handler) async {
    audioHandler = handler;
    audioHandler.playingStream.listen((_) => notifyListeners());
    audioHandler.positionStream.listen((pos) {
      _updateLyricIndex(pos);
    });
    loadPlaylist(currentPlaylistId, currentPlaylistName);
    loadLocalSongs();
  }

  void _updateLyricIndex(Duration position) {
    if (lyrics.isEmpty) return;
    int newIndex = -1;
    for (int i = 0; i < lyrics.length; i++) {
      if (position >= lyrics[i].key) {
        newIndex = i;
      } else {
        break;
      }
    }
    if (newIndex != currentLyricIndex) {
      currentLyricIndex = newIndex;
      notifyListeners();
    }
  }

  Future<void> loadPlaylist(int id, String name) async {
    currentPlaylistId = id;
    currentPlaylistName = name;
    isLoadingOnline = true;
    onlineError = null;
    notifyListeners();
    onlineSongs = await _onlineService.getPlaylistSongs(id);
    if (onlineSongs.isEmpty) {
      onlineError = _onlineService.lastError;
    }
    isLoadingOnline = false;
    notifyListeners();
  }

  Future<void> loadOnlineSongs() async {
    await loadPlaylist(currentPlaylistId, currentPlaylistName);
  }

  Future<void> loadLocalSongs() async {
    isLoadingLocal = true;
    notifyListeners();
    hasPermission = await _localService.requestPermission();
    if (hasPermission) localSongs = await _localService.scanLocalMusic();
    isLoadingLocal = false;
    notifyListeners();
  }

  Future<void> search(String keyword) async {
    if (keyword.trim().isEmpty) {
      searchOnlineResults = [];
      searchLocalResults = [];
      notifyListeners();
      return;
    }
    isSearching = true;
    notifyListeners();
    searchOnlineResults = await _onlineService.searchSongs(keyword);
    searchLocalResults = localSongs
        .where((s) =>
            s.title.toLowerCase().contains(keyword.toLowerCase()) ||
            s.artist.toLowerCase().contains(keyword.toLowerCase()))
        .toList();
    isSearching = false;
    notifyListeners();
  }

  Future<void> playSong(Song song, {List<Song>? playlist}) async {
    if (song.isOnline && (song.url == null || song.url!.isEmpty)) {
      final url = await _onlineService.getSongUrl(song.id);
      if (url != null && url.isNotEmpty) {
        song = song.copyWith(url: url);
      } else {
        return;
      }
    }
    await audioHandler.playSong(song, playlist: playlist);
    notifyListeners();
    // 加载歌词
    loadLyrics(song);
  }

  Future<void> loadLyrics(Song song) async {
    if (song.lyricsUrl == null || song.lyricsUrl!.isEmpty) {
      lyrics = [];
      currentLyricIndex = -1;
      notifyListeners();
      return;
    }
    isLoadingLyrics = true;
    notifyListeners();
    lyrics = await _onlineService.getLyrics(song.lyricsUrl);
    currentLyricIndex = -1;
    isLoadingLyrics = false;
    notifyListeners();
  }

  Future<void> togglePlay() async {
    if (audioHandler.isPlaying) {
      await audioHandler.pause();
    } else {
      await audioHandler.play();
    }
    notifyListeners();
  }

  Future<void> next() async {
    await audioHandler.skipToNext();
    notifyListeners();
    final cs = currentSong;
    if (cs != null) loadLyrics(cs);
  }

  Future<void> previous() async {
    await audioHandler.skipToPrevious();
    notifyListeners();
    final cs = currentSong;
    if (cs != null) loadLyrics(cs);
  }

  Future<void> seek(Duration pos) async {
    await audioHandler.seek(pos);
  }

  Future<void> seekForward() async {
    await audioHandler.seekRelative(10);
  }

  Future<void> seekBackward() async {
    await audioHandler.seekRelative(-10);
  }

  void toggleFavorite(String songId) {
    if (favorites.contains(songId)) {
      favorites.remove(songId);
    } else {
      favorites.add(songId);
    }
    notifyListeners();
  }

  bool isFavorite(String songId) => favorites.contains(songId);
}
