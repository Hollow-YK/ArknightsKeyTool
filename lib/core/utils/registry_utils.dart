import '../data/registry_repository.dart';
import '../config/platform_config.dart'; // 确保此行存在

/// 注册表工具类 - 封装查找与写入逻辑
class RegistryUtils {
  static final _repo = RegistryRepository();

  static List<String> findAllKeyboardSettingNames() {
    final names = _repo.getValueNames();
    return names
        .where((name) => name.contains(PlatformConfig.registryValuePattern))
        .toList();
  }

  static String? readByValueName(String valueName) {
    return _repo.readBinaryString(valueName);
  }

  static bool writeByValueName(String valueName, String json) {
    return _repo.writeBinaryString(valueName, json);
  }
}
