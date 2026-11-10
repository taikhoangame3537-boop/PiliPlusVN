import 'dart:async' show FutureOr;
import 'dart:convert' show utf8, jsonDecode;
import 'dart:io';
import 'dart:typed_data' show Uint8List;

import 'package:PiliPlus/common/style.dart';
import 'package:PiliPlus/common/widgets/dialog/simple_dialog_option.dart';
import 'package:PiliPlus/utils/config_archive.dart';
import 'package:PiliPlus/utils/date_utils.dart';
import 'package:PiliPlus/utils/extension/file_ext.dart';
import 'package:PiliPlus/utils/extension/theme_ext.dart';
import 'package:PiliPlus/utils/platform_utils.dart';
import 'package:PiliPlus/utils/storage_utils.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart' show Clipboard;
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:re_highlight/languages/json.dart';
import 'package:re_highlight/re_highlight.dart';
import 'package:re_highlight/styles/base16/github.dart';
import 'package:re_highlight/styles/github-dark.dart';

void exportToClipBoard({
  required ValueGetter<String> onExport,
}) {
  Utils.copyText(onExport());
}

void exportToLocalFile({
  required ValueGetter<String> onExport,
  required ValueGetter<String> localFileName,
}) {
  final res = utf8.encode(onExport());
  StorageUtils.saveBytes2File(
    name:
        'piliplus_${localFileName()}_'
        '${DateFormatUtils.only0_9.format(DateTime.now())}.json',
    bytes: res,
  );
}

Future<void> importFromClipBoard<T>(
  BuildContext context, {
  required String title,
  required ValueGetter<String> onExport,
  required FutureOr<void> Function(T json) onImport,
  bool showConfirmDialog = true,
}) async {
  final data = await Clipboard.getData('text/plain');
  if (data?.text case final text? when (text.isNotEmpty)) {
    if (!context.mounted) return;
    final T json;
    final String formatText;
    try {
      json = jsonDecode(text);
      formatText = Utils.jsonEncoder.convert(json);
    } catch (e) {
      SmartDialog.showToast('Phân tích json thất bại: $e');
      return;
    }
    bool? executeImport;
    if (showConfirmDialog) {
      final highlight = Highlight()..registerLanguage('json', langJson);
      final result = highlight.highlight(
        code: formatText,
        language: 'json',
      );
      late TextSpanRenderer renderer;
      bool? isDarkMode;
      executeImport = await showDialog<bool>(
        context: context,
        builder: (context) {
          final colorScheme = ColorScheme.of(context);
          final isDark = colorScheme.isDark;
          if (isDark != isDarkMode) {
            isDarkMode = isDark;
            renderer = TextSpanRenderer(
              null,
              isDark ? githubDarkTheme : githubTheme,
            );
            result.render(renderer);
          }
          return AlertDialog(
            title: Text('Có nhập $title sau đây không?'),
            content: SingleChildScrollView(
              child: Text.rich(renderer.span!),
            ),
            actions: [
              TextButton(
                onPressed: Get.back,
                child: Text('Hủy', style: TextStyle(color: colorScheme.outline)),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: const Text('Đồng ý'),
              ),
            ],
          );
        },
      );
    } else {
      executeImport = true;
    }
    if (executeImport ?? false) {
      try {
        await onImport(json);
        SmartDialog.showToast('Nhập thành công');
      } catch (e) {
        SmartDialog.showToast('Nhập thất bại: $e');
      }
    }
  } else {
    SmartDialog.showToast('Bộ nhớ tạm không có dữ liệu');
    return;
  }
}

Future<void> importFromLocalFile<T>({
  required FutureOr<void> Function(T json) onImport,
}) async {
  final result = await FilePicker.pickFile(
    type: .custom,
    allowedExtensions: const ['json', 'txt'],
  );
  if (result != null) {
    final data = await result.xFile.readAsString();
    final T json;
    try {
      json = jsonDecode(data);
    } catch (e) {
      SmartDialog.showToast('Phân tích json thất bại: $e');
      return;
    }
    try {
      await onImport(json);
      SmartDialog.showToast('Nhập thành công');
    } catch (e) {
      SmartDialog.showToast('Nhập thất bại: $e');
    }
  }
}

void importFromInput<T>(
  BuildContext context, {
  required String title,
  required FutureOr<void> Function(T json) onImport,
}) {
  final key = GlobalKey<FormFieldState<String>>();
  late T json;
  String? forceErrorText;

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Nhập $title'),
      constraints: Style.dialogFixedConstraints,
      content: TextFormField(
        key: key,
        minLines: 4,
        maxLines: 12,
        autofocus: true,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          errorMaxLines: 3,
        ),
        validator: (value) {
          if (forceErrorText != null) return forceErrorText;
          try {
            json = jsonDecode(value!) as T;
            return null;
          } catch (e) {
            return 'Phân tích json thất bại: $e';
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: Get.back,
          child: Text(
            'Hủy',
            style: TextStyle(
              color: ColorScheme.of(context).outline,
            ),
          ),
        ),
        TextButton(
          onPressed: () async {
            if (key.currentState?.validate() == true) {
              try {
                await onImport(json);
                Get.back();
                SmartDialog.showToast('Nhập thành công');
                return;
              } catch (e) {
                forceErrorText = 'Nhập thất bại: $e';
              }
              key.currentState?.validate();
              forceErrorText = null;
            }
          },
          child: const Text('Đồng ý'),
        ),
      ],
    ),
  );
}

Future<void> _exportAllDataToArchive() async {
  final name =
      'piliplus_data_'
      '${DateFormatUtils.only0_9.format(DateTime.now())}.zip';
  if (PlatformUtils.isDesktop) {
    final path = await FilePicker.saveFile(
      fileName: name,
      bytes: Uint8List(0),
    );
    if (path == null) {
      SmartDialog.showToast("Hủy lưu");
      return;
    }
    try {
      final out = OutputFileStream(path.toFilePath());
      ConfigArchive.export(out);
      await out.close();
    } catch (e) {
      SmartDialog.showToast('Xuất thất bại: $e');
      File.fromUri(path).tryDel();
      return;
    }
  } else {
    final out = OutputMemoryStream();
    try {
      ConfigArchive.export(out);
    } catch (e) {
      out.closeSync();
      SmartDialog.showToast('Xuất thất bại: $e');
      return;
    }
    final path = await FilePicker.saveFile(
      fileName: name,
      bytes: out.getBytes(),
    );
    out.closeSync();
    if (path == null) {
      SmartDialog.showToast("Hủy lưu");
    }
  }
}

Future<void> _importAllDataFromArchive(BuildContext context) async {
  final result = await FilePicker.pickFile(
    type: .custom,
    allowedExtensions: const ['zip'],
  );
  if (result == null) return;

  final Uint8List bytes;
  try {
    bytes = await result.readAsBytes();
  } catch (e) {
    SmartDialog.showToast('Nhập thất bại: $e');
    return;
  }

  if (!context.mounted) return;

  final actions = [
    TextButton(
      onPressed: Get.back,
      child: Text(
        'Hủy',
        style: TextStyle(color: ColorScheme.of(context).outline),
      ),
    ),
    TextButton(
      onPressed: () => Get.back(result: true),
      child: const Text('Tiếp tục'),
    ),
  ];

  final res = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Nhập toàn bộ dữ liệu?'),
      content: const Text('Cài đặt, thông tin tài khoản, bình luận cũ, lịch sử tìm kiếm, danh sách đen và phông chữ tùy chỉnh trong gói nén sẽ ghi đè dữ liệu hiện tại, thao tác này không thể hoàn tác.'),
      actions: actions,
    ),
  );

  if (res != true) return;

  try {
    final res = await ConfigArchive.import(
      bytes,
      onWarning: (warning) async {
        if (!context.mounted) return false;
        return await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Lưu ý'),
                content: Text(warning),
                actions: actions,
              ),
            ) ??
            false;
      },
    );
    if (res != null) {
      SmartDialog.showToast(res.isEmpty ? 'Nhập thành công' : 'Nhập thành công, nhưng $res');
    }
  } catch (e) {
    SmartDialog.showToast('Nhập thất bại: $e');
  }
}

Future<void> showDataImportExportDialog(BuildContext context) {
  final pageContext = context;
  return showDialog(
    context: context,
    builder: (context) {
      const style = TextStyle(fontSize: 15);
      return SimpleDialog(
        clipBehavior: .hardEdge,
        title: const Text('Nhập/xuất toàn bộ dữ liệu'),
        children: [
          DialogOption(
            child: const Text('Xuất ra gói nén', style: style),
            onPressed: () {
              Get.back();
              _exportAllDataToArchive();
            },
          ),
          DialogOption(
            child: const Text('Nhập từ gói nén', style: style),
            onPressed: () {
              Get.back();
              _importAllDataFromArchive(pageContext);
            },
          ),
        ],
      );
    },
  );
}

Future<void> showImportExportDialog<T>(
  BuildContext context, {
  required String title,
  required ValueGetter<String> onExport,
  required FutureOr<void> Function(T json) onImport,
  required ValueGetter<String> localFileName,
}) => showDialog(
  context: context,
  builder: (context) {
    const style = TextStyle(fontSize: 15);
    return SimpleDialog(
      clipBehavior: .hardEdge,
      title: Text('Nhập/xuất $title'),
      children: [
        DialogOption(
          child: const Text('Xuất ra bộ nhớ tạm', style: style),
          onPressed: () {
            Get.back();
            exportToClipBoard(onExport: onExport);
          },
        ),
        DialogOption(
          child: const Text('Xuất tệp ra máy', style: style),
          onPressed: () {
            Get.back();
            exportToLocalFile(onExport: onExport, localFileName: localFileName);
          },
        ),
        Divider(
          height: 1,
          color: ColorScheme.of(context).outline.withValues(alpha: 0.1),
        ),
        DialogOption(
          child: const Text('Nhập', style: style),
          onPressed: () {
            Get.back();
            importFromInput<T>(context, title: title, onImport: onImport);
          },
        ),
        DialogOption(
          child: const Text('Nhập từ bộ nhớ tạm', style: style),
          onPressed: () {
            Get.back();
            importFromClipBoard<T>(
              context,
              title: title,
              onExport: onExport,
              onImport: onImport,
            );
          },
        ),
        DialogOption(
          child: const Text('Nhập từ tệp trên máy', style: style),
          onPressed: () {
            Get.back();
            importFromLocalFile<T>(onImport: onImport);
          },
        ),
      ],
    );
  },
);
