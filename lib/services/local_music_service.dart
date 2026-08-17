import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/song.dart';

class LocalMusicService {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  Future<bool> requestPermission() async {
    if (await Permission.storage.isGranted) return true;
    if (await Permission.audio.isGranted) return true;
    final s = await Permission.audio.request();
    if (s.isGranted) return true;
    final ss = await Permission.storage.request();
    return ss.isGranted;
  }
  Future<List<Song>> scanLocalMusic() async {
    final hasPermission = await requestPermission();
    if (!hasPermission) return [];
    try {
      final List<SongModel> songs = await _audioQuery.querySongs(sortType: SongSortType.DATE_ADDED, orderType: OrderType.DESC_OR_GREATER, uriType: UriType.EXTERNAL, ignoreCase: true);
      return songs.map((s) => Song(id: s.id.toString(), title: s.title.isNotEmpty ? s.title : '未知',
        artist: s.artist != null && s.artist != '<unknown>' ? s.artist! : '未知',
        album: s.album, albumArt: null, url: s.data, duration: s.duration ?? 0, isOnline: false, filePath: s.data)).toList();
    } catch (_) { return []; }
  }
}
