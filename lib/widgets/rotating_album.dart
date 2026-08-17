import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/song.dart';

class RotatingAlbum extends StatefulWidget {
  final Song? song;
  final double size;
  final bool playing;
  const RotatingAlbum({super.key, required this.song, this.size = 200, this.playing = false});

  @override
  State<RotatingAlbum> createState() => _RotatingAlbumState();
}

class _RotatingAlbumState extends State<RotatingAlbum> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 8));
    if (widget.playing) _ctrl.repeat();
  }

  @override
  void didUpdateWidget(RotatingAlbum old) {
    super.didUpdateWidget(old);
    if (widget.playing) _ctrl.repeat(); else _ctrl.stop();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _ctrl,
      child: Container(
        width: widget.size, height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFE0E5EC),
          boxShadow: const [
            BoxShadow(color: Color(0xFFFFFFFF), blurRadius: 15, offset: Offset(-5, -5)),
            BoxShadow(color: Color(0xFFA3B1C6), blurRadius: 15, offset: Offset(5, 5)),
          ],
        ),
        child: ClipOval(child: _buildImage()),
      ),
    );
  }

  Widget _buildImage() {
    final s = widget.song;
    if (s == null) return const Icon(Icons.music_note, size: 60, color: Color(0xFF7C8BA0));
    if (s.coverUrl != null && s.coverUrl!.isNotEmpty) {
      return CachedNetworkImage(imageUrl: s.coverUrl!, fit: BoxFit.cover, errorWidget: (_, __, ___) => const Icon(Icons.music_note, size: 60, color: Color(0xFF7C8BA0)));
    }
    if (s.filePath != null && File(s.filePath!).existsSync()) {
      return const Icon(Icons.music_note, size: 60, color: Color(0xFF7C8BA0));
    }
    return const Icon(Icons.music_note, size: 60, color: Color(0xFF7C8BA0));
  }
}
