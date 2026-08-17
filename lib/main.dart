import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audio_service/audio_service.dart';
import 'theme/app_theme.dart';
import 'providers/music_provider.dart';
import 'services/audio_player_service.dart';
import 'pages/main_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };

  runApp(const ChumianMusicApp());
}

class ChumianMusicApp extends StatefulWidget {
  const ChumianMusicApp({super.key});

  @override
  State<ChumianMusicApp> createState() => _ChumianMusicAppState();
}

class _ChumianMusicAppState extends State<ChumianMusicApp> {
  MusicProvider? _musicProvider;
  bool _initialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final audioHandler = await AudioService.init(
        builder: () => MusicAudioHandler(),
        config: const AudioServiceConfig(
          androidNotificationChannelId: 'com.chumian.music.channel',
          androidNotificationChannelName: '初眠音乐播放',
          androidNotificationOngoing: true,
          androidStopForegroundOnPause: true,
        ),
      );
      final provider = MusicProvider();
      await provider.init(audioHandler);
      if (mounted) {
        setState(() {
          _musicProvider = provider;
          _initialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _initialized = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '初眠音乐',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: _buildHome(),
    );
  }

  Widget _buildHome() {
    if (!_initialized) {
      return const Scaffold(
        backgroundColor: AppTheme.bgColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.music_note, size: 64, color: AppTheme.accentMint),
              SizedBox(height: 24),
              CircularProgressIndicator(color: AppTheme.accentMint),
              SizedBox(height: 16),
              Text('正在加载...', style: TextStyle(color: AppTheme.textSecondary)),
            ],
          ),
        ),
      );
    }

    if (_error != null || _musicProvider == null) {
      return Scaffold(
        backgroundColor: AppTheme.bgColor,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
                const SizedBox(height: 16),
                const Text('初始化失败', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                const SizedBox(height: 8),
                Text(_error ?? '未知错误', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13), textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentMint),
                  onPressed: () {
                    setState(() {
                      _initialized = false;
                      _error = null;
                      _musicProvider = null;
                    });
                    _init();
                  },
                  child: const Text('重试', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ChangeNotifierProvider.value(
      value: _musicProvider!,
      child: const MainPage(),
    );
  }
}
