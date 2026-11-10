import 'package:PiliPlus/pages/setting/models/dm_settings.dart';
import 'package:PiliPlus/pages/setting/models/dyn_settings.dart';
import 'package:PiliPlus/pages/setting/models/extra_settings.dart';
import 'package:PiliPlus/pages/setting/models/model.dart';
import 'package:PiliPlus/pages/setting/models/play_settings.dart';
import 'package:PiliPlus/pages/setting/models/privacy_settings.dart';
import 'package:PiliPlus/pages/setting/models/recommend_settings.dart';
import 'package:PiliPlus/pages/setting/models/reply_settings.dart';
import 'package:PiliPlus/pages/setting/models/style_settings.dart';
import 'package:PiliPlus/pages/setting/models/video_settings.dart';

enum SettingType {
  privacySetting('Cài đặt quyền riêng tư'),
  recommendSetting('Cài đặt luồng đề xuất'),
  videoSetting('Cài đặt âm thanh/video'),
  playSetting('Cài đặt trình phát'),
  dmSetting('Cài đặt danmaku'),
  replySetting('Cài đặt bình luận'),
  dynSetting('Cài đặt dòng thời gian'),
  styleSetting('Cài đặt giao diện'),
  extraSetting('Cài đặt khác'),
  webdavSetting('Cài đặt WebDAV'),
  about('Giới thiệu'),
  ;

  final String title;
  const SettingType(this.title);

  List<SettingsModel> get settings => switch (this) {
    .privacySetting => privacySettings,
    .recommendSetting => recommendSettings,
    .videoSetting => videoSettings,
    .playSetting => playSettings,
    .dmSetting => dmSettings,
    .dynSetting => dynSettings,
    .replySetting => replySettings,
    .styleSetting => styleSettings,
    .extraSetting => extraSettings,
    .webdavSetting || .about => throw UnimplementedError(),
  };
}
