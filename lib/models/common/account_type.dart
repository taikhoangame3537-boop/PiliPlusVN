enum AccountType {
  main('Tài khoản chính'),
  heartbeat('Ghi lịch sử xem'),
  recommend('Đề xuất'),
  video('Lấy luồng video'),
  ;

  final String title;
  const AccountType(this.title);
}
