import 'dart:convert';

class TemplateRenderer {
  static String _escape(String v) {
    return v
        .replaceAll('\\', r'\\')
        .replaceAll('"', r'\"')
        .replaceAll('\n', r'\n');
  }

  static dynamic render(String template, Map<String, String> values, {Map<String, dynamic>? fallback}) {
    if (template.trim().isEmpty) {
      return Map<String, dynamic>.from(fallback ?? <String, dynamic>{});
    }
    String rendered = template;
    for (final entry in values.entries) {
      rendered = rendered.replaceAll('{{${entry.key}}}', _escape(entry.value));
    }
    try {
      final decoded = jsonDecode(rendered);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return rendered;
    } catch (_) {
      return rendered;
    }
  }
}


