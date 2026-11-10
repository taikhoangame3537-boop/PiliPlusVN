import 'package:PiliPlus/common/style.dart';
import 'package:PiliPlus/common/widgets/scaffold/simple_scaffold.dart';
import 'package:PiliPlus/common/widgets/view_insets_safe_area.dart';
import 'package:PiliPlus/pages/webdav/webdav.dart';
import 'package:PiliPlus/utils/storage.dart';
import 'package:PiliPlus/utils/storage_key.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:material_ui/material_ui.dart';

class WebDavSettingPage extends StatefulWidget {
  const WebDavSettingPage({
    super.key,
    this.showAppBar = true,
  });

  final bool showAppBar;

  @override
  State<WebDavSettingPage> createState() => _WebDavSettingPageState();
}

class _WebDavSettingPageState extends State<WebDavSettingPage> {
  final _uriCtr = TextEditingController(text: Pref.webdavUri);
  final _usernameCtr = TextEditingController(text: Pref.webdavUsername);
  final _passwordCtr = TextEditingController(text: Pref.webdavPassword);
  final _directoryCtr = TextEditingController(text: Pref.webdavDirectory);
  bool _obscureText = true;

  @override
  void dispose() {
    _uriCtr.dispose();
    _usernameCtr.dispose();
    _passwordCtr.dispose();
    _directoryCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showAppBar = widget.showAppBar;
    final padding = MediaQuery.viewPaddingOf(context);
    return SimpleScaffold(
      appBar: showAppBar ? AppBar(title: const Text('Cài đặt WebDAV')) : null,
      body: ViewInsetsSafeArea(
        child: ListView(
          padding: padding.copyWith(
            top: 20,
            left: 20 + (showAppBar ? padding.left : 0),
            right: 20 + (showAppBar ? padding.right : 0),
            bottom: padding.bottom + 100,
          ),
          children: [
            TextField(
              controller: _uriCtr,
              decoration: const InputDecoration(
                labelText: 'Địa chỉ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _usernameCtr,
              decoration: const InputDecoration(
                labelText: 'Người dùng',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordCtr,
              autofillHints: const [AutofillHints.password],
              decoration: InputDecoration(
                labelText: 'Mật khẩu',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscureText = !_obscureText),
                  icon: _obscureText
                      ? const Icon(Icons.visibility)
                      : const Icon(Icons.visibility_off),
                ),
              ),
              obscureText: _obscureText,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _directoryCtr,
              decoration: const InputDecoration(
                labelText: 'Đường dẫn',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonal(
                    style: FilledButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                        borderRadius: Style.mdRadius,
                      ),
                    ),
                    onPressed: WebDav().backup,
                    child: const Text('Sao lưu cài đặt'),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: FilledButton.tonal(
                    style: FilledButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                        borderRadius: Style.mdRadius,
                      ),
                    ),
                    onPressed: WebDav().restore,
                    child: const Text('Khôi phục cài đặt'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      fab: Padding(
        padding: .only(
          right: kFloatingActionButtonMargin + (showAppBar ? padding.right : 0),
          bottom: kFloatingActionButtonMargin + padding.bottom,
        ),
        child: ViewInsetsSafeArea(
          child: FloatingActionButton(
            child: const Icon(Icons.save),
            onPressed: () async {
              await GStorage.setting.putAll({
                SettingBoxKey.webdavUri: _uriCtr.text,
                SettingBoxKey.webdavUsername: _usernameCtr.text,
                SettingBoxKey.webdavPassword: _passwordCtr.text,
                SettingBoxKey.webdavDirectory: _directoryCtr.text,
              });
              if (_uriCtr.text.isEmpty) {
                return;
              }
              try {
                final res = await WebDav().init();
                if (res.first) {
                  SmartDialog.showToast('Cấu hình thành công');
                } else {
                  SmartDialog.showToast('Cấu hình thất bại: ${res.second}');
                }
              } catch (e) {
                SmartDialog.showToast('Cấu hình thất bại: ${e.toString()}');
                return;
              }
            },
          ),
        ),
      ),
    );
  }
}
