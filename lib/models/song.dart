class Song {
  final String id;
  final String title;
  final String artist;
  final String? album;
  final String? albumArt;
  final String url;
  final int duration;
  final bool isOnline;
  final String? filePath;
  Song({required this.id, required this.title, required this.artist, this.album, this.albumArt, required this.url, this.duration = 0, this.isOnline = false, this.filePath});
  String get durationText {
    final min = duration ~/ 60000;
    final sec = (duration % 60000) ~/ 1000;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }
}
