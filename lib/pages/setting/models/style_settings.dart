import 'dart:io';
import 'dart:math' as math;

import 'package:PiliPlus/common/widgets/color_palette.dart';
import 'package:PiliPlus/common/widgets/custom_toast.dart';
import 'package:PiliPlus/common/widgets/dialog/dialog.dart';
import 'package:PiliPlus/common/widgets/emote_tooltip.dart'
    show enableEmoteTooltip;
import 'package:PiliPlus/common/widgets/image/network_img_layer.dart';
import 'package:PiliPlus/common/widgets/pendant_avatar.dart';
import 'package:PiliPlus/common/widgets/scale_app.dart';
import 'package:PiliPlus/common/widgets/scroll_physics.dart'
    show kSpringDescription;
import 'package:PiliPlus/common/widgets/stateful_builder.dart';
import 'package:PiliPlus/models/common/bar_hide_type.dart';
import 'package:PiliPlus/models/common/dynamic/dynamic_badge_mode.dart';
import 'package:PiliPlus/models/common/dynamic/up_panel_position.dart';
import 'package:PiliPlus/models/common/home_tab_type.dart';
import 'package:PiliPlus/models/common/member/tab_type.dart';
import 'package:PiliPlus/models/common/mine_tab_type.dart';
import 'package:PiliPlus/models/common/msg/msg_unread_type.dart';
import 'package:PiliPlus/models/common/nav_bar_config.dart';
import 'package:PiliPlus/models/common/theme/theme_color_type.dart';
import 'package:PiliPlus/models/common/theme/theme_type.dart';
import 'package:PiliPlus/pages/main/controller.dart';
import 'package:PiliPlus/pages/mine/controller.dart';
import 'package:PiliPlus/pages/setting/models/model.dart';
import 'package:PiliPlus/pages/setting/slide_color_picker.dart';
import 'package:PiliPlus/pages/setting/widgets/dual_slider_dialog.dart';
import 'package:PiliPlus/pages/setting/widgets/multi_select_dialog.dart';
import 'package:PiliPlus/pages/setting/widgets/ordered_multi_select_dialog.dart';
import 'package:PiliPlus/pages/setting/widgets/select_dialog.dart';
import 'package:PiliPlus/pages/setting/widgets/slider_dialog.dart';
import 'package:PiliPlus/plugin/pl_player/utils/fullscreen.dart';
import 'package:PiliPlus/utils/extension/file_ext.dart';
import 'package:PiliPlus/utils/extension/get_ext.dart';
import 'package:PiliPlus/utils/extension/num_ext.dart';
import 'package:PiliPlus/utils/extension/theme_ext.dart';
import 'package:PiliPlus/utils/global_data.dart';
import 'package:PiliPlus/utils/path_utils.dart';
import 'package:PiliPlus/utils/platform_utils.dart';
import 'package:PiliPlus/utils/storage.dart';
import 'package:PiliPlus/utils/storage_key.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:PiliPlus/utils/theme_utils.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:material_ui/material_ui.dart' hide StatefulBuilder;
import 'package:path/path.dart' as path;

List<SettingsModel> get styleSettings => [
  if (PlatformUtils.isDesktop) ...[
    const SwitchModel(
      title: 'Hiển thị thanh tiêu đề cửa sổ',
      leading: Icon(Icons.window),
      setKey: SettingBoxKey.showWindowTitleBar,
      defaultVal: true,
      needReboot: true,
    ),
    const SwitchModel(
      title: 'Hiển thị biểu tượng khay',
      leading: Icon(Icons.donut_large_rounded),
      setKey: SettingBoxKey.showTrayIcon,
      defaultVal: true,
      needReboot: true,
    ),
  ],
  if (Platform.isLinux) _useSSDModel(),
  SwitchModel(
    title: 'Thích ứng ngang',
    subtitle: 'Bật bố cục và logic ngang, có thể bật cho máy tính bảng, điện thoại gập; nên đặt hướng toàn màn hình là 【Không đổi hướng hiện tại】',
    leading: const Icon(Icons.phonelink_outlined),
    setKey: SettingBoxKey.horizontalScreen,
    defaultVal: Pref.horizontalScreen,
    onChanged: _onHorizontalScreenChanged,
  ),
  const SwitchModel(
    title: 'Dùng thanh bên',
    subtitle: 'Khi bật, thanh dưới và thanh trên bị thay thế, các cài đặt liên quan mất tác dụng',
    leading: Icon(Icons.chrome_reader_mode_outlined),
    setKey: SettingBoxKey.useSideBar,
    defaultVal: false,
    needReboot: true,
  ),
  const SwitchModel(
    title: 'Ẩn chữ thanh bên',
    subtitle: 'Chỉ hiển thị biểu tượng, giảm chiều rộng thanh bên',
    leading: Icon(Icons.label_off_outlined),
    setKey: SettingBoxKey.hideSideBarLabel,
    defaultVal: false,
    needReboot: true,
  ),
  NormalModel(
    title: 'Cài đặt phông chữ ứng dụng',
    subtitle: 'Bấm để cài đặt',
    leading: const Icon(Icons.text_fields),
    onTap: (context, setState) => Get.toNamed('/fontSetting'),
  ),
  NormalModel(
    title: 'Thu phóng giao diện',
    getSubtitle: () => 'Tỉ lệ thu phóng hiện tại: ${Pref.uiScale.toStringAsFixed(2)}',
    leading: const Icon(Icons.zoom_in_outlined),
    onTap: _showUiScaleDialog,
  ),
  const SwitchModel(
    title: 'Hiệu ứng chuyển trang ở trang chủ',
    leading: Icon(Icons.home_outlined),
    setKey: SettingBoxKey.mainTabBarView,
    defaultVal: false,
    needReboot: true,
  ),
  if (PlatformUtils.isDesktop)
    const SwitchModel(
      title: 'Hiển thị nút làm mới ở trang chủ',
      leading: Icon(Icons.refresh),
      setKey: SettingBoxKey.showRefreshFAB,
      defaultVal: true,
      needReboot: true,
    ),
  NormalModel(
    title: 'Hiệu ứng chuyển trang',
    leading: const Icon(Icons.animation),
    getSubtitle: () => 'Hiện tại: ${Pref.pageTransition.name}',
    onTap: _showTransitionDialog,
  ),
  const SwitchModel(
    title: 'Tối ưu thanh điều hướng máy tính bảng',
    leading: Icon(Icons.auto_fix_high),
    setKey: SettingBoxKey.optTabletNav,
    defaultVal: true,
    needReboot: true,
  ),
  const SwitchModel(
    title: 'Thanh dưới kiểu MD3',
    subtitle: 'Thanh dưới theo quy chuẩn Material You, tắt để thu hẹp',
    leading: Icon(Icons.design_services_outlined),
    setKey: SettingBoxKey.enableMYBar,
    defaultVal: true,
    needReboot: true,
  ),
  const SwitchModel(
    title: 'Thanh dưới nổi',
    leading: Icon(MdiIcons.soundbar),
    setKey: SettingBoxKey.floatingNavBar,
    defaultVal: false,
    needReboot: true,
  ),
  SwitchModel(
    title: 'Hiển thị huy hiệu fan',
    leading: const Icon(MdiIcons.medalOutline),
    setKey: SettingBoxKey.showMedal,
    defaultVal: true,
    onChanged: (value) => GlobalData().showMedal = value,
  ),
  SwitchModel(
    title: 'Hiển thị trang trí ảnh đại diện/bình luận/bài đăng',
    leading: const Icon(MdiIcons.stickerCircleOutline),
    setKey: SettingBoxKey.showDecorate,
    defaultVal: true,
    onChanged: (value) => PendantAvatar.showDecorate = value,
  ),
  SwitchModel(
    title: 'Bấm biểu cảm hiển thị Tooltip',
    leading: const Icon(Icons.emoji_emotions_outlined),
    setKey: SettingBoxKey.enableEmoteTooltip,
    defaultVal: false,
    onChanged: (value) => enableEmoteTooltip = value,
  ),
  NormalModel(
    leading: const Icon(Icons.calendar_view_week_outlined),
    title: 'Giới hạn độ rộng danh sách (dp)',
    getSubtitle: () =>
        'Hiện tại: trang chủ ${Pref.recommendCardWidth.toInt()}dp khác ${Pref.smallCardWidth.toInt()}dp, chiều rộng màn hình: ${MediaQuery.widthOf(Get.context!).toPrecision(2)}dp. Chiều rộng càng nhỏ càng nhiều cột.',
    onTap: _showCardWidthDialog,
  ),
  const SwitchModel(
    title: 'Bỏ vùng an toàn ở trang phát',
    leading: Icon(Icons.fit_screen_outlined),
    setKey: SettingBoxKey.removeSafeArea,
    defaultVal: false,
  ),
  const SwitchModel(
    title: 'Trang phát video dùng giao diện tối',
    leading: Icon(Icons.dark_mode_outlined),
    setKey: SettingBoxKey.darkVideoPage,
    defaultVal: false,
  ),
  SwitchModel(
    title: 'Bật dạng thác nước ở trang dòng thời gian',
    subtitle: 'Khi tắt sẽ hiển thị một cột',
    leading: const Icon(Icons.view_array_outlined),
    setKey: SettingBoxKey.dynamicsWaterfallFlow,
    defaultVal: Pref.horizontalScreen,
    needReboot: true,
  ),
  PopupModel(
    title: 'Vị trí hiển thị UP chủ ở trang dòng thời gian',
    leading: const Icon(Icons.person_outlined),
    value: () => Pref.upPanelPosition,
    items: UpPanelPosition.values,
    onSelected: (value, setState) {
      GStorage.setting
          .put(SettingBoxKey.upPanelPosition, value.index)
          .whenComplete(setState);
      SmartDialog.showToast('Khởi động lại để áp dụng');
    },
  ),
  const SwitchModel(
    title: 'Trang dòng thời gian hiển thị tất cả UP chủ đã theo dõi',
    leading: Icon(Icons.people_alt_outlined),
    setKey: SettingBoxKey.dynamicsShowAllFollowedUp,
    defaultVal: false,
    needReboot: true,
  ),
  const SwitchModel(
    title: 'Trang dòng thời gian mở rộng danh sách UP đang phát trực tiếp',
    leading: Icon(Icons.live_tv),
    setKey: SettingBoxKey.expandDynLivePanel,
    defaultVal: false,
    needReboot: true,
  ),
  PopupModel(
    title: 'Dấu chưa đọc dòng thời gian',
    leading: const Icon(Icons.motion_photos_on_outlined),
    value: () => Pref.dynamicBadgeType,
    items: DynamicBadgeMode.values,
    onSelected: _setDynBadge,
  ),
  PopupModel(
    title: 'Dấu chưa đọc tin nhắn',
    leading: const Icon(MdiIcons.bellBadgeOutline),
    value: () => Pref.msgBadgeMode,
    items: DynamicBadgeMode.values,
    onSelected: _setMsgBadge,
  ),
  NormalModel(
    onTap: _showMsgUnReadDialog,
    title: 'Loại tin nhắn chưa đọc',
    leading: const Icon(MdiIcons.bellCogOutline),
    getSubtitle: () =>
        'Loại tin nhắn hiện tại: ${Pref.msgUnReadTypeV2.map((item) => item.title).join(', ')}',
  ),
  PopupModel(
    title: 'Kiểu thu gọn thanh trên/dưới',
    leading: const Icon(MdiIcons.arrowExpandVertical),
    value: () => Pref.barHideType,
    items: BarHideType.values,
    onSelected: (value, setState) {
      GStorage.setting
          .put(SettingBoxKey.barHideType, value.index)
          .whenComplete(setState);
      SmartDialog.showToast('Khởi động lại để áp dụng');
    },
  ),
  NormalModel(
    title: 'Tab mặc định trang người dùng',
    leading: const Icon(Icons.tab),
    getSubtitle: () => 'Hiện ưu tiên hiển thị 「${Pref.memberTab.title}」',
    onTap: _showMemberTabDialog,
  ),
  SwitchModel(
    title: 'Hiển thị tab Cửa hàng nhỏ ở trang UP chủ',
    leading: const Icon(Icons.shop_outlined),
    setKey: SettingBoxKey.showMemberShop,
    defaultVal: false,
    onChanged: (value) => MemberTabType.showMemberShop = value,
  ),
  SwitchModel(
    title: 'Thu gọn thanh trên trang chủ',
    subtitle: 'Thu gọn thanh trên khi cuộn danh sách trang chủ',
    leading: const Icon(Icons.vertical_align_top_outlined),
    setKey: SettingBoxKey.hideTopBar,
    defaultVal: PlatformUtils.isMobile,
    needReboot: true,
  ),
  SwitchModel(
    title: 'Thu gọn thanh dưới trang chủ',
    subtitle: 'Thu gọn thanh dưới khi cuộn danh sách trang chủ',
    leading: const Icon(Icons.vertical_align_bottom_outlined),
    setKey: SettingBoxKey.hideBottomBar,
    defaultVal: PlatformUtils.isMobile,
    needReboot: true,
  ),
  NormalModel(
    onTap: (context, setState) => _showQualityDialog(
      context: context,
      title: const Text('Chất lượng ảnh'),
      initValue: Pref.picQuality,
      onChanged: (picQuality) async {
        GlobalData().imgQuality = picQuality;
        await GStorage.setting.put(SettingBoxKey.defaultPicQa, picQuality);
        setState();
      },
    ),
    title: 'Chất lượng ảnh',
    subtitle: 'Chọn độ nét ảnh phù hợp, tối đa 100%',
    leading: const Icon(Icons.image_outlined),
    getTrailing: (theme) => Text(
      '${Pref.picQuality}%',
      style: theme.textTheme.titleSmall,
    ),
  ),
  NormalModel(
    onTap: (context, setState) => _showQualityDialog(
      context: context,
      title: const Text('Chất lượng xem ảnh lớn'),
      initValue: Pref.previewQ,
      onChanged: (picQuality) async {
        await GStorage.setting.put(SettingBoxKey.previewQuality, picQuality);
        setState();
      },
    ),
    title: 'Chất lượng xem ảnh lớn',
    subtitle: 'Chọn độ nét ảnh phù hợp, tối đa 100%',
    leading: const Icon(Icons.image_outlined),
    getTrailing: (theme) => Text(
      '${Pref.previewQ}%',
      style: theme.textTheme.titleSmall,
    ),
  ),
  NormalModel(
    onTap: _showReduceColorDialog,
    title: 'Phủ màu ảnh khi ở giao diện tối',
    subtitle: 'Màu hiển thị = màu gốc ảnh x màu đã chọn, xem ảnh lớn không bị ảnh hưởng',
    leading: const Icon(Icons.format_color_fill_outlined),
    getTrailing: (theme) => Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: Pref.reduceLuxColor ?? Colors.white,
        shape: BoxShape.circle,
      ),
    ),
  ),
  NormalModel(
    leading: const Icon(Icons.opacity_outlined),
    title: 'Độ mờ thông báo bong bóng',
    subtitle: 'Tùy chỉnh độ mờ thông báo bong bóng (Toast)',
    getTrailing: (theme) => Text(
      CustomToast.toastOpacity.toStringAsFixed(1),
      style: theme.textTheme.titleSmall,
    ),
    onTap: _showToastDialog,
  ),
  PopupModel(
    leading: const Icon(Icons.flashlight_on_outlined),
    title: 'Chế độ giao diện',
    value: () => Pref.themeType,
    items: ThemeType.values,
    onSelected: _setThemeType,
  ),
  SwitchModel(
    leading: const Icon(Icons.invert_colors),
    title: 'Giao diện đen tuyền',
    setKey: SettingBoxKey.isPureBlackTheme,
    defaultVal: false,
    onChanged: (value) {
      if (ThemeUtils.isDarkMode || Pref.darkVideoPage) {
        Get.updateMyAppTheme();
      }
    },
  ),
  NormalModel(
    onTap: (context, setState) => Get.toNamed('/colorSetting'),
    leading: const Icon(Icons.color_lens_outlined),
    title: 'Giao diện ứng dụng',
    getSubtitle: () => 'Giao diện hiện tại: ${Pref.dynamicColor ? 'Màu động' : 'Màu chỉ định'}',
    getTrailing: _themeTrailing,
  ),
  NormalModel(
    onTap: _showMineTabsDialog,
    title: 'Thẻ trang của tôi',
    leading: const Icon(Icons.person_outline),
    getSubtitle: () =>
        'Đang hiển thị: ${Pref.mineTabs.map((item) => item.label).join(', ')}',
  ),
  PopupModel(
    leading: const Icon(Icons.home_outlined),
    title: 'Trang khởi động mặc định',
    value: () => Pref.defaultHomePage,
    items: NavigationBarType.values,
    onSelected: (value, setState) {
      GStorage.setting
          .put(SettingBoxKey.defaultHomePage, value.index)
          .whenComplete(setState);
      SmartDialog.showToast('Khởi động lại để áp dụng');
    },
  ),
  const NormalModel(
    title: 'Tham số lò xo hiệu ứng vuốt',
    leading: Icon(Icons.chrome_reader_mode_outlined),
    onTap: _showSpringDialog,
  ),
  NormalModel(
    onTap: (context, setState) => Get.toNamed(
      '/barSetting',
      arguments: {
        'key': SettingBoxKey.tabBarSort,
        'defaultBars': HomeTabType.values,
        'title': 'Tab trang chủ',
      },
    ),
    title: 'Tab trang chủ',
    subtitle: 'Xóa hoặc đổi chỗ tab trang chủ',
    leading: const Icon(Icons.toc_outlined),
  ),
  NormalModel(
    onTap: (context, setState) => Get.toNamed(
      '/barSetting',
      arguments: {
        'key': SettingBoxKey.navBarSort,
        'defaultBars': NavigationBarType.values,
        'title': 'Navbar',
      },
    ),
    title: 'Chỉnh sửa Navbar',
    subtitle: 'Xóa hoặc đổi chỗ Navbar',
    leading: const Icon(Icons.toc_outlined),
  ),
  SwitchModel(
    title: 'Thoát thẳng khi quay lại',
    subtitle: 'Khi bật, nhấn quay lại ở bất kỳ tab nào của trang chủ sẽ thoát ngay, khi tắt sẽ về tab đầu tiên của Navbar trước',
    leading: const Icon(Icons.exit_to_app_outlined),
    setKey: SettingBoxKey.directExitOnBack,
    defaultVal: false,
    onChanged: (value) => Get.find<MainController>().directExitOnBack = value,
  ),
  if (Platform.isAndroid)
    NormalModel(
      onTap: (context, setState) => Get.toNamed('/displayModeSetting'),
      title: 'Tốc độ khung hình màn hình',
      leading: const Icon(Icons.autofps_select_outlined),
    ),
];

void _showQualityDialog({
  required BuildContext context,
  required Widget title,
  required int initValue,
  required ValueChanged<int> onChanged,
}) {
  showDialog<double>(
    context: context,
    builder: (context) => SliderDialog(
      value: initValue.toDouble(),
      title: title,
      min: 10,
      max: 100,
      divisions: 9,
      suffix: '%',
      precise: 0,
    ),
  ).then((result) {
    if (result != null) {
      SmartDialog.showToast('Đã cài đặt');
      onChanged(result.toInt());
    }
  });
}

void _showUiScaleDialog(
  BuildContext context,
  VoidCallback setState,
) {
  const minUiScale = 0.5;
  const maxUiScale = 2.0;

  double uiScale = Pref.uiScale;
  final textController = TextEditingController(
    text: uiScale.toStringAsFixed(2),
  );

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Thu phóng giao diện'),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      content: StatefulBuilder(
        onDispose: textController.dispose,
        builder: (context, setDialogState) => Column(
          spacing: 20,
          mainAxisSize: MainAxisSize.min,
          children: [
            Slider(
              padding: .zero,
              value: uiScale,
              min: minUiScale,
              max: maxUiScale,
              secondaryTrackValue: 1.0,
              divisions: ((maxUiScale - minUiScale) * 20).toInt(),
              label: textController.text,
              onChanged: (value) => setDialogState(() {
                uiScale = value.toPrecision(2);
                textController.text = uiScale.toStringAsFixed(2);
              }),
            ),
            TextFormField(
              controller: textController,
              keyboardType: const .numberWithOptions(decimal: true),
              inputFormatters: [
                LengthLimitingTextInputFormatter(4),
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]+')),
              ],
              decoration: const InputDecoration(
                labelText: 'Tỉ lệ thu phóng',
                hintText: '0.50 - 2.00',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                final parsed = double.tryParse(value);
                if (parsed != null &&
                    parsed >= minUiScale &&
                    parsed <= maxUiScale) {
                  setDialogState(() {
                    uiScale = parsed;
                  });
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            GStorage.setting.delete(SettingBoxKey.uiScale).whenComplete(() {
              setState();
              Get.appUpdate();
              ScaledWidgetsFlutterBinding.instance.scaleFactor = 1.0;
            });
          },
          child: const Text('Đặt lại'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Hủy',
            style: TextStyle(color: ColorScheme.of(context).outline),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            GStorage.setting.put(SettingBoxKey.uiScale, uiScale).whenComplete(
              () {
                setState();
                Get.appUpdate();
                ScaledWidgetsFlutterBinding.instance.scaleFactor = uiScale;
              },
            );
          },
          child: const Text('Đồng ý'),
        ),
      ],
    ),
  );
}

void _showSpringDialog(BuildContext context, _) {
  final List<String> springDescription = Pref.springDescription
      .map((i) => i.toString())
      .toList(growable: false);
  bool physicalMode = true;

  void physical2Duration() {
    final mass = double.parse(springDescription[0]);
    final stiffness = double.parse(springDescription[1]);
    final damping = double.parse(springDescription[2]);

    final duration = math.sqrt(4 * math.pi * math.pi * mass / stiffness);
    final dampingRatio = damping / (2.0 * math.sqrt(mass * stiffness));
    final bounce = dampingRatio < 1.0
        ? 1.0 - dampingRatio
        : 1.0 / dampingRatio - 1;

    springDescription[0] = duration.toString();
    springDescription[1] = bounce.toString();
  }

  /// from [SpringDescription.withDurationAndBounce] but with higher precision
  void duration2Physical() {
    final duration = double.parse(springDescription[0]);
    final bounce = double.parse(springDescription[1]).clamp(-1.0, 1.0);

    final stiffness = 4 * math.pi * math.pi / math.pow(duration, 2);
    final dampingRatio = bounce > 0 ? 1.0 - bounce : 1.0 / (bounce + 1);
    final damping = 2 * math.sqrt(stiffness) * dampingRatio;

    springDescription[0] = '1';
    springDescription[1] = stiffness.toString();
    springDescription[2] = damping.toString();
  }

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        mainAxisAlignment: .spaceBetween,
        children: [
          const Text('Tham số lò xo'),
          TextButton(
            style: TextButton.styleFrom(
              visualDensity: .compact,
              tapTargetSize: .shrinkWrap,
            ),
            onPressed: () {
              try {
                if (physicalMode) {
                  physical2Duration();
                } else {
                  duration2Physical();
                }
                physicalMode = !physicalMode;
                (context as Element).markNeedsBuild();
              } catch (e) {
                SmartDialog.showToast(e.toString());
              }
            },
            child: Text(physicalMode ? 'Thời gian vuốt' : 'Tham số vật lý'),
          ),
        ],
      ),
      content: Column(
        key: ValueKey(physicalMode),
        mainAxisSize: .min,
        children: List.generate(
          physicalMode ? 3 : 2,
          (index) => TextFormField(
            autofocus: index == 0,
            initialValue: springDescription[index],
            keyboardType: .numberWithOptions(
              signed: !physicalMode && index == 1,
              decimal: true,
            ),
            onChanged: (value) => springDescription[index] = value,
            inputFormatters: [
              !physicalMode && index == 1
                  ? FilteringTextInputFormatter.allow(RegExp(r'[-\d\.]+'))
                  : FilteringTextInputFormatter.allow(RegExp(r'[\d\.]+')),
            ],
            decoration: InputDecoration(
              labelText: (physicalMode
                  ? const ['mass', 'stiffness', 'damping']
                  : const ['duration', 'bounce'])[index],
              suffixText: !physicalMode && index == 0 ? 's' : null,
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
            GStorage.setting.delete(SettingBoxKey.springDescription);
            SmartDialog.showToast('Đặt lại thành công, khởi động lại để áp dụng');
          },
          child: const Text('Đặt lại'),
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
              if (!physicalMode) {
                duration2Physical();
              }
              final res = springDescription.map(double.parse).toList();
              Get.back();
              GStorage.setting.put(SettingBoxKey.springDescription, res);
              kSpringDescription = SpringDescription(
                mass: res[0],
                stiffness: res[1],
                damping: res[2],
              );
              SmartDialog.showToast('Đã cài đặt');
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

Future<void> _showTransitionDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  final res = await showDialog<Transition>(
    context: context,
    builder: (context) => SelectDialog<Transition>(
      title: 'Hiệu ứng chuyển trang',
      value: Pref.pageTransition,
      values: Transition.values.map((e) => (e, e.name)).toList(),
    ),
  );
  if (res != null) {
    Get.rootController.defaultTransition = res;
    await GStorage.setting.put(SettingBoxKey.pageTransition, res.index);
    setState();
  }
}

Future<void> _showCardWidthDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  final res = await showDialog<(double, double)>(
    context: context,
    builder: (context) => DualSliderDialog(
      title: const Text('Chiều rộng cột tối đa của danh sách (mặc định 240dp)'),
      value1: Pref.recommendCardWidth,
      value2: Pref.smallCardWidth,
      description1: const Text('Luồng đề xuất trang chủ'),
      description2: const Text('Khác'),
      min: 150.0,
      max: 500.0,
      divisions: 35,
      suffix: 'dp',
    ),
  );
  if (res != null) {
    await GStorage.setting.putAll({
      SettingBoxKey.recommendCardWidth: res.$1,
      SettingBoxKey.smallCardWidth: res.$2,
    });
    SmartDialog.showToast('Khởi động lại để áp dụng');
    setState();
  }
}

void _setDynBadge(DynamicBadgeMode value, VoidCallback setState) {
  final mainController = Get.find<MainController>()..dynamicBadgeMode = value;
  if (value != DynamicBadgeMode.hidden) mainController.getUnreadDynamic();
  GStorage.setting
      .put(SettingBoxKey.dynamicBadgeMode, value.index)
      .whenComplete(setState);
}

void _setMsgBadge(DynamicBadgeMode value, VoidCallback setState) {
  final mainController = Get.find<MainController>()..msgBadgeMode = value;
  if (value != DynamicBadgeMode.hidden) {
    mainController.queryUnreadMsg(true);
  } else {
    mainController.clearUnreadMsg();
  }
  GStorage.setting
      .put(SettingBoxKey.msgBadgeMode, value.index)
      .whenComplete(setState);
}

Future<void> _showMsgUnReadDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  final res = await showDialog<Set<MsgUnReadType>>(
    context: context,
    builder: (context) => MultiSelectDialog<MsgUnReadType>(
      title: 'Loại tin nhắn chưa đọc',
      initValues: Pref.msgUnReadTypeV2,
      values: {for (final i in MsgUnReadType.values) i: i.title},
    ),
  );
  if (res != null) {
    final mainController = Get.find<MainController>()..msgUnReadTypes = res;
    if (mainController.msgBadgeMode != DynamicBadgeMode.hidden) {
      mainController.queryUnreadMsg();
    }
    await GStorage.setting.put(
      SettingBoxKey.msgUnReadTypeV2,
      res.map((item) => item.index).toList()..sort(),
    );
    SmartDialog.showToast('Đã cài đặt');
    setState();
  }
}

void _showReduceColorDialog(
  BuildContext context,
  VoidCallback setState,
) {
  final reduceLuxColor = Pref.reduceLuxColor;
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      clipBehavior: Clip.hardEdge,
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      title: const Text('Color Picker'),
      content: SlideColorPicker(
        color: reduceLuxColor ?? Colors.white,
        onChanged: (Color? color) {
          if (color != null && color != reduceLuxColor) {
            if (color == Colors.white) {
              NetworkImgLayer.reduceLuxColor = null;
              GStorage.setting.delete(SettingBoxKey.reduceLuxColor);
              SmartDialog.showToast('Đã cài đặt');
              setState();
            } else {
              void onConfirm() {
                NetworkImgLayer.reduceLuxColor = color;
                GStorage.setting.put(
                  SettingBoxKey.reduceLuxColor,
                  color.toARGB32(),
                );
                SmartDialog.showToast('Đã cài đặt');
                setState();
              }

              if (color.computeLuminance() < 0.2) {
                showConfirmDialog(
                  context: context,
                  title: Text(
                    'Xác nhận dùng #${(color.toARGB32() & 0xFFFFFF).toRadixString(16).toUpperCase().padLeft(6)}?',
                  ),
                  content: const Text('Màu đã chọn quá tối, có thể ảnh hưởng việc xem ảnh'),
                  onConfirm: onConfirm,
                );
              } else {
                onConfirm();
              }
            }
          }
        },
      ),
    ),
  );
}

Future<void> _showToastDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  final res = await showDialog<double>(
    context: context,
    builder: (context) => SliderDialog(
      title: const Text('Độ mờ Toast'),
      value: CustomToast.toastOpacity,
      min: 0.0,
      max: 1.0,
      divisions: 10,
    ),
  );
  if (res != null) {
    CustomToast.toastOpacity = res;
    await GStorage.setting.put(SettingBoxKey.defaultToastOp, res);
    SmartDialog.showToast('Đã cài đặt');
    setState();
  }
}

void _setThemeType(ThemeType value, VoidCallback setState) {
  try {
    Get.find<MineController>().themeType.value = value;
  } catch (_) {}
  GStorage.setting.put(SettingBoxKey.themeMode, value.index);
  Get.changeThemeMode(ThemeUtils.themeMode = value.toThemeMode);
  setState();
}

NormalModel _useSSDModel() {
  final file = File(path.join(appSupportDirPath, 'use_ssd'));
  void onChanged(BuildContext context, VoidCallback setState) {
    (file.existsSync() ? file.tryDel() : file.create()).whenComplete(setState);
  }

  return NormalModel(
    title: 'Dùng SSD (Server-Side Decoration)',
    leading: const Icon(Icons.web_asset),
    onTap: onChanged,
    getTrailing: (theme) => Builder(
      builder: (context) => Transform.scale(
        scale: 0.8,
        alignment: .centerRight,
        child: Switch(
          value: file.existsSync(),
          onChanged: (_) =>
              onChanged(context, (context as Element).markNeedsBuild),
        ),
      ),
    ),
  );
}

Widget _themeTrailing(ThemeData theme) {
  if (Pref.dynamicColor) {
    return Icon(Icons.color_lens_rounded, color: theme.colorScheme.primary);
  }
  final customColor = Pref.customColor;
  final color =
      colorThemeTypes.elementAtOrNull(customColor)?.color ?? Color(customColor);
  return SizedBox.square(
    dimension: 20,
    child: ColorPalette(
      colorScheme: color.asColorSchemeSeed(
        Pref.schemeVariant,
        theme.brightness,
      ),
      selected: false,
      showBgColor: false,
    ),
  );
}

void _onHorizontalScreenChanged(bool value) {
  if (value) {
    fullMode();
  } else {
    portraitUpMode();
  }
}

Future<void> _showMineTabsDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  final res = await showDialog<List<MineTabType>>(
    context: context,
    builder: (context) => OrderedMultiSelectDialog<MineTabType>(
      title: const Text('Thẻ trang của tôi'),
      initValues: Pref.mineTabs,
      values: {for (final i in MineTabType.values) i: i.label},
    ),
  );
  if (res != null) {
    await GStorage.setting.put(
      SettingBoxKey.mineTabs,
      res.map((item) => item.index).toList(),
    );
    SmartDialog.showToast('Khởi động lại để áp dụng');
    setState();
  }
}

Future<void> _showMemberTabDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  final res = await showDialog<MemberTabType>(
    context: context,
    builder: (context) => SelectDialog<MemberTabType>(
      title: 'Tab mặc định trang người dùng',
      value: Pref.memberTab,
      values: MemberTabType.values.map((e) => (e, e.title)).toList(),
    ),
  );
  if (res != null) {
    await GStorage.setting.put(SettingBoxKey.memberTab, res.index);
    setState();
  }
}
