enum FavOrderType {
  mtime('Yêu thích gần đây'),
  view('Phát nhiều nhất'),
  pubtime('Đăng gần đây'),
  ;

  final String label;

  const FavOrderType(this.label);
}
