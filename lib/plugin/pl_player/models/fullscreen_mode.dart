const double kScreenRatio = 1.2;

// 全屏模式
enum FullScreenMode {
  // 根据内容自适应
  auto('Theo hướng video (mặc định)'),
  // 不改变当前方向
  none('Không đổi hướng hiện tại'),
  // 始终竖屏
  vertical('Bắt buộc dọc'),
  // 始终横屏
  horizontal('Bắt buộc ngang'),
  // 屏幕长宽比 < kScreenRatio 或为竖屏视频时竖屏，否则横屏
  ratio('Dọc khi tỉ lệ màn hình <$kScreenRatio hoặc video dọc, ngược lại ngang'),
  // 强制重力转屏（仅安卓）
  gravity('Bỏ qua khóa hướng hệ thống, bắt buộc xoay theo trọng lực (chỉ Android)'),
  ;

  final String desc;
  const FullScreenMode(this.desc);
}
