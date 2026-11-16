import 'dart:io' show Platform;

import 'package:PiliPlus/common/widgets/custom_icon.dart';
import 'package:PiliPlus/grpc/reply.dart';
import 'package:PiliPlus/models/common/reply/reply_sort_type.dart';
import 'package:PiliPlus/pages/setting/models/model.dart';
import 'package:PiliPlus/pages/setting/widgets/slider_dialog.dart';
import 'package:PiliPlus/pages/video/reply/widgets/reply_item_grpc.dart';
import 'package:PiliPlus/utils/storage.dart';
import 'package:PiliPlus/utils/storage_key.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:material_ui/material_ui.dart' hide RefreshIndicator;

List<SettingsModel> get replySettings => [
  const SwitchModel(
    title: 'Hiển thị bình luận video',
    leading: Icon(MdiIcons.commentTextOutline),
    setKey: SettingBoxKey.showVideoReply,
    defaultVal: true,
  ),
  const SwitchModel(
    title: 'Hiển thị bình luận anime',
    leading: Icon(MdiIcons.commentTextOutline),
    setKey: SettingBoxKey.showBangumiReply,
    defaultVal: true,
  ),
  NormalModel(
    title: 'Số dòng thu gọn bình luận',
    subtitle: '0 là không thu gọn',
    leading: const Icon(Icons.compress),
    getTrailing: (theme) => Text(
      '${ReplyItemGrpc.replyLengthLimit} dòng',
      style: theme.textTheme.titleSmall,
    ),
    onTap: _showReplyLengthDialog,
  ),
  const SwitchModel(
    title: 'Ghi bình luận',
    leading: Icon(Icons.message_outlined),
    setKey: SettingBoxKey.saveReply,
    defaultVal: true,
    needReboot: true,
  ),
  const SwitchModel(
    title: 'Chống lừa đảo khi bình luận',
    subtitle: 'Kiểm tra bình luận có hiển thị sau khi gửi',
    leading: Icon(CustomIcons.shield_reply),
    setKey: SettingBoxKey.enableCommAntifraud,
    defaultVal: false,
  ),
  if (Platform.isAndroid)
    const SwitchModel(
      title: 'Dùng 「Bilibili chống lừa đảo bình luận」 để kiểm tra bình luận',
      leading: Icon(
        FontAwesomeIcons.b,
        size: 22,
      ),
      setKey: SettingBoxKey.biliSendCommAntifraud,
      defaultVal: false,
    ),
  SwitchModel(
    title: 'Chặn bình luận bán hàng',
    leading: const Icon(CustomIcons.shopping_bag_not_interested),
    setKey: SettingBoxKey.antiGoodsReply,
    defaultVal: false,
    onChanged: (value) => ReplyGrpc.antiGoodsReply = value,
  ),
  const NormalModel(
    title: 'Chặn số lượng @ trong bình luận',
    getSubtitle: _replyAtBlockSubtitle,
    leading: Icon(Icons.pin_outlined),
    onTap: _showReplyAtBlockDialog,
  ),
  const SwitchModel(
    title: 'Chặn bình luận chỉ chứa @',
    leading: Icon(Icons.alternate_email),
    setKey: SettingBoxKey.blockAtOnlyReply,
    onChanged: _onBlockAtOnlyReplyChanged,
  ),
  const SwitchModel(
    title: 'Chặn bình luận sao chép phần giới thiệu',
    leading: Icon(Icons.summarize),
    setKey: SettingBoxKey.filterIntro,
    defaultVal: false,
  ),
  getBanWordModel(
    title: 'Lọc từ khóa bình luận',
    key: SettingBoxKey.banWordForReply,
    onChanged: (value) {
      ReplyGrpc.replyRegExp = value;
      ReplyGrpc.enableFilter = value.pattern.isNotEmpty;
    },
  ),
  NormalModel(
    title: 'Ngưỡng thu gọn bình luận dạng chuỗi',
    getSubtitle: () => 'Hiện tại: 「${Pref.foldDepth}」, 0 là không thu gọn',
    leading: const Icon(Icons.compress),
    onTap: _showReplyDepthDialog,
  ),
  SwitchModel(
    title: 'Từ khóa tìm kiếm trong khu bình luận',
    subtitle: 'Hiển thị từ khóa tìm kiếm trong khu bình luận',
    leading: const Icon(Icons.search_outlined),
    setKey: SettingBoxKey.enableWordRe,
    defaultVal: false,
    onChanged: (value) => ReplyItemGrpc.enableWordRe = value,
  ),
  const SwitchModel(
    title: 'Mặc định hiển thị khu bình luận',
    subtitle: 'Ở trang chi tiết video mặc định chuyển sang trang bình luận (chỉ bố cục dạng Tab)',
    leading: Icon(Icons.mode_comment_outlined),
    setKey: SettingBoxKey.defaultShowComment,
    defaultVal: false,
  ),
  PopupModel(
    title: 'Hiển thị bình luận',
    leading: const Icon(Icons.whatshot_outlined),
    value: () => Pref.replySortType,
    items: ReplySortType.values.take(2),
    onSelected: (value, setState) => GStorage.setting
        .put(SettingBoxKey.replySortType, value.index)
        .whenComplete(setState),
  ),
  PopupModel(
    title: 'Hiển thị bình luận lồng nhau',
    leading: const Icon(Icons.subdirectory_arrow_right_outlined),
    value: () => Pref.reply2SortType,
    items: ReplySortType.values.take(2),
    onSelected: (value, setState) => GStorage.setting
        .put(SettingBoxKey.reply2SortType, value.index)
        .whenComplete(setState),
  ),
];

void _showReplyLengthDialog(BuildContext context, VoidCallback setState) {
  String replyLengthLimit = ReplyItemGrpc.replyLengthLimit.toString();
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Số dòng thu gọn bình luận'),
      content: TextFormField(
        autofocus: true,
        initialValue: replyLengthLimit,
        keyboardType: TextInputType.number,
        onChanged: (value) => replyLengthLimit = value,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(suffixText: 'dòng'),
      ),
      actions: [
        TextButton(
          onPressed: Get.back,
          child: Text(
            'Hủy',
            style: TextStyle(color: ColorScheme.of(context).outline),
          ),
        ),
        TextButton(
          onPressed: () async {
            try {
              final val = int.parse(replyLengthLimit);
              Get.back();
              ReplyItemGrpc.replyLengthLimit = val == 0 ? null : val;
              await GStorage.setting.put(SettingBoxKey.replyLengthLimit, val);
              setState();
            } catch (e) {
              SmartDialog.showToast(e.toString());
            }
          },
          child: const Text('Đồng ý'),
        ),
      ],
    ),
  );
}

String _replyAtBlockSubtitle() {
  final blockReplyAtCount = Pref.blockReplyAtCount;
  if (blockReplyAtCount == null) {
    return 'Vô hiệu hóa';
  }
  return 'Chặn bình luận có từ $blockReplyAtCount @ trở lên';
}

Future<void> _showReplyAtBlockDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  void onChanged([int? value]) {
    Get.back();
    ReplyGrpc.blockReplyAtCount = value;
    GStorage.setting
        .put(SettingBoxKey.blockReplyAtCount, value)
        .whenComplete(setState);
  }

  var countStr = Pref.blockReplyAtCount?.toString();
  await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Số lượng @ bị chặn'),
      content: TextFormField(
        autofocus: true,
        keyboardType: .number,
        initialValue: countStr,
        onChanged: (value) => countStr = value,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      ),
      actions: [
        TextButton(
          onPressed: onChanged,
          child: const Text('Vô hiệu hóa'),
        ),
        TextButton(
          onPressed: Get.back,
          child: Text(
            'Hủy',
            style: TextStyle(color: ColorScheme.of(context).outline),
          ),
        ),
        TextButton(
          onPressed: () {
            try {
              final count = int.parse(countStr!);
              onChanged(count > 0 ? count : null);
            } catch (e) {
              SmartDialog.showToast(e.toString());
            }
          },
          child: const Text('Xác nhận'),
        ),
      ],
    ),
  );
}

void _onBlockAtOnlyReplyChanged(bool value) =>
    ReplyGrpc.blockAtOnlyReply = value;

Future<void> _showReplyDepthDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  final res = await showDialog<double>(
    context: context,
    builder: (context) => SliderDialog(
      title: const Text('Ngưỡng thu gọn bình luận dạng chuỗi'),
      min: 0,
      max: 18,
      divisions: 19,
      precise: 0,
      value: Pref.foldDepth.toDouble(),
    ),
  );
  if (res != null) {
    GStorage.setting.put(SettingBoxKey.foldDepth, res.toInt());
    setState();
  }
}
