import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/music_provider.dart';
import '../widgets/song_tile.dart';

class OnlineMusicPage extends StatelessWidget {
  const OnlineMusicPage({super.key});
  @override Widget build(BuildContext context) {
    return Consumer<MusicProvider>(builder: (context, p, _) => Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 8), child: Row(children: [
        const Text('在线音乐', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
        const Spacer(),
        NeuButton(onPressed: () => p.loadOnlineSongs(), padding: const EdgeInsets.all(10), borderRadius: 14, child: const Icon(Icons.refresh, color: AppTheme.textPrimary, size: 20)),
      ])),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: NeuBox(borderRadius: 16, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [const Icon(Icons.trending_up, color: AppTheme.accentMint, size: 20), const SizedBox(width: 8), Text('推荐新歌 · ${p.onlineSongs.length} 首', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13))]))),
      const SizedBox(height: 12),
      Expanded(child: p.isLoadingOnline ? const Center(child: CircularProgressIndicator(color: AppTheme.accentMint))
        : p.onlineSongs.isEmpty ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.cloud_off, size: 64, color: AppTheme.textSecondary), const SizedBox(height: 16), const Text('暂无在线音乐', style: TextStyle(color: AppTheme.textSecondary)), const SizedBox(height: 12), NeuButton(onPressed: () => p.loadOnlineSongs(), child: const Text('重新加载'))]))
        : RefreshIndicator(color: AppTheme.accentMint, onRefresh: () => p.loadOnlineSongs(), child: ListView.separated(padding: const EdgeInsets.fromLTRB(16, 8, 16, 100), itemCount: p.onlineSongs.length, separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) { final s = p.onlineSongs[i]; return SongTile(song: s, isPlaying: p.currentSong?.id == s.id, onTap: () => p.playSong(s, playlist: p.onlineSongs)); }))),
    ]));
  }
}
