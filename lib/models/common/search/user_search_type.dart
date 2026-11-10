enum UserOrderType {
  def('Sắp xếp mặc định', 0, ''),
  fansDesc('Số người hâm mộ cao đến thấp', 0, 'fans'),
  fansAsc('Số người hâm mộ thấp đến cao', 1, 'fans'),
  levelDesc('Cấp Lv cao đến thấp', 0, 'level'),
  levelAsc('Cấp Lv thấp đến cao', 1, 'level'),
  ;

  final String label;
  final int orderSort;
  final String order;
  const UserOrderType(this.label, this.orderSort, this.order);
}

enum UserType {
  all('Tất cả người dùng'),
  up('UP chủ'),
  common('Người dùng thường'),
  verified('Người dùng xác thực'),
  ;

  final String label;
  const UserType(this.label);
}
