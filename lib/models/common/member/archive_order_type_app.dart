import 'package:PiliPlus/models/common/enum_with_label.dart';

enum ArchiveOrderTypeApp with EnumWithLabel {
  pubdate('Mới đăng'),
  click('Phát nhiều nhất'),
  ;

  @override
  final String label;
  const ArchiveOrderTypeApp(this.label);
}
