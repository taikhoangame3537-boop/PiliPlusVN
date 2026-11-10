enum WebviewMenuItem {
  refresh('Làm mới'),
  copy('Sao chép liên kết'),
  openInBrowser('Mở trong trình duyệt'),
  clearCache('Xóa bộ nhớ đệm'),
  resetCookie('Đặt lại Cookie'),
  goBack('Quay lại'),
  ;

  final String title;
  const WebviewMenuItem(this.title);
}
