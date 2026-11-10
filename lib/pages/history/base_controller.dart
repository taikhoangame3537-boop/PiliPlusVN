import 'package:PiliPlus/http/user.dart';
import 'package:PiliPlus/utils/accounts.dart';
import 'package:PiliPlus/utils/storage.dart';
import 'package:PiliPlus/utils/storage_key.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

class HistoryBaseController extends GetxController {
  RxBool pauseStatus = false.obs;

  RxBool enableMultiSelect = false.obs;
  RxInt checkedCount = 0.obs;

  final account = Accounts.history;

  // 清空观看历史
  void onClearHistory(BuildContext context, VoidCallback onSuccess) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thông báo'),
        content: const Text('Ơ? Bạn muốn xóa chức năng lịch sử sao?'),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text(
              'Hủy',
              style: TextStyle(color: Theme.of(context).colorScheme.outline),
            ),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              SmartDialog.showLoading(msg: 'Đang yêu cầu');
              final res = await UserHttp.clearHistory(account: account);
              SmartDialog.dismiss();
              if (res.isSuccess) {
                SmartDialog.showToast('Xóa lịch sử xem');
                onSuccess();
              } else {
                res.toast();
              }
            },
            child: const Text('Xác nhận xóa'),
          ),
        ],
      ),
    );
  }

  // 暂停观看历史
  void onPauseHistory(BuildContext context) {
    final pauseStatus = !this.pauseStatus.value;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thông báo'),
        content: Text(pauseStatus ? 'Ơ? Bạn muốn tạm dừng chức năng lịch sử sao?' : 'Ơ? Bạn muốn tiếp tục chức năng lịch sử sao?'),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text(
              'Hủy',
              style: TextStyle(color: Theme.of(context).colorScheme.outline),
            ),
          ),
          TextButton(
            onPressed: () async {
              SmartDialog.showLoading(msg: 'Đang yêu cầu');
              final res = await UserHttp.pauseHistory(
                pauseStatus,
                account: account,
              );
              SmartDialog.dismiss();
              if (res.isSuccess) {
                SmartDialog.showToast(pauseStatus ? 'Tạm dừng lịch sử xem' : 'Tiếp tục lịch sử xem');
                this.pauseStatus.value = pauseStatus;
                GStorage.localCache.put(
                  LocalCacheKey.historyPause,
                  pauseStatus,
                );
              } else {
                res.toast();
              }
              Get.back();
            },
            child: Text(pauseStatus ? 'Xác nhận tạm dừng' : 'Xác nhận tiếp tục'),
          ),
        ],
      ),
    );
  }
}
