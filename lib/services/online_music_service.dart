import 'package:dio/dio.dart';
import '../models/song.dart';

class OnlineMusicService {
  final Dio _dio = Dio();

  static const String _metingApi = 'https://api.injahow.cn/meting/';
  static const String _neteaseApi = 'https://music.163.com/api';

  // 云音乐热歌榜, 云音乐新歌榜
  static const List<int> _hotPlaylists = [3778678, 3779629];

  Future<Response> _get(String url,
      {Map<String, dynamic>? params,
      Map<String, String>? headers}) async {
    return await _dio.get(url,
        queryParameters: params,
        options: Options(
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
          headers: headers ??
              {
                'User-Agent': 'Mozilla/5.0',
                'Referer': 'https://music.163.com/'
              },
        ));
  }

  Future<List<Song>> getRecommendSongs() async {
    for (final playlistId in _hotPlaylists) {
      try {
        final resp = await _get(_metingApi,
            params: {'type': 'playlist', 'id': playlistId});
        if (resp.statusCode == 200 && resp.data is List) {
          final List data = resp.data;
          if (data.isNotEmpty) {
            return data.take(30).map((item) {
              final id = _extractId(item['url'] ?? '');
              return Song(
                id: id.isNotEmpty ? id : (item['name'] ?? '').toString(),
                title: item['name'] ?? '未知',
                artist: item['artist'] ?? '未知',
                album: playlistId == 3778678 ? '云音乐热歌榜' : '云音乐新歌榜',
                coverUrl: item['pic'],
                url: item['url'],
                duration: Duration.zero,
                isOnline: true,
              );
            }).toList();
          }
        }
      } catch (_) {}
    }
    return [];
  }

  String _extractId(String url) {
    final match = RegExp(r'id=(\d+)').firstMatch(url);
    return match?.group(1) ?? '';
  }

  Future<List<Song>> searchSongs(String keyword) async {
    if (keyword.trim().isEmpty) return [];
    try {
      final resp = await _get('$_neteaseApi/search/get',
          params: {'s': keyword, 'type': 1, 'limit': 30});
      if (resp.statusCode == 200) {
        final data = resp.data;
        if (data is Map && data['result'] is Map) {
          final List songs = data['result']['songs'] ?? [];
          return songs.map((s) {
            final id = s['id']?.toString() ?? '';
            final album = s['album'];
            return Song(
              id: id,
              title: s['name'] ?? '未知',
              artist: (s['artists'] as List?)
                      ?.map((a) => a['name']?.toString() ?? '')
                      .where((a) => a.isNotEmpty)
                      .join('/') ??
                  '未知',
              album: album?['name']?.toString() ?? '未知专辑',
              coverUrl: album?['picUrl']?.toString(),
              url: '',
              duration: Duration(milliseconds: (s['duration'] ?? 0) as int),
              isOnline: true,
            );
          }).toList();
        }
      }
    } catch (_) {}
    return [];
  }

  Future<String?> getSongUrl(String songId) async {
    try {
      // Meting URL proxy returns 302 redirect to actual MP3
      // just_audio (ExoPlayer) follows redirects automatically
      return '$_metingApi?server=netease&type=url&id=$songId';
    } catch (_) {}
    return null;
  }
}
