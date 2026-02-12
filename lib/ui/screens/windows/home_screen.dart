import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../features/key_settings/providers/key_settings_provider.dart';
import '../../widgets/common/key_setting_item.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('明日方舟PC快捷键修改器'), centerTitle: true),
      body: Consumer<KeySettingsProvider>(
        builder: (context, provider, child) {
          // 1. 没有可用配置 -> 提示启动游戏
          if (provider.availableValueNames.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  '未找到键盘设置，请先启动一次明日方舟PC版。',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          // 2. 有多个配置但未选择 -> 显示选择器
          if (provider.availableValueNames.length > 1 &&
              provider.selectedValueName == null) {
            return _buildValueSelector(context, provider);
          }

          // 3. 已选择配置 -> 显示快捷键列表 + 保存按钮
          if (provider.selectedValueName != null) {
            return Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: provider.mappings.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (ctx, index) {
                      final mapping = provider.mappings[index];
                      return KeySettingItem(
                        keyId: mapping.id,
                        label: mapping.displayName,
                        virtualEnum: mapping.virtualButtonEnum,
                        currentKey: provider.keyIdToDisplay(mapping.keyId),
                        isLocked: mapping.isLocked,
                        onPressed: mapping.isLocked
                            ? null
                            : () => _showKeySelector(
                                context,
                                provider,
                                mapping.id,
                                mapping.keyId,
                              ),
                      );
                    },
                  ),
                ),
                _buildSaveButton(context, provider),
              ],
            );
          }

          // 4. 其他情况（如只有一个配置但还未加载完成）
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  /// 多配置选择界面
  Widget _buildValueSelector(
    BuildContext context,
    KeySettingsProvider provider,
  ) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '发现多个键盘配置，请选择要编辑的项：',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...provider.availableValueNames.map((name) {
                return ListTile(
                  title: Text(name),
                  leading: const Icon(Icons.settings),
                  onTap: () => provider.selectValueName(name),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  /// 底部保存按钮
  Widget _buildSaveButton(BuildContext context, KeySettingsProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -2),
            blurRadius: 4,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: provider.hasChanges && provider.hasSelectedValue
            ? () async {
                final success = await provider.saveChanges();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? '保存成功' : '保存失败，请稍后重试'),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                }
              }
            : null,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: const Text('保存更改', style: TextStyle(fontSize: 16)),
      ),
    );
  }

  /// 修改按键弹窗（支持自定义输入）
  void _showKeySelector(
    BuildContext context,
    KeySettingsProvider provider,
    String mappingId,
    String currentKeyId,
  ) {
    final TextEditingController controller = TextEditingController(
      text: currentKeyId,
    );

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              title: Text('修改按键 - ${_getLabelById(mappingId)}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('手动输入 keyId：'),
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: '例如 alphaW, keySpace, bannedEscape',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('或从预设中选择：'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _buildPresetButtons(ctx, controller),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text('取消'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final newKeyId = controller.text.trim();
                    if (newKeyId.isNotEmpty) {
                      provider.updateKeyId(mappingId, newKeyId);
                      Navigator.pop(dialogCtx);
                    }
                  },
                  child: const Text('确认'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// 预设按键按钮列表
  List<Widget> _buildPresetButtons(
    BuildContext context,
    TextEditingController controller,
  ) {
    final List<Map<String, String>> presets = [];

    // A~Z
    for (int i = 0; i < 26; i++) {
      final letter = String.fromCharCode(65 + i);
      presets.add({'label': letter, 'value': 'alpha$letter'});
    }
    presets.add({'label': 'Space', 'value': 'keySpace'});
    presets.add({'label': 'Tab', 'value': 'keyTab'});
    presets.add({'label': 'Esc (禁用)', 'value': 'bannedEscape'});

    return presets.map((p) {
      return ActionChip(
        label: Text(p['label']!),
        onPressed: () {
          controller.text = p['value']!;
          // 刷新对话框内的 State
          if (context is Element) {
            (context as Element).markNeedsBuild();
          }
        },
      );
    }).toList();
  }

  String _getLabelById(String id) {
    const labels = {
      'CHANGE_SPEED': '二倍速',
      'RELEASE_SKILL': '释放技能',
      'RETREAT_CHAR': '撤退干员',
      'ESC': '退出/取消',
      'HOME_KEY': '首页',
      'MOVE_FORWARD': '向上移动',
      'MOVE_BACKWARD': '向下移动',
      'MOVE_TO_LEFT': '向左移动',
      'MOVE_TO_RIGHT': '向右移动',
      'Space': '暂停',
    };
    return labels[id] ?? id;
  }
}
