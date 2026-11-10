import 'package:PiliPlus/models/common/enum_with_label.dart';

enum DynamicsTabType implements EnumWithLabel {
  all('Tất cả'),
  video('Đăng bài'),
  pgc('Anime'),
  article('Chuyên mục'),
  up('UP'),
  ;

  @override
  final String label;
  const DynamicsTabType(this.label);
}
