import 'package:PiliPlus/models/common/enum_with_label.dart';

enum DynamicBadgeMode implements EnumWithLabel {
  hidden('Ẩn'),
  point('Chấm đỏ'),
  number('Số'),
  ;

  @override
  final String label;
  const DynamicBadgeMode(this.label);
}
