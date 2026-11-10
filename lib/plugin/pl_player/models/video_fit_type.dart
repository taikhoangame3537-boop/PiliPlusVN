import 'package:PiliPlus/common/style.dart';
import 'package:material_ui/material_ui.dart' show BoxFit;

enum VideoFitType {
  fill('Kéo giãn', boxFit: BoxFit.fill),
  contain('Tự động', boxFit: BoxFit.contain),
  cover('Cắt', boxFit: BoxFit.cover),
  fitWidth('Cùng chiều rộng', boxFit: BoxFit.fitWidth),
  fitHeight('Cùng chiều cao', boxFit: BoxFit.fitHeight),
  none('Gốc', boxFit: BoxFit.none),
  scaleDown('Giới hạn', boxFit: BoxFit.scaleDown),
  ratio_4x3('4:3', aspectRatio: 4 / 3),
  ratio_16x9('16:9', aspectRatio: Style.aspectRatio16x9),
  ;

  final String desc;
  final BoxFit boxFit;
  final double? aspectRatio;
  const VideoFitType(
    this.desc, {
    this.boxFit = BoxFit.contain,
    this.aspectRatio,
  });
}
