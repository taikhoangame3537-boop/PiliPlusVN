import 'package:PiliPlus/models/common/enum_with_label.dart';

enum ReplySortType implements EnumWithLabel {
  time('Bình luận mới nhất', 'Mới nhất', label: 'Theo thời gian'),
  hot('Bình luận hot nhất', 'Hot nhất', label: 'Theo độ hot'),
  select('Bình luận chọn lọc', 'Chọn lọc'),
  ;

  @override
  final String label;
  final String desc;
  final String descShort;
  const ReplySortType(this.desc, this.descShort, {this.label = ''});
}
