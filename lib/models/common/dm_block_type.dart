enum DmBlockType {
  keyword('Từ khóa'),
  regex('Regex'),
  uid('Người dùng'),
  ;

  final String label;
  const DmBlockType(this.label);
}
