import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/music_provider.dart';
import 'rotating_album.dart';

class FullPlayer extends StatefulWidget {
  const FullPlayer({super.key});

  @override
  State<FullPlayer> createState() => _FullPlayerState();
}

class _FullPlayerState extends State<FullPlayer> {
  bool _showLyrics = false;
  final ScrollController _lyricScroll = ScrollController();

  @override
  void dispose() {
    _lyricScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicProvider>(builder: (context, p, _) {
      final s = p.currentSong;
      return Container(
        decoration: const BoxDecoration(
          color: AppTheme.bgColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textSecondary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              // 封面 / 歌词 切换区域
              SizedBox(
                height: 260,
                child: _showLyrics
                    ? _buildLyricsView(p)
                    : RotatingAlbum(song: s, size: 220, playing: p.isPlaying),
              ),
              const SizedBox(height: 20),
              // 切换按钮
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _viewToggle(Icons.album, '封面', !_showLyrics, () {
                    setState(() => _showLyrics = false);
                  }),
                  const SizedBox(width: 16),
                  _viewToggle(Icons.lyrics, '歌词', _showLyrics, () {
                    setState(() => _showLyrics = true);
                  }),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                s?.title ?? '未在播放',
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(s?.artist ?? '',
                  style: const TextStyle(
                      fontSize: 14, color: AppTheme.textSecondary)),
              const SizedBox(height: 24),
              _progress(p),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  NeuButton(
                    onPressed: () => p.previous(),
                    padding: const EdgeInsets.all(14),
                    borderRadius: 20,
                    child: const Icon(Icons.skip_previous,
                        color: AppTheme.textPrimary, size: 28),
                  ),
                  const SizedBox(width: 16),
                  NeuButton(
                    onPressed: () => p.seekBackward(),
                    padding: const EdgeInsets.all(12),
                    borderRadius: 18,
                    child: const Icon(Icons.replay_10,
                        color: AppTheme.textPrimary, size: 24),
                  ),
                  const SizedBox(width: 16),
                  NeuButton(
                    onPressed: () => p.togglePlay(),
                    padding: const EdgeInsets.all(20),
                    borderRadius: 30,
                    color: AppTheme.accentMint,
                    child: Icon(
                        p.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 40),
                  ),
                  const SizedBox(width: 16),
                  NeuButton(
                    onPressed: () => p.seekForward(),
                    padding: const EdgeInsets.all(12),
                    borderRadius: 18,
                    child: const Icon(Icons.forward_10,
                        color: AppTheme.textPrimary, size: 24),
                  ),
                  const SizedBox(width: 16),
                  NeuButton(
                    onPressed: () => p.next(),
                    padding: const EdgeInsets.all(14),
                    borderRadius: 20,
                    child: const Icon(Icons.skip_next,
                        color: AppTheme.textPrimary, size: 28),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  NeuButton(
                    onPressed: () {
                      if (s != null) p.toggleFavorite(s.id);
                    },
                    padding: const EdgeInsets.all(10),
                    borderRadius: 16,
                    child: Icon(
                        s != null && p.isFavorite(s.id)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: s != null && p.isFavorite(s.id)
                            ? Colors.redAccent
                            : AppTheme.textSecondary,
                        size: 22),
                  ),
                  const SizedBox(width: 24),
                  NeuButton(
                    onPressed: () => ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(
                            content: Text('下载功能开发中'),
                            behavior: SnackBarBehavior.floating)),
                    padding: const EdgeInsets.all(10),
                    borderRadius: 16,
                    child: const Icon(Icons.download,
                        color: AppTheme.textSecondary, size: 22),
                  ),
                  const SizedBox(width: 24),
                  NeuButton(
                    onPressed: () => Navigator.pop(context),
                    padding: const EdgeInsets.all(10),
                    borderRadius: 16,
                    child: const Icon(Icons.expand_more,
                        color: AppTheme.textSecondary, size: 22),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ]),
          ),
        ),
      );
    });
  }

  Widget _viewToggle(
      IconData icon, String label, bool active, VoidCallback onTap) {
    return NeuButton(
      onPressed: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      borderRadius: 16,
      color: active ? AppTheme.accentMint.withOpacity(0.3) : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 16,
              color: active ? AppTheme.textPrimary : AppTheme.textSecondary),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
                color:
                    active ? AppTheme.textPrimary : AppTheme.textSecondary,
              )),
        ],
      ),
    );
  }

  Widget _buildLyricsView(MusicProvider p) {
    if (p.isLoadingLyrics) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.accentMint),
      );
    }
    if (p.lyrics.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lyrics_outlined,
                size: 48, color: AppTheme.textSecondary),
            SizedBox(height: 12),
            Text('暂无歌词',
                style: TextStyle(color: AppTheme.textSecondary)),
          ],
        ),
      );
    }
    // 自动滚动到当前歌词
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (p.currentLyricIndex >= 0 && _lyricScroll.hasClients) {
        final target = p.currentLyricIndex * 48.0;
        _lyricScroll.animateTo(
          target.clamp(0.0, _lyricScroll.position.maxScrollExtent),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
    return ListView.builder(
      controller: _lyricScroll,
      padding: const EdgeInsets.symmetric(vertical: 80),
      itemCount: p.lyrics.length,
      itemBuilder: (_, i) {
        final isCurrent = i == p.currentLyricIndex;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Text(
            p.lyrics[i].value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isCurrent ? 18 : 15,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              color: isCurrent
                  ? AppTheme.accentMint
                  : AppTheme.textSecondary.withOpacity(0.6),
            ),
          ),
        );
      },
    );
  }

  Widget _progress(MusicProvider p) => StreamBuilder<Duration>(
      stream: p.positionStream,
      builder: (_, ps) => StreamBuilder<Duration?>(
          stream: p.durationStream,
          builder: (_, ds) {
            final pos = ps.data ?? Duration.zero;
            final dur = ds.data ?? Duration.zero;
            final v = dur.inMilliseconds > 0
                ? pos.inMilliseconds / dur.inMilliseconds
                : 0.0;
            return Column(
              children: [
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 6,
                    thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 8),
                    activeTrackColor: AppTheme.accentMint,
                    inactiveTrackColor:
                        AppTheme.textSecondary.withOpacity(0.2),
                    thumbColor: AppTheme.accentMint,
                  ),
                  child: Slider(
                    value: v.clamp(0.0, 1.0),
                    onChanged: (val) {
                      if (dur.inMilliseconds > 0) {
                        p.seek(Duration(
                            milliseconds: (val * dur.inMilliseconds).toInt()));
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_fmt(pos),
                          style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 12)),
                      Text(_fmt(dur),
                          style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            );
          }));

  String _fmt(Duration d) =>
      '${d.inMinutes.toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
}
