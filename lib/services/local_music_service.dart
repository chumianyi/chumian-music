import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../models/song.dart';

class LocalMusicService {
  static const List<String> _extensions = [
    '.mp3', '.flac', '.wav', '.aac', '.ogg', '.m4a', '.wma', '.opus'
  ];

  Future<bool> requestPermission() async {
    if (Platform.isIOS) return true; // iOS 沙箱内无需权限
    if (!Platform.isAndroid) return true;
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    final sdkInt = androidInfo.version.sdkInt;
    if (sdkInt >= 33) {
      final status = await Permission.audio.request();
      if (status.isGranted) return true;
      final manageStatus = await Permission.manageExternalStorage.request();
      return manageStatus.isGranted;
    } else {
      final status = await Permission.storage.request();
      if (status.isGranted) return true;
      final manageStatus = await Permission.manageExternalStorage.request();
      return manageStatus.isGranted;
    }
  }

  Future<List<Song>> scanLocalMusic() async {
    final List<Song> songs = [];
    final Set<String> seen = {};
    final List<Directory> dirs = [];

    if (Platform.isIOS) {
      // iOS 沙箱：只能扫描 App 自己的 Documents 目录
      try {
        final docsDir = await getApplicationDocumentsDirectory();
        dirs.add(docsDir);
        // 也扫描 tmp 目录（用户可能通过文件 App 导入）
        final tmpDir = await getTemporaryDirectory();
        dirs.add(tmpDir);
      } catch (e) {
        print('iOS get directories error: $e');
      }
    } else {
      // Android：扫描内部存储
      const primaryPaths = ['/storage/emulated/0', '/sdcard'];
      for (final p in primaryPaths) {
        final d = Directory(p);
        if (await d.exists()) {
          if (!dirs.any((existing) => existing.path == d.path)) dirs.add(d);
        }
      }
      try {
        final extDirs = await getExternalStorageDirectories();
        if (extDirs != null) {
          for (final d in extDirs) {
            if (!dirs.any((existing) => existing.path == d.path)) dirs.add(d);
          }
        }
      } catch (_) {}
    }

    for (final dir in dirs) {
      try {
        await for (final entity
            in dir.list(recursive: true, followLinks: false)) {
          if (entity is File) {
            if (Platform.isAndroid && entity.path.contains('/Android/')) continue;
            final path = entity.path.toLowerCase();
            if (_extensions.any((ext) => path.endsWith(ext))) {
              if (seen.contains(entity.path)) continue;
              seen.add(entity.path);
              try {
                final stat = await entity.stat();
                final name = entity.path.split('/').last;
                songs.add(Song(
                  id: 'local_${entity.path.hashCode}',
                  title: name.replaceAll(RegExp(r'\.[^.]+$'), ''),
                  artist: '未知艺术家',
                  album: '本地音乐',
                  duration: Duration.zero,
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
