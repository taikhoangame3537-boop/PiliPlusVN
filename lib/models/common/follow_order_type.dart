enum FollowOrderType {
  def('', 'Theo dõi gần đây'),
  attention('attention', 'Truy cập nhiều nhất'),
  ;

  final String type;
  final String title;

  const FollowOrderType(this.type, this.title);
}
