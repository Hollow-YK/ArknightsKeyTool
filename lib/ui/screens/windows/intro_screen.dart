import 'package:flutter/material.dart';

/// 介绍页面 – 应用概览
class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.grey[300]! : Colors.grey.shade800;
    final subtleColor = isDark ? Colors.grey[400]! : Colors.grey.shade600;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 48),
            Center(
              child: Column(
                children: [
                  // 应用图标占位
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.keyboard,
                      size: 60,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '明日方舟PC快捷键修改器',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Arknights Key Tool',
                    style: TextStyle(fontSize: 16, color: subtleColor),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '版本 1.0.0',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Text(
              '功能介绍',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              context: context,
              icon: Icons.keyboard,
              title: '快捷键自定义',
              description: '修改游戏中的快捷键，支持自定义 keyId。我爱设什么设什么，鹰角不让我设简直坏事做尽！',
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 12),
            _buildFeatureCard(
              context: context,
              icon: Icons.save,
              title: '手动保存',
              description: '修改后通过“保存更改”按钮统一提交更改，以防手滑。',
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 12),
            _buildFeatureCard(
              context: context,
              icon: Icons.lock_outline,
              title: 'ESC 返回键锁定',
              description: '返回键绑定 ESC 不可修改，改了可能出事。要是想改可以去翻注册表，没那能力还是别碰了。',
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 12),
            _buildFeatureCard(
              context: context,
              icon: Icons.add_circle_outline,
              title: 'Space 键可以暂停！',
              description:
                  '专门处理了暂停键，你可以把空格键绑暂停，返回键还是ESC。鹰角你配置明明支持为什么不在游戏内允许配置！',
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required ColorScheme colorScheme,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: colorScheme.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
