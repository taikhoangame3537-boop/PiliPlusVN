// ignore_for_file: constant_identifier_names

import 'dart:ui';

import 'package:PiliPlus/models/common/sponsor_block/action_type.dart';

enum SegmentType {
  sponsor(
    'Tài trợ/Quảng cáo',
    'Tài trợ',
    'Quảng bá trả phí, giới thiệu và quảng cáo trực tiếp. Không phải tự quảng bá hoặc nhắc miễn phí đến sản phẩm/người sáng tạo/trang web/sản phẩm mà họ yêu thích.',
    Color(0xFF00d400),
    [
      ActionType.skip,
      ActionType.mute,
      ActionType.full,
    ],
  ),
  selfpromo(
    'Không thu phí/Tự quảng bá',
    'Quảng bá',
    'Tương tự "quảng cáo tài trợ" nhưng không có thù lao hoặc là tự quảng bá. Bao gồm thông tin về hàng hóa, quyên góp hoặc cộng tác viên.',
    Color(0xFFffff00),
    [
      ActionType.skip,
      ActionType.mute,
      ActionType.full,
    ],
  ),
  exclusive_access(
    'Truy cập độc quyền/Trải nghiệm sớm',
    'Hợp tác thương hiệu',
    'Chỉ dùng để đánh dấu toàn bộ video. Áp dụng cho video giới thiệu sản phẩm, dịch vụ hoặc địa điểm mà UP chủ dùng miễn phí hoặc được tài trợ.',
    Color(0xFF008a5c),
    [ActionType.full],
  ),
  interaction(
    'Nhắc tam liên/tương tác',
    'Nhắc tam liên',
    'Nhắc ngắn khán giả ở giữa video để tam liên hoặc theo dõi. Nếu đoạn dài hoặc có nội dung cụ thể thì nên phân loại là tự quảng bá.',
    Color(0xFFcc00ff),
    [
      ActionType.skip,
      ActionType.mute,
    ],
  ),
  poi_highlight(
    'Khoảnh khắc đặc sắc/Điểm chính',
    'Khoảnh khắc đặc sắc',
    'Thời điểm nhảy mà đa số người xem tìm. Giống bình luận kiểu "ảnh bìa ở 12:34".',
    Color(0xFFff1684),
    [ActionType.poi],
  ),
  intro(
    'Cảnh chuyển/Hoạt cảnh mở đầu',
    'Hoạt cảnh mở đầu',
    'Đoạn ngắt không có nội dung thực. Có thể là tạm dừng, khung tĩnh hoặc hoạt ảnh lặp lại. Không áp dụng cho cảnh chuyển có nội dung.',
    Color(0xFF00ffff),
    [
      ActionType.skip,
      ActionType.mute,
    ],
  ),
  outro(
    'Lời cảm ơn/Màn hình kết thúc',
    'Đoạn kết',
    'Màn hình cảm ơn hoặc màn hình kết thúc. Phần cuối không có nội dung.',
    Color(0xFF0202ed),
    [
      ActionType.skip,
      ActionType.mute,
    ],
  ),
  preview(
    'Nhìn lại/Tóm tắt',
    'Xem trước',
    'Hiển thị tổng hợp các cảnh sẽ xuất hiện trong video này hoặc cùng series, mọi nội dung trong đoạn sẽ xuất hiện lại trong phần chính sau đó.',
    Color(0xFF008fd6),
    [
      ActionType.skip,
      ActionType.mute,
    ],
  ),
  padding(
    'Nội dung lấp chỗ/Đen đầu/Đen cuối',
    'Nội dung lấp chỗ',
    'Nội dung lấp chỗ thuần túy ở đầu và cuối video repost, như màn hình đen hoặc hình không liên quan, không có ý nghĩa hay liên hệ thực với nội dung chính.',
    Color(0xFF222222),
    [ActionType.skip],
  ),
  filler(
    'Tán gẫu lạc đề/Đùa',
    'Lạc đề',
    "Đoạn lạc đề chỉ để lấp chỗ hoặc thêm vui, không cần thiết để hiểu nội dung chính của video. Không bao gồm đoạn cung cấp bối cảnh hoặc ngữ cảnh. Đây là phân loại rất mạnh tay, dùng khi bạn không muốn xem nội dung “giải trí”.",
    Color(0xFF7300FF),
    [
      ActionType.skip,
      ActionType.mute,
    ],
  ),
  music_offtopic(
    'Nhạc: phần không phải nhạc',
    'Không phải nhạc',
    'Chỉ dùng cho video nhạc. Phân loại này chỉ dùng cho phần trong video nhạc không thuộc các phân loại khác.',
    Color(0xFFff9900),
    [ActionType.skip],
  ),
  jumpscare(
    'Đoạn giật mình',
    'Giật mình',
    'Âm lượng lớn đột ngột, mặt nhảy ra, âm thanh kinh dị và các cú giật mình bất ngờ.',
    Color(0xFFe53935),
    [ActionType.mute],
  ),
  ;

  /// from https://github.com/hanydd/BilibiliSponsorBlock/blob/master/public/_locales/zh_CN/messages.json
  final String title;
  final String shortTitle;
  final String description;
  final Color color;
  final List<ActionType> toActionType;

  const SegmentType(
    this.title,
    this.shortTitle,
    this.description,
    this.color,
    this.toActionType,
  );
}

// List<SegmentType> _actionType2SegmentType(ActionType actionType) {
//   return switch (actionType) {
//     ActionType.skip => [
//         SegmentType.sponsor,
//         SegmentType.selfpromo,
//         SegmentType.interaction,
//         SegmentType.intro,
//         SegmentType.outro,
//         SegmentType.preview,
//         SegmentType.filler,
//       ],
//     ActionType.mute => [
//         SegmentType.sponsor,
//         SegmentType.selfpromo,
//         SegmentType.interaction,
//         SegmentType.intro,
//         SegmentType.outro,
//         SegmentType.preview,
//         SegmentType.music_offtopic,
//         SegmentType.filler,
//       ],
//     ActionType.full => [
//         SegmentType.sponsor,
//         SegmentType.selfpromo,
//         SegmentType.exclusive_access,
//       ],
//     ActionType.poi => [
//         SegmentType.poi_highlight,
//       ],
//   };
// }
