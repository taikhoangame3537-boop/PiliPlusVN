import 'package:PiliPlus/utils/storage_pref.dart';

enum MemberTabType {
  def('Mặc định'),
  home('Trang chủ'),
  dynamic('Dòng thời gian'),
  contribute('Đăng bài'),
  favorite('Yêu thích'),
  bangumi('Anime'),
  cheese('Lớp học'),
  shop('Cửa hàng nhỏ'),
  ;

  static bool showMemberShop = Pref.showMemberShop;

  static bool contains(String type) {
    if (type == shop.name && !showMemberShop) {
      return false;
    }
    for (final e in MemberTabType.values) {
      if (e.name == type) {
        return true;
      }
    }
    return false;
  }

  final String title;
  const MemberTabType(this.title);
}
