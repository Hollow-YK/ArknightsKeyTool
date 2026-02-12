/// 单个快捷键映射模型
class KeyMapping {
  final String id; // 功能标识符，如 "MOVE_FORWARD"
  final String displayName; // 界面显示名称，如 "向前移动"
  final int virtualButtonEnum; // 固定枚举值，不可修改
  String keyId; // 当前绑定的键ID，如 "alphaW"
  final bool isLocked; // 是否禁止修改（ESC 专用）

  KeyMapping({
    required this.id,
    required this.displayName,
    required this.virtualButtonEnum,
    required this.keyId,
    this.isLocked = false,
  });

  /// 转换为 JSON 字段值
  Map<String, dynamic> toJson() {
    return {'keyId': keyId, 'virtualButtonEnum': virtualButtonEnum};
  }

  /// 从 JSON 创建（仅当存在时）
  factory KeyMapping.fromJson(
    String id,
    String displayName,
    Map<String, dynamic> json, {
    bool isLocked = false,
  }) {
    return KeyMapping(
      id: id,
      displayName: displayName,
      virtualButtonEnum: json['virtualButtonEnum'] as int,
      keyId: json['keyId'] as String,
      isLocked: isLocked,
    );
  }

  KeyMapping copyWith({String? keyId}) {
    return KeyMapping(
      id: id,
      displayName: displayName,
      virtualButtonEnum: virtualButtonEnum,
      keyId: keyId ?? this.keyId,
      isLocked: isLocked,
    );
  }
}

/// 预定义功能列表（ESC 锁定）
final List<KeyMapping> defaultMappings = [
  KeyMapping(
    id: 'CHANGE_SPEED',
    displayName: '二倍速',
    virtualButtonEnum: 2,
    keyId: 'alphaF',
  ),
  KeyMapping(
    id: 'RELEASE_SKILL',
    displayName: '释放技能',
    virtualButtonEnum: 4,
    keyId: 'alphaE',
  ),
  KeyMapping(
    id: 'RETREAT_CHAR',
    displayName: '撤退干员',
    virtualButtonEnum: 5,
    keyId: 'alphaQ',
  ),
  KeyMapping(
    id: 'ESC',
    displayName: '退出/取消',
    virtualButtonEnum: 0,
    keyId: 'bannedEscape',
    isLocked: true, // ESC 不可修改
  ),
  KeyMapping(
    id: 'HOME_KEY',
    displayName: '首页',
    virtualButtonEnum: 6,
    keyId: 'keyTab',
  ),
  KeyMapping(
    id: 'MOVE_FORWARD',
    displayName: '向上移动',
    virtualButtonEnum: 7,
    keyId: 'alphaW',
  ),
  KeyMapping(
    id: 'MOVE_BACKWARD',
    displayName: '向下移动',
    virtualButtonEnum: 8,
    keyId: 'alphaS',
  ),
  KeyMapping(
    id: 'MOVE_TO_LEFT',
    displayName: '向左移动',
    virtualButtonEnum: 9,
    keyId: 'alphaA',
  ),
  KeyMapping(
    id: 'MOVE_TO_RIGHT',
    displayName: '向右移动',
    virtualButtonEnum: 10,
    keyId: 'alphaD',
  ),
];

/// Space 专用定义
class SpaceMapping {
  static const String id = 'Space';
  static const String displayName = '暂停';
  static const int virtualButtonEnum = 11;
  static const String defaultKeyId = 'keySpace';

  /// 是否已在配置中存在
  static bool existsInJson(Map<String, dynamic> json) {
    return json.containsKey(id);
  }

  /// 创建默认的 Space 映射（仅用于 UI 展示）
  static KeyMapping createDefault() {
    return KeyMapping(
      id: id,
      displayName: displayName,
      virtualButtonEnum: virtualButtonEnum,
      keyId: defaultKeyId,
    );
  }
}
