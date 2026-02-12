import 'dart:convert';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';
import '../config/platform_config.dart';

/// 注册表仓储 - 底层使用 Win32 API 直接操作 REG_BINARY
class RegistryRepository {
  static const int _bufferSize = 4096;

  /// 打开注册表键，返回 HKEY（int），失败返回 null
  int? _openKey(int desiredAccess, {bool createIfMissing = false}) {
    final path = TEXT(PlatformConfig.registryPath); // Pointer<Utf16>
    final phkResult = calloc<HKEY>();

    try {
      if (createIfMissing) {
        final result = RegCreateKeyEx(
          HKEY_CURRENT_USER,
          path,
          0,
          nullptr,
          0,
          desiredAccess,
          nullptr,
          phkResult,
          nullptr,
        );
        if (result == ERROR_SUCCESS) {
          return phkResult.value;
        }
      } else {
        final result = RegOpenKeyEx(
          HKEY_CURRENT_USER,
          path,
          0,
          desiredAccess,
          phkResult,
        );
        if (result == ERROR_SUCCESS) {
          return phkResult.value;
        }
      }
    } catch (_) {
      // 忽略异常
    } finally {
      calloc.free(phkResult);
    }
    return null;
  }

  /// 获取指定路径下的所有值名称
  List<String> getValueNames() {
    final hKey = _openKey(KEY_QUERY_VALUE | KEY_ENUMERATE_SUB_KEYS);
    if (hKey == null) return [];

    final names = <String>[];
    try {
      var index = 0;
      while (true) {
        // ✅ 修复：Utf16 不是 SizedNativeType，改用 Uint16 分配后 cast
        final lpValueName = calloc<Uint16>(_bufferSize).cast<Utf16>();
        final lpcchValueName = calloc<Uint32>()..value = _bufferSize;

        try {
          final result = RegEnumValue(
            hKey,
            index,
            lpValueName,
            lpcchValueName,
            nullptr,
            nullptr,
            nullptr,
            nullptr,
          );

          if (result == ERROR_SUCCESS) {
            final name = lpValueName.toDartString();
            names.add(name);
            index++;
          } else if (result == ERROR_NO_MORE_ITEMS) {
            break;
          } else {
            break;
          }
        } finally {
          calloc.free(lpValueName);
          calloc.free(lpcchValueName);
        }
      }
    } finally {
      RegCloseKey(hKey);
    }

    return names;
  }

  /// 读取二进制值，返回 UTF-8 解码后的字符串；若不存在或错误返回 null
  String? readBinaryString(String valueName) {
    final hKey = _openKey(KEY_QUERY_VALUE);
    if (hKey == null) return null;

    try {
      final lpType = calloc<Uint32>();
      final lpcbData = calloc<Uint32>()..value = 0;

      try {
        var result = RegQueryValueEx(
          hKey,
          TEXT(valueName),
          nullptr,
          lpType,
          nullptr,
          lpcbData,
        );

        if (result != ERROR_SUCCESS) return null;
        if (lpType.value != REG_BINARY) return null;

        final dataSize = lpcbData.value;
        if (dataSize == 0) return null;

        final buffer = calloc<Uint8>(dataSize);
        final cbData = calloc<Uint32>()..value = dataSize;

        try {
          result = RegQueryValueEx(
            hKey,
            TEXT(valueName),
            nullptr,
            lpType,
            buffer,
            cbData,
          );

          if (result == ERROR_SUCCESS) {
            final bytes = buffer.asTypedList(cbData.value);
            final validBytes = bytes.takeWhile((b) => b != 0).toList();
            return utf8.decode(validBytes);
          }
        } finally {
          calloc.free(buffer);
          calloc.free(cbData);
        }
      } finally {
        calloc.free(lpType);
        calloc.free(lpcbData);
      }
    } finally {
      RegCloseKey(hKey);
    }
    return null;
  }

  /// 写入二进制值（UTF-8 编码 + 尾部 0x00），自动创建路径
  bool writeBinaryString(String valueName, String data) {
    final hKey = _openKey(KEY_SET_VALUE, createIfMissing: true);
    if (hKey == null) return false;

    try {
      final bytes = utf8.encode(data)..add(0);
      final lpData = calloc<Uint8>(bytes.length);
      lpData.asTypedList(bytes.length).setAll(0, bytes);

      final result = RegSetValueEx(
        hKey,
        TEXT(valueName),
        0,
        REG_BINARY,
        lpData,
        bytes.length,
      );

      calloc.free(lpData);
      return result == ERROR_SUCCESS;
    } finally {
      RegCloseKey(hKey);
    }
  }
}
