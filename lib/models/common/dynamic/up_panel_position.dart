import 'package:PiliPlus/models/common/enum_with_label.dart';

enum UpPanelPosition implements EnumWithLabel {
  top('Trên cùng'),
  leftFixed('Thường trực bên trái'),
  rightFixed('Thường trực bên phải'),
  leftDrawer('Ngăn kéo bên trái'),
  rightDrawer('Ngăn kéo bên phải'),
  ;

  @override
  final String label;
  const UpPanelPosition(this.label);
}
