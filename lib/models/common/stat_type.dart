import 'package:material_ui/material_ui.dart' show IconData, Icons;

enum StatType {
  view(Icons.remove_red_eye_outlined, 'Lượt xem'),
  danmaku(Icons.subtitles_outlined, 'Danmaku'),
  like(Icons.thumb_up_outlined, 'Thích'),
  reply(Icons.comment_outlined, 'Bình luận'),
  follow(Icons.favorite_border, 'Theo dõi'),
  play(Icons.play_circle_outlined, 'Phát'),
  listen(Icons.headset_outlined, 'Phát'),
  ;

  final IconData iconData;
  final String label;
  const StatType(this.iconData, this.label);
}
