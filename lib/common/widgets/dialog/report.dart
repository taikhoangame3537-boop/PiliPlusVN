import 'package:PiliPlus/common/widgets/button/icon_button.dart';
import 'package:PiliPlus/common/widgets/radio_widget.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/utils/extension/string_ext.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:material_ui/material_ui.dart';

typedef ReasonCheck = bool Function(int? reasonType);

bool _kReportCheck(int? reasonType) => reasonType == 0;

typedef OnReport = Future<LoadingState> Function(
  int reasonType,
  String? reasonDesc,
  bool banUid,
);

Future<void> autoWrapReportDialog(
  BuildContext context,
  Map<String, Map<int, String>> options,
  OnReport onReport, {
  ValueGetter<int>? mid,
  VoidCallback? onRemove,
  String? reportUrl,
  ReasonCheck withContent = _kReportCheck,
  ReasonCheck contentRequired = _kReportCheck,
}) {
  int? reasonType;
  String? reasonDesc;
  bool banUid = false;
  late final key = GlobalKey<FormFieldState<String>>();

  bool isWithContent = withContent(reasonType);
  bool isContentRequired = contentRequired(reasonType);

  void updateReasonType(int? value) {
    reasonType = value;
    isWithContent = withContent(reasonType);
    isContentRequired = contentRequired(reasonType);
    if (isWithContent) {
      key.currentState?.clearError();
    }
  }

  Widget title = const Text('Báo cáo');
  if (reportUrl != null) {
    title = Row(
      mainAxisAlignment: .spaceBetween,
      children: [
        title,
        iconButton(
          iconSize: 21,
          tooltip: 'Báo cáo qua web',
          onPressed: () =>
              Get.toNamed('/webview', parameters: {'url': reportUrl}),
          icon: const Icon(MdiIcons.web, size: 22),
        ),
      ],
    );
  }

  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: title,
      titlePadding: const .only(left: 22, top: 16, right: 22),
      contentPadding: const .symmetric(vertical: 5),
      actionsPadding: const .only(left: 16, right: 16, bottom: 10),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: SingleChildScrollView(
              child: AnimatedSize(
                duration: const Duration(milliseconds: 200),
                child: Builder(
                  builder: (context) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: .only(left: 22, right: 22, bottom: 5),
                        child: Text('Vui lòng chọn lý do báo cáo:'),
                      ),
                      RadioGroup(
                        onChanged: (value) {
                          updateReasonType(value);
                          (context as Element).markNeedsBuild();
                        },
                        groupValue: reasonType,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: options.entries.map((entry) {
                            return WrapRadioOptionsGroup<int>(
                              groupTitle: entry.key,
                              options: entry.value,
                            );
                          }).toList(),
                        ),
                      ),
                      if (isWithContent)
                        Padding(
                          padding: const .only(left: 22, top: 5, right: 22),
                          child: TextFormField(
                            key: key,
                            minLines: 2,
                            maxLines: 4,
                            initialValue: reasonDesc,
                            autofocus: isContentRequired,
                            decoration: const InputDecoration(
                              labelText: 'Để giúp người duyệt xử lý nhanh hơn, vui lòng bổ sung loại vấn đề và vị trí xuất hiện',
                              border: OutlineInputBorder(),
                              contentPadding: .all(10),
                              labelStyle: TextStyle(fontSize: 14),
                              floatingLabelStyle: TextStyle(fontSize: 14),
                            ),
                            onChanged: (value) => reasonDesc = value,
                            validator: (value) =>
                                isContentRequired && value.isNullOrEmpty
                                ? 'Lý do không được để trống'
                                : null,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (mid != null)
            Padding(
              padding: const EdgeInsets.only(left: 14, top: 6),
              child: CheckBoxText(
                text: 'Chặn người dùng này',
                onChanged: (value) => banUid = value,
              ),
            ),
        ],
      ),
      actions: [
        if (mid != null)
          TextButton(
            onPressed: () {
              Get.back();
              Pref.setBlackMid(mid());
              onRemove?.call();
            },
            child: const Text('Chặn cục bộ'),
          ),
        TextButton(
          onPressed: Get.back,
          child: Text(
            'Hủy',
            style: TextStyle(color: ColorScheme.of(context).outline),
          ),
        ),
        TextButton(
          onPressed: () async {
            if (reasonType == null ||
                (isContentRequired && key.currentState?.validate() != true)) {
              return;
            }
            SmartDialog.showLoading();
            try {
              final res = await onReport(
                reasonType!,
                isWithContent ? reasonDesc : null,
                banUid,
              );
              SmartDialog.dismiss();
              if (res.isSuccess) {
                Get.back();
                SmartDialog.showToast('Báo cáo thành công');
              } else {
                res.toast();
              }
            } catch (e, s) {
              SmartDialog.dismiss();
              SmartDialog.showToast('Gửi thất bại: $e');
              Utils.reportError(e, s);
            }
          },
          child: const Text('Đồng ý'),
        ),
      ],
    ),
  );
}

class CheckBoxText extends StatefulWidget {
  final String text;
  final ValueChanged<bool> onChanged;
  final bool selected;

  const CheckBoxText({
    super.key,
    required this.text,
    required this.onChanged,
    this.selected = false,
  });

  @override
  State<CheckBoxText> createState() => _CheckBoxTextState();
}

class _CheckBoxTextState extends State<CheckBoxText> {
  late bool _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    return InkWell(
      onTap: () {
        setState(() {
          _selected = !_selected;
          widget.onChanged(_selected);
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              size: 22,
              _selected
                  ? Icons.check_box_outlined
                  : Icons.check_box_outline_blank,
              color: _selected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
            Text(
              ' ${widget.text}',
              style: TextStyle(color: _selected ? colorScheme.primary : null),
            ),
          ],
        ),
      ),
    );
  }
}

abstract final class ReportOptions {
  // from https://s1.hdslb.com/bfs/seed/jinkela/comment-h5/static/js/605.chunks.js
  static Map<String, Map<int, String>> get commentReport => const {
    'Vi phạm pháp luật': {9: 'Vi phạm pháp luật', 2: 'Khiêu dâm', 10: 'Thô tục', 12: 'Cờ bạc lừa đảo', 23: 'Liên kết ngoài trái pháp luật'},
    'Tin đồn, thông tin sai sự thật': {19: 'Tin đồn chính trị', 22: 'Thông tin giả mạo*', 20: 'Tin đồn sự kiện xã hội'},
    'Xâm phạm quyền lợi cá nhân': {7: 'Công kích cá nhân', 15: 'Xâm phạm quyền riêng tư'},
    'Gây hại môi trường cộng đồng': {
      1: 'Quảng cáo rác',
      4: 'Kích động tranh cãi',
      5: 'Tiết lộ nội dung',
      3: 'Spam',
      8: 'Video không liên quan',
      18: 'Rút thăm trái phép',
      17: 'Thông tin xấu cho thanh thiếu niên',
    },
    'Khác': {0: 'Khác*'},
  };
  static bool withContentReply(int? reasonType) => reasonType != null;
  static bool contentRequiredReply(int? reasonType) =>
      reasonType == 0 || reasonType == 22;

  static Map<String, Map<int, String>> get dynamicReport => const {
    '': {
      4: 'Quảng cáo rác',
      8: 'Kích động tranh cãi',
      1: 'Khiêu dâm',
      5: 'Công kích cá nhân',
      3: 'Thông tin trái pháp luật',
      9: 'Tin đồn chính trị',
      10: 'Tin đồn sự kiện xã hội',
      12: 'Thông tin giả mạo',
      13: 'Liên kết ngoài trái pháp luật',
      0: 'Khác*',
    },
  };

  static Map<String, Map<int, String>> get danmakuReport => const {
    '': {
      1: 'Vi phạm điều cấm',
      2: 'Khiêu dâm, thô tục',
      3: 'Cờ bạc lừa đảo',
      4: 'Công kích cá nhân',
      5: 'Xâm phạm quyền riêng tư',
      6: 'Quảng cáo rác',
      7: 'Kích động tranh cãi',
      8: 'Tiết lộ nội dung',
      9: 'Spam ác ý',
      10: 'Video không liên quan',
      12: 'Thông tin xấu cho thanh thiếu niên',
      13: 'Liên kết ngoài trái pháp luật',
      11: 'Khác*',
    },
  };
  static bool danmakuReportCheck(int? reasonType) => reasonType == 11;

  static Map<String, Map<int, String>> get liveDanmakuReport => const {
    '': {
      1: 'Vi phạm pháp luật',
      2: 'Thô tục, khiêu dâm',
      3: 'Quảng cáo rác',
      4: 'Chửi bới, kích động tranh cãi',
      5: 'Nhạy cảm chính trị',
      6: 'Thông tin xấu cho thanh thiếu niên',
      0: 'Khác',
    },
  };
  static bool liveDanmakuReportCheck(int? _) => false;

  static Map<String, Map<int, String>> get imMsgReport => const {
    '': {
      1: 'Khiêu dâm, thô tục',
      2: 'Nhạy cảm chính trị',
      3: 'Trái pháp luật, có hại',
      4: 'Quảng cáo, quấy rối',
      5: 'Công kích cá nhân',
      6: 'Lừa đảo',
      0: 'Vấn đề khác*',
    },
  };
}
