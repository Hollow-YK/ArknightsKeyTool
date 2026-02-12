import 'package:flutter/material.dart';
import '../models/key_mapping.dart';
import '../services/key_settings_service.dart';
import '../../../core/utils/registry_utils.dart';

/// 状态管理
class KeySettingsProvider extends ChangeNotifier {
  // 当前内存中的按键映射
  List<KeyMapping> _mappings = [];

  // 所有可用的注册表值名称
  List<String> _availableValueNames = [];

  // 当前选中的值名称
  String? _selectedValueName;

  // 原始 JSON 字符串（用于合并未知字段）
  String? _originalJson;

  // 是否有未保存的更改
  bool _hasChanges = false;

  // ---------- 对外只读属性 ----------
  List<KeyMapping> get mappings => _mappings;
  List<String> get availableValueNames => _availableValueNames;
  String? get selectedValueName => _selectedValueName;
  bool get hasChanges => _hasChanges;
  bool get hasSelectedValue => _selectedValueName != null;

  // ---------- 加载与选择 ----------
  /// 扫描注册表，填充可用值名称列表
  Future<void> loadSettings() async {
    _availableValueNames = RegistryUtils.findAllKeyboardSettingNames();
    _selectedValueName = null;
    _mappings = [];
    _originalJson = null;
    _hasChanges = false;

    if (_availableValueNames.length == 1) {
      // 仅有一个时自动选中
      await selectValueName(_availableValueNames.first);
    }
    notifyListeners();
  }

  /// 用户主动选择一个值名称，并加载其内容
  Future<void> selectValueName(String name) async {
    if (!_availableValueNames.contains(name)) return;

    _selectedValueName = name;
    final jsonStr = RegistryUtils.readByValueName(name);
    _originalJson = jsonStr;

    final map = KeySettingsService.parseFromJson(jsonStr);
    _mappings = map.values.toList();

    // 排序：默认9个 + Space（如果有）
    _sortMappings();

    _hasChanges = false;
    notifyListeners();
  }

  // ---------- 修改操作（仅内存）----------
  /// 更新某个功能的 keyId
  void updateKeyId(String id, String newKeyId) {
    final index = _mappings.indexWhere((m) => m.id == id);
    if (index == -1) {
      // 如果是 Space 且当前不存在，则新增
      if (id == SpaceMapping.id) {
        _mappings.add(SpaceMapping.createDefault()..keyId = newKeyId);
        _sortMappings();
      } else {
        return; // 未知 ID，忽略
      }
    } else {
      // 锁定项不允许修改
      if (_mappings[index].isLocked) return;
      _mappings[index] = _mappings[index].copyWith(keyId: newKeyId);
    }

    _hasChanges = true;
    notifyListeners();
  }

  /// 保存所有更改到注册表
  Future<bool> saveChanges() async {
    if (_selectedValueName == null) return false;
    if (!_hasChanges) return true; // 无更改视为成功

    final jsonStr = KeySettingsService.serializeToJson(
      _mappings.fold({}, (map, m) => map..[m.id] = m),
      _originalJson,
    );

    final success = RegistryUtils.writeByValueName(
      _selectedValueName!,
      jsonStr,
    );
    if (success) {
      _originalJson = jsonStr; // 更新原始快照
      _hasChanges = false;
      notifyListeners();
    }
    return success;
  }

  // ---------- 辅助方法 ----------
  void _sortMappings() {
    const order = [
      'CHANGE_SPEED',
      'RELEASE_SKILL',
      'RETREAT_CHAR',
      'ESC',
      'HOME_KEY',
      'MOVE_FORWARD',
      'MOVE_BACKWARD',
      'MOVE_TO_LEFT',
      'MOVE_TO_RIGHT',
      'Space',
    ];
    _mappings.sort((a, b) {
      final i1 = order.indexOf(a.id);
      final i2 = order.indexOf(b.id);
      if (i1 == -1) return 1;
      if (i2 == -1) return -1;
      return i1.compareTo(i2);
    });
  }

  /// 将 keyId 转换为用户友好的显示文本
  String keyIdToDisplay(String keyId) {
    switch (keyId) {
      case 'bannedEscape':
        return 'Esc (不建议更改)';
      case 'keyTab':
        return 'Tab';
      case 'keySpace':
        return 'Space';
      default:
        if (keyId.startsWith('alpha')) {
          return keyId.substring(5); // 返回字母部分
        }
        return keyId;
    }
  }
}
