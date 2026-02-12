import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/key_settings/providers/key_settings_provider.dart';
import 'features/settings/providers/settings_provider.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化设置管理器并加载配置
  final settingsProvider = SettingsProvider();
  await settingsProvider.loadSettings();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => KeySettingsProvider()..loadSettings(),
        ),
        ChangeNotifierProvider.value(value: settingsProvider), // 使用已初始化的实例
      ],
      child: const MyApp(),
    ),
  );
}
