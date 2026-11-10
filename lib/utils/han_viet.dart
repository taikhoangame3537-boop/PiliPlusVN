/// Đổi tên người tiếng Trung sang âm Hán Việt (大雄 -> Đại Hùng).
/// Bảng chữ viết tay, tập trung họ và chữ hay dùng làm tên; chữ nào chưa có
/// trong bảng thì `convert` trả về null (giữ nguyên cách dịch của máy).
/// Thiếu hay sai chữ nào thì sửa/thêm trực tiếp vào [_data] (định dạng 字:Âm).
abstract final class HanViet {
  // họ ghép đọc khác âm từng chữ
  static const Map<String, String> _special = {'诸葛': 'Gia Cát'};

  static Map<String, String>? _cache;

  static Map<String, String> get _table => _cache ??= _build();

  static Map<String, String> _build() {
    final m = <String, String>{};
    for (final e in _data.split(RegExp(r'\s+'))) {
      final i = e.indexOf(':');
      if (i <= 0) continue;
      m[e.substring(0, i)] = e.substring(i + 1);
    }
    return m;
  }

  /// "林凡" -> "Lâm Phàm"; null nếu có chữ chưa có trong bảng.
  static String? convert(String name) {
    final out = <String>[];
    var rest = name;
    for (final e in _special.entries) {
      if (rest.startsWith(e.key)) {
        out.add(e.value);
        rest = rest.substring(e.key.length);
      }
    }
    for (final r in rest.runes) {
      final v = _table[String.fromCharCode(r)];
      if (v == null) return null;
      out.add(v);
    }
    return out.isEmpty ? null : out.join(' ');
  }

  static const String _data = '''
李:Lý 王:Vương 张:Trương 刘:Lưu 陈:Trần 杨:Dương 赵:Triệu 黄:Hoàng 周:Chu 吴:Ngô
徐:Từ 孙:Tôn 胡:Hồ 朱:Chu 高:Cao 林:Lâm 何:Hà 郭:Quách 马:Mã 罗:La
梁:Lương 宋:Tống 郑:Trịnh 谢:Tạ 韩:Hàn 唐:Đường 冯:Phùng 于:Vu 董:Đổng 萧:Tiêu
程:Trình 曹:Tào 袁:Viên 邓:Đặng 许:Hứa 傅:Phó 沈:Thẩm 曾:Tằng 彭:Bành 吕:Lữ
苏:Tô 卢:Lư 蒋:Tưởng 蔡:Thái 贾:Giả 丁:Đinh 魏:Ngụy 薛:Tiết 叶:Diệp 阎:Diêm
余:Dư 潘:Phan 杜:Đỗ 戴:Đới 夏:Hạ 钟:Chung 汪:Uông 田:Điền 任:Nhậm 姜:Khương
范:Phạm 方:Phương 石:Thạch 姚:Diêu 谭:Đàm 廖:Liêu 邹:Trâu 熊:Hùng 金:Kim 陆:Lục
郝:Hác 孔:Khổng 白:Bạch 崔:Thôi 康:Khang 毛:Mao 邱:Khâu 秦:Tần 江:Giang 史:Sử
顾:Cố 侯:Hầu 邵:Thiệu 孟:Mạnh 龙:Long 万:Vạn 段:Đoạn 雷:Lôi 钱:Tiền 汤:Thang
尹:Doãn 黎:Lê 易:Dịch 常:Thường 武:Võ 乔:Kiều 贺:Hạ 赖:Lại 龚:Cung 文:Văn
庞:Bàng 樊:Phàn 兰:Lan 殷:Ân 施:Thi 陶:Đào 洪:Hồng 翟:Địch 安:An 颜:Nhan
倪:Nghê 严:Nghiêm 牛:Ngưu 温:Ôn 季:Quý 俞:Du 章:Chương 鲁:Lỗ 葛:Cát 伍:Ngũ
韦:Vi 申:Thân 尤:Vưu 毕:Tất 聂:Nhiếp 焦:Tiêu 向:Hướng 柳:Liễu 邢:Hình 路:Lộ
岳:Nhạc 齐:Tề 梅:Mai 莫:Mạc 庄:Trang 辛:Tân 管:Quản 祝:Chúc 左:Tả 涂:Đồ
谷:Cốc 祁:Kỳ 时:Thời 舒:Thư 耿:Cảnh 詹:Chiêm 关:Quan 苗:Miêu 凌:Lăng 费:Phí
纪:Kỷ 靳:Cận 盛:Thịnh 童:Đồng 欧:Âu 甄:Chân 项:Hạng 曲:Khúc 成:Thành 游:Du
阳:Dương 裴:Bùi 席:Tịch 卫:Vệ 屈:Khuất 鲍:Bào 霍:Hoắc 翁:Ông 隋:Tùy 甘:Cam
薄:Bạc 包:Bao 司:Tư 柏:Bách 柯:Kha 阮:Nguyễn 桂:Quế 肖:Tiêu
慕:Mộ 容:Dung 令:Lệnh 狐:Hồ 皇:Hoàng 甫:Phủ 东:Đông 西:Tây 门:Môn 上:Thượng
官:Quan 公:Công 南:Nam 北:Bắc 中:Trung 下:Hạ
大:Đại 小:Tiểu 雄:Hùng 明:Minh 华:Hoa 伟:Vĩ 强:Cường 军:Quân 勇:Dũng 杰:Kiệt
涛:Đào 磊:Lỗi 浩:Hạo 宇:Vũ 轩:Hiên 辰:Thần 天:Thiên 峰:Phong 飞:Phi 云:Vân
风:Phong 雨:Vũ 雪:Tuyết 月:Nguyệt 星:Tinh 海:Hải 山:Sơn 河:Hà 森:Sâm 刚:Cương
平:Bình 宁:Ninh 静:Tĩnh 慧:Tuệ 美:Mỹ 丽:Lệ 婷:Đình 娜:Na 倩:Thiến 琳:Lâm
欣:Hân 怡:Di 雅:Nhã 萱:Huyên 瑶:Dao 薇:Vi 蕾:Lôi 莉:Lị 芳:Phương 敏:Mẫn
玉:Ngọc 珍:Trân 菊:Cúc 竹:Trúc 凤:Phượng 凰:Hoàng 虎:Hổ 豹:Báo 鹰:Ưng 鹏:Bằng
鹤:Hạc 英:Anh 俊:Tuấn 帅:Soái 豪:Hào 志:Chí 国:Quốc 建:Kiến 功:Công 德:Đức
仁:Nhân 义:Nghĩa 礼:Lễ 智:Trí 信:Tín 忠:Trung 孝:Hiếu 诚:Thành 正:Chính 清:Thanh
青:Thanh 蓝:Lam 紫:Tử 红:Hồng 黑:Hắc 银:Ngân 铁:Thiết 钢:Cương 玄:Huyền 冰:Băng
火:Hỏa 炎:Viêm 水:Thủy 木:Mộc 土:Thổ 光:Quang 影:Ảnh 夜:Dạ 晨:Thần 旭:Húc
昊:Hạo 泽:Trạch 洋:Dương 凯:Khải 博:Bác 渊:Uyên 逸:Dật 凡:Phàm 尘:Trần 烨:Diệp
然:Nhiên 琪:Kỳ 欢:Hoan 乐:Lạc 喜:Hỷ 福:Phúc 禄:Lộc 寿:Thọ 健:Kiện 泰:Thái
和:Hòa 顺:Thuận 利:Lợi 达:Đạt 通:Thông 远:Viễn 长:Trường 永:Vĩnh 久:Cửu 恒:Hằng
昌:Xương 兴:Hưng 旺:Vượng 荣:Vinh 耀:Diệu 辉:Huy 煌:Hoàng 灿:Xán 亮:Lượng 朗:Lãng
晴:Tình 晓:Hiểu 暖:Noãn 春:Xuân 秋:Thu 冬:Đông 子:Tử 儿:Nhi 女:Nữ 男:Nam
一:Nhất 二:Nhị 三:Tam 四:Tứ 五:Ngũ 六:Lục 七:Thất 八:Bát 九:Cửu 十:Thập 百:Bách 千:Thiên
婉:Uyển 莹:Oánh 洁:Khiết 菲:Phi 妍:Nghiên 嫣:Yên 颖:Dĩnh 涵:Hàm 思:Tư 梦:Mộng
梓:Tử 彤:Đồng 筠:Quân 蓉:Dung 荷:Hà 莲:Liên 芸:Vân 茜:Thiến 若:Nhược 汐:Tịch
沐:Mộc 楠:Nam 墨:Mặc 默:Mặc 言:Ngôn 语:Ngữ 诗:Thi 书:Thư 剑:Kiếm 刀:Đao
枪:Thương 弓:Cung 战:Chiến 胜:Thắng 傲:Ngạo 霸:Bá 帝:Đế 君:Quân 主:Chủ 神:Thần
仙:Tiên 魔:Ma 鬼:Quỷ 妖:Yêu 灵:Linh 魂:Hồn 心:Tâm 情:Tình 爱:Ái 悠:Du
澈:Triệt 睿:Duệ 瑾:Cẩn 瑜:Du 玮:Vĩ 琛:Sâm 锐:Nhuệ 毅:Nghị 斌:Bân 彬:Bân
岚:Lam 珊:San 丹:Đan 彩:Thái 虹:Hồng 霞:Hà 露:Lộ 霜:Sương 哲:Triết 澜:Lan
昭:Chiêu 景:Cảnh 老:Lão 前:Tiền 后:Hậu 内:Nội 外:Ngoại 右:Hữu
''';
}
