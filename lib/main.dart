import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audio_service/audio_service.dart';
import 'theme/app_theme.dart';
import 'providers/music_provider.dart';
import 'services/audio_player_service.dart';
import 'pages/main_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final audioHandler = await AudioService.init(
    builder: () => MusicAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.chumian.music.channel',
      androidNotificationChannelName: '初眠音乐播放',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );
  final musicProvider = MusicProvider();
  await musicProvider.init(audioHandler);
  runApp(
    ChangeNotifierProvider.value(
      value: musicProvider,
      child: const ChumianMusicApp(),
    ),
  );
}

class ChumianMusicApp extends StatelessWidget {
  const ChumianMusicApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '初眠音乐',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainPage(),
    );
  }
}
