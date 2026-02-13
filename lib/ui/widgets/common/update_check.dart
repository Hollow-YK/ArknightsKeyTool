import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:arknights_key_tool/core/services/update_manager.dart';

// 本地版本常量（请根据实际发布版本修改）
const String LOCAL_VERSION = "1.0.0";
const String LOCAL_VERSION_CODE = "1";
const String LOCAL_CORE_VERSION_CODE = "1";
const bool IS_BETA = false;

class VersionInfo {
  final String version;
  final String versionCode;
  final String changelog;

  VersionInfo({
    required this.version,
    required this.versionCode,
    required this.changelog,
  });
}

class RemoteVersionData {
  final VersionInfo release;
  final VersionInfo beta;
  final VersionInfo core;

  RemoteVersionData({
    required this.release,
    required this.beta,
    required this.core,
  });

  factory RemoteVersionData.fromJson(Map<String, dynamic> json) {
    return RemoteVersionData(
      release: VersionInfo(
        version: json['release']['version'] ?? '',
        versionCode: json['release']['versioncode'] ?? '0',
        changelog: json['release']['changelog'] ?? '',
      ),
      beta: VersionInfo(
        version: json['beta']['version'] ?? '',
        versionCode: json['beta']['versioncode'] ?? '0',
        changelog: json['beta']['changelog'] ?? '',
      ),
      core: VersionInfo(
        version: json['core']['version'] ?? '',
        versionCode: json['core']['versioncode'] ?? '0',
        changelog: '',
      ),
    );
  }
}

class UpdateCheckerDialog extends StatefulWidget {
  const UpdateCheckerDialog({Key? key}) : super(key: key);

  @override
  _UpdateCheckerDialogState createState() => _UpdateCheckerDialogState();
}

class _UpdateCheckerDialogState extends State<UpdateCheckerDialog> {
  RemoteVersionData? _remoteData;
  bool _isLoading = true;
  String? _error;
  HttpClient? _httpClient;
  bool _isDisposed = false;
  late UpdateManager _updateManager;
  String _currentChannel = 'github';
  bool _useMirror = false;

  @override
  void initState() {
    super.initState();
    _initializeUpdateManager();
  }

  Future<void> _initializeUpdateManager() async {
    _updateManager = UpdateManager();
    await _updateManager.init();
    _currentChannel = _updateManager.updateChannel;
    _useMirror = _updateManager.useMirror;
    _checkForUpdates();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _httpClient?.close(force: true);
    super.dispose();
  }

  Future<void> _checkForUpdates() async {
    if (_isDisposed || !mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final url = _updateManager.getVersionCheckUrl(isBeta: IS_BETA);
      debugPrint('检查更新URL: $url');

      _httpClient = HttpClient()
        ..connectionTimeout = const Duration(seconds: 10);

      final request = await _httpClient!.getUrl(Uri.parse(url));
      final response = await request.close().timeout(
        const Duration(seconds: 15),
      );

      if (!mounted || _isDisposed) return;

      if (response.statusCode == 200) {
        final content = await response.transform(utf8.decoder).join();
        final jsonData = json.decode(content);
        if (!mounted || _isDisposed) return;

        setState(() {
          _remoteData = RemoteVersionData.fromJson(jsonData);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = '获取版本信息失败: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } on SocketException catch (e) {
      if (!mounted || _isDisposed) return;
      setState(() {
        _error = '网络连接失败: ${e.message}';
        _isLoading = false;
      });
    } on TimeoutException catch (_) {
      if (!mounted || _isDisposed) return;
      setState(() {
        _error = '请求超时，请检查网络连接';
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted || _isDisposed) return;
      setState(() {
        _error = '发生未知错误: $e';
        _isLoading = false;
      });
    } finally {
      _httpClient?.close();
    }
  }

  Future<void> _openReleasePage() async {
    final url = _currentChannel == 'gitee'
        ? 'https://gitee.com/Hollow-YK/ArknightsKeyTool/releases'
        : _updateManager.getGitHubReleaseUrl();

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  String _getReleaseStatus() {
    if (_remoteData == null) return '';
    final localCode = int.tryParse(LOCAL_VERSION_CODE) ?? 0;
    final remoteCode = int.tryParse(_remoteData!.release.versionCode) ?? 0;

    if (localCode < remoteCode) return 'new_version';
    if (localCode == remoteCode) return 'latest';
    return IS_BETA ? 'beta_version' : 'future_version';
  }

  String _getBetaStatus() {
    if (_remoteData == null || !IS_BETA) return '';
    final localCode = int.tryParse(LOCAL_VERSION_CODE) ?? 0;
    final remoteReleaseCode =
        int.tryParse(_remoteData!.release.versionCode) ?? 0;
    final remoteBetaCode = int.tryParse(_remoteData!.beta.versionCode) ?? 0;

    if (remoteBetaCode <= remoteReleaseCode) return 'no_newer_beta';
    if (localCode < remoteBetaCode) return 'new_beta';
    if (localCode == remoteBetaCode) return 'latest_beta';
    return 'custom_build';
  }

  Widget _buildCoreUpdateWarning() {
    if (_remoteData == null) return const SizedBox();
    final localCore = int.tryParse(LOCAL_CORE_VERSION_CODE) ?? 0;
    final remoteCore = int.tryParse(_remoteData!.core.versionCode) ?? 0;

    if (localCore < remoteCore) {
      return Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.yellow[700],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.warning, color: Colors.red[900]),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '核心版本有更新！',
                style: TextStyle(
                  color: Colors.red[900],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('检查更新'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '当前版本：$LOCAL_VERSION ($LOCAL_VERSION_CODE) Core $LOCAL_CORE_VERSION_CODE',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    _currentChannel == 'github' ? Icons.code : Icons.speed,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '当前渠道：$_currentChannel',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (_currentChannel == 'github' && _useMirror)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        '（使用镜像）',
                        style: TextStyle(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_error != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('错误：$_error', style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _checkForUpdates,
                    icon: const Icon(Icons.refresh),
                    label: const Text('重试'),
                  ),
                ],
              )
            else if (_remoteData != null) ...[
              _buildCoreUpdateWarning(),
              _buildReleaseSection(),
              if (IS_BETA) _buildBetaSection(),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('关闭'),
        ),
        if (_remoteData != null &&
            (_getReleaseStatus() == 'new_version' ||
                _getBetaStatus() == 'new_beta'))
          ElevatedButton(
            onPressed: _openReleasePage,
            child: Text(
              _currentChannel == 'github'
                  ? '前往GitHub Release'
                  : '前往Gitee Release',
            ),
          ),
      ],
    );
  }

  Widget _buildReleaseSection() {
    final status = _getReleaseStatus();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '正式版：',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (status == 'new_version' && _remoteData != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '有新版本：${_remoteData!.release.version} (${_remoteData!.release.versionCode})',
              ),
              const SizedBox(height: 8),
              Text(
                '更新日志：',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _remoteData!.release.changelog,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          )
        else if (status == 'latest')
          Text('当前是最新版！', style: TextStyle(color: Colors.green[700]))
        else if (status == 'beta_version')
          Text('当前是测试版！', style: TextStyle(color: Colors.orange[700]))
        else if (status == 'future_version')
          Text(
            '你的版本是未来的，软件却相当古老。你究竟是什么版本？',
            style: TextStyle(color: Colors.purple[700]),
          ),
      ],
    );
  }

  Widget _buildBetaSection() {
    final status = _getBetaStatus();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          '测试版：',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (status == 'new_beta' && _remoteData != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '有新版本：${_remoteData!.beta.version} (${_remoteData!.beta.versionCode})',
              ),
              const SizedBox(height: 8),
              Text(
                '更新日志：',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _remoteData!.beta.changelog,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          )
        else if (status == 'no_newer_beta')
          Text('当前没有比正式版更新的测试版！', style: TextStyle(color: Colors.blue[700]))
        else if (status == 'latest_beta')
          Text('当前是最新版！', style: TextStyle(color: Colors.green[700]))
        else if (status == 'custom_build')
          Text('你是自己编译的？', style: TextStyle(color: Colors.orange[700])),
      ],
    );
  }
}

/// 显示更新检查对话框
void showUpdateCheckerDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => const UpdateCheckerDialog(),
  );
}
