import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/music_provider.dart';
import 'rotating_album.dart';

class FullPlayer extends StatelessWidget {
  const FullPlayer({super.key});
  @override Widget build(BuildContext context) => Consumer<MusicProvider>(builder: (context, p, _) {
    final s = p.currentSong;
    return Container(decoration: const BoxDecoration(color: AppTheme.bgColor, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      child: SafeArea(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.textSecondary.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 24),
        RotatingAlbum(song: s, size: 220, isPlaying: p.isPlaying),
        const SizedBox(height: 32),
        Text(s?.title ?? '未在播放', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 8),
        Text(s?.artist ?? '', style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
        const SizedBox(height: 24),
        _progress(p),
        const SizedBox(height: 24),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          NeuButton(onPressed: () => p.previous(), padding: const EdgeInsets.all(14), borderRadius: 20, child: const Icon(Icons.skip_previous, color: AppTheme.textPrimary, size: 28)),
          const SizedBox(width: 16),
          NeuButton(onPressed: () => p.seekBackward(), padding: const EdgeInsets.all(12), borderRadius: 18, child: const Icon(Icons.replay_10, color: AppTheme.textPrimary, size: 24)),
          const SizedBox(width: 16),
          NeuButton(onPressed: () => p.togglePlay(), padding: const EdgeInsets.all(20), borderRadius: 30, color: AppTheme.accentMint, child: Icon(p.isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 40)),
          const SizedBox(width: 16),
          NeuButton(onPressed: () => p.seekForward(), padding: const EdgeInsets.all(12), borderRadius: 18, child: const Icon(Icons.forward_10, color: AppTheme.textPrimary, size: 24)),
          const SizedBox(width: 16),
          NeuButton(onPressed: () => p.next(), padding: const EdgeInsets.all(14), borderRadius: 20, child: const Icon(Icons.skip_next, color: AppTheme.textPrimary, size: 28)),
        ]),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          NeuButton(onPressed: () { if (s != null) p.toggleFavorite(s.id); }, padding: const EdgeInsets.all(10), borderRadius: 16, child: Icon(s != null && p.isFavorite(s.id) ? Icons.favorite : Icons.favorite_border, color: s != null && p.isFavorite(s.id) ? Colors.redAccent : AppTheme.textSecondary, size: 22)),
          const SizedBox(width: 24),
          NeuButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('下载功能开发中'), behavior: SnackBarBehavior.floating)), padding: const EdgeInsets.all(10), borderRadius: 16, child: const Icon(Icons.download, color: AppTheme.textSecondary, size: 22)),
          const SizedBox(width: 24),
          NeuButton(onPressed: () => Navigator.pop(context), padding: const EdgeInsets.all(10), borderRadius: 16, child: const Icon(Icons.expand_more, color: AppTheme.textSecondary, size: 22)),
        ]),
        const SizedBox(height: 16),
      ]))));
  });
  Widget _progress(MusicProvider p) => StreamBuilder<Duration>(stream: p.positionStream, builder: (_, ps) => StreamBuilder<Duration?>(stream: p.durationStream, builder: (_, ds) {
    final pos = ps.data ?? Duration.zero; final dur = ds.data ?? Duration.zero;
    final v = dur.inMilliseconds > 0 ? pos.inMilliseconds / dur.inMilliseconds : 0.0;
    return Column(children: [
      SliderTheme(data: SliderThemeData(trackHeight: 6, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8), activeTrackColor: AppTheme.accentMint, inactiveTrackColor: AppTheme.textSecondary.withOpacity(0.2), thumbColor: AppTheme.accentMint),
        child: Slider(value: v.clamp(0.0, 1.0), onChanged: (val) { if (dur.inMilliseconds > 0) p.seek(Duration(milliseconds: (val * dur.inMilliseconds).toInt())); })),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(_fmt(pos), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)), Text(_fmt(dur), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12))])),
    ]);
  }));
  String _fmt(Duration d) => '${d.inMinutes.toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
}
