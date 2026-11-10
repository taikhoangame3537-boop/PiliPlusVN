enum ActionType {
  skip('Bỏ qua'),
  mute('Tắt tiếng'),
  full('Toàn bộ video'),
  poi('Khoảnh khắc đặc sắc'),
  ;

  final String title;
  const ActionType(this.title);
}
