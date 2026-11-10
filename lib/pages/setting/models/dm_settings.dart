import 'dart:math' show max;

import 'package:PiliPlus/common/widgets/custom_icon.dart';
import 'package:PiliPlus/pages/setting/models/model.dart';
import 'package:PiliPlus/utils/extension/num_ext.dart';
import 'package:PiliPlus/utils/filtering_text.dart';
import 'package:PiliPlus/utils/platform_utils.dart';
import 'package:PiliPlus/utils/storage.dart';
import 'package:PiliPlus/utils/storage_key.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:material_ui/material_ui.dart' hide RefreshIndicator;

List<SettingsModel> get dmSettings => [
  const SwitchModel(
    title: 'Công tắc danmaku',
    subtitle: 'Có hiển thị danmaku không',
    leading: Icon(CustomIcons.dm_settings),
    setKey: SettingBoxKey.enableShowDanmaku,
    defaultVal: true,
  ),
  if (PlatformUtils.isMobile)
    const SwitchModel(
      title: 'Bật bấm vào danmaku',
      subtitle: 'Bấm danmaku để dừng, hỗ trợ thích, sao chép, báo cáo',
      leading: Icon(Icons.touch_app_outlined),
      setKey: SettingBoxKey.enableTapDm,
      defaultVal: true,
    ),
  NormalModel(
    title: 'Chiều cao dòng danmaku',
    subtitle: 'Mặc định 1.6',
    leading: const Icon(CustomIcons.dm_settings),
    getTrailing: (theme) => Text(
      Pref.danmakuLineHeight.toString(),
      style: theme.textTheme.titleSmall,
    ),
    onTap: _showDmHeightDialog,
  ),
  const SwitchModel(
    title: 'Hiển thị danmaku màu của hội viên',
    leading: Icon(MdiIcons.gradientHorizontal),
    setKey: SettingBoxKey.showVipDanmaku,
    defaultVal: true,
  ),
  const SwitchModel(
    title: 'Gộp danmaku',
    subtitle: 'Gộp các danmaku giống nhau lấy được trong một khoảng thời gian',
    leading: Icon(Icons.merge),
    setKey: SettingBoxKey.mergeDanmaku,
    defaultVal: false,
  ),
];

void _showDmHeightDialog(BuildContext context, VoidCallback setState) {
  String danmakuLineHeight = Pref.danmakuLineHeight.toString();
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Chiều cao dòng danmaku'),
      content: TextFormField(
        autofocus: true,
        initialValue: danmakuLineHeight,
        keyboardType: const .numberWithOptions(decimal: true),
        onChanged: (value) => danmakuLineHeight = value,
        inputFormatters: FilteringText.decimal,
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
              final val = max(
                1.0,
                double.parse(danmakuLineHeight).toPrecision(1),
              );
              Get.back();
              await GStorage.setting.put(SettingBoxKey.danmakuLineHeight, val);
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
