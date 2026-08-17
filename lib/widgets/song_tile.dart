import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../theme/app_theme.dart';
import '../models/song.dart';

class SongTile extends StatelessWidget {
  final Song song; final VoidCallback onTap; final bool isPlaying;
  const SongTile({super.key, required this.song, required this.onTap, this.isPlaying = false});
  @override Widget build(BuildContext context) => NeuBox(borderRadius: 14, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    child: ListTile(onTap: onTap, contentPadding: EdgeInsets.zero, leading: _leading(),
      title: Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: isPlaying ? AppTheme.accentMint : AppTheme.textPrimary, fontWeight: isPlaying ? FontWeight.bold : FontWeight.w500)),
      subtitle: Text('${song.artist}${song.duration > 0 ? '  ·  ${song.durationText}' : ''}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
      trailing: isPlaying ? const Icon(Icons.graphic_eq, color: AppTheme.accentMint) : Icon(song.isOnline ? Icons.cloud : Icons.music_note, color: AppTheme.textSecondary, size: 20)));
  Widget _leading() {
    if (song.albumArt != null && song.albumArt!.isNotEmpty) {
      if (song.isOnline) return ClipRRect(borderRadius: BorderRadius.circular(8), child: CachedNetworkImage(imageUrl: song.albumArt!, width: 48, height: 48, fit: BoxFit.cover, placeholder: (_, __) => _ph(), errorWidget: (_, __, ___) => _ph()));
      if (song.albumArt!.startsWith('artwork_')) { final id = int.tryParse(song.albumArt!.split('_').last) ?? 0; return ClipRRect(borderRadius: BorderRadius.circular(8), child: QueryArtworkWidget(id: id, type: ArtworkType.AUDIO, artworkWidth: 48, artworkHeight: 48, artworkFit: BoxFit.cover, nullArtworkWidget: _ph())); }
    }
    return _ph();
  }
  Widget _ph() => Container(width: 48, height: 48, decoration: BoxDecoration(color: AppTheme.bgColor, borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), offset: const Offset(2, 2), blurRadius: 4)]), child: const Icon(Icons.music_note, color: AppTheme.accentMint, size: 24));
}
