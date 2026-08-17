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
  bool isLoadingOnline = false;
  bool isLoadingLocal = false;
  bool isSearching = false;
  bool hasPermission = false;
  Song? get currentSong => audioHandler.currentSong;
  bool get isPlaying => audioHandler.isPlaying;
  Stream<Duration> get positionStream => audioHandler.positionStream;
  Stream<Duration?> get durationStream => audioHandler.durationStream;
  Stream<bool> get playingStream => audioHandler.playingStream;

  Future<void> init(MusicAudioHandler handler) async {
    audioHandler = handler;
    audioHandler.playingStream.listen((_) => notifyListeners());
    loadOnlineSongs();
    loadLocalSongs();
  }
  Future<void> loadOnlineSongs() async {
    isLoadingOnline = true; notifyListeners();
    onlineSongs = await _onlineService.getRecommendSongs();
    isLoadingOnline = false; notifyListeners();
  }
  Future<void> loadLocalSongs() async {
    isLoadingLocal = true; notifyListeners();
    hasPermission = await _localService.requestPermission();
    if (hasPermission) localSongs = await _localService.scanLocalMusic();
    isLoadingLocal = false; notifyListeners();
  }
  Future<void> search(String keyword) async {
    if (keyword.trim().isEmpty) { searchOnlineResults = []; searchLocalResults = []; notifyListeners(); return; }
    isSearching = true; notifyListeners();
    searchOnlineResults = await _onlineService.searchSongs(keyword);
    searchLocalResults = localSongs.where((s) => s.title.toLowerCase().contains(keyword.toLowerCase()) || s.artist.toLowerCase().contains(keyword.toLowerCase())).toList();
    isSearching = false; notifyListeners();
  }
  Future<void> playSong(Song song, {List<Song>? playlist}) async {
    if (song.isOnline && song.url.isEmpty) {
      final url = await _onlineService.getSongUrl(song.id);
      if (url != null && url.isNotEmpty) {
        song = Song(id: song.id, title: song.title, artist: song.artist, album: song.album, albumArt: song.albumArt, url: url, duration: song.duration, isOnline: true);
      } else return;
    }
    await audioHandler.playSong(song, playlist: playlist);
    notifyListeners();
  }
  Future<void> togglePlay() async { if (audioHandler.isPlaying) await audioHandler.pause(); else await audioHandler.play(); notifyListeners(); }
  Future<void> next() async { await audioHandler.skipToNext(); notifyListeners(); }
  Future<void> previous() async { await audioHandler.skipToPrevious(); notifyListeners(); }
  Future<void> seek(Duration pos) async { await audioHandler.seek(pos); }
  Future<void> seekForward() async { await audioHandler.seekRelative(10); }
  Future<void> seekBackward() async { await audioHandler.seekRelative(-10); }
  void toggleFavorite(String songId) { if (favorites.contains(songId)) favorites.remove(songId); else favorites.add(songId); notifyListeners(); }
  bool isFavorite(String songId) => favorites.contains(songId);
}
