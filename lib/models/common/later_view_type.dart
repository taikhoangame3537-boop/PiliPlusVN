import 'package:PiliPlus/pages/later/child_view.dart';
import 'package:material_ui/material_ui.dart';

enum LaterViewType {
  all(0, 'Tất cả'),
  // toView(1, '未看'),
  unfinished(2, 'Chưa xem xong'),
  // viewed(3, '已看完'),
  ;

  Widget get page => LaterViewChildPage(laterViewType: this);

  final int type;
  final String title;
  const LaterViewType(this.type, this.title);
}
