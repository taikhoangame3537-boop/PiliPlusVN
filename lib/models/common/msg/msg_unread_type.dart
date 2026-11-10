enum MsgUnReadType {
  pm('Tin nhắn riêng'),
  reply('Trả lời tôi'),
  at('@tôi'),
  like('Lượt thích nhận được'),
  sysMsg('Thông báo hệ thống'),
  ;

  final String title;
  const MsgUnReadType(this.title);
}
