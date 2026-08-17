class Song {
  final String id;
  final String title;
  final String artist;
  final String album;
  final Duration duration;
  final String? filePath;
  final String? coverUrl;
  final String? lyricsUrl;
  final bool isOnline;
  final int? fileSize;
  final String? url;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    this.filePath,
    this.coverUrl,
    this.lyricsUrl,
    this.isOnline = false,
    this.fileSize,
    this.url,
  });

  Song copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    Duration? duration,
    String? filePath,
    String? coverUrl,
    String? lyricsUrl,
    bool? isOnline,
    int? fileSize,
    String? url,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      duration: duration ?? this.duration,
      filePath: filePath ?? this.filePath,
      coverUrl: coverUrl ?? this.coverUrl,
      lyricsUrl: lyricsUrl ?? this.lyricsUrl,
      isOnline: isOnline ?? this.isOnline,
      fileSize: fileSize ?? this.fileSize,
      url: url ?? this.url,
    );
  }
}
