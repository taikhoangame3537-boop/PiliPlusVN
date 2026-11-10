import 'package:PiliPlus/models/common/enum_with_label.dart';

enum ArchiveOrderTypeWeb with EnumWithLabel {
  pubdate('Mới đăng'),
  click('Phát nhiều nhất'),
  stow('Yêu thích nhiều nhất'),
  ;

  @override
  final String label;
  const ArchiveOrderTypeWeb(this.label);
}
