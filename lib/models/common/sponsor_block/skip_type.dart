import 'package:PiliPlus/models/common/enum_with_label.dart';

enum SkipType implements EnumWithLabel {
  alwaysSkip('Luôn bỏ qua'),
  skipOnce('Bỏ qua một lần'),
  skipManually('Bỏ qua thủ công'),
  showOnly('Chỉ hiển thị'),
  disable('Vô hiệu hóa'),
  ;

  @override
  final String label;
  const SkipType(this.label);
}
