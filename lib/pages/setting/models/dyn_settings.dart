import 'package:PiliPlus/common/widgets/custom_icon.dart';
import 'package:PiliPlus/models/common/dynamic/dynamics_type.dart';
import 'package:PiliPlus/models/dynamics/result.dart'
    show DynamicsDataModel, ItemModulesModel;
import 'package:PiliPlus/pages/main/controller.dart';
import 'package:PiliPlus/pages/setting/models/model.dart';
import 'package:PiliPlus/utils/storage.dart';
import 'package:PiliPlus/utils/storage_key.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart' hide RefreshIndicator;

List<SettingsModel> get dynSettings => [
  SplitModel(
    normalModel: const NormalModel.split(
      title: 'Kiểm tra bài đăng chưa đọc',
      subtitle: 'Bấm để đặt chu kỳ kiểm tra (phút)',
      leading: Icon(Icons.notifications_none),
    ),
    switchModel: SwitchModel.split(
      defaultVal: true,
      setKey: SettingBoxKey.checkDynamic,
      onChanged: (value) => Get.find<MainController>().checkDynamic = value,
      onTap: _showDynDialog,
    ),
  ),
  SwitchModel(
    title: 'Hiển thị cảnh báo/thông tin gây tranh cãi của bài đăng',
    leading: const Icon(Icons.warning_amber_rounded),
    setKey: SettingBoxKey.showDynDispute,
    defaultVal: false,
    onChanged: (val) => ItemModulesModel.showDynDispute = val,
  ),
  getBanWordModel(
    title: 'Lọc từ khóa bài đăng',
    key: SettingBoxKey.banWordForDyn,
    onChanged: (value) {
      DynamicsDataModel.banWordForDyn = value;
      DynamicsDataModel.enableFilter = value.pattern.isNotEmpty;
    },
  ),
  const SwitchModel(
    title: 'Chống lừa đảo khi đăng/chuyển tiếp bài',
    subtitle: 'Kiểm tra bài đăng có hiển thị sau khi đăng/chuyển tiếp',
    leading: Icon(CustomIcons.shield_published),
    setKey: SettingBoxKey.enableCreateDynAntifraud,
    defaultVal: false,
  ),
  SwitchModel(
    title: 'Chặn bài đăng bán hàng',
    leading: const Icon(CustomIcons.shopping_bag_not_interested),
    setKey: SettingBoxKey.antiGoodsDyn,
    defaultVal: false,
    onChanged: (value) => DynamicsDataModel.antiGoodsDyn = value,
  ),
  const SwitchModel(
    title: 'Hiển thị thanh thao tác dưới ở trang chi tiết bài đăng/chuyên mục',
    leading: Icon(Icons.more_horiz),
    setKey: SettingBoxKey.showDynActionBar,
    defaultVal: true,
  ),
  PopupModel(
    title: 'Hiển thị bài đăng',
    leading: const Icon(Icons.dynamic_feed_rounded),
    value: () => Pref.defaultDynamicType,
    items: DynamicsTabType.values.take(4),
    onSelected: (value, setState) => GStorage.setting
        .put(SettingBoxKey.defaultDynamicType, value.index)
        .whenComplete(setState),
  ),
  SwitchModel(
    title: 'Hiển thị nội dung tương tác của bài đăng',
    subtitle: 'Khi bật, hiển thị nội dung tương tác (như người theo dõi thích, bình luận nổi bật) ở cuối thẻ bài đăng',
    leading: const Icon(Icons.quickreply_outlined),
    setKey: SettingBoxKey.showDynInteraction,
    defaultVal: true,
    onChanged: (val) => ItemModulesModel.showDynInteraction = val,
  ),
];

void _showDynDialog(BuildContext context) {
  String dynamicPeriod = Pref.dynamicPeriod.toString();
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Chu kỳ kiểm tra'),
      content: TextFormField(
        autofocus: true,
        initialValue: dynamicPeriod,
        keyboardType: TextInputType.number,
        onChanged: (value) => dynamicPeriod = value,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(suffixText: 'min'),
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
          onPressed: () {
            try {
              final val = int.parse(dynamicPeriod);
              Get.back();
              GStorage.setting.put(SettingBoxKey.dynamicPeriod, val);
              Get.find<MainController>().dynamicPeriod = val * 60 * 1000;
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
