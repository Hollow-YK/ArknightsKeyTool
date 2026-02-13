import 'package:flutter/material.dart';

/// 文档页面 – 使用说明与常见问题
class DocumentScreen extends StatelessWidget {
  const DocumentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subtleColor = isDark ? Colors.grey[400]! : Colors.grey.shade600;
    final infoBackground = isDark
        ? colorScheme.surfaceContainerHighest
        : colorScheme.primaryContainer.withOpacity(0.3);
    final infoBorder = isDark
        ? colorScheme.outlineVariant
        : colorScheme.primaryContainer;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Text(
              '使用文档',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '如何配置与使用快捷键',
              style: TextStyle(fontSize: 16, color: subtleColor),
            ),
            const SizedBox(height: 32),

            // 快速开始
            _buildSection(
              context: context,
              title: '快速开始',
              content: '''
1. 保证你下载并安装了PC版明日方舟。
2. 打开本工具，若注册表中无任何键盘配置，将提示“未找到键盘设置”，此时请先正常启动一次明日方舟PC版。
3. 点击需要修改的按键右侧的“修改”按钮，在弹出的对话框中输入或选择你想要的 keyId（鹰角使用的keyId，而非键值）。
4. 修改完成后，点击底部的“保存更改”按钮，配置将立即写入注册表。
              ''',
              colorScheme: colorScheme,
            ),

            const SizedBox(height: 24),

            // keyId规则
            _buildSection(
              context: context,
              title: '关于 keyId',
              content: '''
• 数字键 0~9 → numX（例如 num0 对应 0 键）
• 字母键 A~Z → alphaX（例如 alphaF 对应 F 键）
• 功能键 → keyX
• Esc 键 → bannedEscape

目前已知可用的功能键
• Tab 键 → keyTab
• Space 键 → keySpace

你可以在修改对话框中手动输入任意 keyId，但请确保该键在游戏内是有效的。
              ''',
              colorScheme: colorScheme,
            ),

            const SizedBox(height: 24),

            // 常见问题
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: infoBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: infoBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.help_outline, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        '常见问题',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildQa(
                    q: 'Q：修改后游戏内没有生效？',
                    a: 'A：请确认你修改后点击了“保存”。如果游戏正在运行，建议重启游戏。',
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(height: 12),
                  _buildQa(
                    q: 'Q：为什么 ESC 键是灰色的？',
                    a: 'A：ESC 键功能特殊，为防止出现问题，作者决定将其锁定为不可使用。',
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(height: 12),
                  _buildQa(
                    q: 'Q：如何恢复默认设置？',
                    a: 'A：本工具不直接提供恢复默认功能。',
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(height: 12),
                  _buildQa(
                    q: 'Q：暂停键为什么显示“默认”？',
                    a: 'A：游戏原生注册表中不包含暂停键，因此首次打开时显示“默认”。但是舟PC实际上支持单独设置暂停键，所以作者添加了这一项。当你修改暂停键后，该字段才会被写入注册表，否则暂停键会像没有更改过一样与ESC绑定。',
                    colorScheme: colorScheme,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required String content,
    required ColorScheme colorScheme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Text(
            content,
            style: TextStyle(
              fontSize: 15,
              color: colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQa({
    required String q,
    required String a,
    required ColorScheme colorScheme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          q,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          a,
          style: TextStyle(color: colorScheme.onSurfaceVariant, height: 1.4),
        ),
      ],
    );
  }
}
