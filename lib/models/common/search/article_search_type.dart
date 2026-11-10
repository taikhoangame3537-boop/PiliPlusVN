enum ArticleOrderType {
  totalrank('Sắp xếp tổng hợp'),
  pubdate('Mới đăng'),
  click('Nhiều lượt bấm nhất'),
  attention('Được thích nhiều nhất'),
  scores('Nhiều bình luận nhất'),
  ;

  String get order => name;
  final String label;
  const ArticleOrderType(this.label);
}

enum ArticleZoneType {
  all('Tất cả phân khu', 0),
  douga('Hoạt hình', 2),
  game('Game', 1),
  cinephile('Phim ảnh', 28),
  life('Đời sống', 3),
  interest('Sở thích', 29),
  novel('Light novel', 16),
  tech('Công nghệ', 17),
  note('Ghi chú', 41),
  ;

  final String label;
  final int categoryId;
  const ArticleZoneType(this.label, this.categoryId);
}
