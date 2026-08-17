import 'package:flutter/material.dart';
import '../models/song.dart';
import '../theme/neumorphism.dart';

class SongTile extends StatelessWidget {
  final Song song;
  final bool isPlaying;
  final VoidCallback onTap;
  const SongTile({super.key, required this.song, this.isPlaying = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: NeuCard(
        onTap: onTap,
        child: ListTile(
          leading: Container(
            width: 48, height: 48,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: const Color(0xFFE0E5EC), boxShadow: NeuTheme.insetShadows),
            child: Icon(song.isOnline ? Icons.cloud : Icons.music_note, color: isPlaying ? const Color(0xFF6B8E7F) : const Color(0xFF7C8BA0)),
          ),
          title: Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w600, color: isPlaying ? const Color(0xFF6B8E7F) : const Color(0xFF333333))),
          subtitle: Text('${song.artist} · ${_fmt(song.duration)}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF888888), fontSize: 12)),
          trailing: isPlaying ? const Icon(Icons.graphic_eq, color: Color(0xFF6B8E7F)) : const Icon(Icons.play_arrow, color: Color(0xFF7C8BA0)),
        ),
      ),
    );
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
