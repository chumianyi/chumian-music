import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/song.dart';

class OnlineMusicService {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
    sendTimeout: const Duration(seconds: 15),
    responseType: ResponseType.plain,
    headers: {
      'User-Agent': 'Mozilla/5.0 (Linux; Android 12) AppleWebKit/537.36',
      'Accept': 'application/json, text/plain, */*',
    },
  ));

  // 多个 API 兜底
  static const List<String> _apiBases = [
    'https://api.mnchen.cn/',
    'https://api.injahow.cn/meting/',
  ];

  static const String _neteaseSearch = 'https://music.163.com/api';

  // 歌单分类: id -> 名称
  static const Map<int, String> playlists = {
    3778678: '热歌榜',
    3779629: '新歌榜',
    19723756: '飙升榜',
    2884035: '原创榜',
    71385702: 'ACG榜',
    71382712: '摇滚榜',
    71385007: '民谣榜',
    71384707: '古典榜',
  };

  String? lastError;

  Future<dynamic> _getJson(String url,
      {Map<String, dynamic>? params}) async {
    final resp = await _dio.get(url, queryParameters: params);
    if (resp.statusCode == 200) {
      final body = resp.data.toString();
      if (body.isEmpty) return null;
      return jsonDecode(body);
    }
    throw Exception('HTTP ${resp.statusCode}');
  }

  Future<List<Song>> getPlaylistSongs(int playlistId) async {
    lastError = null;
    for (final base in _apiBases) {
      try {
        final data = await _getJson(base,
            params: {'server': 'netease', 'type': 'playlist', 'id': playlistId});
        if (data is List && data.isNotEmpty) {
          return data.take(50).map<Song>((item) {
            final id = _extractId(item['url'] ?? '');
            return Song(
              id: id.isNotEmpty ? id : (item['name'] ?? '').toString(),
              title: item['name'] ?? '未知',
              artist: item['artist'] ?? '未知',
              album: playlists[playlistId] ?? '网易云',
              coverUrl: item['pic'],
              lyricsUrl: item['lrc'],
              url: item['url'],
              duration: Duration.zero,
              isOnline: true,
            );
          }).toList();
        }
      } catch (e) {
        lastError = '$base: $e';
        continue;
      }
    }
    return [];
  }

  Future<List<Song>> getRecommendSongs() async {
    return getPlaylistSongs(3778678);
  }

  String _extractId(String url) {
    final match = RegExp(r'id=(\d+)').firstMatch(url);
    return match?.group(1) ?? '';
  }

  Future<List<Song>> searchSongs(String keyword) async {
    if (keyword.trim().isEmpty) return [];
    lastError = null;
    try {
      final data = await _getJson('$_neteaseSearch/search/get',
          params: {'s': keyword, 'type': 1, 'limit': 30});
      if (data is Map && data['result'] is Map) {
        final List songs = data['result']['songs'] ?? [];
        return songs.map<Song>((s) {
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
            lyricsUrl: '${_apiBases[0]}?server=netease&type=lrc&id=$id',
            url: '',
            duration: Duration(milliseconds: (s['duration'] ?? 0) as int),
            isOnline: true,
          );
        }).toList();
      }
    } catch (e) {
      lastError = 'search: $e';
    }
    return [];
  }

  Future<String?> getSongUrl(String songId) async {
    for (final base in _apiBases) {
      try {
        return '$base?server=netease&type=url&id=$songId';
      } catch (_) {}
    }
    return null;
  }

  /// 获取并解析 LRC 歌词
  Future<List<MapEntry<Duration, String>>> getLyrics(String? lyricsUrl) async {
    if (lyricsUrl == null || lyricsUrl.isEmpty) return [];
    try {
      final resp = await _dio.get(lyricsUrl);
      if (resp.statusCode == 200) {
        return parseLrc(resp.data.toString());
      }
    } catch (_) {}
    return [];
  }

  List<MapEntry<Duration, String>> parseLrc(String lrc) {
    final lines = <MapEntry<Duration, String>>[];
    final regex = RegExp(r'\[(\d{2}):(\d{2})\.(\d{2,3})\](.*)');
    for (final line in lrc.split('\n')) {
      final match = regex.firstMatch(line);
      if (match != null) {
        final minutes = int.parse(match.group(1)!);
        final seconds = int.parse(match.group(2)!);
        final msStr = match.group(3)!;
        final ms = int.parse(msStr.padRight(3, '0').substring(0, 3));
        final text = match.group(4)!.trim();
        if (text.isNotEmpty) {
          lines.add(MapEntry(
            Duration(minutes: minutes, seconds: seconds, milliseconds: ms),
            text,
          ));
        }
      }
    }
    lines.sort((a, b) => a.key.compareTo(b.key));
    return lines;
  }
}
