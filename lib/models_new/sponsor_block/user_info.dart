import 'package:PiliPlus/utils/duration_utils.dart';
import 'package:PiliPlus/utils/num_utils.dart';

class UserInfo {
  final int viewCount;
  final double minutesSaved;
  final int segmentCount;

  const UserInfo({
    required this.viewCount,
    required this.minutesSaved,
    required this.segmentCount,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) => UserInfo(
    viewCount: json['viewCount'],
    minutesSaved: (json['minutesSaved'] as num).toDouble(),
    segmentCount: json['segmentCount'],
  );

  @override
  String toString() {
    String minutes = DurationUtils.formatTimeDuration(
      Duration(minutes: minutesSaved.round()),
    );
    if (minutes.isEmpty) {
      minutes = '0 phút';
    }
    return ('Bạn đã gửi ${NumUtils.formatPositiveDecimal(segmentCount)} đoạn\n'
        'Bạn đã giúp mọi người tiết kiệm ${NumUtils.formatPositiveDecimal(viewCount)} đoạn\n'
        '($minutes của cuộc đời)');
  }
}
