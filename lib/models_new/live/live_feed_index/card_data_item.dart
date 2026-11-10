import 'package:PiliPlus/models_new/live/live_feed_index/card_data_list_item.dart';

class CardDataItem {
  final List<CardLiveItem>? list;
  final ExtraInfo? extraInfo;

  const CardDataItem({
    this.list,
    this.extraInfo,
  });

  factory CardDataItem.fromJson(Map<String, dynamic> json) => CardDataItem(
    list: (json['list'] as List<dynamic>?)
        ?.map((e) => CardLiveItem.fromJson(e as Map<String, dynamic>))
        .toList(),
    extraInfo: json['extra_info'] == null
        ? null
        : ExtraInfo.fromJson(json['extra_info'] as Map<String, dynamic>),
  );

  static const kAreaEntrance = CardDataItem(
    list: [
      CardLiveItem(
        areaV2Id: 0,
        areaV2ParentId: 0,
        title: 'Độ nổi tiếng',
      ),
      CardLiveItem(
        areaV2Id: 0,
        areaV2ParentId: 9,
        title: 'VTuber',
      ),
      CardLiveItem(
        areaV2Id: 0,
        areaV2ParentId: 14,
        title: 'Phòng chat',
      ),
      CardLiveItem(
        areaV2Id: 145,
        areaV2ParentId: 1,
        title: 'Nhan sắc',
      ),
      CardLiveItem(
        areaV2Id: 0,
        areaV2ParentId: 1,
        title: 'Giải trí',
      ),
      CardLiveItem(
        areaV2Id: 86,
        areaV2ParentId: 2,
        title: 'Liên Minh Huyền Thoại',
      ),
      CardLiveItem(
        areaV2Id: 35,
        areaV2ParentId: 3,
        title: 'Vương Giả Vinh Diệu',
      ),
      CardLiveItem(
        areaV2Id: 0,
        areaV2ParentId: 5,
        title: 'Đài phát thanh',
      ),
      CardLiveItem(
        areaV2Id: 89,
        areaV2ParentId: 2,
        title: 'CS2',
      ),
      CardLiveItem(
        areaV2Id: 0,
        areaV2ParentId: 15,
        title: 'Chơi tương tác',
      ),
      CardLiveItem(
        areaV2Id: 0,
        areaV2ParentId: 6,
        title: 'Game đơn',
      ),
      CardLiveItem(
        areaV2Id: 21,
        areaV2ParentId: 1,
        title: 'Video ca hát',
      ),
      CardLiveItem(
        areaV2Id: 301000,
        areaV2ParentId: 301,
        title: 'Chơi giúp tôi',
      ),
      CardLiveItem(
        areaV2Id: 1013,
        areaV2ParentId: 1,
        title: 'Phát nhóm',
      ),
    ],
  );
}

class ExtraInfo {
  int? totalCount;

  ExtraInfo.fromJson(Map<String, dynamic> json) {
    totalCount = json['total_count'];
  }
}
