import 'package:PiliPlus/models/common/enum_with_label.dart';

enum PlayRepeat implements EnumWithLabel {
  pause('Tạm dừng khi phát xong'),
  listOrder('Phát tuần tự'),
  singleCycle('Lặp một video'),
  listCycle('Lặp danh sách'),
  autoPlayRelated('Tự động phát tiếp'),
  ;

  @override
  final String label;
  const PlayRepeat(this.label);
}
