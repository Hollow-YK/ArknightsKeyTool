import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../features/settings/providers/settings_provider.dart';
import '../../widgets/common/update_check.dart';

/// 设置页面 – 主题切换、检查更新等
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

            // ---- 主题设置卡片 ----
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

            // ---- 更新设置卡片 ----
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
                    // 检查更新按钮
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => showUpdateCheckerDialog(context),
                        icon: const Icon(Icons.update),
                        label: const Text('检查更新'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // 当前版本显示
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
