import 'dart:io';

import 'package:PiliPlus/models/common/video/base_quality.dart';
import 'package:PiliPlus/models/common/video/cdn_type.dart';
import 'package:PiliPlus/models/common/video/video_decode_type.dart';
import 'package:PiliPlus/pages/setting/models/model.dart';
import 'package:PiliPlus/pages/setting/widgets/ordered_multi_select_dialog.dart';
import 'package:PiliPlus/pages/setting/widgets/select_dialog.dart';
import 'package:PiliPlus/plugin/pl_player/models/audio_output_type.dart';
import 'package:PiliPlus/plugin/pl_player/models/hwdec_type.dart';
import 'package:PiliPlus/utils/filtering_text.dart';
import 'package:PiliPlus/utils/storage.dart';
import 'package:PiliPlus/utils/storage_key.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:PiliPlus/utils/video_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:material_ui/material_ui.dart';

List<SettingsModel> get videoSettings => [
  const SwitchModel(
    title: 'Bật giải mã phần cứng',
    subtitle: 'Phát video với mức tiêu thụ điện thấp hơn, nếu bị treo bất thường hãy tắt',
    leading: Icon(Icons.flash_on_outlined),
    setKey: SettingBoxKey.enableHA,
    defaultVal: true,
  ),
  const SwitchModel(
    title: '1080P không cần đăng nhập',
    subtitle: 'Xem video 1080P không cần đăng nhập',
    leading: Icon(Icons.hd_outlined),
    setKey: SettingBoxKey.p1080,
    defaultVal: true,
  ),
  NormalModel(
    title: 'Hỗ trợ lưu lượng định hướng của Bilibili',
    subtitle: 'Nếu gói cước có lưu lượng định hướng Bilibili sẽ tự động dùng. Có thể xem bản ghi dữ liệu của nhà mạng để xác nhận.',
    leading: const Icon(Icons.perm_data_setting_outlined),
    getTrailing: (theme) => IgnorePointer(
      child: Transform.scale(
        scale: 0.8,
        alignment: Alignment.centerRight,
        child: Switch(
          value: true,
          onChanged: (_) {},
          thumbIcon: WidgetStateProperty.all(
            const Icon(Icons.lock_outline_rounded),
          ),
        ),
      ),
    ),
  ),
  NormalModel(
    title: 'Cài đặt CDN',
    leading: const Icon(MdiIcons.cloudPlusOutline),
    getSubtitle: () =>
        'Đang dùng: ${VideoUtils.cdnService.desc}, một số CDN có thể không hoạt động, nếu không phát được hãy thử đổi',
    onTap: _showCDNDialog,
  ),
  NormalModel(
    title: 'Cài đặt CDN phát trực tiếp',
    leading: const Icon(MdiIcons.cloudPlusOutline),
    getSubtitle: () => 'Đang dùng: ${Pref.liveCdnUrl ?? "Mặc định"}',
    onTap: _showLiveCDNDialog,
  ),
  const SwitchModel(
    title: 'Đo tốc độ CDN',
    leading: Icon(Icons.speed),
    subtitle: 'Đo tốc độ bằng cách mô phỏng tải video, lưu ý tiêu hao dữ liệu, kết quả chỉ để tham khảo',
    setKey: SettingBoxKey.cdnSpeedTest,
    defaultVal: true,
  ),
  SwitchModel(
    title: 'Âm thanh không theo cài đặt CDN',
    subtitle: 'Dùng thẳng URL dự phòng, có thể khắc phục một số video không có tiếng',
    leading: const Icon(MdiIcons.musicNotePlus),
    setKey: SettingBoxKey.disableAudioCDN,
    defaultVal: false,
    onChanged: (value) => VideoUtils.disableAudioCDN = value,
  ),
  NormalModel(
    title: 'Chất lượng mặc định',
    leading: const Icon(Icons.video_settings_outlined),
    getSubtitle: () =>
        'Chất lượng hiện tại: ${VideoQuality.fromCode(Pref.defaultVideoQa).desc}',
    onTap: _showVideoQaDialog,
  ),
  NormalModel(
    title: 'Chất lượng mạng di động',
    leading: const Icon(Icons.video_settings_outlined),
    getSubtitle: () =>
        'Chất lượng hiện tại: ${VideoQuality.fromCode(Pref.defaultVideoQaCellular).desc}',
    onTap: _showVideoCellularQaDialog,
  ),
  NormalModel(
    title: 'Âm thanh mặc định',
    leading: const Icon(Icons.music_video_outlined),
    getSubtitle: () =>
        'Âm thanh hiện tại: ${AudioQuality.fromCode(Pref.defaultAudioQa).desc}',
    onTap: _showAudioQaDialog,
  ),
  NormalModel(
    title: 'Âm thanh mạng di động',
    leading: const Icon(Icons.music_video_outlined),
    getSubtitle: () =>
        'Âm thanh hiện tại: ${AudioQuality.fromCode(Pref.defaultAudioQaCellular).desc}',
    onTap: _showAudioCellularQaDialog,
  ),
  NormalModel(
    title: 'Chất lượng phát trực tiếp mặc định',
    leading: const Icon(Icons.video_settings_outlined),
    getSubtitle: () => 'Chất lượng hiện tại: ${LiveQuality.fromCode(Pref.liveQuality).desc}',
    onTap: _showLiveQaDialog,
  ),
  NormalModel(
    title: 'Chất lượng phát trực tiếp mạng di động',
    leading: const Icon(Icons.video_settings_outlined),
    getSubtitle: () =>
        'Chất lượng hiện tại: ${LiveQuality.fromCode(Pref.liveQualityCellular).desc}',
    onTap: _showLiveCellularQaDialog,
  ),
  NormalModel(
    title: 'Định dạng giải mã ưu tiên',
    leading: const Icon(Icons.movie_creation_outlined),
    getSubtitle: () =>
        'Định dạng giải mã ưu tiên: ${(Pref.preferCodecs.map((i) => i.name).join(","))}, vui lòng điều chỉnh theo thiết bị hỗ trợ và nhu cầu',
    onTap: _showCodecsDialog,
  ),
  NormalModel(
    title: 'Định dạng giải mã ưu tiên mạng di động',
    leading: const Icon(Icons.movie_creation_outlined),
    getSubtitle: () =>
        'Định dạng giải mã ưu tiên: ${(Pref.preferCodecsCellular.map((i) => i.name).join(","))}, vui lòng điều chỉnh theo thiết bị hỗ trợ và nhu cầu',
    onTap: _showCellularCodecsDialog,
  ),
  if (kDebugMode || Platform.isAndroid)
    NormalModel(
      title: 'Thiết bị xuất âm thanh',
      leading: const Icon(Icons.speaker_outlined),
      getSubtitle: () => 'Hiện tại: ${Pref.audioOutput}',
      onTap: _showAudioOutputDialog,
    ),
  NormalModel(
    title: 'Kích thước bộ đệm',
    leading: const Icon(Icons.storage_outlined),
    getSubtitle: () =>
        'Hiện tại: ${Pref.bufferSize}MB. Kích thước bộ đệm trước và sau của video theo yêu cầu (tùy chọn này là --demuxer-max-bytes, --demuxer-max-back-bytes của mpv). Luồng phát trực tiếp hãy đặt kích thước bộ đệm phát trực tiếp bên dưới',
    onTap: _showBufferSizeDialog,
  ),
  NormalModel(
    title: 'Thời lượng bộ đệm',
    leading: const Icon(Icons.av_timer),
    getSubtitle: () =>
        'Hiện tại: ${Pref.bufferSec}s. Bộ đệm thực tế của video theo yêu cầu là giá trị nhỏ hơn giữa kích thước và thời lượng (tùy chọn này là --cache-secs của mpv). Luồng phát trực tiếp không áp dụng, hãy đặt thời lượng bộ đệm phát trực tiếp bên dưới',
    onTap: _showBufferSecDialog,
  ),
  NormalModel(
    title: 'Kích thước bộ đệm phát trực tiếp',
    leading: const Icon(Icons.storage_outlined),
    getSubtitle: () =>
        'Hiện tại: ${Pref.liveBufferSize > 0 ? '${Pref.liveBufferSize}MB' : 'Theo kích thước bộ đệm (${(Pref.bufferSize * 2).toStringAsFixed(0)}MB)'}. Chỉ áp dụng cho luồng phát trực tiếp, khi nhỏ hơn hoặc bằng 0 dùng gấp 2 lần kích thước bộ đệm (tùy chọn này là --demuxer-max-bytes của mpv)',
    onTap: _showLiveBufferSizeDialog,
  ),
  NormalModel(
    title: 'Thời lượng bộ đệm phát trực tiếp',
    leading: const Icon(Icons.av_timer),
    getSubtitle: () =>
        'Hiện tại: ${Pref.liveBufferSec > 0 ? '${Pref.liveBufferSec}s' : 'Không giới hạn'}. Chỉ áp dụng cho luồng phát trực tiếp, khi lớn hơn 0 có thể giới hạn thời lượng bộ đệm để giảm độ trễ (tùy chọn này là --cache-secs của mpv)',
    onTap: _showLiveBufferSecDialog,
  ),
  NormalModel(
    title: 'Tự động đồng bộ',
    leading: const Icon(Icons.sync_rounded),
    getSubtitle: () => 'Hiện tại: ${Pref.autosync} (tùy chọn này là --autosync của mpv)',
    onTap: _showAutoSyncDialog,
  ),
  NormalModel(
    title: 'Đồng bộ video',
    leading: const Icon(Icons.view_timeline_outlined),
    getSubtitle: () => 'Hiện tại: ${Pref.videoSync} (tùy chọn này là --video-sync của mpv)',
    onTap: _showVideoSyncDialog,
  ),
  NormalModel(
    title: 'Chế độ giải mã phần cứng',
    leading: const Icon(Icons.memory_outlined),
    getSubtitle: () => 'Hiện tại: ${Pref.hardwareDecoding} (tùy chọn này là --hwdec của mpv)',
    onTap: _showHwDecDialog,
  ),
];

Future<void> _showCDNDialog(BuildContext context, VoidCallback setState) async {
  final res = await showDialog<CDNService>(
    context: context,
    builder: (context) => const CdnSelectDialog(),
  );
  if (res != null) {
    VideoUtils.cdnService = res;
    await GStorage.setting.put(SettingBoxKey.CDNService, res.name);
    setState();
  }
}

Future<void> _showLiveCDNDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  String host = Pref.liveCdnUrl ?? '';
  String? res = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Nhập host CDN'),
      content: TextFormField(
        initialValue: host,
        autofocus: true,
        onChanged: (value) => host = value,
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
          onPressed: () => Get.back(result: host),
          child: const Text('Đồng ý'),
        ),
      ],
    ),
  );
  if (res != null) {
    if (res.isEmpty) {
      res = null;
      await GStorage.setting.delete(SettingBoxKey.liveCdnUrl);
    } else {
      if (!res.startsWith('http')) {
        res = 'https://$res';
      }
      await GStorage.setting.put(SettingBoxKey.liveCdnUrl, res);
    }
    VideoUtils.liveCdnUrl = res;
    setState();
  }
}

Future<void> _showVideoQaDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  final res = await showDialog<int>(
    context: context,
    builder: (context) => SelectDialog<int>(
      title: 'Chất lượng mặc định',
      value: Pref.defaultVideoQa,
      values: VideoQuality.values.map((e) => (e.code, e.desc)).toList(),
    ),
  );
  if (res != null) {
    await GStorage.setting.put(SettingBoxKey.defaultVideoQa, res);
    setState();
  }
}

Future<void> _showVideoCellularQaDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  final res = await showDialog<int>(
    context: context,
    builder: (context) => SelectDialog<int>(
      title: 'Chất lượng mạng di động',
      value: Pref.defaultVideoQaCellular,
      values: VideoQuality.values.map((e) => (e.code, e.desc)).toList(),
    ),
  );
  if (res != null) {
    await GStorage.setting.put(
      SettingBoxKey.defaultVideoQaCellular,
      res,
    );
    setState();
  }
}

Future<void> _showAudioQaDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  final res = await showDialog<int>(
    context: context,
    builder: (context) => SelectDialog<int>(
      title: 'Âm thanh mặc định',
      value: Pref.defaultAudioQa,
      values: AudioQuality.values.map((e) => (e.code, e.desc)).toList(),
    ),
  );
  if (res != null) {
    await GStorage.setting.put(SettingBoxKey.defaultAudioQa, res);
    setState();
  }
}

Future<void> _showAudioCellularQaDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  final res = await showDialog<int>(
    context: context,
    builder: (context) => SelectDialog<int>(
      title: 'Âm thanh mạng di động',
      value: Pref.defaultAudioQaCellular,
      values: AudioQuality.values.map((e) => (e.code, e.desc)).toList(),
    ),
  );
  if (res != null) {
    await GStorage.setting.put(
      SettingBoxKey.defaultAudioQaCellular,
      res,
    );
    setState();
  }
}

Future<void> _showLiveQaDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  final res = await showDialog<int>(
    context: context,
    builder: (context) => SelectDialog<int>(
      title: 'Chất lượng phát trực tiếp mặc định',
      value: Pref.liveQuality,
      values: LiveQuality.values.map((e) => (e.code, e.desc)).toList(),
    ),
  );
  if (res != null) {
    await GStorage.setting.put(SettingBoxKey.liveQuality, res);
    setState();
  }
}

Future<void> _showLiveCellularQaDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  final res = await showDialog<int>(
    context: context,
    builder: (context) => SelectDialog<int>(
      title: 'Chất lượng phát trực tiếp mạng di động',
      value: Pref.liveQualityCellular,
      values: LiveQuality.values.map((e) => (e.code, e.desc)).toList(),
    ),
  );
  if (res != null) {
    await GStorage.setting.put(SettingBoxKey.liveQualityCellular, res);
    setState();
  }
}

Future<void> _showCodecsDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  final res = await showDialog<List<VideoDecodeFormatType>>(
    context: context,
    builder: (context) => OrderedMultiSelectDialog<VideoDecodeFormatType>(
      title: const Text('Định dạng giải mã ưu tiên'),
      initValues: Pref.preferCodecs,
      values: {for (final e in VideoDecodeFormatType.values) e: e.name},
    ),
  );
  if (res != null && res.isNotEmpty) {
    await GStorage.setting.put(
      SettingBoxKey.preferCodecs,
      res.map((i) => i.name).toList(),
    );
    setState();
  }
}

Future<void> _showCellularCodecsDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  final res = await showDialog<List<VideoDecodeFormatType>>(
    context: context,
    builder: (context) => OrderedMultiSelectDialog<VideoDecodeFormatType>(
      title: const Text('Định dạng giải mã ưu tiên mạng di động'),
      initValues: Pref.preferCodecsCellular,
      values: {for (final e in VideoDecodeFormatType.values) e: e.name},
    ),
  );
  if (res != null && res.isNotEmpty) {
    await GStorage.setting.put(
      SettingBoxKey.preferCodecsCellular,
      res.map((i) => i.name).toList(),
    );
    setState();
  }
}

Future<void> _showAudioOutputDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  final res = await showDialog<List<String>>(
    context: context,
    builder: (context) => OrderedMultiSelectDialog<String>(
      title: const Text('Thiết bị xuất âm thanh'),
      initValues: Pref.audioOutput.split(','),
      values: {
        for (final e in AudioOutput.values) e.name: e.label,
      },
    ),
  );
  if (res != null && res.isNotEmpty) {
    await GStorage.setting.put(
      SettingBoxKey.audioOutput,
      res.join(','),
    );
    setState();
  }
}

Future<void> _showVideoSyncDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  final res = await showDialog<String>(
    context: context,
    builder: (context) => SelectDialog<String>(
      title: 'Đồng bộ video',
      value: Pref.videoSync,
      values: const [
        'audio',
        'display-resample',
        'display-resample-vdrop',
        'display-resample-desync',
        'display-tempo',
        'display-vdrop',
        'display-adrop',
        'display-desync',
        'desync',
      ].map((e) => (e, e)).toList(),
    ),
  );
  if (res != null) {
    await GStorage.setting.put(SettingBoxKey.videoSync, res);
    setState();
  }
}

Future<void> _showHwDecDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  final res = await showDialog<List<String>>(
    context: context,
    builder: (context) => OrderedMultiSelectDialog<String>(
      title: const Text('Chế độ giải mã phần cứng'),
      initValues: Pref.hardwareDecoding.split(','),
      values: {
        for (final e in HwDecType.values) e.hwdec: '${e.hwdec}\n${e.desc}',
      },
    ),
  );
  if (res != null && res.isNotEmpty) {
    await GStorage.setting.put(
      SettingBoxKey.hardwareDecoding,
      res.join(','),
    );
    setState();
  }
}

void _showAutoSyncDialog(BuildContext context, VoidCallback setState) {
  String autosync = Pref.autosync.toString();
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Tự động đồng bộ'),
      content: TextFormField(
        autofocus: true,
        initialValue: autosync,
        keyboardType: TextInputType.number,
        onChanged: (value) => autosync = value,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
              // validate
              int.parse(autosync);
              Get.back();
              await GStorage.setting.put(SettingBoxKey.autosync, autosync);
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

void _showDecimalDialog(
  BuildContext context,
  VoidCallback setState, {
  required String key,
  required double defVal,
  required String title,
  required String? suffix,
}) {
  String value = (GStorage.setting.get(key) ?? defVal).toString();
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextFormField(
        autofocus: true,
        initialValue: value,
        keyboardType: const .numberWithOptions(decimal: true),
        onChanged: (val) => value = val,
        inputFormatters: FilteringText.decimal,
        decoration: suffix == null ? null : InputDecoration(suffixText: suffix),
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
              final val = double.parse(value);
              Get.back();
              await GStorage.setting.put(key, val);
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

void _showBufferSizeDialog(BuildContext context, VoidCallback setState) =>
    _showDecimalDialog(
      context,
      setState,
      key: SettingBoxKey.bufferSize,
      defVal: Pref.bufferSize,
      title: 'Kích thước bộ đệm',
      suffix: 'MB',
    );

void _showBufferSecDialog(BuildContext context, VoidCallback setState) =>
    _showDecimalDialog(
      context,
      setState,
      key: SettingBoxKey.bufferSec,
      defVal: Pref.bufferSec,
      title: 'Thời lượng bộ đệm',
      suffix: 's',
    );

void _showLiveBufferSizeDialog(BuildContext context, VoidCallback setState) =>
    _showDecimalDialog(
      context,
      setState,
      key: SettingBoxKey.liveBufferSize,
      defVal: Pref.liveBufferSize,
      title: 'Kích thước bộ đệm phát trực tiếp',
      suffix: 'MB',
    );

void _showLiveBufferSecDialog(BuildContext context, VoidCallback setState) =>
    _showDecimalDialog(
      context,
      setState,
      key: SettingBoxKey.liveBufferSec,
      defVal: Pref.liveBufferSec,
      title: 'Thời lượng bộ đệm phát trực tiếp',
      suffix: 's',
    );
