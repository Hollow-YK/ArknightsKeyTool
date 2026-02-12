import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/key_settings/providers/key_settings_provider.dart';
import '/ui/screens/common/main_screen.dart';
import 'ui/themes/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => KeySettingsProvider()..loadSettings(),
      child: MaterialApp(
        title: '明日方舟PC快捷键修改器',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const MainScreen(), // ✅ 使用新的主界面
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
