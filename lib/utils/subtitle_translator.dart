import 'dart:convert';

import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:dio/dio.dart';

class _Cue {
  _Cue(this.head, this.orig) : text = orig;
  final String head;
  final String orig;
  String text;
}

abstract final class SubtitleTranslator {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 90),
      sendTimeout: const Duration(seconds: 30),
    ),
  );

  static const int _batchSize = 30;
  // số cặp (gốc, đã dịch) của lô trước gửi kèm làm ngữ cảnh cho LLM
  static const int _contextSize = 6;
  static const int _llmAttempts = 2;
  static final RegExp _blankSplit = RegExp(r'\r?\n\r?\n');
  static final RegExp _lineSplit = RegExp(r'\r?\n');
  static final RegExp _viLan = RegExp(
    r'(^|[-_])vi($|[-_])',
    caseSensitive: false,
  );

  /// Track phụ đề đã là tiếng Việt (`vi`, `ai-vi`, `vi-VN`...) thì không dịch nữa.
  static bool isVietnamese(String lan) => _viLan.hasMatch(lan);

  static Future<String> translateVtt(String vtt, {String? title}) async {
    final blocks = vtt.split(_blankSplit);
    final cues = <_Cue>[];
    for (final block in blocks) {
      final lines = block.split(_lineSplit);
      final ti = lines.indexWhere((l) => l.contains('-->'));
      if (ti < 0) continue;
      cues.add(
        _Cue(
          lines.sublist(0, ti + 1).join('\n'),
          lines.sublist(ti + 1).join(' ').trim(),
        ),
      );
    }
    if (cues.isEmpty) return vtt;

    final indexes = <int>[
      for (var i = 0; i < cues.length; i++)
        if (cues[i].text.isNotEmpty) i,
    ];

    final baseUrl = Pref.subtitleLlmBaseUrl.trim();
    final apiKey = Pref.subtitleLlmKey.trim();
    final model = Pref.subtitleLlmModel.trim();
    final useLlm = baseUrl.isNotEmpty && apiKey.isNotEmpty && model.isNotEmpty;
    final videoTitle = title?.trim() ?? '';

    var failed = 0;
    var batches = 0;
    String? lastError;
    for (var start = 0; start < indexes.length; start += _batchSize) {
      batches++;
      final end = (start + _batchSize).clamp(0, indexes.length);
      final slice = indexes.sublist(start, end);
      final texts = [for (final i in slice) cues[i].orig];

      List<String>? out;
      try {
        if (useLlm) {
          // ngữ cảnh: vài dòng ngay trước lô này (gốc + bản dịch)
          final ctx = <Map<String, String>>[
            for (final i in indexes.sublist(
              start > _contextSize ? start - _contextSize : 0,
              start,
            ))
              {'src': cues[i].orig, 'vi': cues[i].text},
          ];
          out = await _llm(texts, baseUrl, apiKey, model, videoTitle, ctx);
        } else {
          out = await _google(texts);
        }
      } catch (e) {
        failed++;
        lastError = '$e';
      }
      if (out == null) continue; // giữ nguyên bản gốc cho lô lỗi
      for (var k = 0; k < slice.length; k++) {
        final t = out[k].trim();
        if (t.isNotEmpty) cues[slice[k]].text = t;
      }
    }

    // mọi lô đều lỗi -> báo lỗi thay vì trả về phụ đề chưa dịch
    if (batches > 0 && failed == batches) {
      throw Exception(lastError ?? 'không có kết nối');
    }

    final sb = StringBuffer('WEBVTT\n\n');
    sb.writeAll(cues.map((c) => '${c.head}\n${c.text}'), '\n\n');
    return sb.toString();
  }

  static Future<List<String>> _google(List<String> texts) async {
    final body = texts
        .map((t) => 'q=${Uri.encodeQueryComponent(t)}')
        .join('&');
    final res = await _dio.post<dynamic>(
      'https://translate.googleapis.com/translate_a/t?client=gtx&sl=auto&tl=vi&dt=t&format=text',
      data: body,
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        responseType: ResponseType.json,
      ),
    );
    final data = res.data;
    if (data is! List || data.length != texts.length) {
      throw Exception('phản hồi dịch không hợp lệ');
    }
    return [
      for (final e in data) e is List ? '${e.isEmpty ? '' : e.first}' : '$e',
    ];
  }

  static const String _systemPrompt =
      'Bạn là dịch giả phụ đề video chuyên nghiệp, dịch sang tiếng Việt như người bản ngữ nói, không dịch từng chữ.\n'
      'Quy tắc:\n'
      '1. Các dòng liên tiếp thường là MỘT câu bị ngắt giữa chừng. Hãy hiểu cả câu rồi mới dịch, sau đó chia ý hợp lý vào từng dòng; mỗi dòng ngắn gọn, dễ đọc trong thời gian hiển thị.\n'
      '2. Dùng "title" và "previous" (các dòng ngay trước đó, gồm bản gốc "src" và bản dịch "vi") chỉ để hiểu ngữ cảnh và giữ thuật ngữ, tên riêng, cách xưng hô nhất quán. KHÔNG dịch lại "previous".\n'
      '3. Tên riêng, tên nhân vật/game/sản phẩm: giữ nguyên hoặc dùng phiên âm quen thuộc với người Việt. Xưng hô và giọng điệu phù hợp thể loại video.\n'
      '4. Không giải thích, không thêm bớt thông tin, không giữ lại ký tự thừa.\n'
      'Đầu vào là JSON {"title": ..., "previous": [...], "lines": [...]}. '
      'Chỉ trả về MỘT mảng JSON các chuỗi tiếng Việt, đúng số phần tử và đúng thứ tự của "lines", không thêm gì khác.';

  static Future<List<String>> _llm(
    List<String> texts,
    String baseUrl,
    String apiKey,
    String model,
    String title,
    List<Map<String, String>> previous,
  ) async {
    final url = '${baseUrl.replaceAll(RegExp(r'/+$'), '')}/chat/completions';
    final payload = jsonEncode({
      if (title.isNotEmpty) 'title': title,
      if (previous.isNotEmpty) 'previous': previous,
      'lines': texts,
    });
    Object? lastError;
    for (var attempt = 0; attempt < _llmAttempts; attempt++) {
      try {
        final res = await _dio.post<dynamic>(
          url,
          data: {
            'model': model,
            'temperature': 0.3,
            'messages': [
              {'role': 'system', 'content': _systemPrompt},
              {'role': 'user', 'content': payload},
            ],
          },
          options: Options(
            headers: {'Authorization': 'Bearer $apiKey'},
            contentType: Headers.jsonContentType,
            responseType: ResponseType.json,
          ),
        );
        var content = '${res.data['choices'][0]['message']['content']}';
        final a = content.indexOf('[');
        final b = content.lastIndexOf(']');
        if (a < 0 || b <= a) throw Exception('LLM không trả về mảng JSON');
        content = content.substring(a, b + 1);
        final list = jsonDecode(content);
        if (list is! List || list.length != texts.length) {
          throw Exception('LLM trả sai số dòng');
        }
        return [for (final e in list) '$e'];
      } catch (e) {
        lastError = e;
      }
    }
    throw Exception('$lastError');
  }
}
