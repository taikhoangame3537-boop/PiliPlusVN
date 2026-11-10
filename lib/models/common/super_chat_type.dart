import 'package:PiliPlus/models/common/enum_with_label.dart';

enum SuperChatType implements EnumWithLabel {
  valid('Hiển thị trong thời gian hiệu lực'),
  persist('Hiển thị thường trực'),
  disable('Không hiển thị'),
  ;

  @override
  final String label;
  const SuperChatType(this.label);
}
