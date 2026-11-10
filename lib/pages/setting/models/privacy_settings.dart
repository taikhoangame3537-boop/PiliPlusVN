import 'package:PiliPlus/common/widgets/custom_icon.dart';
import 'package:PiliPlus/common/widgets/stateful_builder.dart';
import 'package:PiliPlus/models/common/account_type.dart';
import 'package:PiliPlus/pages/setting/models/model.dart';
import 'package:PiliPlus/utils/accounts.dart';
import 'package:PiliPlus/utils/accounts/account.dart';
import 'package:PiliPlus/utils/accounts/api_type.dart';
import 'package:PiliPlus/utils/login_utils.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart' hide StatefulBuilder;

List<SettingsModel> get privacySettings => [
  NormalModel(
    onTap: (context, setState) => Get.toNamed('/blackListPage'),
    title: 'Quản lý danh sách đen',
    subtitle: 'Người dùng đã chặn',
    leading: const Icon(Icons.block),
  ),
  const NormalModel(
    title: 'Cài đặt buvid',
    leading: Icon(CustomIcons.identifier_circle),
    onTap: _showBuvidDialog,
  ),
  NormalModel(
    onTap: (context, setState) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Chi tiết chế độ tài khoản'),
          content: SelectionArea(
            child: SingleChildScrollView(
              child: _getAccountDetail(context),
            ),
          ),
          actions: [
            TextButton(
              onPressed: Get.back,
              child: const Text('Xác nhận'),
            ),
          ],
        ),
      );
    },
    leading: const Icon(Icons.flag_outlined),
    title: 'Tìm hiểu chế độ tài khoản',
    subtitle: 'Xem danh sách API mà từng chế độ tài khoản tác động',
  ),
];

Widget _getAccountDetail(BuildContext context) {
  final children = <Widget>[];
  final theme = TextTheme.of(context);
  for (final i in AccountType.values) {
    final url = ApiType.apiTypeSet[i];
    if (url == null) continue;

    children
      ..add(Center(child: Text(i.title, style: theme.titleMedium)))
      ..add(Text(url.join('\n')));
  }
  return Column(
    spacing: 8,
    mainAxisSize: .min,
    crossAxisAlignment: .start,
    children: children,
  );
}

void _showBuvidDialog(BuildContext context, VoidCallback setState) {
  final filter = [
    FilteringTextInputFormatter.allow(
      RegExp(r"[a-z\d\-_]+", caseSensitive: false),
    ),
  ];
  final controllers = [
    (
      AnonymousAccount(),
      TextEditingController(text: AnonymousAccount().buvid),
    ),
    ...Accounts.account.values.map(
      (i) => (i, TextEditingController(text: i.buvid)),
    ),
  ];
  showDialog<bool>(
    context: context,
    builder: (context) {
      final theme = Theme.of(context);
      return StatefulBuilder(
        onDispose: () {
          for (var (_, ctr) in controllers) {
            ctr.dispose();
          }
          controllers.clear();
        },
        builder: (context, _) => AlertDialog(
          title: const Text('buvid'),
          content: SingleChildScrollView(
            child: Column(
              spacing: 8,
              mainAxisSize: .min,
              children: controllers
                  .map(
                    (i) => TextField(
                      controller: i.$2,
                      decoration: InputDecoration(
                        isDense: true,
                        labelText: 'mid: ${i.$1.mid}',
                        labelStyle: theme.textTheme.titleMedium,
                        suffixIcon: IconButton(
                          onPressed: () =>
                              i.$2.text = LoginUtils.generateBuvid(),
                          iconSize: 24,
                          tooltip: 'Ngẫu nhiên',
                          icon: const Icon(Icons.casino_outlined),
                        ),
                      ),
                      inputFormatters: filter,
                    ),
                  )
                  .toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: Get.back,
              child: Text(
                'Hủy',
                style: TextStyle(color: theme.colorScheme.outline),
              ),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                for (var (account, ctr) in controllers) {
                  if (ctr.text case final text when text.isNotEmpty) {
                    account.buvid = text;
                  }
                }
              },
              child: const Text('Đồng ý'),
            ),
          ],
        ),
      );
    },
  );
}
