import 'package:PiliPlus/utils/storage.dart';
import 'package:PiliPlus/utils/subtitle_translator.dart';
import 'package:PiliPlus/utils/storage_key.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart';

void showTranslateApiDialog(BuildContext context, {VoidCallback? onSaved}) {
  final baseUrl = TextEditingController(text: Pref.subtitleLlmBaseUrl);
  final apiKey = TextEditingController(text: Pref.subtitleLlmKey);
  final model = TextEditingController(text: Pref.subtitleLlmModel);
  final result = ValueNotifier<String>('');

  InputDecoration deco(String label, String hint) =>
      InputDecoration(labelText: label, hintText: hint, isDense: true);

  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('API dịch phụ đề'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Để trống để dùng Google Dịch miễn phí. Điền đủ 3 ô để dùng LLM (API kiểu OpenAI).',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: baseUrl,
              decoration: deco('Base URL', 'https://api.openai.com/v1'),
              keyboardType: TextInputType.url,
              autocorrect: false,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: apiKey,
              decoration: deco('API Key', 'sk-...'),
              obscureText: true,
              autocorrect: false,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: model,
              decoration: deco('Model', 'gpt-4o-mini'),
              autocorrect: false,
            ),
            ValueListenableBuilder<String>(
              valueListenable: result,
              builder: (context, v, child) => v.isEmpty
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: SelectableText(
                        v,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            result.value = 'Đang kiểm tra…';
            result.value = await SubtitleTranslator.testConnection(
              baseUrl.text.trim(),
              apiKey.text.trim(),
              model.text.trim(),
            );
          },
          child: const Text('Kiểm tra'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        TextButton(
          onPressed: () {
            GStorage.setting
              ..put(SettingBoxKey.subtitleLlmBaseUrl, baseUrl.text.trim())
              ..put(SettingBoxKey.subtitleLlmKey, apiKey.text.trim())
              ..put(SettingBoxKey.subtitleLlmModel, model.text.trim());
            Navigator.of(context).pop();
            onSaved?.call();
          },
          child: const Text('Lưu'),
        ),
      ],
    ),
  );
}
