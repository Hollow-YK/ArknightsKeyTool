import 'package:flutter/material.dart';
import '../../../core/config/app_settings.dart';

/// 设置状态管理器
class SettingsProvider extends ChangeNotifier {
  final SettingsManager _manager = SettingsManager.instance;
  AppSettings _settings = AppSettings();

  AppSettings get settings => _settings;
  String get themeMode => _settings.themeMode;

  /// 初始化加载设置
  Future<void> loadSettings() async {
    await _manager.load();
    _settings = _manager.settings;
    notifyListeners();
  }

  /// 设置主题模式
  Future<void> setThemeMode(String mode) async {
    await _manager.setThemeMode(mode);
    _settings = _manager.settings;
    notifyListeners();
  }

  /// 根据存储的主题模式获取 ThemeMode 枚举
  ThemeMode getThemeMode() {
    switch (_settings.themeMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}
