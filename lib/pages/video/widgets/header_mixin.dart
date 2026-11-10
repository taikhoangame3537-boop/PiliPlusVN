import 'package:PiliPlus/common/widgets/button/icon_button.dart';
import 'package:PiliPlus/pages/video/introduction/ugc/widgets/menu_row.dart';
import 'package:PiliPlus/plugin/pl_player/controller.dart';
import 'package:PiliPlus/plugin/pl_player/utils/danmaku_options.dart';
import 'package:PiliPlus/utils/extension/num_ext.dart';
import 'package:PiliPlus/utils/page_utils.dart';
import 'package:PiliPlus/utils/theme_utils.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

mixin HeaderMixin<T extends StatefulWidget> on State<T> {
  PlPlayerController get plPlayerController;

  bool get isFullScreen => plPlayerController.isFullScreen.value;

  ThemeData? get theme {
    if (plPlayerController.darkVideoPage) {
      return ThemeUtils.darkTheme;
    }
    return null;
  }

  Future<void>? showBottomSheet(
    StatefulWidgetBuilder builder, {
    ValueGetter<EdgeInsets>? padding,
  }) {
    final theme = this.theme;
    return PageUtils.showVideoBottomSheet(
      context,
      maxWidth: 512,
      padding: padding,
      child: theme != null
          ? Theme(
              data: theme,
              child: StatefulBuilder(builder: builder),
            )
          : StatefulBuilder(builder: builder),
    );
  }

  Widget resetBtn(ThemeData theme, Object def, VoidCallback onPressed) {
    return iconButton(
      tooltip: 'Giá trị mặc định: $def',
      icon: const Icon(Icons.refresh),
      onPressed: onPressed,
      iconColor: theme.colorScheme.outline,
      size: 24,
      iconSize: 24,
    );
  }

  /// 弹幕功能
  void showSetDanmaku({bool isLive = false}) {
    // 屏蔽类型
    const blockTypesList = [
      (value: 2, label: 'Cuộn'),
      (value: 5, label: 'Trên cùng'),
      (value: 4, label: 'Dưới'),
      (value: 6, label: 'Màu'),
      (value: 7, label: 'Nâng cao'),
    ];

    final danmakuController = plPlayerController.danmakuController;

    final isFullScreen = this.isFullScreen;

    showBottomSheet(
      (context, setState) {
        final theme = Theme.of(context);

        void setOptions() => danmakuController?.updateOption(
          DanmakuOptions.get(
            notFullscreen: !isFullScreen,
            speed: plPlayerController.playbackSpeed,
          ),
        );

        const EdgeInsets sliderPadding = .symmetric(vertical: 16);

        final sliderTheme = SliderThemeData(
          trackHeight: 10,
          padding: const .symmetric(horizontal: 6),
          trackShape: const MSliderTrackShape(),
          thumbColor: theme.colorScheme.primary,
          activeTrackColor: theme.colorScheme.primary,
          inactiveTrackColor: theme.colorScheme.onInverseSurface,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
        );

        void updateLineHeight(double val) {
          DanmakuOptions.danmakuLineHeight = val.toPrecision(1);
          setState(() {});
          setOptions();
        }

        void updateDuration(double val) {
          DanmakuOptions.danmakuDuration = val.toPrecision(1);
          setState(() {});
          setOptions();
        }

        void updateStaticDuration(double val) {
          DanmakuOptions.danmakuStaticDuration = val.toPrecision(1);
          setState(() {});
          setOptions();
        }

        void updateFontSizeFS(double val) {
          DanmakuOptions.danmakuFontScaleFS = val.toPrecision(2);
          setState(() {});
          if (isFullScreen) {
            setOptions();
          }
        }

        void updateFontSize(double val) {
          DanmakuOptions.danmakuFontScale = val.toPrecision(2);
          setState(() {});
          if (!isFullScreen) {
            setOptions();
          }
        }

        void updateStrokeWidth(double val) {
          DanmakuOptions.danmakuStrokeWidth = val;
          setState(() {});
          setOptions();
        }

        void updateFontWeight(double val) {
          DanmakuOptions.danmakuFontWeight = val.toInt();
          setState(() {});
          setOptions();
        }

        void updateOpacity(double val) {
          plPlayerController.danmakuOpacity.value = val.toPrecision(2);
          setState(() {});
        }

        void updateShowArea(double val) {
          DanmakuOptions.danmakuShowArea = val.toPrecision(1);
          setState(() {});
          setOptions();
        }

        void updateDanmakuWeight(double val) {
          DanmakuOptions.danmakuWeight = val.toInt();
          setState(() {});
        }

        void onUpdateBlockType(int blockType, bool blocked) {
          if (blocked) {
            DanmakuOptions.blockTypes.remove(blockType);
          } else {
            DanmakuOptions.blockTypes.add(blockType);
          }
          DanmakuOptions.blockColorful = DanmakuOptions.blockTypes.contains(6);
          setState(() {});
          setOptions();
        }

        return Padding(
          padding: const EdgeInsets.all(12),
          child: Material(
            clipBehavior: Clip.hardEdge,
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: SliderTheme(
                data: sliderTheme,
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    const SizedBox(
                      height: 45,
                      child: Center(
                        child: Text('Cài đặt danmaku', style: TextStyle(fontSize: 14)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (!isLive) ...[
                      Row(
                        mainAxisAlignment: .spaceBetween,
                        children: [
                          Text('Chặn đám mây thông minh cấp ${DanmakuOptions.danmakuWeight}'),
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () => Get
                              ..back()
                              ..toNamed(
                                '/danmakuBlock',
                                arguments: plPlayerController,
                              ),
                            child: Text(
                              "Quản lý chặn(${plPlayerController.filters.count})",
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: sliderPadding,
                        child: Slider(
                          min: 0,
                          max: 11,
                          value: DanmakuOptions.danmakuWeight.toDouble(),
                          divisions: 11,
                          label: DanmakuOptions.danmakuWeight.toString(),
                          onChanged: updateDanmakuWeight,
                        ),
                      ),
                    ],
                    const Text('Chặn theo loại'),
                    SingleChildScrollView(
                      scrollDirection: .horizontal,
                      padding: const .symmetric(vertical: 10),
                      child: Row(
                        spacing: 10,
                        children: blockTypesList.map(
                          (e) {
                            final blocked = DanmakuOptions.blockTypes.contains(
                              e.value,
                            );
                            return ActionRowLineItem(
                              onTap: () => onUpdateBlockType(e.value, blocked),
                              text: e.label,
                              selectStatus: blocked,
                            );
                          },
                        ).toList(),
                      ),
                    ),
                    const Text('Khác'),
                    SingleChildScrollView(
                      scrollDirection: .horizontal,
                      padding: const .symmetric(vertical: 10),
                      child: Row(
                        spacing: 10,
                        children: [
                          ActionRowLineItem(
                            selectStatus: DanmakuOptions.danmakuMassiveMode,
                            onTap: () {
                              DanmakuOptions.danmakuMassiveMode =
                                  !DanmakuOptions.danmakuMassiveMode;
                              setState(() {});
                              setOptions();
                            },
                            text: 'Danmaku số lượng lớn',
                          ),
                          ActionRowLineItem(
                            selectStatus: DanmakuOptions.danmakuStatic2Scroll,
                            onTap: () {
                              DanmakuOptions.danmakuStatic2Scroll =
                                  !DanmakuOptions.danmakuStatic2Scroll;
                              setState(() {});
                              setOptions();
                            },
                            text: 'Cố định thành cuộn',
                          ),
                          ActionRowLineItem(
                            selectStatus: DanmakuOptions.danmakuFixedV,
                            onTap: () {
                              DanmakuOptions.danmakuFixedV =
                                  !DanmakuOptions.danmakuFixedV;
                              setState(() {});
                              setOptions();
                            },
                            text: 'Danmaku cuộn tốc độ cố định',
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Vùng hiển thị ${(DanmakuOptions.danmakuShowArea * 100).toStringAsFixed(1)}%',
                        ),
                        resetBtn(theme, '50.0%', () => updateShowArea(0.5)),
                      ],
                    ),
                    Padding(
                      padding: sliderPadding,
                      child: Slider(
                        min: 0.1,
                        max: 1,
                        value: DanmakuOptions.danmakuShowArea,
                        divisions: 9,
                        label: '${DanmakuOptions.danmakuShowArea * 100}%',
                        onChanged: updateShowArea,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Độ mờ ${(plPlayerController.danmakuOpacity * 100).toStringAsFixed(1)}%',
                        ),
                        resetBtn(theme, '100.0%', () => updateOpacity(1.0)),
                      ],
                    ),
                    Padding(
                      padding: sliderPadding,
                      child: Slider(
                        min: 0,
                        max: 1,
                        value: plPlayerController.danmakuOpacity.value,
                        divisions: 100,
                        label:
                            '${(plPlayerController.danmakuOpacity * 100).toStringAsFixed(1)}%',
                        onChanged: updateOpacity,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Độ đậm chữ ${DanmakuOptions.danmakuFontWeight + 1} (có thể không chỉnh chính xác)',
                        ),
                        resetBtn(theme, 6, () => updateFontWeight(5)),
                      ],
                    ),
                    Padding(
                      padding: sliderPadding,
                      child: Slider(
                        min: 0,
                        max: 8,
                        value: DanmakuOptions.danmakuFontWeight.toDouble(),
                        divisions: 8,
                        label: '${DanmakuOptions.danmakuFontWeight + 1}',
                        onChanged: updateFontWeight,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Độ dày viền ${DanmakuOptions.danmakuStrokeWidth}'),
                        resetBtn(theme, 1.5, () => updateStrokeWidth(1.5)),
                      ],
                    ),
                    Padding(
                      padding: sliderPadding,
                      child: Slider(
                        min: 0,
                        max: 5,
                        value: DanmakuOptions.danmakuStrokeWidth,
                        divisions: 10,
                        label: DanmakuOptions.danmakuStrokeWidth.toString(),
                        onChanged: updateStrokeWidth,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Cỡ chữ ${(DanmakuOptions.danmakuFontScale * 100).toStringAsFixed(1)}%',
                        ),
                        resetBtn(theme, '100.0%', () => updateFontSize(1.0)),
                      ],
                    ),
                    Padding(
                      padding: sliderPadding,
                      child: Slider(
                        min: 0.5,
                        max: 2.5,
                        value: DanmakuOptions.danmakuFontScale,
                        divisions: 200,
                        label:
                            '${(DanmakuOptions.danmakuFontScale * 100).toStringAsFixed(1)}%',
                        onChanged: updateFontSize,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Cỡ chữ toàn màn hình ${(DanmakuOptions.danmakuFontScaleFS * 100).toStringAsFixed(1)}%',
                        ),
                        resetBtn(theme, '120.0%', () => updateFontSizeFS(1.2)),
                      ],
                    ),
                    Padding(
                      padding: sliderPadding,
                      child: Slider(
                        min: 0.5,
                        max: 2.5,
                        value: DanmakuOptions.danmakuFontScaleFS,
                        divisions: 200,
                        label:
                            '${(DanmakuOptions.danmakuFontScaleFS * 100).toStringAsFixed(1)}%',
                        onChanged: updateFontSizeFS,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Thời lượng danmaku cuộn ${DanmakuOptions.danmakuDuration} giây'),
                        resetBtn(theme, 7.0, () => updateDuration(7.0)),
                      ],
                    ),
                    Padding(
                      padding: sliderPadding,
                      child: Slider(
                        min: 1,
                        max: 50,
                        value: DanmakuOptions.danmakuDuration,
                        divisions: 49,
                        label: DanmakuOptions.danmakuDuration.toString(),
                        onChanged: updateDuration,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Thời lượng danmaku tĩnh ${DanmakuOptions.danmakuStaticDuration} giây',
                        ),
                        resetBtn(theme, 4.0, () => updateStaticDuration(4.0)),
                      ],
                    ),
                    Padding(
                      padding: sliderPadding,
                      child: Slider(
                        min: 1,
                        max: 50,
                        value: DanmakuOptions.danmakuStaticDuration,
                        divisions: 49,
                        label: DanmakuOptions.danmakuStaticDuration.toString(),
                        onChanged: updateStaticDuration,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Chiều cao dòng danmaku ${DanmakuOptions.danmakuLineHeight}'),
                        resetBtn(theme, 1.6, () => updateLineHeight(1.6)),
                      ],
                    ),
                    Padding(
                      padding: sliderPadding,
                      child: Slider(
                        min: 1.0,
                        max: 3.0,
                        value: DanmakuOptions.danmakuLineHeight,
                        onChanged: updateLineHeight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    )?.whenComplete(
      () => DanmakuOptions.save(plPlayerController.danmakuOpacity.value),
    );
  }
}

class MSliderTrackShape extends RoundedRectSliderTrackShape {
  const MSliderTrackShape();

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    SliderThemeData? sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    const double trackHeight = 3;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
