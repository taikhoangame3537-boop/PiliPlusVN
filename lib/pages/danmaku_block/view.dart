import 'package:PiliPlus/common/widgets/button/icon_button.dart';
import 'package:PiliPlus/common/widgets/dialog/dialog.dart';
import 'package:PiliPlus/common/widgets/keep_alive_wrapper.dart';
import 'package:PiliPlus/common/widgets/loading_widget/loading_widget.dart';
import 'package:PiliPlus/common/widgets/scaffold/simple_scaffold.dart';
import 'package:PiliPlus/common/widgets/scroll_physics.dart' show tabBarView;
import 'package:PiliPlus/models/common/dm_block_type.dart';
import 'package:PiliPlus/models/user/danmaku_block.dart';
import 'package:PiliPlus/models/user/danmaku_rule.dart';
import 'package:PiliPlus/pages/danmaku_block/controller.dart';
import 'package:PiliPlus/plugin/pl_player/controller.dart';
import 'package:PiliPlus/utils/storage.dart';
import 'package:PiliPlus/utils/storage_key.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

class DanmakuBlockPage extends StatefulWidget {
  const DanmakuBlockPage({super.key});

  @override
  State<DanmakuBlockPage> createState() => _DanmakuBlockPageState();
}

class _DanmakuBlockPageState extends State<DanmakuBlockPage> {
  final DanmakuBlockController _controller = Get.put(DanmakuBlockController());
  late PlPlayerController plPlayerController;
  late EdgeInsets padding;

  @override
  void initState() {
    super.initState();
    plPlayerController = Get.arguments as PlPlayerController;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    padding = MediaQuery.viewPaddingOf(context);
  }

  @override
  void dispose() {
    final ruleFilter = RuleFilter.fromRuleTypeEntries(_controller.rules);
    plPlayerController.filters = ruleFilter;
    GStorage.localCache.put(LocalCacheKey.danmakuFilterRules, ruleFilter);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleScaffold(
      appBar: AppBar(title: const Text('Chặn danmaku')),
      body: Column(
        children: [
          TabBar(
            controller: _controller.tabController,
            tabs: DmBlockType.values
                .map(
                  (e) => Obx(
                    () => Tab(
                      text: '${e.label}(${_controller.rules[e.index].length})',
                    ),
                  ),
                )
                .toList(),
          ),
          Expanded(
            child: tabBarView(
              controller: _controller.tabController,
              children: DmBlockType.values
                  .map(
                    (e) => KeepAliveWrapper(
                      child: Obx(
                        () =>
                            tabViewBuilder(e.index, _controller.rules[e.index]),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
      fab: Padding(
        padding: .only(
          right: kFloatingActionButtonMargin + padding.right,
          bottom: kFloatingActionButtonMargin + padding.bottom,
        ),
        child: FloatingActionButton(
          tooltip: 'Thêm',
          onPressed: () => _showAddDialog(
            DmBlockType.values[_controller.tabController.index],
          ),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget tabViewBuilder(int tabIndex, List<SimpleRule> list) {
    if (list.isEmpty) {
      return scrollableError;
    }
    return ListView.builder(
      itemCount: list.length,
      padding: .only(bottom: padding.bottom + 100),
      itemBuilder: (context, itemIndex) {
        final SimpleRule item = list[itemIndex];
        final child = iconButton(
          iconSize: 20,
          tooltip: 'Xóa',
          icon: const Icon(Icons.delete_outlined),
          onPressed: () => showConfirmDialog(
            context: context,
            title: const Text('Xóa quy tắc này?'),
            onConfirm: () => _controller.danmakuFilterDel(
              tabIndex,
              itemIndex,
              item.id,
            ),
          ),
        );
        return ListTile(
          title: Text(
            item.filter,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          trailing: tabIndex == 2
              ? child
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    iconButton(
                      iconSize: 20,
                      tooltip: 'Chỉnh sửa',
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _showAddDialog(
                        DmBlockType.values[_controller.tabController.index],
                        initFilter: item.filter,
                        itemIndex: itemIndex,
                        itemId: item.id,
                      ),
                    ),
                    child,
                  ],
                ),
        );
      },
    );
  }

  void _showAddDialog(
    DmBlockType type, {
    String initFilter = '',
    int? itemIndex,
    int? itemId,
  }) {
    assert((itemIndex == null) == (itemId == null));
    String filter = initFilter;
    final hintText = switch (type) {
      DmBlockType.keyword => 'Nhập từ khóa cần lọc, loại khác vui lòng chuyển tab rồi thêm',
      DmBlockType.regex => '输入//之间的正则表达式，无需包含头尾的"/"',
      DmBlockType.uid => 'Nhập UID người dùng',
    };
    final isUid = type == DmBlockType.uid;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${itemId != null ? "Sửa" : "Thêm"} quy tắc ${type.label}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(hintText),
            TextFormField(
              autofocus: true,
              initialValue: filter,
              onChanged: (value) => filter = value,
              keyboardType: isUid ? TextInputType.number : null,
              inputFormatters: isUid
                  ? [FilteringTextInputFormatter.digitsOnly]
                  : null,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text(
              'Hủy',
              style: TextStyle(color: Theme.of(context).colorScheme.outline),
            ),
          ),
          TextButton(
            child: const Text('Đồng ý'),
            onPressed: () async {
              if (filter != initFilter) {
                Get.back();
                if (itemId != null) {
                  await _controller.danmakuFilterDel(
                    type.index,
                    itemIndex!,
                    itemId,
                  );
                }
                await _controller.danmakuFilterAdd(
                  filter: filter,
                  type: type.index,
                );
              } else {
                SmartDialog.showToast(
                  'Nội dung nhập ${filter.isEmpty ? "không được để trống" : "giống lần trước"}',
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
