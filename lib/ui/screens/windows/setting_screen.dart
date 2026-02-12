import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:arknights_key_tool/features/settings/providers/settings_provider.dart';
import 'package:arknights_key_tool/core/services/update_manager.dart';
import 'package:arknights_key_tool/ui/widgets/common/update_check.dart';

/// 设置页面 – 主题切换 + 更新设置（包含镜像配置）
class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subtleColor = isDark ? Colors.grey[400]! : Colors.grey.shade600;
    final cardBackground = isDark ? Colors.grey[900]! : Colors.white;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 48),
            // 标题
            Text(
              '设置',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text('应用参数配置', style: TextStyle(color: subtleColor, fontSize: 16)),
            const SizedBox(height: 32),

            // ---- 1. 主题设置卡片（已有）----
            Card(
              elevation: 2,
              color: cardBackground,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.palette_outlined,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '主题模式',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Consumer<SettingsProvider>(
                      builder: (context, provider, child) {
                        return Column(
                          children: [
                            _buildThemeOption(
                              context: context,
                              value: 'system',
                              label: '跟随系统',
                              icon: Icons.brightness_auto,
                              selected: provider.themeMode == 'system',
                              onChanged: (val) => provider.setThemeMode(val!),
                            ),
                            const Divider(height: 24),
                            _buildThemeOption(
                              context: context,
                              value: 'light',
                              label: '浅色',
                              icon: Icons.light_mode,
                              selected: provider.themeMode == 'light',
                              onChanged: (val) => provider.setThemeMode(val!),
                            ),
                            const Divider(height: 24),
                            _buildThemeOption(
                              context: context,
                              value: 'dark',
                              label: '深色',
                              icon: Icons.dark_mode,
                              selected: provider.themeMode == 'dark',
                              onChanged: (val) => provider.setThemeMode(val!),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ---- 2. 更新设置卡片（增强版）----
            Card(
              elevation: 2,
              color: cardBackground,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.update, color: colorScheme.primary),
                        const SizedBox(width: 12),
                        Text(
                          '软件更新',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 检查更新按钮 + 版本信息
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => showUpdateCheckerDialog(context),
                            icon: const Icon(Icons.update),
                            label: const Text('检查更新'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.info_outline, size: 18, color: subtleColor),
                        const SizedBox(width: 8),
                        Text(
                          '当前版本：1.0.0',
                          style: TextStyle(color: subtleColor),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ---------- 更新渠道与镜像详细设置 ----------
                    const _UpdateSettingsDetail(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required String value,
    required String label,
    required IconData icon,
    required bool selected,
    required ValueChanged<String?> onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  color: selected ? colorScheme.primary : colorScheme.onSurface,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: selected ? value : null,
              onChanged: onChanged,
              activeColor: colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

/// 更新渠道与镜像详细设置组件（内部状态管理）
class _UpdateSettingsDetail extends StatefulWidget {
  const _UpdateSettingsDetail();

  @override
  State<_UpdateSettingsDetail> createState() => __UpdateSettingsDetailState();
}

class __UpdateSettingsDetailState extends State<_UpdateSettingsDetail> {
  final UpdateManager _updateManager = UpdateManager();
  final TextEditingController _mirrorUrlController = TextEditingController();

  String _updateChannel = 'github';
  bool _useMirror = false;
  String _mirrorUrl = '';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _mirrorUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    await _updateManager.init();
    if (mounted) {
      setState(() {
        _updateChannel = _updateManager.updateChannel;
        _useMirror = _updateManager.useMirror;
        _mirrorUrl = _updateManager.mirrorUrl;
        _mirrorUrlController.text = _mirrorUrl;
      });
    }
  }

  Future<void> _saveSettings() async {
    if (mounted) {
      setState(() {
        _updateChannel = _updateManager.updateChannel;
        _useMirror = _updateManager.useMirror;
        _mirrorUrl = _updateManager.mirrorUrl;
      });
    }
  }

  Future<void> _testMirrorConnection() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('正在测试镜像连接...'),
        duration: Duration(seconds: 2),
      ),
    );

    final success = await _updateManager.testMirrorConnection();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? '镜像连接成功' : '镜像连接失败，请检查地址'),
          backgroundColor: success ? Colors.green : Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subtleColor = isDark ? Colors.grey[400]! : Colors.grey.shade600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---- 渠道选择 ----
        Row(
          children: [
            Icon(Icons.cloud_queue, size: 20, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text('更新渠道', style: TextStyle(fontWeight: FontWeight.w600)),
            const Spacer(),
            DropdownButton<String>(
              value: _updateChannel,
              onChanged: (String? newValue) async {
                if (newValue != null) {
                  await _updateManager.setUpdateChannel(newValue);
                  await _saveSettings();
                }
              },
              items: const [
                DropdownMenuItem(value: 'github', child: Text('GitHub')),
                DropdownMenuItem(value: 'gitee', child: Text('Gitee')),
              ],
            ),
          ],
        ),

        const SizedBox(height: 16),

        // ---- 镜像开关 ----
        Row(
          children: [
            Icon(Icons.cloud_circle, size: 20, color: colorScheme.primary),
            const SizedBox(width: 8),
            const Text('使用镜像', style: TextStyle(fontWeight: FontWeight.w600)),
            const Spacer(),
            Switch(
              value: _useMirror,
              onChanged: (value) async {
                await _updateManager.setUseMirror(value);
                await _saveSettings();
              },
              activeColor: colorScheme.primary,
            ),
          ],
        ),

        // ---- 镜像地址输入（仅当启用镜像时显示）----
        if (_useMirror) ...[
          const SizedBox(height: 16),
          TextField(
            controller: _mirrorUrlController,
            decoration: InputDecoration(
              labelText: '镜像地址',
              hintText: '例如: https://mirror.ghproxy.com/',
              prefixIcon: const Icon(Icons.link),
              suffixIcon: _mirrorUrlController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () async {
                        _mirrorUrlController.clear();
                        await _updateManager.setMirrorUrl('');
                        await _saveSettings();
                      },
                    )
                  : null,
              border: const OutlineInputBorder(),
            ),
            onChanged: (value) {
              _updateManager.setMirrorUrl(value);
            },
            onSubmitted: (value) async {
              await _updateManager.setMirrorUrl(value);
              await _saveSettings();
            },
          ),
          const SizedBox(height: 8),
          Text(
            '请输入完整的镜像地址，系统会自动将GitHub地址附加在后面。',
            style: TextStyle(fontSize: 12, color: subtleColor),
          ),

          // 镜像状态提示
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isValidUrl(_mirrorUrl)
                  ? Colors.green.withAlpha(25)
                  : Colors.orange.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isValidUrl(_mirrorUrl)
                    ? Colors.green.withAlpha(76)
                    : Colors.orange.withAlpha(76),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isValidUrl(_mirrorUrl) ? Icons.check_circle : Icons.warning,
                  color: isValidUrl(_mirrorUrl) ? Colors.green : Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isValidUrl(_mirrorUrl)
                        ? '镜像地址格式正确'
                        : '请输入有效的URL地址（以http://或https://开头）',
                    style: TextStyle(
                      color: isValidUrl(_mirrorUrl)
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                ),
                if (isValidUrl(_mirrorUrl))
                  TextButton(
                    onPressed: _testMirrorConnection,
                    child: const Text('测试连接'),
                  ),
              ],
            ),
          ),

          // 常用镜像地址参考
          const SizedBox(height: 16),
          ExpansionTile(
            title: const Text('镜像地址参考'),
            initiallyExpanded: false,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMirrorExample(
                      context,
                      name: 'gh.llkk.cc',
                      url: 'https://gh.llkk.cc/',
                      description: '网上找的',
                    ),
                    const SizedBox(height: 8),
                    _buildMirrorExample(
                      context,
                      name: 'ghproxy',
                      url: 'https://ghproxy.net/',
                      description: '应该能用',
                    ),
                    const SizedBox(height: 8),
                    _buildMirrorExample(
                      context,
                      name: 'gitproxy.click',
                      url: 'https://gitproxy.click/',
                      description: '能用吧',
                    ),
                    const SizedBox(height: 8),
                    _buildMirrorExample(
                      context,
                      name: 'gh-proxy',
                      url: 'https://gh-proxy.top',
                      description: '我寻思能用',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],

        // 提示信息
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withAlpha(25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '如果GitHub访问困难，可以切换至Gitee渠道或启用镜像。',
                  style: TextStyle(color: subtleColor, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMirrorExample(
    BuildContext context, {
    required String name,
    required String url,
    required String description,
  }) {
    return InkWell(
      onTap: () async {
        _mirrorUrlController.text = url;
        await _updateManager.setMirrorUrl(url);
        await _saveSettings();
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withAlpha(51),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.content_copy,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              url,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
