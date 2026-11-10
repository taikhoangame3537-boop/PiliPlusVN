import 'package:PiliPlus/utils/bili_colors.dart';
import 'package:material_ui/material_ui.dart';

enum BadgeType {
  none(),
  vip('VIP'),
  person('Cá nhân xác thực', BiliColors.yellow),
  institution('Tổ chức xác thực', Colors.lightBlueAccent),
  ;

  final String? desc;
  final Color? color;
  const BadgeType([this.desc, this.color]);
}
