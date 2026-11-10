import 'package:PiliPlus/http/api.dart';

enum PgcReviewType {
  long(label: 'Bình luận dài', api: Api.pgcReviewL),
  short(label: 'Bình luận ngắn', api: Api.pgcReviewS),
  ;

  final String label;
  final String api;
  const PgcReviewType({
    required this.label,
    required this.api,
  });
}

enum PgcReviewSortType {
  def('Mặc định', 0),
  latest('Mới nhất', 1),
  ;

  final int sort;
  final String label;
  const PgcReviewSortType(this.label, this.sort);
}
