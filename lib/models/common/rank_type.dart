enum RankType {
  all('Toàn trang', rid: 0),
  anime('Anime', seasonType: 1),
  guochuang('Hoạt hình Trung Quốc', seasonType: 4),
  douga('Hoạt hình', rid: 1005),
  music('Âm nhạc', rid: 1003),
  dance('Nhảy múa', rid: 1004),
  game('Game', rid: 1008),
  knowledge('Kiến thức', rid: 1010),
  tech('Công nghệ', rid: 1012),
  sports('Thể thao', rid: 1018),
  car('Ô tô', rid: 1013),
  food('Ẩm thực', rid: 1020),
  animal('Động vật', rid: 1024),
  kichiku('Guichu', rid: 1007),
  fashion('Thời trang', rid: 1014),
  ent('Giải trí', rid: 1002),
  cinephile('Phim ảnh', rid: 1001),
  documentary('Bản ghi', seasonType: 3),
  movie('Phim', seasonType: 2),
  tv('Các tập', seasonType: 5),
  variety('Tạp kỹ', seasonType: 7),
  ;

  final String label;
  final int? rid;
  final int? seasonType;
  const RankType(this.label, {this.rid, this.seasonType});
}
