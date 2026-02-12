import 'package:flutter/material.dart';

class KeySettingItem extends StatelessWidget {
  final String keyId;
  final String label;
  final int virtualEnum; // 显示枚举值
  final String currentKey;
  final bool isLocked;
  final VoidCallback? onPressed;

  const KeySettingItem({
    super.key,
    required this.keyId,
    required this.label,
    required this.virtualEnum,
    required this.currentKey,
    required this.isLocked,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '枚举值: $virtualEnum',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: isLocked ? Colors.grey : Colors.blue),
              borderRadius: BorderRadius.circular(4),
              color: isLocked ? Colors.grey[200] : null,
            ),
            child: Text(
              currentKey,
              style: TextStyle(
                fontSize: 14,
                color: isLocked ? Colors.grey[600] : null,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: 80,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: isLocked ? Colors.grey : null,
              foregroundColor: isLocked ? Colors.white : null,
            ),
            child: Text(isLocked ? '锁定' : '修改'),
          ),
        ),
      ],
    );
  }
}
