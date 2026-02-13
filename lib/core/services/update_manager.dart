import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

/// 更新管理器 - 管理更新渠道和镜像设置（单例模式，使用文件存储）
class UpdateManager {
  static final UpdateManager _instance = UpdateManager._internal();
  factory UpdateManager() => _instance;
  UpdateManager._internal();

  static const String _appDirName = 'Hollow';
  static const String _subDirName = 'ArknightsKeyTool';
  static const String _fileName = 'update_settings.json';

  static const String _defaultChannel = 'github';
  static const bool _defaultUseMirror = false;
  static const String _defaultMirrorUrl = 'https://mirror.ghproxy.com/';

  String _updateChannel = _defaultChannel;
  bool _useMirror = _defaultUseMirror;
  String _mirrorUrl = _defaultMirrorUrl;

  /// 当前更新渠道
  String get updateChannel => _updateChannel;

  /// 是否使用镜像
  bool get useMirror => _useMirror;

  /// 镜像地址
  String get mirrorUrl => _mirrorUrl;

  /// 获取配置文件目录
  Future<Directory> _getAppDataDirectory() async {
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
    final appSupport = await path_provider.getApplicationSupportDirectory();
    final dir = Directory('${appSupport.path}/$_appDirName/$_subDirName');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// 加载设置
  Future<void> init() async {
    try {
      final dir = await _getAppDataDirectory();
      final file = File('${dir.path}\\$_fileName');
      if (await file.exists()) {
        final content = await file.readAsString();
        final json = jsonDecode(content) as Map<String, dynamic>;
        _updateChannel = json['updateChannel'] as String? ?? _defaultChannel;
        _useMirror = json['useMirror'] as bool? ?? _defaultUseMirror;
        _mirrorUrl = json['mirrorUrl'] as String? ?? _defaultMirrorUrl;
      } else {
        // 使用默认值，不创建文件（等用户修改时再保存）
      }
    } catch (e) {
      debugPrint('加载更新设置失败: $e');
    }
  }

  /// 保存设置
  Future<void> _save() async {
    try {
      final dir = await _getAppDataDirectory();
      final file = File('${dir.path}\\$_fileName');
      final json = {
        'updateChannel': _updateChannel,
        'useMirror': _useMirror,
        'mirrorUrl': _mirrorUrl,
      };
      await file.writeAsString(jsonEncode(json));
    } catch (e) {
      debugPrint('保存更新设置失败: $e');
    }
  }

  /// 获取版本检查URL
  String getVersionCheckUrl({required bool isBeta}) {
    final String baseUrl;

    if (_updateChannel == 'gitee') {
      baseUrl = isBeta
          ? 'https://gitee.com/Hollow-YK/ArknightsKeyTool/raw/dev/version.json'
          : 'https://gitee.com/Hollow-YK/ArknightsKeyTool/raw/main/version.json';
    } else {
      final String githubUrl = isBeta
          ? 'https://raw.githubusercontent.com/Hollow-YK/ArknightsKeyTool/dev/version.json'
          : 'https://raw.githubusercontent.com/Hollow-YK/ArknightsKeyTool/main/version.json';

      if (_useMirror && _mirrorUrl.isNotEmpty) {
        final String mirror = _mirrorUrl.endsWith('/')
            ? _mirrorUrl
            : '$_mirrorUrl/';
        baseUrl = '$mirror$githubUrl';
      } else {
        baseUrl = githubUrl;
      }
    }

    return baseUrl;
  }

  /// 获取GitHub Release页面URL
  String getGitHubReleaseUrl() {
    const String githubReleaseUrl =
        'https://github.com/Hollow-YK/ArknightsKeyTool/releases';

    if (_updateChannel == 'github' && _useMirror && _mirrorUrl.isNotEmpty) {
      final String mirror = _mirrorUrl.endsWith('/')
          ? _mirrorUrl
          : '$_mirrorUrl/';
      return '$mirror$githubReleaseUrl';
    }

    return githubReleaseUrl;
  }

  /// 设置更新渠道
  Future<void> setUpdateChannel(String channel) async {
    if (_updateChannel != channel) {
      _updateChannel = channel;
      await _save();
    }
  }

  /// 设置是否使用镜像
  Future<void> setUseMirror(bool use) async {
    if (_useMirror != use) {
      _useMirror = use;
      await _save();
    }
  }

  /// 设置镜像地址
  Future<void> setMirrorUrl(String url) async {
    final trimmedUrl = url.trim();
    if (_mirrorUrl != trimmedUrl) {
      _mirrorUrl = trimmedUrl;
      await _save();
    }
  }

  /// 测试镜像连接
  Future<bool> testMirrorConnection() async {
    // 这里可以添加实际的网络测试逻辑
    // 暂时简单验证URL格式
    return _mirrorUrl.isNotEmpty &&
        (_mirrorUrl.startsWith('http://') || _mirrorUrl.startsWith('https://'));
  }

  /// 重置为默认设置
  Future<void> resetToDefaults() async {
    _updateChannel = _defaultChannel;
    _useMirror = _defaultUseMirror;
    _mirrorUrl = _defaultMirrorUrl;
    await _save();
  }
}

/// URL验证辅助函数
bool isValidUrl(String url) {
  return url.isNotEmpty &&
      (url.startsWith('http://') || url.startsWith('https://'));
}
