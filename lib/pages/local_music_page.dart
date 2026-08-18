import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/music_provider.dart';
import '../widgets/song_tile.dart';
import 'full_player_page.dart';

class LocalMusicPage extends StatelessWidget {
  const LocalMusicPage({super.key});
  @override Widget build(BuildContext context) {
    return Consumer<MusicProvider>(builder: (context, p, _) => Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 8), child: Row(children: [
        const Text('播放列表', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
        const Spacer(),
        NeuButton(onPressed: () => p.loadLocalSongs(), padding: const EdgeInsets.all(10), borderRadius: 14, child: const Icon(Icons.refresh, color: AppTheme.textPrimary, size: 20)),
      ])),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: NeuBox(borderRadius: 16, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [const Icon(Icons.folder, color: AppTheme.accentBlue, size: 20), const SizedBox(width: 8), Text('本地音乐 · ${p.localSongs.length} 首', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13))]))),
      const SizedBox(height: 12),
      Expanded(child: p.isLoadingLocal ? const Center(child: CircularProgressIndicator(color: AppTheme.accentMint))
        : !p.hasPermission ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.lock_outline, size: 64, color: AppTheme.textSecondary), const SizedBox(height: 16), const Text('需要存储权限来扫描本地音乐', style: TextStyle(color: AppTheme.textSecondary)), const SizedBox(height: 12), NeuButton(onPressed: () => p.loadLocalSongs(), child: const Text('授予权限'))]))
        : p.localSongs.isEmpty ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.library_music, size: 64, color: AppTheme.textSecondary), const SizedBox(height: 16), const Text('未找到本地音乐文件', style: TextStyle(color: AppTheme.textSecondary)), const SizedBox(height: 12), NeuButton(onPressed: () => p.loadLocalSongs(), child: const Text('重新扫描'))]))
        : RefreshIndicator(color: AppTheme.accentMint, onRefresh: () => p.loadLocalSongs(), child: ListView.separated(padding: const EdgeInsets.fromLTRB(16, 8, 16, 100), itemCount: p.localSongs.length, separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) { final s = p.localSongs[i]; return SongTile(song: s, isPlaying: p.currentSong?.id == s.id, onTap: () async { await p.playSong(s, playlist: p.localSongs); if (context.mounted) Navigator.push(context, MaterialPageRoute(builder: (_) => const FullPlayerPage())); }); }))),
    ]));
  }
}
