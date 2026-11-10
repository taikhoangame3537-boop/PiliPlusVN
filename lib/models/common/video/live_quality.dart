part of 'base_quality.dart';

class LiveQuality extends BaseQuality {
  const LiveQuality(super.code, super.desc);

  static const LiveQuality dolby = .new(30000, 'Dolby');
  static const LiveQuality origin4K = .new(25000, '4K gốc');
  static const LiveQuality super4K = .new(20000, '4K');
  static const LiveQuality super2K = .new(15000, '2K');
  static const LiveQuality origin = .new(10000, 'Gốc');
  static const LiveQuality bluRay = .new(400, 'Blu-ray');
  static const LiveQuality superHD = .new(250, 'Siêu nét');
  static const LiveQuality smooth = .new(150, 'Nét cao');
  static const LiveQuality flunt = .new(80, 'Mượt');

  static const List<LiveQuality> values = [
    dolby,
    origin4K,
    super4K,
    super2K,
    origin,
    bluRay,
    superHD,
    smooth,
    flunt,
  ];

  static final _codeMap = {for (final i in values) i.code: i};

  LiveQuality.fromId(super.code) : super.fromId();

  factory LiveQuality.fromCode(int code) => _codeMap[code] ?? .fromId(code);

  LiveQuality.fromJson(Map<String, dynamic> json)
    : super(json['qn'] ?? -1, json['desc'] ?? json['qn'].toString());

  factory LiveQuality.fromFormat(int code, List<LiveQuality>? liveQn) {
    if (liveQn != null && liveQn.isNotEmpty) {
      for (final qn in liveQn) {
        if (qn.code == code) {
          return qn;
        }
      }
    }

    return .fromCode(code);
  }
}
