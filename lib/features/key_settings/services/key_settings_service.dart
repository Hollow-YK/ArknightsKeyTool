import 'dart:convert';
import '../models/key_mapping.dart';

/// 按键设置业务服务：解析、合并、序列化
class KeySettingsService {
  /// 从 JSON 字符串解析，返回映射表（ID -> KeyMapping）
  /// 若 jsonStr 为 null 或空，返回纯默认映射（不含 Space）
  static Map<String, KeyMapping> parseFromJson(String? jsonStr) {
    final Map<String, KeyMapping> result = {};

    // 加入所有默认映射（含 ESC 锁定状态）
    for (final m in defaultMappings) {
      result[m.id] = m;
    }

    if (jsonStr == null || jsonStr.isEmpty) {
      return result;
    }

    try {
      final Map<String, dynamic> jsonMap = jsonDecode(jsonStr);
      // 更新默认功能
      for (final m in defaultMappings) {
        if (jsonMap.containsKey(m.id)) {
          try {
            result[m.id] = KeyMapping.fromJson(
              m.id,
              m.displayName,
              jsonMap[m.id],
              isLocked: m.isLocked, // 保留锁定状态
            );
          } catch (_) {
            // 解析失败则保留默认
          }
        }
      }
      // 处理 Space：若存在则加入
      if (jsonMap.containsKey(SpaceMapping.id)) {
        try {
          result[SpaceMapping.id] = KeyMapping.fromJson(
            SpaceMapping.id,
            SpaceMapping.displayName,
            jsonMap[SpaceMapping.id],
          );
        } catch (_) {}
      }
    } catch (_) {
      // JSON 解析错误，返回纯默认
    }
    return result;
  }

  /// 将当前映射表序列化为 JSON 字符串，并合并未修改的未知字段
  static String serializeToJson(
    Map<String, KeyMapping> currentMappings,
    String? originalJson,
  ) {
    // 解析原 JSON，保留所有字段
    final Map<String, dynamic> fullMap = {};
    if (originalJson != null && originalJson.isNotEmpty) {
      try {
        fullMap.addAll(jsonDecode(originalJson));
      } catch (_) {}
    }

    // 更新或添加已知功能
    for (final entry in currentMappings.entries) {
      fullMap[entry.key] = entry.value.toJson();
    }

    // Space：仅当 currentMappings 中有时才写入，否则删除（保持注册表无 Space 字段）
    if (!currentMappings.containsKey(SpaceMapping.id)) {
      fullMap.remove(SpaceMapping.id);
    }

    return jsonEncode(fullMap);
  }
}
