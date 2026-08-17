import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/song.dart';

class LocalMusicService {
  static const List<String> _extensions = ['.mp3', '.flac', '.wav', '.aac', '.ogg', '.m4a', '.wma', '.opus', '.midi', '.amr'];

  Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        final status = await Permission.audio.request();
        return status.isGranted;
      } else {
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    }
    return true;
  }

  Future<List<Song>> scanLocalMusic() async {
    final List<Song> songs = [];
    final List<Directory> dirs = [];

    try {
      final extDirs = await getExternalStorageDirectories();
      if (extDirs != null) dirs.addAll(extDirs);
    } catch (_) {}

    try {
      final appDir = await getApplicationDocumentsDirectory();
      dirs.add(appDir);
    } catch (_) {}

    // Also try common music directories
    const commonPaths = ['/storage/emulated/0/Music', '/storage/emulated/0/Download', '/sdcard/Music', '/sdcard/Download'];
    for (final p in commonPaths) {
      final d = Directory(p);
      if (await d.exists()) dirs.add(d);
    }

    final Set<String> seen = {};
    for (final dir in dirs) {
      try {
        await for (final entity in dir.list(recursive: true, followLinks: false)) {
          if (entity is File) {
            final path = entity.path.toLowerCase();
            if (_extensions.any((ext) => path.endsWith(ext))) {
              if (seen.contains(entity.path)) continue;
              seen.add(entity.path);
              try {
                final stat = await entity.stat();
                final name = entity.uri.pathSegments.isEmpty ? entity.path.split('/').last : entity.uri.pathSegments.last;
                songs.add(Song(
                  id: 'local_${entity.path.hashCode}',
                  title: name.replaceAll(RegExp(r'\.[^.]+$'), ''),
                  artist: '未知艺术家',
                  album: '本地音乐',
                  duration: const Duration(seconds: 0),
                  filePath: entity.path,
                  isOnline: false,
                  fileSize: stat.size,
                ));
              } catch (_) {}
            }
          }
        }
      } catch (_) {}
    }
    return songs;
  }
}

class DeviceInfoPlugin {
  Future<AndroidInfo> get androidInfo async => AndroidInfo();
}

class AndroidInfo {
  final AndroidVersion version = AndroidVersion();
}

class AndroidVersion {
  final int sdkInt = 33;
}
