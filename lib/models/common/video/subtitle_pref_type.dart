enum SubtitlePrefType {
  off('Mặc định không hiển thị phụ đề'),
  on('Ưu tiên phụ đề không tự động tạo (ai)'),
  withoutAi('Bỏ qua phụ đề tự động tạo (ai), chọn phụ đề khả dụng đầu tiên'),
  auto('Khi tắt tiếng giống mục 2, khi có tiếng giống mục 3'),
  ;

  final String desc;
  const SubtitlePrefType(this.desc);
}
