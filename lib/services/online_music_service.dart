import 'package:dio/dio.dart';
import '../models/song.dart';

class OnlineMusicService {
  final Dio _dio = Dio();
  static const List<String> _apiBaseUrls = [
    'https://netease-cloud-music-api-five-roan-88.vercel.app',
    'https://netease-cloud-music-api-tau-ruddy.vercel.app',
  ];

  Future<Response> _get(String path, {Map<String, dynamic>? params}) async {
    for (final base in _apiBaseUrls) {
      try {
        final resp = await _dio.get('$base$path', queryParameters: params,
          options: Options(receiveTimeout: const Duration(seconds: 15), sendTimeout: const Duration(seconds: 15),
            headers: {'User-Agent': 'Mozilla/5.0', 'Referer': 'https://music.163.com/'}));
        if (resp.statusCode == 200) return resp;
      } catch (_) { continue; }
    }
    throw Exception('API unavailable');
  }

  Future<List<Song>> getRecommendSongs() async {
    try {
      final resp = await _get('/personalized/newsong');
      final data = resp.data;
      if (data is Map && data['code'] == 200) {
        final List result = data['result'] ?? [];
        return result.take(20).map((item) {
          final song = item['song'] ?? item;
          return Song(
            id: song['id']?.toString() ?? '',
            title: song['name'] ?? '未知',
            artist: (song['artists'] as List?)?.map((a) => a['name']).join('/') ?? '未知',
            album: song['album']?['name'] ?? '未知专辑',
            coverUrl: song['album']?['picUrl'] ?? song['picUrl'],
            url: '',
            duration: Duration(milliseconds: (song['duration'] ?? 0) as int),
            isOnline: true,
          );
        }).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<List<Song>> searchSongs(String keyword) async {
    if (keyword.trim().isEmpty) return [];
    try {
      final resp = await _get('/search', params: {'keywords': keyword, 'limit': 30});
      final data = resp.data;
      if (data is Map && data['code'] == 200) {
        final List songsData = data['result']?['songs'] ?? [];
        final ids = songsData.map((s) => s['id']).join(',');
        Map<int, String> coverMap = {};
        try {
          final dResp = await _get('/song/detail', params: {'ids': ids});
          final dData = dResp.data;
          if (dData is Map && dData['code'] == 200) {
            for (final s in dData['songs'] ?? []) {
              coverMap[s['id']] = s['al']?['picUrl'];
            }
          }
        } catch (_) {}
        return songsData.map((s) => Song(
          id: s['id']?.toString() ?? '',
          title: s['name'] ?? '未知',
          artist: (s['artists'] as List?)?.map((a) => a['name']).join('/') ?? '未知',
          album: s['album']?['name'] ?? '未知专辑',
          coverUrl: coverMap[s['id']],
          url: '',
          duration: Duration(milliseconds: (s['duration'] ?? 0) as int),
          isOnline: true,
        )).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<String?> getSongUrl(String songId) async {
    try {
      final resp = await _get('/song/url/v1', params: {'id': songId, 'level': 'standard'});
      final data = resp.data;
      if (data is Map && data['code'] == 200) {
        final List d = data['data'] ?? [];
        if (d.isNotEmpty) return d[0]['url'];
      }
    } catch (_) {}
    try {
      final resp = await _get('/song/url', params: {'id': songId});
      final data = resp.data;
      if (data is Map && data['code'] == 200) {
        final List d = data['data'] ?? [];
        if (d.isNotEmpty) return d[0]['url'];
      }
    } catch (_) {}
    return null;
  }
}
