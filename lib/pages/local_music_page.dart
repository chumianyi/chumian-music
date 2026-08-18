import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/music_provider.dart';
import '../widgets/song_tile.dart';
import 'full_player_page.dart';

class LocalMusicPage extends StatefulWidget {
  const LocalMusicPage({super.key});

  @override
  State<LocalMusicPage> createState() => _LocalMusicPageState();
}

class _LocalMusicPageState extends State<LocalMusicPage> {
  int _tab = 0; // 0=本地音乐, 1=我的收藏

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicProvider>(builder: (context, p, _) {
      final songs = _tab == 0 ? p.localSongs : p.favoriteSongs;
      return Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          child: Row(children: [
            const Text('播放列表',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary)),
            const Spacer(),
            NeuButton(
              onPressed: () => p.loadLocalSongs(),
              padding: const EdgeInsets.all(8),
              borderRadius: 12,
              child: const Icon(Icons.refresh,
                  color: AppTheme.textPrimary, size: 18),
            ),
          ]),
        ),
        // Tab 切换
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: [
            _tabBtn('本地音乐', 0, p.localSongs.length),
            const SizedBox(width: 8),
            _tabBtn('我的收藏', 1, p.favoriteSongs.length),
          ]),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _tab == 0
              ? _buildLocalList(p)
              : _buildFavoriteList(p, songs),
        ),
      ]);
    });
  }

  Widget _tabBtn(String label, int index, int count) {
    final sel = _tab == index;
    return Expanded(
      child: NeuButton(
        onPressed: () => setState(() => _tab = index),
        padding: const EdgeInsets.symmetric(vertical: 8),
        borderRadius: 12,
        color: sel ? AppTheme.accentMint.withOpacity(0.3) : null,
        child: Text('$label ($count)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: sel ? FontWeight.bold : FontWeight.normal,
              color: sel ? AppTheme.textPrimary : AppTheme.textSecondary,
            )),
      ),
    );
  }

  Widget _buildLocalList(MusicProvider p) {
    if (p.isLoadingLocal) {
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.accentMint));
    }
    if (!p.hasPermission) {
      return Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.lock_outline,
            size: 48, color: AppTheme.textSecondary),
        const SizedBox(height: 12),
        const Text('需要存储权限来扫描本地音乐',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
        const SizedBox(height: 10),
        NeuButton(onPressed: () => p.loadLocalSongs(), child: const Text('授予权限')),
      ]));
    }
    if (p.localSongs.isEmpty) {
      return Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.library_music,
            size: 48, color: AppTheme.textSecondary),
        const SizedBox(height: 12),
        const Text('未找到本地音乐文件',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
        const SizedBox(height: 10),
        NeuButton(
            onPressed: () => p.loadLocalSongs(), child: const Text('重新扫描')),
      ]));
    }
    return RefreshIndicator(
      color: AppTheme.accentMint,
      onRefresh: () => p.loadLocalSongs(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 100),
        itemCount: p.localSongs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 4),
        itemBuilder: (_, i) {
          final s = p.localSongs[i];
          return SongTile(
            song: s,
            isPlaying: p.currentSong?.id == s.id,
            onTap: () async {
              await p.playSong(s, playlist: p.localSongs);
              if (context.mounted) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const FullPlayerPage()));
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildFavoriteList(MusicProvider p, List songs) {
    if (songs.isEmpty) {
      return Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.favorite_border,
            size: 48, color: AppTheme.textSecondary),
        const SizedBox(height: 12),
        const Text('还没有收藏的歌曲',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
        const SizedBox(height: 8),
        const Text('播放时点击 ❤️ 收藏',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
      ]));
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 100),
      itemCount: songs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 4),
      itemBuilder: (_, i) {
        final s = songs[i];
        return SongTile(
          song: s,
          isPlaying: p.currentSong?.id == s.id,
          onTap: () async {
            await p.playSong(s, playlist: p.favoriteSongs);
            if (context.mounted) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const FullPlayerPage()));
            }
          },
        );
      },
    );
  }
}
