import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/user.dart';
import 'package:PiliPlus/models_new/login_log/data.dart';
import 'package:PiliPlus/models_new/login_log/list.dart';
import 'package:PiliPlus/pages/log_table/controller.dart';

class LoginLogController extends LogController<LoginLogData, LoginLogItem> {
  @override
  List<LoginLogItem>? getDataList(LoginLogData response) {
    return response.list;
  }

  @override
  Future<LoadingState<LoginLogData>> customGetData() => UserHttp.loginLog();

  @override
  List<(int, String)> getFlexAndText(LoginLogItem item) {
    return [(3, item.timeAt), (2, item.ip), (3, item.geo)];
  }

  @override
  final LoginLogItem header = const LoginLogItem(
    timeAt: 'Thời gian',
    ip: 'Thay đổi',
    geo: 'Vị trí địa lý',
  );

  @override
  final String title = 'Lịch sử đăng nhập';
}
