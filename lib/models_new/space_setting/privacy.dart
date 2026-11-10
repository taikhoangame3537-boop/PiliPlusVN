class SpaceSettingModel {
  SpaceSettingModel({
    required this.name,
    required this.key,
    required this.value,
    this.isReverse = false,
  });

  String name;
  String key;
  int? value;
  bool isReverse;

  bool get boolVal => isReverse ? value == 0 : value == 1;
}

class Privacy {
  List<SpaceSettingModel> list1;
  List<SpaceSettingModel> list2;
  List<SpaceSettingModel> list3;

  Privacy({
    required this.list1,
    required this.list2,
    required this.list3,
  });

  factory Privacy.fromJson(Map<String, dynamic> json) => Privacy(
    list1: [
      SpaceSettingModel(
        name: 'Công khai mục yêu thích của tôi',
        key: 'fav_video',
        value: json['fav_video'],
      ),
      SpaceSettingModel(
        name: 'Công khai anime/phim đang theo dõi',
        key: 'bangumi',
        value: json['bangumi'],
      ),
      SpaceSettingModel(
        name: 'Công khai truyện tranh đang theo dõi',
        key: 'comic',
        value: json['comic'],
      ),
      SpaceSettingModel(
        name: 'Công khai video đã thả xu gần đây',
        key: 'coins_video',
        value: json['coins_video'],
      ),
      SpaceSettingModel(
        name: 'Công khai video đã thích gần đây',
        key: 'likes_video',
        value: json['likes_video'],
      ),
      SpaceSettingModel(
        name: 'Công khai game đã chơi gần đây',
        key: 'played_game',
        value: json['played_game'],
      ),
      SpaceSettingModel(
        name: 'Công khai trang phục fan đang sở hữu',
        key: 'dress_up',
        value: json['dress_up'],
      ),
      SpaceSettingModel(
        name: 'Công khai danh sách tôi theo dõi',
        key: 'disable_following',
        value: json['disable_following'],
        isReverse: true,
      ),
      SpaceSettingModel(
        name: 'Công khai danh sách người hâm mộ',
        key: 'disable_show_fans',
        value: json['disable_show_fans'],
        isReverse: true,
      ),
    ],
    list2: [
      SpaceSettingModel(
        name: 'Công khai huy hiệu fan đang đeo',
        key: 'close_space_medal',
        value: json['close_space_medal'],
        isReverse: true,
      ),
      SpaceSettingModel(
        name: 'Tường huy hiệu hiển thị công khai tất cả huy hiệu fan',
        key: 'only_show_wearing',
        value: json['only_show_wearing'],
        isReverse: true,
      ),
      SpaceSettingModel(
        name: 'Công khai thông tin trường học',
        key: 'disable_show_school',
        value: json['disable_show_school'],
        isReverse: true,
      ),
    ],
    list3: [
      SpaceSettingModel(
        name: 'Hiển thị bản phát lại trực tiếp trong danh sách video đã đăng',
        key: 'live_playback',
        value: json['live_playback'],
      ),
      SpaceSettingModel(
        name: 'Hiển thị video nạp điện hàng tháng trong danh sách video đã đăng',
        key: 'charge_video',
        value: json['charge_video'],
      ),
      SpaceSettingModel(
        name: 'Hiển thị video lớp học trong danh sách video đã đăng',
        key: 'lesson_video',
        value: json['lesson_video'],
      ),
    ],
  );
}
