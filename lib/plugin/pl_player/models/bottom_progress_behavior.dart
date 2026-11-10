import 'package:PiliPlus/models/common/enum_with_label.dart';

enum BtmProgressBehavior implements EnumWithLabel {
  alwaysShow('Luôn hiển thị'),
  alwaysHide('Luôn ẩn'),
  onlyShowFullScreen('Chỉ hiển thị khi toàn màn hình'),
  onlyHideFullScreen('Chỉ ẩn khi toàn màn hình'),
  ;

  @override
  final String label;
  const BtmProgressBehavior(this.label);
}
