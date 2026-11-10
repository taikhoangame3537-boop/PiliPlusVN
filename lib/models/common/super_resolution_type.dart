import 'package:PiliPlus/models/common/enum_with_label.dart';

enum SuperResolutionType with EnumWithLabel {
  disable('Vô hiệu hóa'),
  efficiency('Hiệu suất'),
  quality('Chất lượng'),
  ;

  @override
  final String label;
  const SuperResolutionType(this.label);
}
