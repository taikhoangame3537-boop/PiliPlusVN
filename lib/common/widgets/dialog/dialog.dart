import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

Future<bool> showConfirmDialog({
  required BuildContext context,
  required Widget title,
  Widget? content,
  // @Deprecated('use `bool result = await showConfirmDialog()` instead')
  VoidCallback? onConfirm,
}) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: title,
          content: content,
          actions: [
            TextButton(
              onPressed: Get.back,
              child: Text(
                'Hủy',
                style: TextStyle(color: ColorScheme.of(context).outline),
              ),
            ),
            TextButton(
              onPressed: () {
                Get.back(result: true);
                onConfirm?.call();
              },
              child: const Text('Xác nhận'),
            ),
          ],
        ),
      ) ??
      false;
}

Widget _statusItem({
  required bool enabled,
  required String text,
  required VoidCallback onTap,
}) {
  return ListTile(
    dense: true,
    enabled: enabled,
    title: Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Text(
        'Đánh dấu là $text',
        style: const TextStyle(fontSize: 14),
      ),
    ),
    trailing: !enabled ? const Icon(size: 22, Icons.check) : null,
    onTap: onTap,
  );
}

void showPgcFollowDialog({
  required BuildContext context,
  required String type,
  required int followStatus,
  required ValueChanged<int> onUpdateStatus,
}) {
  showDialog(
    context: context,
    builder: (context) => SimpleDialog(
      clipBehavior: Clip.hardEdge,
      contentPadding: const EdgeInsets.symmetric(vertical: 12),
      children: [
        ...const [
          (followStatus: 3, title: 'Đã xem'),
          (followStatus: 2, title: 'Đang xem'),
          (followStatus: 1, title: 'Muốn xem'),
        ].map(
          (item) => _statusItem(
            enabled: followStatus != item.followStatus,
            text: item.title,
            onTap: () {
              Get.back();
              onUpdateStatus(item.followStatus);
            },
          ),
        ),
        ListTile(
          dense: true,
          title: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text(
              'Hủy $type',
              style: const TextStyle(fontSize: 14),
            ),
          ),
          onTap: () {
            Get.back();
            onUpdateStatus(-1);
          },
        ),
      ],
    ),
  );
}
