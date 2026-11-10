import 'package:PiliPlus/models/common/enum_with_label.dart';

enum MineTabType implements EnumWithLabel {
  favorite('Yêu thích của tôi'),
  history('Lịch sử xem'),
  later('Xem sau'),
  sub('Đăng ký của tôi');

  static const Set<MineTabType> kDefault = {.favorite};

  @override
  final String label;

  const MineTabType(this.label);
}
