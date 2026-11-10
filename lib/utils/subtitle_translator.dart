import 'dart:convert';

import 'package:PiliPlus/utils/han_viet.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:PiliPlus/utils/subtitle_default_rules.dart';
import 'package:dio/dio.dart';

/// Quy tắc dịch do người dùng tự viết (mỗi dòng một quy tắc):
///  `A => B`  sửa phụ đề GỐC trước khi dịch (lỗi nhận dạng/nghe nhầm)
///  `A = B`   thuật ngữ/tên riêng: A luôn được dịch thành B
///  `A >> B`  sửa bản dịch tiếng Việt SAU khi dịch (không phân biệt hoa/thường)
///  dòng bắt đầu bằng `#` là ghi chú
class _Rules {
  _Rules(this.fixSrc, this.glossary, this.fixOut);
  final List<List<String>> fixSrc;
  final List<List<String>> glossary;
  final List<List<String>> fixOut;

  static _Rules parse(String raw) {
    final fixSrc = <List<String>>[];
    final glossary = <List<String>>[];
    final fixOut = <List<String>>[];
    for (final line in raw.split('\n')) {
      final l = line.trim();
      if (l.isEmpty || l.startsWith('#')) continue;
      if (l.startsWith('@hv')) {
        // @hv 林凡 苏婉清: tên người -> Hán Việt (bỏ qua tên có chữ chưa có trong bảng)
        for (final n in l.substring(3).split(RegExp(r'[\s,，、;；]+'))) {
          if (n.isEmpty) continue;
          final v = HanViet.convert(n);
          if (v != null) glossary.add([n, v]);
        }
        continue;
      }
      final String sep;
      if (l.contains('=>')) {
        sep = '=>';
      } else if (l.contains('>>')) {
        sep = '>>';
      } else if (l.contains('=')) {
        sep = '=';
      } else {
        continue;
      }
      final at = l.indexOf(sep);
      final a = l.substring(0, at).trim();
      final b = l.substring(at + sep.length).trim();
      if (a.isEmpty) continue;
      (sep == '=>' ? fixSrc : (sep == '>>' ? fixOut : glossary)).add([a, b]);
    }
    // thuật ngữ dài xử lý trước (丧尸潮 trước 丧尸); sort ổn định theo độ dài
    final order = [for (var i = 0; i < glossary.length; i++) i]
      ..sort((x, y) {
        final c = glossary[y][0].length.compareTo(glossary[x][0].length);
        return c != 0 ? c : x.compareTo(y);
      });
    final sorted = [for (final i in order) glossary[i]];
    return _Rules(fixSrc, sorted, fixOut);
  }

  String pre(String s) {
    for (final r in fixSrc) {
      s = s.replaceAll(r[0], r[1]);
    }
    for (var i = 0; i < glossary.length; i++) {
      s = s.replaceAll(glossary[i][0], ' ZQX${i}Q ');
    }
    return s;
  }

  String post(String s) {
    for (var i = 0; i < glossary.length; i++) {
      final v = glossary[i][1];
      // chịu được việc dịch máy chèn khoảng trắng/đổi hoa thường trong mã tạm
      final fuzzy = 'Z\\s*Q\\s*X\\s*${i.toString().split('').join(r'\s*')}\\s*Q';
      s = s.replaceAllMapped(
        RegExp('\\s*$fuzzy\\s*', caseSensitive: false),
        (_) => ' $v ',
      );
    }
    for (final r in fixOut) {
      s = s.replaceAllMapped(
        RegExp(RegExp.escape(r[0]), caseSensitive: false, unicode: true),
        (_) => r[1],
      );
    }
    // dọn dẹp chung: khoảng trắng thừa, khoảng trắng trước dấu câu
    s = s.replaceAll(RegExp(r' {2,}'), ' ').trim();
    s = s.replaceAllMapped(RegExp(r' +([,.!?;:…])'), (m) => m[1]!);
    return s;
  }
}

class _Cue {
  _Cue(this.head, this.orig, this.src) : out = List<String>.of(orig);
  final String head; // dòng thời gian của cue, giữ nguyên
  final List<String> orig; // từng dòng chữ gốc của cue
  final List<String> src; // orig sau khi áp quy tắc sửa gốc/thuật ngữ
  final List<String> out; // bản dịch, cùng số dòng và cùng vị trí với orig
}

abstract final class SubtitleTranslator {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 90),
      sendTimeout: const Duration(seconds: 30),
    ),
  );

  static const int _llmBatch = 30;
  static const int _googleBatch = 40;
  // số cặp (gốc, đã dịch) của các dòng liền trước gửi kèm làm ngữ cảnh cho LLM
  static const int _contextSize = 6;
  static const int _llmAttempts = 2;
  // AI miễn phí không cần key (LLM7, bên thứ ba): dịch thử, lỗi thì dùng Google
  static const String _freeBaseUrl = 'https://api.llm7.io/v1';
  static const String _freeKey = 'unused';
  static const String _freeModel = 'gpt-4.1-nano-2025-04-14';

  /// Cảnh báo của lần dịch gần nhất (ví dụ AI miễn phí lỗi nên đã dùng Google).
  static String? lastWarning;

  static final RegExp _blankSplit = RegExp(r'\r?\n\r?\n');
  static final RegExp _lineSplit = RegExp(r'\r?\n');
  static final RegExp _viLan = RegExp(
    r'(^|[-_])vi($|[-_])',
    caseSensitive: false,
  );

  /// Track phụ đề đã là tiếng Việt (`vi`, `ai-vi`, `vi-VN`...) thì không dịch nữa.
  static bool isVietnamese(String lan) => _viLan.hasMatch(lan);

  /// Dịch phụ đề VTT, giữ nguyên 1-1: mỗi dòng gốc chỉ cho đúng một dòng dịch,
  /// nằm trong đúng cue (đúng thời gian) và đúng vị trí dòng của nó. Không bao
  /// giờ gộp hai dòng/hai cue hay chuyển chữ từ dòng này sang dòng khác, vì
  /// các dòng liền nhau có thể do các nhân vật khác nhau nói.
  static Future<String> translateVtt(String vtt, {String? title}) async {
    // quy tắc người dùng đứng trước nên được ưu tiên hơn quy tắc có sẵn
    final rules = _Rules.parse('${Pref.subtitleRules}\n$kDefaultSubtitleRules');
    final cues = <_Cue>[];
    for (final block in vtt.split(_blankSplit)) {
      final lines = block.split(_lineSplit);
      final ti = lines.indexWhere((l) => l.contains('-->'));
      if (ti < 0) continue;
      final body = [for (final l in lines.sublist(ti + 1)) l.trim()];
      cues.add(
        _Cue(lines.sublist(0, ti + 1).join('\n'), body, [
          for (final l in body) rules.pre(l),
        ]),
      );
    }
    if (cues.isEmpty) return vtt;

    // đơn vị dịch = từng dòng chữ của từng cue: [chỉ số cue, chỉ số dòng]
    final units = <List<int>>[
      for (var i = 0; i < cues.length; i++)
        for (var j = 0; j < cues[i].orig.length; j++)
          if (cues[i].orig[j].isNotEmpty) [i, j],
    ];

    var baseUrl = Pref.subtitleLlmBaseUrl.trim();
    var apiKey = Pref.subtitleLlmKey.trim();
    var model = Pref.subtitleLlmModel.trim();
    final hasKey = baseUrl.isNotEmpty && apiKey.isNotEmpty && model.isNotEmpty;
    final free = !hasKey && Pref.subtitleFreeAi;
    if (free) {
      baseUrl = _freeBaseUrl;
      apiKey = _freeKey;
      model = _freeModel;
    }
    final useLlm = hasKey || free;
    final videoTitle = title?.trim() ?? '';
    final size = useLlm ? _llmBatch : _googleBatch;

    lastWarning = null;
    var fellBack = false;
    var failed = 0;
    var batches = 0;
    String? lastError;

    for (var start = 0; start < units.length; start += size) {
      batches++;
      final end = (start + size).clamp(0, units.length);
      final slice = units.sublist(start, end);
      final texts = [for (final u in slice) cues[u[0]].src[u[1]]];
      List<String>? out;
      try {
        if (useLlm) {
          // ngữ cảnh: vài dòng ngay trước lô này (gốc + bản dịch)
          final ctx = <Map<String, String>>[
            for (final u in units.sublist(
              start > _contextSize ? start - _contextSize : 0,
              start,
            ))
              {'src': cues[u[0]].orig[u[1]], 'vi': cues[u[0]].out[u[1]]},
          ];
          out = await _llm(texts, baseUrl, apiKey, model, videoTitle, ctx);
        } else {
          out = await _google(texts);
        }
      } catch (e) {
        lastError = useLlm
            ? '$e'.replaceFirst('Exception: ', '')
            : _describe(e, 'translate.googleapis.com');
        if (free) {
          // AI miễn phí lỗi/quá tải: dịch lô này bằng Google thay vì bỏ trống
          try {
            out = await _google(texts);
            fellBack = true;
          } catch (_) {
            failed++;
          }
        } else {
          failed++;
        }
      }
      if (out == null) continue; // giữ nguyên bản gốc cho lô lỗi
      for (var k = 0; k < slice.length; k++) {
        final t = rules.post(out[k].trim());
        if (t.isNotEmpty) cues[slice[k][0]].out[slice[k][1]] = t;
      }
    }
    if (fellBack) lastWarning = lastError;

    // mọi lô đều lỗi -> báo lỗi thay vì trả về phụ đề chưa dịch
    if (batches > 0 && failed == batches) {
      throw Exception(lastError ?? 'không có kết nối');
    }

    final bilingual = Pref.subtitleBilingual;
    final sb = StringBuffer('WEBVTT\n\n');
    sb.writeAll(
      cues.map((c) {
        var body = c.out.join('\n');
        if (bilingual && body != c.orig.join('\n')) {
          body = '${c.orig.join('\n')}\n$body';
        }
        return '${c.head}\n$body';
      }),
      '\n\n',
    );
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
      '1. Mỗi phần tử của "lines" là MỘT lời thoại hiển thị riêng trên màn hình, và các dòng liền nhau có thể do các nhân vật KHÁC NHAU nói. Dịch từng dòng độc lập: tuyệt đối không gộp hai dòng, không chuyển chữ hay ý từ dòng này sang dòng khác, kể cả khi một câu bị ngắt giữa hai dòng. Dòng nào dịch vào dòng đó, ngắn gọn dễ đọc.\n'
      '2. Dùng "title" và "previous" (các dòng ngay trước đó, gồm bản gốc "src" và bản dịch "vi") chỉ để hiểu ngữ cảnh và giữ thuật ngữ, tên riêng, cách xưng hô nhất quán. KHÔNG dịch lại "previous".\n'
      '3. Tên riêng, tên nhân vật/game/sản phẩm: giữ nguyên hoặc dùng phiên âm quen thuộc với người Việt. Xưng hô và giọng điệu phù hợp thể loại video.\n'
      '4. Phụ đề thường do máy nhận dạng giọng nói (ASR) tạo ra nên hay sai ở từ đồng âm/gần âm. Nếu một câu vô nghĩa, thô tục hoặc không hợp ngữ cảnh, hãy suy ra câu đúng từ các dòng xung quanh và dịch câu đúng đó; chỉ làm vậy khi thật sự vô lý, còn lại dịch sát nghĩa.\n'
      '5. Không giải thích, không thêm bớt thông tin, không giữ lại ký tự thừa.\n'
      'Đầu vào là JSON {"title": ..., "previous": [...], "lines": [...]}. '
      'Chỉ trả về MỘT mảng JSON các chuỗi tiếng Việt, đúng số phần tử và đúng thứ tự của "lines", không thêm gì khác.';

  /// Gọi thử LLM bằng một câu ngắn; nếu là Gemini gốc và lỗi thì liệt kê
  /// các model Flash mà key này dùng được.
  static Future<String> testConnection(
    String baseUrl,
    String apiKey,
    String model,
  ) async {
    if (baseUrl.isEmpty || apiKey.isEmpty || model.isEmpty) {
      return 'Cần điền đủ 3 ô.';
    }
    try {
      final out = await _llm(['我知道错了'], baseUrl, apiKey, model, '', const []);
      return 'OK: 我知道错了 → ${out.first}';
    } catch (e) {
      var msg = '$e'.replaceFirst('Exception: ', '');
      final base = baseUrl.replaceAll(RegExp(r'/+$'), '');
      if (base.contains('generativelanguage.googleapis.com') &&
          !base.contains('/openai')) {
        final names = await _geminiModels(base, apiKey);
        if (names.isNotEmpty) {
          msg += '\n\nModel Flash dùng được với key này:\n${names.join('\n')}';
        }
      }
      return 'LỖI: $msg';
    }
  }

  static Future<List<String>> _geminiModels(String base, String apiKey) async {
    try {
      final root = RegExp(r'/v1\w*$').hasMatch(base) ? base : '$base/v1beta';
      final res = await _dio.get<dynamic>(
        '$root/models?pageSize=200',
        options: Options(
          headers: {'x-goog-api-key': apiKey},
          responseType: ResponseType.json,
        ),
      );
      final list = res.data['models'] as List;
      return [
        for (final m in list)
          if (((m['supportedGenerationMethods'] as List?) ?? const []).contains(
            'generateContent',
          ))
            '${m['name']}'.replaceFirst('models/', ''),
      ].where((n) => n.contains('flash')).take(10).toList();
    } catch (_) {
      return const [];
    }
  }

  /// Mô tả lỗi kèm URL (không chứa key) và lời giải thích của server.
  static String _describe(Object e, String url) {
    if (e is DioException) {
      final data = e.response?.data;
      var msg = '';
      if (data is Map) {
        final err = data['error'];
        msg = '${err is Map ? (err['message'] ?? jsonEncode(err)) : jsonEncode(data)}';
      } else if (data != null) {
        msg = '$data';
      } else {
        msg = '${e.message ?? e.type.name}';
      }
      if (msg.length > 300) msg = '${msg.substring(0, 300)}…';
      return 'HTTP ${e.response?.statusCode ?? '?'} ${url.split('?').first}\n$msg';
    }
    return '$e'.replaceFirst('Exception: ', '');
  }

  static String _geminiText(dynamic data) {
    final parts = data['candidates'][0]['content']['parts'] as List;
    return parts
        .where((p) => p['thought'] != true)
        .map((p) => '${p['text'] ?? ''}')
        .join();
  }

  static Future<List<String>> _llm(
    List<String> texts,
    String baseUrl,
    String apiKey,
    String model,
    String title,
    List<Map<String, String>> previous,
  ) async {
    final base = baseUrl.replaceAll(RegExp(r'/+$'), '');
    // Gemini gốc (key kiểu "AQ." có thể bị từ chối ở endpoint /openai)
    final native =
        base.contains('generativelanguage.googleapis.com') &&
        !base.contains('/openai');
    final String url;
    if (native) {
      final root = RegExp(r'/v1\w*$').hasMatch(base) ? base : '$base/v1beta';
      url = '$root/models/$model:generateContent';
    } else {
      url = '$base/chat/completions';
    }
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
          data: native
              ? {
                  'systemInstruction': {
                    'parts': [
                      {'text': _systemPrompt},
                    ],
                  },
                  'contents': [
                    {
                      'role': 'user',
                      'parts': [
                        {'text': payload},
                      ],
                    },
                  ],
                  'generationConfig': {'temperature': 0.3},
                }
              : {
                  'model': model,
                  'temperature': 0.3,
                  'messages': [
                    {'role': 'system', 'content': _systemPrompt},
                    {'role': 'user', 'content': payload},
                  ],
                },
          options: Options(
            headers: native
                ? {'x-goog-api-key': apiKey}
                : {'Authorization': 'Bearer $apiKey'},
            contentType: Headers.jsonContentType,
            responseType: ResponseType.json,
          ),
        );
        var content = native
            ? _geminiText(res.data)
            : '${res.data['choices'][0]['message']['content']}';
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
        lastError = _describe(e, url);
        if (attempt + 1 < _llmAttempts) {
          await Future<void>.delayed(const Duration(seconds: 3));
        }
      }
    }
    throw Exception(lastError);
  }
}
