import 'package:PiliPlus/pages/fav/article/view.dart';
import 'package:PiliPlus/pages/fav/cheese/view.dart';
import 'package:PiliPlus/pages/fav/note/view.dart';
import 'package:PiliPlus/pages/fav/pgc/view.dart';
import 'package:PiliPlus/pages/fav/topic/view.dart';
import 'package:PiliPlus/pages/fav/video/view.dart';
import 'package:material_ui/material_ui.dart';

enum FavTabType {
  video('Video', FavVideoPage()),
  bangumi('Theo dõi anime', FavPgcPage(type: 1)),
  cinema('Theo dõi phim', FavPgcPage(type: 2)),
  article('Chuyên mục', FavArticlePage()),
  note('Ghi chú', FavNotePage()),
  topic('Chủ đề', FavTopicPage()),
  cheese('Lớp học', FavCheesePage()),
  ;

  final String title;
  final Widget page;
  const FavTabType(this.title, this.page);
}
