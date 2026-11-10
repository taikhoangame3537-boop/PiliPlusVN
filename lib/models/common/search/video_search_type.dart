enum VideoPubTimeType {
  all('Không giới hạn'),
  day('Một ngày qua'),
  week('Một tuần qua'),
  halfYear('Nửa năm qua'),
  ;

  final String label;
  const VideoPubTimeType(this.label);
}

enum VideoDurationType {
  all('Mọi thời lượng'),
  tenMins('0-10 phút'),
  halfHour('10-30 phút'),
  hour('30-60 phút'),
  hourPlus('Trên 60 phút'),
  ;

  final String label;
  const VideoDurationType(this.label);
}

enum VideoZoneType {
  all('Tất cả'),
  douga('Hoạt hình', tids: 1),
  anime('Anime', tids: 13),
  guochuang('Hoạt hình Trung Quốc', tids: 167),
  music('Âm nhạc', tids: 3),
  dance('Nhảy múa', tids: 129),
  game('Game', tids: 4),
  knowledge('Kiến thức', tids: 36),
  tech('Công nghệ', tids: 188),
  sports('Thể thao', tids: 234),
  car('Ô tô', tids: 223),
  life('Đời sống', tids: 160),
  food('Ẩm thực', tids: 221),
  animal('Động vật', tids: 217),
  kichiku('Guichu', tids: 119),
  fashion('Thời trang', tids: 115),
  info('Tin tức', tids: 202),
  ent('Giải trí', tids: 5),
  cinephile('Phim ảnh', tids: 181),
  documentary('Bản ghi', tids: 177),
  movie('Phim', tids: 23),
  tv('TV', tids: 11),
  ;

  final String label;
  final int? tids;
  const VideoZoneType(this.label, {this.tids});
}

// 搜索类型为视频、专栏及相簿时
enum ArchiveFilterType {
  totalrank('Sắp xếp mặc định'),
  click('Phát nhiều'),
  pubdate('Mới đăng'),
  dm('Nhiều danmaku'),
  stow('Nhiều yêu thích'),
  scores('Nhiều bình luận'),
  ;

  // 专栏
  // attention('最多喜欢'),

  final String desc;
  const ArchiveFilterType(this.desc);
}
