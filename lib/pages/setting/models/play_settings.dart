import 'dart:io' show Platform;

import 'package:PiliPlus/common/widgets/custom_icon.dart';
import 'package:PiliPlus/common/widgets/image_grid/image_grid_view.dart';
import 'package:PiliPlus/models/common/audio_normalization.dart';
import 'package:PiliPlus/models/common/super_chat_type.dart';
import 'package:PiliPlus/models/common/super_resolution_type.dart';
import 'package:PiliPlus/models/common/video/subtitle_pref_type.dart';
import 'package:PiliPlus/pages/setting/models/model.dart';
import 'package:PiliPlus/pages/setting/pages/fullscreen_sc.dart';
import 'package:PiliPlus/pages/setting/widgets/select_dialog.dart';
import 'package:PiliPlus/pages/setting/widgets/slider_dialog.dart';
import 'package:PiliPlus/plugin/pl_player/models/bottom_progress_behavior.dart';
import 'package:PiliPlus/plugin/pl_player/models/fullscreen_mode.dart';
import 'package:PiliPlus/plugin/pl_player/models/play_repeat.dart';
import 'package:PiliPlus/services/service_locator.dart';
import 'package:PiliPlus/utils/android/android_helper.dart';
import 'package:PiliPlus/utils/desktop/window_controller.dart';
import 'package:PiliPlus/utils/extension/num_ext.dart';
import 'package:PiliPlus/utils/ios/pip_helper.dart';
import 'package:PiliPlus/utils/platform_utils.dart';
import 'package:PiliPlus/utils/storage.dart';
import 'package:PiliPlus/utils/storage_key.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:material_ui/material_ui.dart';

List<SettingsModel> get playSettings => [
  NormalModel(
    onTap: (context, setState) => Get.toNamed('/playSpeedSet'),
    leading: const Icon(Icons.speed_outlined),
    title: 'Cài đặt tốc độ phát',
    subtitle: 'Đặt tốc độ phát video',
  ),
  if (kDebugMode || Platform.isAndroid)
    NormalModel(
      onTap: _showAngleDegreesDialog,
      leading: const Icon(MdiIcons.angleAcute),
      title: 'Ngưỡng góc nghiêng',
      getSubtitle: () => 'Hiện tại: 「${Pref.angleDegrees}°」',
    ),
  if (kDebugMode || Platform.isAndroid)
    NormalModel(
      title: 'Cân bằng âm lượng',
      leading: const Icon(Icons.multitrack_audio),
      getSubtitle: () {
        final audioNormalization = AudioNormalization.getTitleFromConfig(
          Pref.audioNormalization,
        );
        String fallback = Pref.fallbackNormalization;
        if (fallback == '0') {
          fallback = '';
        } else {
          fallback =
              ', khi không có tham số: 「${AudioNormalization.getTitleFromConfig(fallback)}」';
        }
        return 'Hiện tại: 「$audioNormalization」$fallback';
      },
      onTap: audioNormalization,
    ),
  NormalModel(
    title: 'Siêu phân giải',
    leading: const Icon(Icons.stay_current_landscape_outlined),
    getSubtitle: () =>
        'Hiện tại: 「${Pref.superResolutionType.label}」\nCài đặt mặc định có hiệu lực với anime, video khác mặc định tắt\nSiêu phân giải cần bật giải mã phần cứng, nếu bật rồi vẫn không có tác dụng, thử chuyển bộ giải mã phần cứng sang auto-copy',
    onTap: _showSuperResolutionDialog,
  ),
  const SwitchModel(
    title: 'Tự động phát',
    subtitle: 'Tự động phát khi vào trang chi tiết',
    leading: Icon(Icons.motion_photos_auto_outlined),
    setKey: SettingBoxKey.autoPlayEnable,
    defaultVal: false,
  ),
  const SwitchModel(
    title: 'Hiển thị nút khóa khi toàn màn hình',
    leading: Icon(Icons.lock_outline),
    setKey: SettingBoxKey.showFsLockBtn,
    defaultVal: true,
  ),
  const SwitchModel(
    title: 'Hiển thị nút chụp màn hình khi toàn màn hình',
    leading: Icon(Icons.photo_camera_outlined),
    setKey: SettingBoxKey.showFsScreenshotBtn,
    defaultVal: true,
  ),
  SwitchModel(
    title: 'Hiển thị pin khi toàn màn hình',
    leading: const Icon(Icons.battery_3_bar),
    setKey: SettingBoxKey.showBatteryLevel,
    defaultVal: PlatformUtils.isMobile,
  ),
  const SwitchModel(
    title: 'Chạm đúp tua lùi/tua tới',
    subtitle: 'Chạm đúp bên trái tua lùi/bên phải tua tới, tắt thì chạm đúp đều là tạm dừng/phát',
    leading: Icon(Icons.touch_app_outlined),
    setKey: SettingBoxKey.enableQuickDouble,
    defaultVal: true,
  ),
  const SwitchModel(
    title: 'Vuốt trái phải chỉnh độ sáng/âm lượng',
    leading: Icon(MdiIcons.tuneVerticalVariant),
    setKey: SettingBoxKey.enableSlideVolumeBrightness,
    defaultVal: true,
  ),
  const SwitchModel(
    title: 'Con lăn chỉnh âm lượng',
    leading: Icon(Icons.mouse_outlined),
    setKey: SettingBoxKey.enableScrollVolume,
    defaultVal: true,
  ),
  if (Platform.isAndroid)
    const SwitchModel(
      title: 'Chỉnh độ sáng hệ thống',
      leading: Icon(Icons.brightness_6_outlined),
      setKey: SettingBoxKey.setSystemBrightness,
      defaultVal: false,
    ),
  const SwitchModel(
    title: 'Vuốt giữa để vào/thoát toàn màn hình',
    leading: Icon(MdiIcons.panVertical),
    setKey: SettingBoxKey.enableSlideFS,
    defaultVal: true,
  ),
  const SwitchModel(
    title: 'Khởi tạo trình phát trước',
    subtitle: 'Giảm tương đối thời gian tải khi phát thủ công',
    leading: Icon(Icons.play_circle_outlined),
    setKey: SettingBoxKey.preInitPlayer,
    defaultVal: false,
  ),
  const SwitchModel(
    title: 'Vuốt để nhảy xem ảnh thu nhỏ video',
    leading: Icon(Icons.preview_outlined),
    setKey: SettingBoxKey.showSeekPreview,
    defaultVal: true,
  ),
  const SwitchModel(
    title: 'Hiển thị thanh tiến trình cao điểm',
    subtitle: 'Thanh tiến trình cao điểm phản ánh xu hướng thay đổi lượng danmaku gửi trong mỗi đơn vị thời gian',
    leading: Icon(Icons.show_chart),
    setKey: SettingBoxKey.showDmChart,
    defaultVal: false,
  ),
  const SwitchModel(
    title: 'Bật chụm hai ngón để thu nhỏ video',
    leading: Icon(Icons.pinch),
    setKey: SettingBoxKey.enableShrinkVideoSize,
    defaultVal: true,
  ),
  const SwitchModel(
    title: 'Bật kéo phụ đề để chỉnh lề dưới',
    leading: Icon(MdiIcons.dragVariant),
    setKey: SettingBoxKey.enableDragSubtitle,
    defaultVal: false,
  ),
  const SwitchModel(
    title: 'Trang video hiển thị video liên quan',
    leading: Icon(MdiIcons.motionPlayOutline),
    setKey: SettingBoxKey.showRelatedVideo,
    defaultVal: true,
  ),
  const SwitchModel(
    title: 'Mặc định mở rộng giới thiệu video',
    leading: Icon(Icons.expand_more),
    setKey: SettingBoxKey.alwaysExpandIntroPanel,
    defaultVal: false,
  ),
  const SwitchModel(
    title: 'Tự động mở rộng giới thiệu video khi xoay ngang',
    leading: Icon(Icons.expand_more),
    setKey: SettingBoxKey.expandIntroPanelH,
    defaultVal: false,
  ),
  SwitchModel(
    title: 'Danh sách phần/bộ sưu tập khi xoay ngang hiển thị ở thanh Tab',
    leading: const Icon(Icons.format_list_numbered_rtl_sharp),
    setKey: SettingBoxKey.horizontalSeasonPanel,
    defaultVal: Pref.horizontalScreen,
  ),
  SwitchModel(
    title: 'Trang phát ngang mở trang UP chủ ở thanh bên',
    leading: const Icon(Icons.account_circle_outlined),
    setKey: SettingBoxKey.horizontalMemberPage,
    defaultVal: Pref.horizontalScreen,
  ),
  SwitchModel(
    title: 'Xoay ngang mở xem trước ảnh ở thanh bên',
    leading: const Icon(Icons.photo_outlined),
    setKey: SettingBoxKey.horizontalPreview,
    defaultVal: false,
    onChanged: (value) => ImageGridView.horizontalPreview = value,
  ),
  const SwitchModel(
    title: 'Hiển thị cảnh báo/thông tin gây tranh cãi của video',
    leading: Icon(Icons.warning_amber_rounded),
    setKey: SettingBoxKey.showArgueMsg,
    defaultVal: true,
  ),
  const SwitchModel(
    title: 'Hiển thị thông tin phân đoạn video',
    leading: Icon(CustomIcons.view_headline_rotate_90),
    setKey: SettingBoxKey.showViewPoints,
    defaultVal: true,
  ),
  const SwitchModel(
    title: 'Hiển thị nhắc tiếp tục phát phần',
    leading: Icon(Icons.local_parking),
    setKey: SettingBoxKey.continuePlayingPart,
    defaultVal: true,
  ),
  const SwitchModel(
    title: 'Phần/bộ sưu tập: phát ngược bắt đầu từ tập đầu',
    subtitle: 'Khi bật tự động chuyển sang tập đầu theo thứ tự ngược, nếu không giữ tập hiện tại',
    leading: Icon(MdiIcons.sort),
    setKey: SettingBoxKey.reverseFromFirst,
    defaultVal: true,
  ),
  if (kDebugMode || PlatformUtils.isMobile)
    NormalModel(
      title: 'Âm lượng trình phát',
      leading: const Icon(Icons.volume_up),
      getSubtitle: () => 'Hiện tại: 「${Pref.playerVolume.toStringAsFixed(0)}%」',
      onTap: showPlayerVolumeDialog,
    )
  else
    NormalModel(
      title: 'Âm lượng tối đa',
      leading: const Icon(Icons.volume_up),
      getSubtitle: () => 'Hiện tại: 「${(Pref.maxVolume * 100).toStringAsFixed(0)}%」',
      onTap: _showMaxVolumeDialog,
    ),
  getVideoFilterSelectModel(
    title: 'Thời lượng chạm đúp tua tới/lùi',
    suffix: 's',
    key: SettingBoxKey.fastForBackwardDuration,
    values: [5, 10, 15],
    defaultValue: 10,
    isFilter: false,
  ),
  const SwitchModel(
    title: 'Vuốt tua tới/lùi dùng thời lượng tương đối',
    leading: Icon(Icons.swap_horiz_outlined),
    setKey: SettingBoxKey.useRelativeSlide,
    defaultVal: false,
  ),
  getVideoFilterSelectModel(
    title: 'Thời lượng vuốt tua tới/lùi',
    subtitle: 'Thời lượng tua tới/lùi khi vuốt từ đầu này sang đầu kia của trình phát',
    suffix: Pref.useRelativeSlide ? '%' : 's',
    key: SettingBoxKey.sliderDuration,
    values: [25, 50, 90, 100],
    defaultValue: 90,
    isFilter: false,
  ),
  NormalModel(
    title: 'Tự động bật phụ đề',
    leading: const Icon(Icons.closed_caption_outlined),
    getSubtitle: () => 'Ưu tiên đã chọn: ${Pref.subtitlePreferenceV2.desc}',
    onTap: _showSubtitleDialog,
  ),
  const SwitchModel(
    title: 'Dịch bình luận sang tiếng Việt (thử nghiệm)',
    subtitle:
        'Gửi locale vi-VN cho gRPC để nút "Dịch" của Bilibili dịch ra tiếng Việt. Cần khởi động lại ứng dụng',
    leading: Icon(Icons.translate),
    setKey: SettingBoxKey.grpcLocaleVi,
    needReboot: true,
  ),
  if (PlatformUtils.isDesktop)
    SwitchModel(
      title: 'Tạm dừng khi thu nhỏ/phát khi khôi phục',
      leading: const Icon(Icons.pause_circle_outline),
      setKey: SettingBoxKey.pauseOnMinimize,
      defaultVal: false,
      onChanged: (value) => WindowController.instance.pauseOnMinimize = value,
    ),
  const SwitchModel(
    title: 'Bật điều khiển bàn phím',
    leading: Icon(Icons.keyboard_alt_outlined),
    setKey: SettingBoxKey.keyboardControl,
    defaultVal: true,
  ),
  PopupModel(
    title: 'Kiểu hiển thị SuperChat (tin nhắn nổi bật)',
    leading: const Icon(Icons.live_tv),
    value: () => Pref.superChatType,
    items: SuperChatType.values,
    onSelected: (value, setState) => GStorage.setting
        .put(SettingBoxKey.superChatType, value.index)
        .whenComplete(setState),
  ),
  NormalModel(
    title: 'Cài đặt SuperChat toàn màn hình',
    subtitle: 'Cài đặt kích thước, độ mờ, thu phóng SuperChat (tin nhắn nổi bật) toàn màn hình',
    leading: const Icon(Icons.open_in_full),
    onTap: (_, _) => Get.to(const FullScreenSc()),
  ),
  const SwitchModel(
    title: 'Mở rộng hiển thị dọc',
    subtitle: 'Tỉ lệ video dọc màn hình nhỏ mở rộng từ 16:9 lên 1:1 (không hỗ trợ thu gọn); khi thích ứng ngang mở rộng lên 9:16',
    leading: Icon(Icons.expand_outlined),
    setKey: SettingBoxKey.enableVerticalExpand,
    defaultVal: false,
  ),
  const SwitchModel(
    title: 'Tự động toàn màn hình',
    subtitle: 'Vào toàn màn hình khi video bắt đầu phát',
    leading: Icon(Icons.fullscreen_outlined),
    setKey: SettingBoxKey.enableAutoEnter,
    defaultVal: false,
  ),
  const SwitchModel(
    title: 'Tự động thoát toàn màn hình',
    subtitle: 'Thoát toàn màn hình khi video phát xong',
    leading: Icon(Icons.fullscreen_exit_outlined),
    setKey: SettingBoxKey.enableAutoExit,
    defaultVal: true,
  ),
  const SwitchModel(
    title: 'Kéo dài thời gian hiển thị điều khiển phát',
    subtitle: 'Khi bật kéo dài đến 30 giây, tiện cho trình đọc màn hình chuyển tiêu điểm điều khiển',
    leading: Icon(Icons.timer_outlined),
    setKey: SettingBoxKey.enableLongShowControl,
    defaultVal: false,
  ),
  if (PlatformUtils.isMobile)
    const SwitchModel(
      title: 'Phát nền',
      subtitle: 'Tiếp tục phát khi vào nền',
      leading: Icon(Icons.motion_photos_pause_outlined),
      setKey: SettingBoxKey.continuePlayInBackground,
      defaultVal: false,
    ),
  if ((Platform.isAndroid && PiliAndroidHelper.isPipAvailable) ||
      (Platform.isIOS && IOSPipHelper.isAvailable))
    SwitchModel(
      title: 'Hình trong hình nền',
      subtitle: 'Phát dạng cửa sổ nhỏ (PiP) khi vào nền',
      leading: const Icon(Icons.picture_in_picture_outlined),
      setKey: SettingBoxKey.autoPiP,
      defaultVal: false,
      onChanged: Platform.isAndroid
          ? (val) {
              if (val && !videoPlayerServiceHandler!.enableBackgroundPlay) {
                SmartDialog.showToast('Nên bật dịch vụ âm thanh nền');
              }
            }
          : null,
    ),
  // PiP on iOS only shows the video frames, without danmaku.
  if (Platform.isAndroid)
    const SwitchModel(
      title: 'Hình trong hình không tải danmaku',
      subtitle: 'Khi công tắc danmaku bật, cửa sổ nhỏ chặn danmaku để có trải nghiệm tốt hơn',
      leading: Icon(CustomIcons.dm_off),
      setKey: SettingBoxKey.pipNoDanmaku,
      defaultVal: false,
    ),
  const SwitchModel(
    title: 'Đảo cử chỉ toàn màn hình',
    subtitle: 'Mặc định vuốt lên từ giữa trình phát để vào toàn màn hình, vuốt xuống để thoát\nKhi bật vuốt xuống để toàn màn hình, vuốt lên để thoát',
    leading: Icon(Icons.swap_vert),
    setKey: SettingBoxKey.fullScreenGestureReverse,
    defaultVal: false,
  ),
  const SwitchModel(
    title: 'Hiển thị các nút thích/thả xu/yêu thích khi toàn màn hình',
    leading: Icon(MdiIcons.dotsHorizontalCircleOutline),
    setKey: SettingBoxKey.showFSActionItem,
    defaultVal: true,
  ),
  const SwitchModel(
    title: 'Số người xem',
    subtitle: 'Hiển thị số người đang xem cùng lúc',
    leading: Icon(Icons.people_outlined),
    setKey: SettingBoxKey.enableOnlineTotal,
    defaultVal: false,
  ),
  NormalModel(
    title: 'Hướng toàn màn hình mặc định',
    leading: const Icon(Icons.open_with_outlined),
    getSubtitle: () => 'Hướng toàn màn hình hiện tại: ${Pref.fullScreenMode.desc}',
    onTap: _showFullScreenModeDialog,
  ),
  PopupModel(
    title: 'Hiển thị thanh tiến trình dưới',
    leading: const Icon(Icons.border_bottom_outlined),
    value: () => Pref.btmProgressBehavior,
    items: BtmProgressBehavior.values,
    onSelected: (value, setState) => GStorage.setting
        .put(SettingBoxKey.btmProgressBehavior, value.index)
        .whenComplete(setState),
  ),
  if (PlatformUtils.isMobile)
    SwitchModel(
      title: 'Dịch vụ âm thanh nền',
      subtitle: 'Tránh hình trong hình không có chức năng phát/tạm dừng',
      leading: const Icon(Icons.volume_up_outlined),
      setKey: SettingBoxKey.enableBackgroundPlay,
      defaultVal: true,
      onChanged: (value) =>
          videoPlayerServiceHandler!.enableBackgroundPlay = value,
    ),
  PopupModel(
    title: 'Thứ tự phát',
    leading: const Icon(Icons.repeat),
    value: () => Pref.playRepeat,
    items: PlayRepeat.values,
    onSelected: (value, setState) => GStorage.video
        .put(VideoBoxKey.playRepeat, value.index)
        .whenComplete(setState),
  ),
  const SwitchModel(
    title: 'Cài đặt trình phát chỉ có hiệu lực hiện tại',
    subtitle: 'Trừ danmaku, phụ đề và một số cài đặt không có trong mục cài đặt',
    leading: Icon(Icons.video_settings_outlined),
    setKey: SettingBoxKey.tempPlayerConf,
    defaultVal: false,
  ),
];

Future<void> _showSubtitleDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  final res = await showDialog<SubtitlePrefType>(
    context: context,
    builder: (context) => SelectDialog<SubtitlePrefType>(
      title: 'Ưu tiên chọn phụ đề',
      value: Pref.subtitlePreferenceV2,
      values: SubtitlePrefType.values.map((e) => (e, e.desc)).toList(),
    ),
  );
  if (res != null) {
    await GStorage.setting.put(
      SettingBoxKey.subtitlePreferenceV2,
      res.index,
    );
    setState();
  }
}

Future<void> _showFullScreenModeDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  final res = await showDialog<FullScreenMode>(
    context: context,
    builder: (context) => SelectDialog<FullScreenMode>(
      title: 'Hướng toàn màn hình mặc định',
      value: Pref.fullScreenMode,
      values: FullScreenMode.values.map((e) => (e, e.desc)).toList(),
    ),
  );
  if (res != null) {
    await GStorage.setting.put(SettingBoxKey.fullScreenMode, res.index);
    setState();
  }
}

Future<void> _showAngleDegreesDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  final res = await showDialog<double>(
    context: context,
    builder: (context) => SliderDialog(
      title: const Text('Ngưỡng góc nghiêng'),
      min: 10.0,
      max: 90.0,
      divisions: 90,
      precise: 0,
      value: Pref.angleDegrees.toDouble(),
      suffix: '°',
    ),
  );
  if (res != null) {
    await GStorage.setting.put(SettingBoxKey.angleDegrees, res.toInt());
    setState();
  }
}

Future<void> showPlayerVolumeDialog(
  BuildContext context,
  VoidCallback setState, {
  ValueChanged<double>? onChanged,
}) {
  return showVolumeDialog(
    context,
    title: const Text('Âm lượng trình phát'),
    value: Pref.playerVolume,
    onChanged: (value) => GStorage.setting
        .put(SettingBoxKey.playerVolume, value)
        .whenComplete(() {
          setState();
          onChanged?.call(value);
        }),
  );
}

Future<void> _showMaxVolumeDialog(
  BuildContext context,
  VoidCallback setState,
) {
  return showVolumeDialog(
    context,
    title: const Text('Âm lượng tối đa'),
    value: Pref.maxVolume * 100,
    onChanged: (rawValue) {
      final maxVolume = (rawValue / 100).toPrecision(2);
      if (Pref.desktopVolume > maxVolume) {
        GStorage.setting.put(SettingBoxKey.desktopVolume, maxVolume);
      }
      GStorage.setting
          .put(SettingBoxKey.maxVolume, maxVolume)
          .whenComplete(setState);
    },
  );
}

const kMinVolume = 100.0;
const kMaxVolume = 300.0;

Future<void> showVolumeDialog(
  BuildContext context, {
  required Widget title,
  required double value,
  required ValueChanged<double> onChanged,
}) async {
  final res = await showDialog<double>(
    context: context,
    builder: (context) => SliderDialog(
      title: title,
      min: kMinVolume,
      max: kMaxVolume,
      divisions: 40,
      precise: 0,
      value: value,
      suffix: '%',
    ),
  );
  if (res != null) {
    onChanged(res);
  }
}

Future<void> _showSuperResolutionDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  final res = await showDialog<SuperResolutionType>(
    context: context,
    builder: (context) => SelectDialog<SuperResolutionType>(
      title: 'Siêu phân giải',
      value: Pref.superResolutionType,
      values: SuperResolutionType.values.map((e) => (e, e.label)).toList(),
    ),
  );
  if (res != null) {
    await GStorage.setting.put(
      SettingBoxKey.superResolutionType,
      res.index,
    );
    setState();
  }
}

Future<void> audioNormalization(
  BuildContext context,
  VoidCallback setState, {
  bool fallback = false,
}) async {
  final key = fallback
      ? SettingBoxKey.fallbackNormalization
      : SettingBoxKey.audioNormalization;
  final res = await showDialog<String>(
    context: context,
    builder: (context) {
      String audioNormalization = fallback
          ? Pref.fallbackNormalization
          : Pref.audioNormalization;
      Set<String> values = {
        '0',
        '1',
        if (!fallback) '2',
        audioNormalization,
        '3',
      };
      return SelectDialog<String>(
        title: fallback ? 'Dùng khi máy chủ không có cấu hình loudnorm' : 'Cân bằng âm lượng',
        toggleable: true,
        value: audioNormalization,
        values: values
            .map(
              (e) => (
                e,
                switch (e) {
                  '0' => AudioNormalization.disable.title,
                  '1' => AudioNormalization.dynaudnorm.title,
                  '2' => AudioNormalization.loudnorm.title,
                  '3' => AudioNormalization.custom.title,
                  _ => e,
                },
              ),
            )
            .toList(),
      );
    },
  );
  if (res != null && context.mounted) {
    if (res == '3') {
      String param = '';
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Tham số tùy chỉnh'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
              const Text('等同于 --lavfi-complex="[aid1] 参数 [ao]"'),
              TextField(
                autofocus: true,
                onChanged: (value) => param = value,
              ),
            ],
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
                Get.back();
                GStorage.setting.put(key, param);
                if (!fallback &&
                    AudioNormalization.loudnormRegExp.hasMatch(param)) {
                  audioNormalization(context, setState, fallback: true);
                }
                setState();
              },
              child: const Text('Đồng ý'),
            ),
          ],
        ),
      );
    } else {
      GStorage.setting.put(key, res);
      if (res == '2') {
        audioNormalization(context, setState, fallback: true);
      }
      setState();
    }
  }
}
