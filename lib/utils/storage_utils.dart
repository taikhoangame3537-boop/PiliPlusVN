import 'dart:io' show File;
import 'dart:typed_data' show Uint8List;

import 'package:PiliPlus/utils/platform_utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

abstract final class StorageUtils {
  static Future<void> saveBytes2File({
    required String name,
    required Uint8List bytes,
  }) async {
    try {
      final path = await FilePicker.saveFile(
        fileName: name,
        bytes: PlatformUtils.isDesktop ? Uint8List(0) : bytes,
      );
      if (path == null) {
        SmartDialog.showToast("Hủy lưu");
        return;
      }
      if (PlatformUtils.isDesktop) {
        await File(path.toFilePath()).writeAsBytes(bytes);
      }
      SmartDialog.showToast("Đã lưu");
    } catch (e) {
      SmartDialog.showToast("Lưu thất bại: $e");
    }
  }
}
