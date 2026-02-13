import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

/// 应用设置模型
class AppSettings {
  String themeMode = 'system'; // system, light, dark

  AppSettings({this.themeMode = 'system'});

  Map<String, dynamic> toJson() => {'themeMode': themeMode};

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(themeMode: json['themeMode'] as String? ?? 'system');
  }
}

/// 设置管理器 - 负责读写 %APPDATA%/Hollow/ArknightsKeyTool/settings.json
class SettingsManager {
  static const String _appDirName = 'Hollow';
  static const String _subDirName = 'ArknightsKeyTool';
  static const String _fileName = 'settings.json';

  static SettingsManager? _instance;
  static SettingsManager get instance =>
      _instance ??= SettingsManager._internal();

  AppSettings _settings = AppSettings();
  AppSettings get settings => _settings;

  SettingsManager._internal();

  /// 获取配置文件目录
  Future<Directory> _getAppDataDirectory() async {
    // Windows 专用：使用 %APPDATA%
    if (Platform.isWindows) {
      final appData = Platform.environment['APPDATA'];
      if (appData != null) {
        final dir = Directory('$appData\\$_appDirName\\$_subDirName');
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
        return dir;
      }
    }
    // 其他平台回退到 getApplicationSupportDirectory
    final appSupport = await path_provider.getApplicationSupportDirectory();
    final dir = Directory('${appSupport.path}/$_appDirName/$_subDirName');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// 加载设置
  Future<void> load() async {
    try {
      final dir = await _getAppDataDirectory();
      final file = File('${dir.path}\\$_fileName');
      if (await file.exists()) {
        final content = await file.readAsString();
        final json = jsonDecode(content) as Map<String, dynamic>;
        _settings = AppSettings.fromJson(json);
      } else {
        _settings = AppSettings(); // 默认
      }
    } catch (e) {
      debugPrint('加载设置失败: $e');
      _settings = AppSettings(); // 出错时使用默认
    }
  }

  /// 保存设置
  Future<void> save() async {
    try {
      final dir = await _getAppDataDirectory();
      final file = File('${dir.path}\\$_fileName');
      final jsonString = jsonEncode(_settings.toJson());
      await file.writeAsString(jsonString);
    } catch (e) {
      debugPrint('保存设置失败: $e');
    }
  }

  /// 更新主题模式并保存
  Future<void> setThemeMode(String mode) async {
    if (_settings.themeMode != mode) {
      _settings.themeMode = mode;
      await save();
    }
  }
}
