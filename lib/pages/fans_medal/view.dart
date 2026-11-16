import 'package:PiliPlus/common/widgets/flutter/refresh_indicator.dart';
import 'package:PiliPlus/common/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/common/widgets/loading_widget/loading_widget.dart';
import 'package:PiliPlus/common/widgets/view_sliver_safe_area.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models_new/live/live_fans_medal/item.dart';
import 'package:PiliPlus/pages/fans_medal/controller.dart';
import 'package:PiliPlus/pages/fans_medal/medal_setting_mixin.dart';
import 'package:PiliPlus/pages/member/widget/medal_widget.dart';
import 'package:PiliPlus/utils/bili_colors.dart';
import 'package:PiliPlus/utils/extension/get_ext.dart';
import 'package:PiliPlus/utils/extension/theme_ext.dart';
import 'package:PiliPlus/utils/num_utils.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

const _kMedalAlign = Alignment(-0.7, 0);
const _kBtnBorderRadius = BorderRadius.all(.circular(4));
const _kBtnPadding = EdgeInsets.symmetric(horizontal: 3, vertical: 2);

class FansMedalPage extends StatefulWidget {
  const FansMedalPage({super.key});

  @override
  State<FansMedalPage> createState() => _FansMedalPageState();
}

class _FansMedalPageState extends State<FansMedalPage> with MedalSettingMixin {
  late final FansMedalController _controller;
  @override
  FansMedalController get medalController => _controller;
  late ColorScheme colorScheme;

  @override
  void initState() {
    super.initState();
    _controller = Get.putOrFind(FansMedalController.new);
    if (_controller.loadingState.value is Loading) {
      _controller.queryData();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    colorScheme = .of(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          final count = _controller.count.value;
          return Text('Huy hiệu fan${count != null ? '($count)' : ''}');
        }),
        actions: [
          IconButton(
            tooltip: 'Cài đặt hiển thị',
            onPressed: showMedalSettingDialog,
            icon: const Icon(Icons.settings),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: refreshIndicator(
        onRefresh: _controller.onRefresh,
        child: CustomScrollView(
          slivers: [
            ViewSliverSafeArea(
              sliver: Obx(() => _buildBody(_controller.loadingState.value)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(LoadingState<List<FansMedalItem>?> state) {
    return switch (state) {
      Loading() => linearLoading,
      Success(:final response) =>
        response != null && response.isNotEmpty
            ? SliverList.builder(
                itemCount: response.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _header();
                  }

                  if (index == response.length) {
                    _controller.onLoadMore();
                  }

                  final item = response[index - 1];
                  return _buildItem(index, item);
                },
              )
            : HttpError(onReload: _controller.onReload),
      Error(:final errMsg) => HttpError(
        errMsg: errMsg,
        onReload: _controller.onReload,
      ),
    };
  }

  Widget _buildItem(int index, FansMedalItem item) {
    final medal = item.medal;
    final isWearing = medal.wearingStatus == 1;
    final medalWidget = MedalWidget.fromMedalInfo(
      medal: item.uinfoMedal,
      padding: const .symmetric(horizontal: 6, vertical: 4),
    );
    const strutStyle = StrutStyle(leading: 0, height: 1, fontSize: 12);
    final child = Padding(
      padding: const .symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Align(alignment: _kMedalAlign, child: medalWidget),
          ),
          Expanded(
            flex: 6,
            child: GestureDetector(
              behavior: .translucent,
              onTap: () => Get.toNamed(
                '/member?mid=${item.uinfoMedal.ruid}',
              ),
              child: Padding(
                padding: const .symmetric(vertical: 12),
                child: Text(
                  item.anchorInfo.nickName,
                  maxLines: 1,
                  overflow: .ellipsis,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              '${medal.intimacy}/${NumUtils.numFormat(medal.nextIntimacy)}',
              style: TextStyle(fontSize: 13, color: colorScheme.outline),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              '${medal.todayFeed}/${NumUtils.numFormat(medal.dayLimit)}',
              style: TextStyle(fontSize: 13, color: colorScheme.outline),
            ),
          ),
          Expanded(
            flex: 5,
            child: isWearing
                ? Align(
                    alignment: .centerLeft,
                    child: GestureDetector(
                      onTap: () => _controller.onTakeOff(item),
                      behavior: .translucent,
                      child: Container(
                        padding: _kBtnPadding,
                        decoration: BoxDecoration(
                          borderRadius: _kBtnBorderRadius,
                          border: .all(
                            color: BiliColors.linkBlue.withValues(alpha: 0.6),
                          ),
                        ),
                        child: const Text(
                          'Bỏ đeo',
                          style: TextStyle(
                            height: 1,
                            fontSize: 12,
                            color: BiliColors.linkBlue,
                          ),
                          strutStyle: strutStyle,
                        ),
                      ),
                    ),
                  )
                : Row(
                    spacing: 8,
                    mainAxisSize: .min,
                    children: [
                      GestureDetector(
                        onTap: () => _controller.onWear(item),
                        behavior: .translucent,
                        child: Container(
                          padding: _kBtnPadding,
                          decoration: BoxDecoration(
                            borderRadius: _kBtnBorderRadius,
                            border: .all(
                              color: BiliColors.linkPurple.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                          child: const Text(
                            'Đeo',
                            style: TextStyle(
                              height: 1,
                              fontSize: 12,
                              color: BiliColors.linkPurple,
                            ),
                            strutStyle: strutStyle,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _onDel(item, medalWidget),
                        behavior: .translucent,
                        child: Container(
                          padding: _kBtnPadding,
                          decoration: BoxDecoration(
                            borderRadius: _kBtnBorderRadius,
                            border: .all(
                              color: BiliColors.linkOrange.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                          child: const Text(
                            'Xóa',
                            style: TextStyle(
                              height: 1,
                              fontSize: 12,
                              color: BiliColors.linkOrange,
                            ),
                            strutStyle: strutStyle,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
    if (index.isOdd) {
      return ColoredBox(
        color: colorScheme.isDark
            ? colorScheme.surfaceContainerHigh
            : colorScheme.surfaceContainer,
        child: child,
      );
    }
    return child;
  }

  Widget _header() {
    return DefaultTextStyle(
      style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
      child: const Padding(
        padding: .fromLTRB(12, 0, 12, 10),
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Align(alignment: _kMedalAlign, child: Text('Huy hiệu')),
            ),
            Expanded(flex: 6, child: Text('Tên streamer')),
            Expanded(flex: 3, child: Text('Tích lũy')),
            Expanded(flex: 3, child: Text('Nhận được')),
            Expanded(flex: 5, child: Text('Thao tác')),
          ],
        ),
      ),
    );
  }

  void _onDel(FansMedalItem item, MedalWidget medalWidget) {
    bool checked = false;
    showDialog(
      context: context,
      builder: (context) {
        final colorScheme = ColorScheme.of(context);
        final descStyle = TextStyle(
          fontSize: 13,
          color: colorScheme.onSurfaceVariant,
        );
        final color = checked ? colorScheme.primary : colorScheme.outline;
        return AlertDialog(
          title: const Text('Lưu ý khi xóa huy hiệu fan'),
          content: Column(
            spacing: 10,
            mainAxisSize: .min,
            crossAxisAlignment: .start,
            children: [
              Row(
                children: [
                  Text('Huy hiệu fan:  ', style: descStyle),
                  medalWidget,
                  const SizedBox(width: 12),
                  Text('Streamer:  ', style: descStyle),
                  Text(
                    item.anchorInfo.nickName,
                    style: const TextStyle(
                      fontWeight: .bold,
                    ),
                  ),
                ],
              ),
              Text(
                'Sau khi xác nhận xóa, huy hiệu fan này sẽ bị xóa khỏi 「Huy hiệu của tôi」, toàn bộ tiến độ thăng cấp của huy hiệu sẽ bị đặt về 0, đồng thời bạn sẽ mất mọi quyền lợi hiện có liên quan đến huy hiệu này, bao gồm quà đặc quyền, bảng xếp hạng, v.v. Sau khi xóa không thể khôi phục. Vui lòng tích chọn lưu ý, đọc trong 10 giây và thao tác cẩn thận.',
                style: descStyle,
              ),
              GestureDetector(
                behavior: .translucent,
                onTap: () {
                  checked = !checked;
                  (context as Element).markNeedsBuild();
                },
                child: Row(
                  spacing: 4,
                  mainAxisSize: .min,
                  children: [
                    Icon(
                      size: 20,
                      color: color,
                      checked ? Icons.check_box : Icons.check_box_outline_blank,
                    ),
                    Text('Đã hiểu', style: TextStyle(color: color)),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: Get.back,
              child: Text('Hủy', style: TextStyle(color: colorScheme.outline)),
            ),
            TextButton(
              onPressed: checked
                  ? () => {Get.back(), _showDelSnackbar(item)}
                  : null,
              child: const Text('Xác nhận xóa'),
            ),
          ],
        );
      },
    );
  }

  void _showDelSnackbar(FansMedalItem item) {
    bool cancelled = false;
    final state = ScaffoldMessenger.of(context);
    final ctr = state.showSnackBar(
      SnackBar(
        persist: false,
        showCloseIcon: true,
        content: const Text('Sắp xóa'),
        backgroundColor: colorScheme.onInverseSurface,
        action: SnackBarAction(
          label: 'Hủy xóa',
          textColor: colorScheme.onSecondaryContainer,
          backgroundColor: colorScheme.secondaryContainer,
          onPressed: () {
            cancelled = true;
            state.hideCurrentSnackBar();
          },
        ),
      ),
    );
    ctr.completer.future.whenComplete(() {
      if (cancelled) return;
      _controller.onDel(item);
    });
  }
}
