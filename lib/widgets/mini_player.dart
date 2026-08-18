import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/music_provider.dart';
import '../pages/full_player_page.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) =>
      Consumer<MusicProvider>(builder: (context, p, _) {
        final s = p.currentSong;
        if (s == null) return const SizedBox.shrink();
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FullPlayerPage()),
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            child: NeuBox(
              borderRadius: 14,
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Row(children: [
                const Icon(Icons.music_note,
                    color: AppTheme.accentMint, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(s.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13)),
                      Text(s.artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 11)),
                    ],
                  ),
                ),
                NeuButton(
                  onPressed: () => p.previous(),
                  padding: const EdgeInsets.all(6),
                  borderRadius: 12,
                  child: const Icon(Icons.skip_previous,
                      color: AppTheme.textPrimary, size: 18),
                ),
                const SizedBox(width: 6),
                NeuButton(
                  onPressed: () => p.togglePlay(),
                  padding: const EdgeInsets.all(8),
                  borderRadius: 14,
                  color: AppTheme.accentMint,
                  child: Icon(
                      p.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 20),
                ),
                const SizedBox(width: 6),
                NeuButton(
                  onPressed: () => p.next(),
                  padding: const EdgeInsets.all(6),
                  borderRadius: 12,
                  child: const Icon(Icons.skip_next,
                      color: AppTheme.textPrimary, size: 18),
                ),
              ]),
            ),
          ),
        );
      });
}
