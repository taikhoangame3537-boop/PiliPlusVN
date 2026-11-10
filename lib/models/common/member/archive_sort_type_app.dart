import 'package:PiliPlus/models/common/enum_with_label.dart';

enum ArchiveSortTypeApp with EnumWithLabel {
  desc('Mặc định'),
  asc('Đảo ngược'),
  ;

  @override
  final String label;
  const ArchiveSortTypeApp(this.label);
}
