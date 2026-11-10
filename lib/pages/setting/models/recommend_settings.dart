import 'package:PiliPlus/http/video.dart';
import 'package:PiliPlus/models/common/rcmd_source.dart';
import 'package:PiliPlus/pages/rcmd/controller.dart';
import 'package:PiliPlus/pages/setting/models/model.dart';
import 'package:PiliPlus/pages/setting/widgets/select_dialog.dart';
import 'package:PiliPlus/utils/recommend_filter.dart';
import 'package:PiliPlus/utils/storage.dart';
import 'package:PiliPlus/utils/storage_key.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart' hide StatefulBuilder;

List<SettingsModel> get recommendSettings => [
  NormalModel(
    title: 'Nguồn đề xuất trang chủ',
    getSubtitle: () => Pref.rcmdSource.label,
    leading: const Icon(Icons.swap_horiz_outlined),
    onTap: _showRcmdSourceDialog,
  ),
  SwitchModel(
    title: 'Giữ làm mới đề xuất trang chủ',
    subtitle: 'Giữ nội dung lần trước khi kéo làm mới',
    leading: const Icon(Icons.refresh),
    setKey: SettingBoxKey.enableSaveLastData,
    defaultVal: true,
    onChanged: (value) {
      try {
        Get.find<RcmdController>()
          ..enableSaveLastData = value
          ..lastRefreshAt = null;
      } catch (e) {
        if (kDebugMode) debugPrint('$e');
      }
    },
  ),
  SwitchModel(
    title: 'Hiển thị gợi ý vị trí đã xem lần trước',
    subtitle: 'Khi giữ đề xuất lần trước, hiển thị gợi ý ở vị trí làm mới lần trước',
    leading: const Icon(Icons.tips_and_updates_outlined),
    setKey: SettingBoxKey.savedRcmdTip,
    defaultVal: true,
    onChanged: (value) {
      try {
        Get.find<RcmdController>()
          ..savedRcmdTip = value
          ..lastRefreshAt = null;
      } catch (e) {
        if (kDebugMode) debugPrint('$e');
      }
    },
  ),
  getVideoFilterSelectModel(
    title: 'Tỉ lệ thích',
    suffix: '%',
    key: SettingBoxKey.minLikeRatioForRecommend,
    values: [0, 1, 2, 3, 4],
    onChanged: (value) => RecommendFilter.minLikeRatioForRecommend = value,
    filterScope: 'Đề xuất Web, thịnh hành, phân khu',
  ),
  getBanWordModel(
    title: 'Lọc từ khóa tiêu đề',
    key: SettingBoxKey.banWordForRecommend,
    onChanged: (value) {
      RecommendFilter.rcmdRegExp = value;
      RecommendFilter.enableFilter = value.pattern.isNotEmpty;
    },
    banScope: 'Đề xuất, thịnh hành, phân khu, video liên quan',
  ),
  getBanWordModel(
    title: 'Lọc từ khóa phân khu',
    key: SettingBoxKey.banWordForZone,
    onChanged: (value) {
      VideoHttp.zoneRegExp = value;
      VideoHttp.enableFilter = value.pattern.isNotEmpty;
    },
    banScope: 'Đề xuất App, thịnh hành, phân khu',
  ),
  getVideoFilterSelectModel(
    title: 'Thời lượng video',
    suffix: 's',
    key: SettingBoxKey.minDurationForRcmd,
    values: [0, 30, 60, 90, 120],
    onChanged: (value) => RecommendFilter.minDurationForRcmd = value,
    filterScope: 'Đề xuất, video liên quan',
  ),
  getVideoFilterSelectModel(
    title: 'Lượt phát',
    key: SettingBoxKey.minPlayForRcmd,
    values: [0, 50, 100, 500, 1000],
    onChanged: (value) => RecommendFilter.minPlayForRcmd = value,
    filterScope: 'Đề xuất, thịnh hành, phân khu, video liên quan',
  ),
  SwitchModel(
    title: 'UP đã theo dõi được miễn lọc đề xuất',
    subtitle: 'Nội dung do người dùng đã theo dõi đăng trong đề xuất sẽ không bị lọc',
    leading: const Icon(Icons.favorite_border_outlined),
    setKey: SettingBoxKey.exemptFilterForFollowed,
    defaultVal: true,
    onChanged: (value) => RecommendFilter.exemptFilterForFollowed = value,
  ),
  SwitchModel(
    title: 'Bộ lọc cũng áp dụng cho video liên quan ở trang chi tiết',
    subtitle: 'Các mục khác (như video thịnh hành, tìm kiếm...) không bị bộ lọc ảnh hưởng, không thể miễn UP đã theo dõi trong video liên quan',
    leading: const Icon(Icons.explore_outlined),
    setKey: SettingBoxKey.applyFilterToRelatedVideos,
    defaultVal: true,
    onChanged: (value) => RecommendFilter.applyFilterToRelatedVideos = value,
  ),
];

Future<void> _showRcmdSourceDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  final res = await showDialog<RcmdSource>(
    context: context,
    builder: (context) => SelectDialog<RcmdSource>(
      title: 'Nguồn đề xuất trang chủ',
      value: Pref.rcmdSource,
      values: RcmdSource.values.map((e) => (e, e.label)).toList(),
      subtitleBuilder: (context, index, type) {
        if (type == .desktop) {
          return const Text(
            'Dùng giao diện đề xuất web công khai, theo ứng dụng Windows chính thức của Bilibili'
            'Gửi yêu cầu với tổ hợp tham số thực tế ở trang chủ, không liên quan giao diện riêng tư và dấu vân tay thiết bị',
          );
        }
        return null;
      },
    ),
  );
  if (res != null) {
    _switchRcmdSource(res, setState);
  }
}

void _switchRcmdSource(RcmdSource value, VoidCallback setState) {
  // 同步旧键（旧版本只有 app / web 二选一），保证降级后语义一致
  GStorage.setting
      .put(SettingBoxKey.appRcmd, value == RcmdSource.app)
      .whenComplete(setState);
  GStorage.setting.put(SettingBoxKey.rcmdSource, value.index);
  try {
    Get.find<RcmdController>()
      ..rcmdSource = value
      ..lastRefreshAt = null
      // 用 onReload 而不是 onRefresh：切换来源后不应把旧来源的列表
      // 拼到新来源的数据前面（"保留上次内容"只在同一来源内生效）
      ..onReload();
  } catch (e) {
    if (kDebugMode) debugPrint('$e');
  }
  SmartDialog.showToast('Đã chuyển sang ${value.label}');
}
