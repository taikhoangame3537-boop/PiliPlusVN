part of 'base_quality.dart';

final class VideoQuality extends BaseQuality {
  final String shortDesc;

  const VideoQuality(super.code, super.desc, this.shortDesc);

  @override
  String toString() => '${super.toString()}, shortDesc: $shortDesc';

  static const VideoQuality hdrVivid = .new(129, 'HDR Vivid', 'HDR Vivid');
  static const VideoQuality super8k = .new(127, '8K siêu nét', '8K');
  static const VideoQuality dolbyVision = .new(126, 'Dolby Vision', 'Dolby');
  static const VideoQuality hdr = .new(125, 'HDR màu thật', 'HDR');
  static const VideoQuality super4K = .new(120, '4K siêu nét', '4K');
  static const VideoQuality high108060 = .new(116, '1080P 60 khung hình', '1080P60');
  static const VideoQuality high1080plus = .new(112, '1080P bitrate cao', '1080P+');
  static const VideoQuality superResolution = .new(100, 'Sửa chữa thông minh', 'Sửa chữa thông minh');
  static const VideoQuality high1080 = .new(80, '1080P nét cao', '1080P');
  static const VideoQuality high72060 = .new(74, '720P 60 khung hình', '720P60');
  static const VideoQuality high720 = .new(64, '720P bán nét cao', '720P');
  static const VideoQuality clear480 = .new(32, '480P nét chuẩn', '480P');
  static const VideoQuality fluent360 = .new(16, '360P mượt', '360P');
  static const VideoQuality speed240 = .new(6, '240P tốc độ', '240P');

  static const List<VideoQuality> values = [
    hdrVivid,
    super8k,
    dolbyVision,
    hdr,
    super4K,
    high108060,
    high1080plus,
    superResolution,
    high1080,
    high72060,
    high720,
    clear480,
    fluent360,
    speed240,
  ];

  static final _codeMap = {for (final i in values) i.code: i};

  VideoQuality.fromId(super.id, super.idStr) : shortDesc = idStr;

  factory VideoQuality.fromCode(int code) =>
      _codeMap[code] ?? .fromId(code, code.toString());

  static VideoQuality? safeFromCode(int code) => _codeMap[code];

  factory VideoQuality.fromFormat(int code, List<FormatItem>? formats) {
    if (formats != null && formats.isNotEmpty) {
      for (final format in formats) {
        if (format.quality == code) {
          return VideoQuality(
            code,
            format.newDesc ?? format.displayDesc ?? code.toString(),
            format.displayDesc ?? format.newDesc ?? code.toString(),
          );
        }
      }
    }

    return .fromCode(code);
  }
}
