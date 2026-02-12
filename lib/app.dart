import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/settings/providers/settings_provider.dart';
import 'ui/screens/common/main_screen.dart';
import 'ui/themes/app_theme.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return MaterialApp(
      title: '明日方舟PC快捷键修改器',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settingsProvider.getThemeMode(), // ✅ 动态主题模式
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
