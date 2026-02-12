import 'package:flutter/material.dart';
import 'key_setting_screen.dart';
import 'intro_screen.dart';
import 'document_screen.dart';
import 'about_screen.dart';

/// 主界面 – 左侧导航栏 + 右侧页面视图
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // 默认选中页面
  final PageController _pageController = PageController(initialPage: 1);

  static const List<Widget> _pages = [
    IntroScreen(),
    KeySettingScreen(),
    DocumentScreen(),
    AboutScreen(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Row(
        children: [
          // ---------- 左侧导航栏 ----------
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
              _pageController.jumpToPage(index);
            },
            labelType: NavigationRailLabelType.selected,
            leading: const SizedBox(height: 40), // 顶部留白
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.info_outline),
                selectedIcon: Icon(Icons.info),
                label: Text('介绍'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.keyboard_outlined),
                selectedIcon: Icon(Icons.keyboard),
                label: Text('键位'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.description_outlined),
                selectedIcon: Icon(Icons.description),
                label: Text('文档'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: Text('关于'),
              ),
            ],
            backgroundColor: isDark ? Colors.grey[900] : Colors.white,
            selectedIconTheme: IconThemeData(color: colorScheme.primary),
            unselectedIconTheme: IconThemeData(
              color: isDark ? Colors.grey[400] : Colors.grey.shade600,
            ),
            selectedLabelTextStyle: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelTextStyle: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey.shade600,
            ),
            elevation: 4,
          ),
          // ---------- 右侧内容区 ----------
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              children: _pages,
            ),
          ),
        ],
      ),
    );
  }
}
