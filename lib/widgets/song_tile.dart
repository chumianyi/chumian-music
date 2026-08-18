import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/song.dart';
import '../theme/neumorphism.dart';

class SongTile extends StatelessWidget {
  final Song song;
  final bool isPlaying;
  final VoidCallback onTap;

  const SongTile(
      {super.key,
      required this.song,
      this.isPlaying = false,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: NeuCard(
        onTap: onTap,
        child: ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 44,
              height: 44,
              child: _buildCover(),
            ),
          ),
          title: Text(song.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: isPlaying
                      ? const Color(0xFF6B8E7F)
                      : const Color(0xFF333333))),
          subtitle: Text('${song.artist} · ${_fmt(song.duration)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
                  const TextStyle(color: Color(0xFF888888), fontSize: 11)),
          trailing: isPlaying
              ? const Icon(Icons.graphic_eq, color: Color(0xFF6B8E7F))
              : const Icon(Icons.play_arrow, color: Color(0xFF7C8BA0)),
        ),
      ),
    );
  }

  Widget _buildCover() {
    if (song.coverUrl != null && song.coverUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: song.coverUrl!,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          color: const Color(0xFFE0E5EC),
          child: const Icon(Icons.music_note,
              color: Color(0xFF7C8BA0), size: 20),
        ),
        errorWidget: (_, __, ___) => Container(
          color: const Color(0xFFE0E5EC),
          child: Icon(
              song.isOnline ? Icons.cloud : Icons.music_note,
              color: const Color(0xFF7C8BA0),
              size: 20),
        ),
      );
    }
    return Container(
      color: const Color(0xFFE0E5EC),
      child: Icon(song.isOnline ? Icons.cloud : Icons.music_note,
          color: const Color(0xFF7C8BA0), size: 20),
    );
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
