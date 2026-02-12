import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// 关于页面 – 作者信息、开源协议、彩蛋等
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

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
              '关于',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text('应用信息与致谢', style: TextStyle(color: subtleColor, fontSize: 16)),
            const SizedBox(height: 32),

            // 作者卡片
            Card(
              elevation: 2,
              color: cardBackground,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: colorScheme.primaryContainer,
                          child: Icon(
                            Icons.person,
                            size: 36,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '域空Hollow',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '开发 | 有 Bug 很正常，因为我菜（逃）',
                                style: TextStyle(color: subtleColor),
                              ),
                            ],
                          ),
                        ) /*
                        IconButton(
                          icon: const Icon(Icons.open_in_new),
                          color: colorScheme.primary,
                          onPressed: () =>
                              _openUrl('https://space.bilibili.com/1572457623'),
                          tooltip: 'B站主页',
                        ),*/,
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildInfoChip(
                          context,
                          icon: Icons.code,
                          label: 'GitHub',
                          onTap: () =>
                              _openUrl('https://github.com/Hollow-YK/'),
                        ),
                        _buildInfoChip(
                          context,
                          icon: Icons.description,
                          label: '哔哩哔哩',
                          onTap: () =>
                              _openUrl('https://space.bilibili.com/1572457623'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 开源协议卡片
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
                        Icon(Icons.security, color: colorScheme.primary),
                        const SizedBox(width: 12),
                        Text(
                          '开源协议',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '本项目采用 GNU GENERAL PUBLIC LICENSE 开源。',
                      style: TextStyle(fontSize: 15, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        ActionChip(
                          avatar: Icon(
                            Icons.code,
                            size: 18,
                            color: colorScheme.primary,
                          ),
                          label: const Text('查看许可证'),
                          onPressed: () => _openUrl(
                            'https://www.gnu.org/licenses/gpl-3.0.html',
                          ),
                        ),
                        ActionChip(
                          avatar: Icon(
                            Icons.article,
                            size: 18,
                            color: colorScheme.primary,
                          ),
                          label: const Text('GitHub仓库'),
                          onPressed: () => _openUrl(
                            'https://github.com/Hollow-YK/arknights_key_tool',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // 版本信息
            Center(
              child: Column(
                children: [
                  Text('明日方舟PC快捷键修改器', style: TextStyle(color: subtleColor)),
                  const SizedBox(height: 4),
                  Text(
                    '版本 1.0.0 · 感谢所有贡献者',
                    style: TextStyle(color: subtleColor, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.primaryContainer.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
