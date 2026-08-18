import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/music_provider.dart';
import '../widgets/mini_player.dart';
import 'online_music_page.dart';
import 'local_music_page.dart';
import 'search_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override State<MainPage> createState() => _MainPageState();
}
class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  final List<Widget> _pages = const [OnlineMusicPage(), LocalMusicPage(), SearchPage()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: SafeArea(child: Column(children: [Expanded(child: _pages[_currentIndex]), const MiniPlayer()])),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: AppTheme.bgColor, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), offset: const Offset(0, -3), blurRadius: 8)]),
        child: SafeArea(child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_navItem(Icons.music_note, '音乐', 0), _navItem(Icons.library_music, '播放列表', 1), _navItem(Icons.search, '搜索', 2)])),
      ),
    );
  }
  Widget _navItem(IconData icon, String label, int index) {
    final sel = _currentIndex == index;
    return GestureDetector(onTap: () => setState(() => _currentIndex = index),
      child: NeuBox(pressed: sel, borderRadius: 12, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), color: sel ? AppTheme.accentMint.withOpacity(0.3) : null,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: sel ? AppTheme.accentMint : AppTheme.textSecondary, size: 20),
          const SizedBox(height: 3),
          Text(label, style: TextStyle(fontSize: 10, color: sel ? AppTheme.textPrimary : AppTheme.textSecondary, fontWeight: sel ? FontWeight.bold : FontWeight.normal)),
        ])));
  }
}
