// mpv --hwdec=help
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kDebugMode;

enum HwDecType {
  no('no', 'Bật giải mã phần mềm'),
  auto('auto', 'Bật bất kỳ bộ giải mã khả dụng nào'),
  autoSafe('auto-safe', 'Bật bộ giải mã tốt nhất'),
  autoCopy('auto-copy', 'Bật bộ giải mã tốt nhất có chức năng sao chép'),
  d3d12va('d3d12va', 'DirectX 12 (Windows 10 trở lên)'),
  d3d12vaCopy('d3d12va-copy', 'DirectX 12 (Windows 10 trở lên) (không truyền thẳng)'),
  d3d11va('d3d11va', 'DirectX 11 (Windows 8 trở lên)'),
  d3d11vaCopy('d3d11va-copy', 'DirectX 11 (Windows 8 trở lên) (không truyền thẳng)'),
  dxva2('dxva2', 'DXVA2 (Windows 7 trở lên)'),
  dxva2Copy('dxva2-copy', 'DXVA2 (Windows 7 trở lên) (không truyền thẳng)'),
  videotoolbox('videotoolbox', 'VideoToolbox (macOS / iOS)'),
  videotoolboxCopy('videotoolbox-copy', 'VideoToolbox (macOS / iOS) (không truyền thẳng)'),
  vaapi('vaapi', 'VAAPI (Linux)'),
  vaapiCopy('vaapi-copy', 'VAAPI (Linux) (không truyền thẳng)'),
  nvdec('nvdec', 'NVDEC (chỉ NVIDIA)'),
  nvdecCopy('nvdec-copy', 'NVDEC (chỉ NVIDIA) (không truyền thẳng)'),
  drm('drm', 'DRM (Linux)'),
  drmCopy('drm-copy', 'DRM (Linux) (không truyền thẳng)'),
  vulkan('vulkan', 'Vulkan (mọi nền tảng) (thử nghiệm)'),
  vulkanCopy('vulkan-copy', 'Vulkan (mọi nền tảng) (thử nghiệm) (không truyền thẳng)'),
  vdpau('vdpau', 'VDPAU (Linux)'),
  vdpauCopy('vdpau-copy', 'VDPAU (Linux) (không truyền thẳng)'),
  mediacodec('mediacodec', 'MediaCodec (Android)'),
  mediacodecCopy('mediacodec-copy', 'MediaCodec (Android) (không truyền thẳng)'),
  cuda('cuda', 'CUDA (chỉ NVIDIA) (lỗi thời)'),
  cudaCopy('cuda-copy', 'CUDA (chỉ NVIDIA) (lỗi thời) (không truyền thẳng)'),
  crystalhd('crystalhd', 'CrystalHD (mọi nền tảng) (lỗi thời)'),
  rkmpp('rkmpp', 'Rockchip MPP (chỉ một số chip Rockchip)'),
  amf('amf', 'AMF (chỉ AMD)'),
  amfCopy('amf-copy', 'AMF (chỉ AMD) (không truyền thẳng)'),
  qsv('qsv', 'Quick Sync Video (chỉ Intel)'),
  qsvCopy('qsv-copy', 'Quick Sync Video (chỉ Intel) (không truyền thẳng)'),
  ;

  final String hwdec;
  final String desc;
  const HwDecType(this.hwdec, this.desc);

  static final String kHwdec = Platform.isAndroid
      ? kDebugMode
            ? autoSafe.hwdec
            : [mediacodec.hwdec, autoSafe.hwdec].join(',')
      : auto.hwdec;
}
