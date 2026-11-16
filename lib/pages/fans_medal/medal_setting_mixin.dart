import 'package:PiliPlus/models_new/live/live_config_plugs/data.dart';
import 'package:PiliPlus/pages/fans_medal/controller.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:material_ui/material_ui.dart';

mixin MedalSettingMixin<T extends StatefulWidget> on State<T> {
  FansMedalController get medalController;
  ThemeData? get pageTheme => null;

  Future<void> showMedalSettingDialog() async {
    if (medalController.config == null) {
      final res = await medalController.getConfigPlus();
      if (!res || !mounted) return;
    }
    final config = medalController.config!;
    showDialog(
      context: context,
      builder: (context) {
        void onChanged(String key, bool value) => medalController
            .setConfigPlus(key: key, status: !value)
            .then((success) {
              if (success && context.mounted) {
                (context as Element).markNeedsBuild();
              }
            });

        final child = SimpleDialog(
          clipBehavior: .hardEdge,
          title: const Text('Cài đặt hiển thị'),
          children: [
            SwitchListTile(
              dense: true,
              controlAffinity: .trailing,
              title: const Text(
                'Hiển thị công khai huy hiệu fan đang đeo trên trang cá nhân',
                style: TextStyle(fontSize: 14),
              ),
              value: !config.closeSpaceMedal,
              onChanged: (value) =>
                  onChanged(ConfigPlusData.kCloseSpaceMedalKey, value),
            ),
            SwitchListTile(
              dense: true,
              controlAffinity: .trailing,
              title: const Text(
                'Hiển thị công khai tất cả huy hiệu fan trên tường huy hiệu',
                style: TextStyle(fontSize: 14),
              ),
              subtitle: const Text('Khi tắt, tường huy hiệu chỉ hiển thị huy hiệu đang đeo'),
              value: !config.closeSpaceMedal && !config.onlyShowWearing,
              onChanged: (value) => !config.closeSpaceMedal
                  ? onChanged(ConfigPlusData.kOnlyShowWearingKey, value)
                  : SmartDialog.showToast('Cần bật trước "Hiển thị công khai huy hiệu fan đang đeo trên trang cá nhân"'),
            ),
          ],
        );
        final theme = pageTheme;
        if (theme != null) {
          return Theme(data: theme, child: child);
        }
        return child;
      },
    );
  }
}
