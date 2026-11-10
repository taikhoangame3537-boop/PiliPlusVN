/// Quy tắc dịch có sẵn cho Google gtx (chạy cùng quy tắc người dùng nhập trong
/// app; quy tắc của người dùng được ưu tiên). Sửa trực tiếp ở đây.
///
/// Cú pháp (mỗi dòng một quy tắc, dòng bắt đầu bằng # là ghi chú):
///   A => B       sửa phụ đề GỐC trước khi dịch (lỗi nghe nhầm của phụ đề AI)
///   A = B        thuật ngữ/tên riêng: A luôn được dịch thành B
///   A >> B       sửa bản dịch tiếng Việt SAU khi dịch (không phân biệt hoa/thường)
///   @hv 林凡 苏婉  liệt kê tên người, tự đổi sang Hán Việt (Lâm Phàm, Tô Uyển)
///
/// Thuật ngữ dài tự được xử lý trước thuật ngữ ngắn. Đây là bộ khởi đầu do
/// người viết tự soạn, hãy thêm bớt cho hợp với phim bạn xem.
const String kDefaultSubtitleRules = r'''
# ===== Tên nhân vật: bỏ dấu # và thêm tên (Hán tự) của phim đang xem =====
# @hv 林凡 苏婉清 大雄

# ===== Sửa lỗi phụ đề gốc hay gặp =====
知到 => 知道

# ===== Mạt thế / zombie =====
末世 = tận thế
末日 = ngày tận thế
丧尸 = zombie
僵尸 = zombie
异能者 = người dị năng
异能 = dị năng
变异 = biến dị
晶核 = tinh hạch
基地 = căn cứ
物资 = vật tư
幸存者 = người sống sót
觉醒 = thức tỉnh
感染者 = người nhiễm bệnh
宿主 = ký chủ
系统 = hệ thống
重生 = trọng sinh
穿越 = xuyên không

# ===== Tu tiên / võ hiệp =====
修仙 = tu tiên
修炼 = tu luyện
灵气 = linh khí
灵力 = linh lực
灵根 = linh căn
真气 = chân khí
内力 = nội lực
丹药 = đan dược
丹田 = đan điền
法宝 = pháp bảo
境界 = cảnh giới
筑基 = trúc cơ
金丹 = kim đan
元婴 = nguyên anh
渡劫 = độ kiếp
飞升 = phi thăng
神识 = thần thức
天道 = thiên đạo
宗门 = tông môn
门派 = môn phái
掌门 = chưởng môn
宗主 = tông chủ
长老 = trưởng lão
弟子 = đệ tử
道友 = đạo hữu
江湖 = giang hồ
武林 = võ lâm
大侠 = đại hiệp
少侠 = thiếu hiệp
魔教 = ma giáo
魔尊 = ma tôn
仙子 = tiên tử
妖兽 = yêu thú

# ===== Xưng hô: sư môn =====
师父 = sư phụ
师尊 = sư tôn
师兄 = sư huynh
师姐 = sư tỷ
师弟 = sư đệ
师妹 = sư muội
前辈 = tiền bối
晚辈 = vãn bối

# ===== Xưng hô: cung đình, gia tộc =====
皇上 = hoàng thượng
陛下 = bệ hạ
殿下 = điện hạ
皇帝 = hoàng đế
皇后 = hoàng hậu
太后 = thái hậu
太子 = thái tử
公主 = công chúa
王爷 = vương gia
王妃 = vương phi
娘娘 = nương nương
爱妃 = ái phi
将军 = tướng quân
公子 = công tử
少爷 = thiếu gia
老爷 = lão gia
夫人 = phu nhân
在下 = tại hạ
属下 = thuộc hạ
臣妾 = thần thiếp
奴婢 = nô tì
本王 = bổn vương
本座 = bản tọa
总裁 = tổng tài

# ===== Xưng hô thường ngày =====
老大 = đại ca
大佬 = đại ca
兄弟 = anh em
老婆 = vợ
老公 = chồng

# ===== Sửa cách dịch máy hay sai =====
thây ma >> zombie
xác sống >> zombie
''';
