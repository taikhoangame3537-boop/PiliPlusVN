import 'package:material_ui/material_ui.dart' show Alignment;

enum UserInfoType {
  fan('Người hâm mộ', .centerLeft),
  follow('Theo dõi', .center),
  like('Lượt thích', .centerRight),
  ;

  final String title;
  final Alignment alignment;

  const UserInfoType(this.title, this.alignment);
}
