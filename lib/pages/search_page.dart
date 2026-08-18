import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/music_provider.dart';
import '../widgets/song_tile.dart';
import 'full_player_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  @override State<SearchPage> createState() => _SearchPageState();
}
class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  @override void dispose() { _controller.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    return Consumer<MusicProvider>(builder: (context, p, _) => Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 8), child: const Text('搜索', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textPrimary))),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: NeuBox(borderRadius: 16, padding: const EdgeInsets.symmetric(horizontal: 16),
        child: TextField(controller: _controller, decoration: const InputDecoration(hintText: '搜索歌曲、艺术家...', hintStyle: TextStyle(color: AppTheme.textSecondary), border: InputBorder.none, icon: Icon(Icons.search, color: AppTheme.textSecondary)),
          style: const TextStyle(color: AppTheme.textPrimary), onSubmitted: (v) => p.search(v), textInputAction: TextInputAction.search))),
      const SizedBox(height: 12),
      Expanded(child: p.isSearching ? const Center(child: CircularProgressIndicator(color: AppTheme.accentMint))
        : _controller.text.isEmpty ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: const [Icon(Icons.search, size: 64, color: AppTheme.textSecondary), SizedBox(height: 16), Text('输入关键词搜索音乐', style: TextStyle(color: AppTheme.textSecondary))]))
        : ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 100), children: [
          if (p.searchOnlineResults.isNotEmpty) ...[_section('在线音乐', p.searchOnlineResults.length), const SizedBox(height: 8), ...p.searchOnlineResults.map((s) => Padding(padding: const EdgeInsets.only(bottom: 8), child: SongTile(song: s, isPlaying: p.currentSong?.id == s.id, onTap: () async { await p.playSong(s, playlist: p.searchOnlineResults); if (context.mounted) Navigator.push(context, MaterialPageRoute(builder: (_) => const FullPlayerPage())); })))],
          if (p.searchLocalResults.isNotEmpty) ...[const SizedBox(height: 16), _section('本地音乐', p.searchLocalResults.length), const SizedBox(height: 8), ...p.searchLocalResults.map((s) => Padding(padding: const EdgeInsets.only(bottom: 8), child: SongTile(song: s, isPlaying: p.currentSong?.id == s.id, onTap: () async { await p.playSong(s, playlist: p.searchLocalResults); if (context.mounted) Navigator.push(context, MaterialPageRoute(builder: (_) => const FullPlayerPage())); })))],
          if (p.searchOnlineResults.isEmpty && p.searchLocalResults.isEmpty) const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('未找到相关结果', style: TextStyle(color: AppTheme.textSecondary)))),
        ])),
    ]));
  }
  Widget _section(String t, int c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: Row(children: [Container(width: 4, height: 18, decoration: BoxDecoration(color: AppTheme.accentMint, borderRadius: BorderRadius.circular(2))), const SizedBox(width: 8), Text('$t ($c)', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary))]));
}
