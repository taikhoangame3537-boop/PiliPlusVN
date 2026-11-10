import 'dart:async';

import 'package:PiliPlus/common/widgets/dialog/dialog.dart';
import 'package:PiliPlus/common/widgets/dialog/report_member.dart';
import 'package:PiliPlus/grpc/bilibili/app/im/v1.pb.dart';
import 'package:PiliPlus/grpc/im.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/msg.dart';
import 'package:PiliPlus/http/video.dart';
import 'package:PiliPlus/models_new/msg/im_user_infos/datum.dart';
import 'package:PiliPlus/models_new/msg/msg_dnd/uid_setting.dart';
import 'package:PiliPlus/models_new/msg/session_ss/data.dart';
import 'package:PiliPlus/utils/accounts.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/widgets.dart' show Text;
import 'package:get/get.dart';

class WhisperLinkSettingController extends GetxController {
  WhisperLinkSettingController({
    required this.talkerUid,
  });

  final int talkerUid;
  RxBool isPinned = false.obs;
  late final sessionId = SessionId(
    privateId: PrivateId(talkerUid: Int64(talkerUid)),
  );

  @override
  void onInit() {
    super.onInit();
    getUserInfo();
    getSessionSs();
    getMsgDnd();
    getIsPinned();
  }

  final Rx<LoadingState<List<ImUserInfosData>?>> userState =
      LoadingState<List<ImUserInfosData>?>.loading().obs;
  final Rx<LoadingState<SessionSsData>> sessionSs =
      LoadingState<SessionSsData>.loading().obs;
  final Rx<LoadingState<List<UidSetting>?>> msgDnd =
      LoadingState<List<UidSetting>?>.loading().obs;

  Future<void> getUserInfo() async {
    userState.value = await MsgHttp.imUserInfos(uids: talkerUid.toString());
  }

  Future<void> getSessionSs() async {
    sessionSs.value = await MsgHttp.getSessionSs(talkerUid: talkerUid);
  }

  Future<void> getMsgDnd() async {
    msgDnd.value = await MsgHttp.getMsgDnd(uidsStr: talkerUid);
  }

  Future<void> getIsPinned() async {
    final res = await ImGrpc.sessionUpdate(sessionId: sessionId);
    if (res case Success(:final response)) {
      isPinned.value = response.session.isPinned;
    }
  }

  void setPush(bool isPush) {
    if (isPush) {
      showConfirmDialog(
        context: Get.context!,
        title: const Text('Xác nhận tắt thông báo nội dung?'),
        content: const Text('Nếu tắt công tắc này, bạn sẽ không nhận được tin nhắn hình ảnh và thông báo bài mới từ tài khoản này, thông báo hệ thống không bị ảnh hưởng'),
        onConfirm: () => _setPush(isPush),
      );
      return;
    }
    _setPush(isPush);
  }

  Future<void> _setPush(bool isPush) async {
    int setting = isPush ? 1 : 0;
    final res = await MsgHttp.setPushSs(
      setting: setting,
      talkerUid: talkerUid,
    );
    if (res.isSuccess) {
      sessionSs
        ..value.data.pushSetting = setting
        ..refresh();
    } else {
      res.toast();
    }
  }

  Future<void> setPin() async {
    final res = isPinned.value
        ? await ImGrpc.unpinSession(sessionId: sessionId)
        : await ImGrpc.pinSession(sessionId: sessionId);
    if (res.isSuccess) {
      isPinned.toggle();
    } else {
      res.toast();
    }
  }

  Future<void> setMute(bool isMuted) async {
    int setting = isMuted ? 0 : 1;
    final res = await MsgHttp.setMsgDnd(
      uid: Accounts.main.mid,
      setting: setting,
      dndUid: talkerUid,
    );
    if (res.isSuccess) {
      msgDnd
        ..value.data!.first.setting = setting
        ..refresh();
    } else {
      res.toast();
    }
  }

  Future<void> setBlock(bool isBlocked) async {
    if (isBlocked) {
      final res = await VideoHttp.relationMod(
        mid: talkerUid,
        act: 6,
        reSrc: 11,
      );
      if (res.isSuccess) {
        sessionSs
          ..value.data.followStatus = null
          ..refresh();
      } else {
        res.toast();
      }
    } else {
      showConfirmDialog(
        context: Get.context!,
        title: const Text('Xác nhận chặn người dùng này'),
        content: const Text('Sau khi thêm vào danh sách đen, sẽ tự động bỏ theo dõi và hủy đăng ký bộ sưu tập của người dùng này, cấm họ tương tác với tôi hoặc xem trang cá nhân của tôi'),
        onConfirm: () async {
          final res = await VideoHttp.relationMod(
            mid: talkerUid,
            act: 5,
            reSrc: 11,
          );
          if (res.isSuccess) {
            sessionSs
              ..value.data.followStatus = 128
              ..refresh();
          } else {
            res.toast();
          }
        },
      );
    }
  }

  void report() => showMemberReportDialog(
    Get.context!,
    name: userState.value.dataOrNull?.firstOrNull?.name,
    mid: talkerUid,
  );
}
