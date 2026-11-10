import 'package:PiliPlus/models/common/enum_with_label.dart';

enum BarHideType with EnumWithLabel {
  instant('Tức thời'),
  sync('Đồng bộ'),
  ;

  @override
  final String label;
  const BarHideType(this.label);
}
