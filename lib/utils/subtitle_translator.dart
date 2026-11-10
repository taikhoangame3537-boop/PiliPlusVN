import 'dart:convert';

import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:dio/dio.dart';

class _Cue {
  _Cue(this.head, this.orig, this.startMs, this.endMs) : text = orig;
  final String head;
  final String orig;
  final int? startMs;
  final int? endMs;
  String text;
  bool skip = false;
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
  // chế độ Google: gom các dòng thành câu rồi mới dịch
  static const int _maxGroupCues = 8;
  static const int _maxGroupChars = 350;
  static const int _maxGapMs = 1200;
  static const int _googleBatch = 15;
  static final RegExp _blankSplit = RegExp(r'\r?\n\r?\n');
  static final RegExp _lineSplit = RegExp(r'\r?\n');
  static final RegExp _sentEnd = RegExp(
    r'''[.!?…。！？]["'”’）)\]」』]*$''',
  );
  static final RegExp _timeRe = RegExp(r'(?:(\d+):)?(\d+):(\d+)[.,](\d+)');
  static final RegExp _wordSplit = RegExp(r'\s+');
  static final RegExp _softBreak = RegExp(r'[,;:.!?，。；：！？]$');
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
      final times = lines[ti].split('-->');
      cues.add(
        _Cue(
          lines.sublist(0, ti + 1).join('\n'),
          lines.sublist(ti + 1).join(' ').trim(),
          _ms(times.first),
          times.length > 1 ? _ms(times[1]) : null,
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

    if (useLlm) {
      for (var start = 0; start < indexes.length; start += _batchSize) {
        batches++;
        final end = (start + _batchSize).clamp(0, indexes.length);
        final slice = indexes.sublist(start, end);
        final texts = [for (final i in slice) cues[i].orig];
        List<String>? out;
        try {
          // ngữ cảnh: vài dòng ngay trước lô này (gốc + bản dịch)
          final ctx = <Map<String, String>>[
            for (final i in indexes.sublist(
              start > _contextSize ? start - _contextSize : 0,
              start,
            ))
              {'src': cues[i].orig, 'vi': cues[i].text},
          ];
          out = await _llm(texts, baseUrl, apiKey, model, videoTitle, ctx);
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
    } else {
      // Google dịch từng dòng rất rời rạc: gom thành câu, dịch cả câu,
      // rồi chia bản dịch lại theo độ dài từng dòng gốc.
      final groups = _group(cues, indexes);
      for (var start = 0; start < groups.length; start += _googleBatch) {
        batches++;
        final end = (start + _googleBatch).clamp(0, groups.length);
        final slice = groups.sublist(start, end);
        final texts = [
          for (final g in slice) g.map((i) => cues[i].orig).join(' '),
        ];
        List<String> out;
        try {
          out = await _google(texts);
        } catch (e) {
          failed++;
          lastError = '$e';
          continue;
        }
        for (var k = 0; k < slice.length; k++) {
          final g = slice[k];
          final t = out[k].trim();
          if (t.isEmpty) continue;
          final pieces = _distribute(t, [
            for (final i in g) cues[i].orig.length,
          ]);
          for (var j = 0; j < g.length; j++) {
            if (pieces[j].isEmpty) {
              cues[g[j]].skip = true;
            } else {
              cues[g[j]].text = pieces[j];
            }
          }
        }
      }
    }

    // mọi lô đều lỗi -> báo lỗi thay vì trả về phụ đề chưa dịch
    if (batches > 0 && failed == batches) {
      throw Exception(lastError ?? 'không có kết nối');
    }

    final sb = StringBuffer('WEBVTT\n\n');
    sb.writeAll(
      cues.where((c) => !c.skip).map((c) => '${c.head}\n${c.text}'),
      '\n\n',
    );
    return sb.toString();
  }

  static int? _ms(String s) {
    final m = _timeRe.firstMatch(s);
    if (m == null) return null;
    final frac = m[4]!.padRight(3, '0').substring(0, 3);
    return (int.parse(m[1] ?? '0') * 3600 +
                int.parse(m[2]!) * 60 +
                int.parse(m[3]!)) *
            1000 +
        int.parse(frac);
  }

  /// Gom các dòng liền nhau thành "câu": ngắt khi dòng trước kết thúc câu,
  /// khi có khoảng lặng dài, hoặc khi nhóm quá dài.
  static List<List<int>> _group(List<_Cue> cues, List<int> indexes) {
    final groups = <List<int>>[];
    var cur = <int>[];
    var chars = 0;
    for (final i in indexes) {
      final c = cues[i];
      if (cur.isNotEmpty) {
        final prev = cues[cur.last];
        final gap = (c.startMs != null && prev.endMs != null)
            ? c.startMs! - prev.endMs!
            : 0;
        if (_sentEnd.hasMatch(prev.orig) ||
            gap > _maxGapMs ||
            cur.length >= _maxGroupCues ||
            chars + c.orig.length > _maxGroupChars) {
          groups.add(cur);
          cur = <int>[];
          chars = 0;
        }
      }
      cur.add(i);
      chars += c.orig.length;
    }
    if (cur.isNotEmpty) groups.add(cur);
    return groups;
  }

  /// Chia bản dịch của cả câu về từng dòng theo tỉ lệ độ dài dòng gốc,
  /// ưu tiên ngắt sau dấu câu gần vị trí cần cắt.
  static List<String> _distribute(String text, List<int> weights) {
    final n = weights.length;
    if (n == 1) return [text];
    final words = text.split(_wordSplit).where((w) => w.isNotEmpty).toList();
    if (words.length < n) {
      return [for (var k = 0; k < n; k++) k < words.length ? words[k] : ''];
    }
    final total = weights.fold<int>(0, (a, b) => a + b);
    final cuts = <int>[0];
    var cum = 0;
    for (var k = 0; k < n - 1; k++) {
      cum += weights[k];
      final lo = cuts.last + 1;
      final hi = words.length - (n - 1 - k);
      var t = total > 0 ? (words.length * cum / total).round() : lo;
      t = t < lo ? lo : (t > hi ? hi : t);
      var best = t;
      for (final d in const [0, -1, 1, -2, 2]) {
        final c = t + d;
        if (c < lo || c > hi) continue;
        if (_softBreak.hasMatch(words[c - 1])) {
          best = c;
          break;
        }
      }
      cuts.add(best);
    }
    cuts.add(words.length);
    return [
      for (var k = 0; k < n; k++) words.sublist(cuts[k], cuts[k + 1]).join(' '),
    ];
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
