import 'package:PiliPlus/utils/storage.dart';
import 'package:PiliPlus/utils/storage_key.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart';

void showTranslateRulesDialog(BuildContext context, {VoidCallback? onSaved}) {
  final rules = TextEditingController(text: Pref.subtitleRules);

  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Quy tắc dịch'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mỗi dòng một quy tắc:\n'
              '• 知到 => 知道   sửa phụ đề gốc trước khi dịch\n'
              '• 末世 = Tận thế   thuật ngữ/tên riêng, luôn dịch thành vế phải\n'
              '• lỗi cũ >> lỗi mới   sửa bản dịch tiếng Việt sau khi dịch\n'
              '• @hv 林凡 苏婉   liệt kê tên người, tự đổi sang Hán Việt\n'
              'Dòng bắt đầu bằng # là ghi chú.',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: rules,
              minLines: 8,
              maxLines: 14,
              autocorrect: false,
              enableSuggestions: false,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                hintText: '# quy tắc của bạn',
                isDense: true,
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        TextButton(
          onPressed: () {
            GStorage.setting.put(SettingBoxKey.subtitleRules, rules.text);
            Navigator.of(context).pop();
            onSaved?.call();
          },
          child: const Text('Lưu'),
        ),
      ],
    ),
  );
}
