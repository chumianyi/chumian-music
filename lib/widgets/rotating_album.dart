import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../theme/app_theme.dart';
import '../models/song.dart';

class RotatingAlbum extends StatefulWidget {
  final Song? song; final double size; final bool isPlaying;
  const RotatingAlbum({super.key, required this.song, this.size = 200, this.isPlaying = false});
  @override State<RotatingAlbum> createState() => _RotatingAlbumState();
}
class _RotatingAlbumState extends State<RotatingAlbum> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override void initState() { super.initState(); _c = AnimationController(vsync: this, duration: const Duration(seconds: 20)); }
  @override void didUpdateWidget(RotatingAlbum old) { super.didUpdateWidget(old); if (widget.isPlaying) _c.repeat(); else _c.stop(); }
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => RotationTransition(turns: _c, child: Container(width: widget.size, height: widget.size, decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.bgColor,
    boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.9), offset: const Offset(-6, -6), blurRadius: 15), BoxShadow(color: Colors.black.withOpacity(0.15), offset: const Offset(6, 6), blurRadius: 15)]),
    child: ClipOval(child: _buildImg())));
  Widget _buildImg() {
    final s = widget.song;
    if (s == null) return Container(color: AppTheme.bgColor, child: const Icon(Icons.music_note, size: 60, color: AppTheme.accentMint));
    if (s.albumArt != null && s.albumArt!.isNotEmpty) {
      if (s.isOnline) return CachedNetworkImage(imageUrl: s.albumArt!, fit: BoxFit.cover, placeholder: (_, __) => _ph(), errorWidget: (_, __, ___) => _ph());
      if (s.albumArt!.startsWith('artwork_')) { final id = int.tryParse(s.albumArt!.split('_').last) ?? 0; return QueryArtworkWidget(id: id, type: ArtworkType.AUDIO, artworkWidth: widget.size, artworkHeight: widget.size, artworkFit: BoxFit.cover, nullArtworkWidget: _ph()); }
    }
    if (s.filePath != null) return QueryArtworkWidget(id: int.tryParse(s.id) ?? 0, type: ArtworkType.AUDIO, artworkWidth: widget.size, artworkHeight: widget.size, artworkFit: BoxFit.cover, nullArtworkWidget: _ph());
    return _ph();
  }
  Widget _ph() => Container(color: AppTheme.bgColor, child: const Icon(Icons.music_note, size: 60, color: AppTheme.accentMint));
}
