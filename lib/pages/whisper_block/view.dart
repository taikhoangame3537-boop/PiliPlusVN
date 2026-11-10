import 'package:PiliPlus/common/assets.dart';
import 'package:PiliPlus/common/widgets/dialog/dialog.dart';
import 'package:PiliPlus/common/widgets/loading_widget/loading_widget.dart';
import 'package:PiliPlus/common/widgets/scaffold/simple_scaffold.dart';
import 'package:PiliPlus/common/widgets/view_insets_safe_area.dart';
import 'package:PiliPlus/grpc/bilibili/app/im/v1.pb.dart'
    show KeywordBlockingItem;
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/pages/search/widgets/search_text.dart';
import 'package:PiliPlus/pages/whisper_block/controller.dart';
import 'package:flutter/services.dart' show LengthLimitingTextInputFormatter;
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

class WhisperBlockPage extends StatefulWidget {
  const WhisperBlockPage({
    super.key,
  });

  @override
  State<WhisperBlockPage> createState() => _WhisperBlockPageState();
}

class _WhisperBlockPageState extends State<WhisperBlockPage> {
  final _controller = Get.put(WhisperBlockController());

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return SimpleScaffold(
      appBar: AppBar(title: const Text('Từ khóa chặn tin nhắn')),
      body: Obx(() => _buildBody(theme, _controller.loadingState.value)),
    );
  }

  Widget _buildBody(
    ThemeData theme,
    LoadingState<List<KeywordBlockingItem>?> loadingState,
  ) {
    return switch (loadingState) {
      Loading() => m3eLoading,
      Success(:final response) =>
        response != null && response.isNotEmpty
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Bấm vào từ khóa chặn để xóa',
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        if (_controller.listLimit != null)
                          Obx(
                            () => Text(
                              '${_controller.count.value}/${_controller.listLimit}',
                              style: TextStyle(
                                fontSize: 13,
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(12),
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: response
                            .map(
                              (e) => SearchText(
                                text: e.keyword,
                                onTap: (keyword) {
                                  showConfirmDialog(
                                    context: context,
                                    title: const Text('Xóa từ khóa chặn?'),
                                    content: const Text('Từ khóa chặn này sẽ không còn hiệu lực'),
                                    onConfirm: () => _controller.onRemove(e),
                                  );
                                },
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 25,
                      right: 25,
                      bottom: MediaQuery.viewPaddingOf(context).bottom + 10,
                    ),
                    child: FilledButton.tonal(
                      onPressed: _onAdd,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Icon(Icons.add, size: 22), Text('Thêm từ khóa chặn tin nhắn')],
                      ),
                    ),
                  ),
                ],
              )
            : Align(
                alignment: const Alignment(0, -0.5),
                child: Column(
                  spacing: 6,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(Assets.error, height: 156),
                    const Text(
                      'Chưa thêm từ khóa chặn',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text('Sau khi thêm, sẽ không nhận tin nhắn chứa từ khóa chặn'),
                    FilledButton.tonal(
                      onPressed: _onAdd,
                      style: FilledButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, size: 22),
                          Text('Thêm'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      Error(:final errMsg) => scrollErrorWidget(
        errMsg: errMsg,
        onReload: _controller.onReload,
      ),
    };
  }

  void _onAdd() {
    String keyword = '';
    showModalBottomSheet(
      context: context,
      enableDrag: false,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) {
        final theme = Theme.of(context);
        return Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12) +
              EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
          child: ViewInsetsSafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Thêm từ khóa chặn tin nhắn',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: Get.back,
                      behavior: HitTestBehavior.opaque,
                      child: Icon(
                        Icons.clear,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  autofocus: true,
                  maxLength: _controller.charLimit,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Vui lòng nhập',
                    visualDensity: .standard,
                    hintStyle: const TextStyle(fontSize: 14),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    border: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(Radius.circular(25)),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.onInverseSurface,
                  ),
                  onChanged: (value) => keyword = value,
                  inputFormatters: [LengthLimitingTextInputFormatter(20)],
                ),
                const SizedBox(height: 12),
                FilledButton.tonal(
                  onPressed: () {
                    if (keyword.isNotEmpty) {
                      _controller.onAdd(keyword);
                    }
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Icon(Icons.add, size: 22), Text('Thêm từ khóa chặn tin nhắn')],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
