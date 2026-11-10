import 'package:PiliPlus/common/constants.dart';
import 'package:PiliPlus/common/dial_prefix.dart';
import 'package:PiliPlus/common/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/common/widgets/loading_widget/loading_widget.dart';
import 'package:PiliPlus/common/widgets/scaffold/simple_scaffold.dart';
import 'package:PiliPlus/common/widgets/scroll_physics.dart' show tabBarView;
import 'package:PiliPlus/common/widgets/view_insets_safe_area.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/pages/login/controller.dart';
import 'package:PiliPlus/utils/extension/size_ext.dart';
import 'package:PiliPlus/utils/extension/widget_ext.dart';
import 'package:PiliPlus/utils/image_utils.dart';
import 'package:PiliPlus/utils/page_utils.dart';
import 'package:PiliPlus/utils/platform_utils.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LoginPageController _loginPageCtr = Get.put(LoginPageController());
  // 二维码生成时间
  bool showPassword = false;
  GlobalKey globalKey = GlobalKey();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loginPageCtr.didChangeDependencies(context);
  }

  Widget loginByQRCode(ThemeData theme) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text('Quét mã đăng nhập bằng ứng dụng chính thức của bilibili'),
        const SizedBox(height: 20),
        Obx(
          () => Text(
            'Thời gian hiệu lực còn lại: ${_loginPageCtr.qrCodeLeftTime} giây',
            style: TextStyle(
              fontFeatures: const [FontFeature.tabularFigures()],
              color: theme.colorScheme.primaryFixedDim,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: _loginPageCtr.refreshQRCode,
              icon: const Icon(Icons.refresh),
              label: const Text('Làm mới mã QR'),
            ),
            TextButton.icon(
              onPressed: () async {
                SmartDialog.showLoading(msg: 'Đang tạo ảnh chụp');
                final boundary =
                    globalKey.currentContext!.findRenderObject()
                        as RenderRepaintBoundary;
                final image = await boundary.toImage(pixelRatio: 3);
                final byteData = await image.toByteData(format: .png);
                final pngBytes = byteData!.buffer.asUint8List();
                image.dispose();
                SmartDialog.dismiss();
                final picName =
                    "${Constants.appName}_loginQRCode_${_loginPageCtr.codeInfo.value.data.authCode.hashCode.toUnsigned(32).toRadixString(16)}";
                ImageUtils.saveByteImg(bytes: pngBytes, fileName: picName);
              },
              icon: const Icon(Icons.save),
              label: const Text('Lưu vào thư viện ảnh'),
            ),
            if (kDebugMode || PlatformUtils.isMobile)
              TextButton.icon(
                onPressed: () => PageUtils.launchURL(
                  'bilibili://browser?url=${Uri.encodeComponent(_loginPageCtr.codeInfo.value.data.url)}',
                  mode: LaunchMode.externalNonBrowserApplication,
                ),
                icon: const Icon(Icons.open_in_browser_outlined),
                label: const Text('Mở bằng ứng dụng khác'),
              ),
          ],
        ),
        RepaintBoundary(
          key: globalKey,
          child: Obx(
            () => switch (_loginPageCtr.codeInfo.value) {
              Loading() => const SizedBox(
                height: 200,
                width: 200,
                child: m3eLoading,
              ),
              Success(:final response) => Container(
                width: 200,
                height: 200,
                color: Colors.white,
                padding: const EdgeInsets.all(8),
                child: PrettyQrView.data(
                  data: response.url,
                  decoration: const PrettyQrDecoration(
                    shape: PrettyQrSquaresSymbol(
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              Error(:final errMsg) => HttpError(
                isSliver: false,
                errMsg: errMsg,
                onReload: _loginPageCtr.refreshQRCode,
              ),
            },
          ),
        ),
        const SizedBox(height: 10),
        Obx(
          () => Text(
            _loginPageCtr.statusQRCode.value,
            style: TextStyle(color: theme.colorScheme.secondaryFixedDim),
          ),
        ),
        Obx(
          () {
            final url = _loginPageCtr.codeInfo.value.dataOrNull?.url ?? '';
            return GestureDetector(
              onTap: () => Utils.copyText(
                url,
                toastText: 'Đã sao chép vào bộ nhớ tạm, có thể dán vào tin nhắn riêng của ứng dụng đã đăng nhập để gửi, rồi bấm vào liên kết đã gửi để mở',
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: Text(
                  url,
                  style: theme.textTheme.labelSmall!.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Hãy tải và cài đặt từ kho mã nguồn mở của ${Constants.appName} hoặc các nguồn đáng tin cậy.',
            style: theme.textTheme.labelSmall!.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ),
      ],
    );
  }

  Widget loginByCookie(ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 20),
        const Text('Đăng nhập bằng Cookie'),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Các chức năng dùng API của App sẽ không khả dụng',
            style: theme.textTheme.labelMedium!.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: TextField(
            minLines: 1,
            maxLines: 10,
            controller: _loginPageCtr.cookieTextController,
            inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r"\s"))],
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.cookie_outlined),
              border: const UnderlineInputBorder(),
              labelText: 'Cookie',
              suffixIcon: IconButton(
                onPressed: _loginPageCtr.cookieTextController.clear,
                icon: const Icon(Icons.clear),
              ),
            ),
          ),
        ),
        OutlinedButton.icon(
          onPressed: _loginPageCtr.loginByCookie,
          icon: const Icon(Icons.login),
          label: const Text('Đăng nhập'),
        ),
      ],
    );
  }

  Widget loginByPassword(ThemeData theme) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text('Đăng nhập bằng tài khoản mật khẩu'),
        const SizedBox(height: 20),
        Padding(
          padding: const .symmetric(horizontal: 20),
          child: AutofillGroup(
            child: Column(
              spacing: 10,
              children: [
                TextField(
                  controller: _loginPageCtr.usernameTextController,
                  autofillHints: const [
                    AutofillHints.telephoneNumber,
                    AutofillHints.email,
                  ],
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r"\s")),
                  ],
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.account_box),
                    border: const UnderlineInputBorder(),
                    labelText: 'Tài khoản',
                    hintText: 'Email/Số điện thoại',
                    suffixIcon: IconButton(
                      onPressed: _loginPageCtr.usernameTextController.clear,
                      icon: const Icon(Icons.clear),
                    ),
                  ),
                ),
                TextField(
                  obscureText: !showPassword,
                  keyboardType: TextInputType.visiblePassword,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r"\s")),
                  ],
                  controller: _loginPageCtr.passwordTextController,
                  autofillHints: const [AutofillHints.password],
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.password),
                    border: const UnderlineInputBorder(),
                    labelText: 'Mật khẩu',
                    suffixIcon: IconButton(
                      onPressed: _loginPageCtr.passwordTextController.clear,
                      icon: const Icon(Icons.clear),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Row(
          children: [
            const SizedBox(width: 10),
            Checkbox(
              value: showPassword,
              onChanged: (value) => setState(() => showPassword = value!),
            ),
            const Text('Hiện mật khẩu'),
            const Spacer(),
            TextButton(
              onPressed: () {
                //https://passport.bilibili.com/h5-app/passport/login/findPassword
                //https://passport.bilibili.com/passport/findPassword
                showDialog(
                  context: context,
                  builder: (context) => SimpleDialog(
                    clipBehavior: Clip.hardEdge,
                    title: const Text('Quên mật khẩu?'),
                    contentPadding: const .only(top: 2, bottom: 16),
                    children: [
                      const Padding(
                        padding: .fromLTRB(25, 0, 25, 10),
                        child: Text("Thử quét mã, đăng nhập bằng số điện thoại, hoặc chọn"),
                      ),
                      ListTile(
                        title: const Text(
                          'Lấy lại mật khẩu (di động)',
                        ),
                        leading: const Icon(Icons.smartphone_outlined),
                        subtitle: const Text(
                          'https://passport.bilibili.com/h5-app/passport/login/findPassword',
                        ),
                        dense: false,
                        onTap: () => Get
                          ..back()
                          ..toNamed(
                            '/webview',
                            parameters: {
                              'url': 'https://passport.bilibili.com/h5-app/passport/login/findPassword',
                              'type': 'url',
                              'pageTitle': 'Quên mật khẩu',
                            },
                          ),
                      ),
                      ListTile(
                        title: const Text('Lấy lại mật khẩu (máy tính)'),
                        leading: const Icon(Icons.desktop_windows_outlined),
                        subtitle: const Text(
                          'https://passport.bilibili.com/pc/passport/findPassword',
                        ),
                        dense: false,
                        onTap: () => Get
                          ..back()
                          ..toNamed(
                            '/webview',
                            parameters: {
                              'url': 'https://passport.bilibili.com/pc/passport/findPassword',
                              'type': 'url',
                              'pageTitle': 'Quên mật khẩu',
                              'uaType': 'pc',
                            },
                          ),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Quên mật khẩu'),
            ),
            const SizedBox(width: 20),
          ],
        ),
        OutlinedButton.icon(
          onPressed: _loginPageCtr.loginByPassword,
          icon: const Icon(Icons.login),
          label: const Text('Đăng nhập'),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Theo quy chuẩn giao diện đăng nhập chính thức của bilibili, mật khẩu sẽ được thêm muối và mã hóa cục bộ trước khi truyền.\n'
            'Muối và khóa công khai đều do phía chính thức cung cấp; mã hóa theo RSA/ECB/PKCS1Padding.\n'
            'Tài khoản mật khẩu chỉ dùng cho giao diện đăng nhập này, không lưu; cục bộ chỉ lưu thông tin đăng nhập.\n'
            'Hãy tải và cài đặt từ kho mã nguồn mở của ${Constants.appName} hoặc các nguồn đáng tin cậy.',
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall!.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ),
      ],
    );
  }

  Widget loginBySmS(ThemeData theme) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text('Đăng nhập bằng mã xác minh SMS'),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: DecoratedBox(
            decoration: UnderlineTabIndicator(
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Builder(
                  builder: (context) {
                    return PopupMenuButton(
                      padding: EdgeInsets.zero,
                      tooltip:
                          'Chọn mã quốc gia, '
                          'Hiện là ${_loginPageCtr.selectedCountryCodeId.cname}, '
                          '+${_loginPageCtr.selectedCountryCodeId.countryId}',
                      onSelected: (item) {
                        _loginPageCtr.selectedCountryCodeId = item;
                        (context as Element).markNeedsBuild();
                      },
                      initialValue: _loginPageCtr.selectedCountryCodeId,
                      itemBuilder: (_) => Login.dialPrefix.map((item) {
                        return PopupMenuItem(
                          value: item,
                          child: Row(
                            children: [
                              Text(item.cname),
                              const Spacer(),
                              Text("+${item.countryId}"),
                            ],
                          ),
                        );
                      }).toList(),
                      child: Row(
                        children: [
                          Icon(
                            Icons.phone,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "+${_loginPageCtr.selectedCountryCodeId.countryId}",
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(width: 6),
                SizedBox(
                  height: 24,
                  child: VerticalDivider(
                    color: theme.colorScheme.outline.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: TextField(
                    controller: _loginPageCtr.telTextController,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: 'Số điện thoại',
                      suffixIcon: IconButton(
                        onPressed: _loginPageCtr.telTextController.clear,
                        icon: const Icon(Icons.clear),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: DecoratedBox(
            decoration: UnderlineTabIndicator(
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _loginPageCtr.smsCodeTextController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.sms_outlined),
                      border: InputBorder.none,
                      labelText: 'Mã xác minh',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                ),
                Obx(
                  () => TextButton.icon(
                    onPressed: _loginPageCtr.smsSendCooldown > 0
                        ? null
                        : _loginPageCtr.sendSmsCode,
                    icon: const Icon(Icons.send),
                    label: Text(
                      _loginPageCtr.smsSendCooldown > 0
                          ? 'Chờ ${_loginPageCtr.smsSendCooldown} giây'
                          : 'Lấy mã xác minh',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          onPressed: _loginPageCtr.loginBySmsCode,
          icon: const Icon(Icons.login),
          label: const Text('Đăng nhập'),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Số điện thoại chỉ dùng cho giao diện gửi mã xác minh và đăng nhập chính thức của bilibili, không lưu;\n'
            'Cục bộ chỉ lưu thông tin đăng nhập.\n'
            'Hãy tải và cài đặt từ kho mã nguồn mở của ${Constants.appName} hoặc các nguồn đáng tin cậy.',
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall!.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ),
      ],
    );
  }

  late EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    padding =
        MediaQuery.viewPaddingOf(context).copyWith(top: 0) +
        const EdgeInsets.only(bottom: 25);
    final isLandscape = !MediaQuery.sizeOf(context).isPortrait;
    return SimpleScaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Đóng',
          icon: const Icon(Icons.close_outlined),
          onPressed: Get.back,
        ),
        title: Row(
          children: [
            const Text('Đăng nhập'),
            if (isLandscape)
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TabBar(
                    isScrollable: true,
                    dividerHeight: 0,
                    tabs: const [
                      Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [Icon(Icons.password), Text(' Mật khẩu')],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [Icon(Icons.sms_outlined), Text(' SMS')],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [Icon(Icons.qr_code), Text(' Quét mã')],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.cookie_outlined),
                            Text(' Cookie'),
                          ],
                        ),
                      ),
                    ],
                    controller: _loginPageCtr.tabController,
                  ),
                ),
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (!isLandscape)
            TabBar(
              tabs: const [
                Tab(icon: Icon(Icons.password), text: 'Mật khẩu'),
                Tab(icon: Icon(Icons.sms_outlined), text: 'SMS'),
                Tab(icon: Icon(Icons.qr_code), text: 'Quét mã'),
                Tab(icon: Icon(Icons.cookie_outlined), text: 'Cookie'),
              ],
              controller: _loginPageCtr.tabController,
            ),
          Expanded(
            child: NotificationListener<ScrollStartNotification>(
              onNotification: (notification) {
                if (notification.metrics.axis == Axis.horizontal) {
                  FocusScope.of(context).unfocus();
                }
                return false;
              },
              child: ViewInsetsSafeArea(
                child: tabBarView(
                  controller: _loginPageCtr.tabController,
                  children: [
                    tabViewOuter(loginByPassword(theme)),
                    tabViewOuter(loginBySmS(theme)),
                    tabViewOuter(loginByQRCode(theme)),
                    tabViewOuter(loginByCookie(theme)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget tabViewOuter(Widget child) {
    return SingleChildScrollView(
      padding: padding,
      child: child.constraintWidth(),
    );
  }
}
