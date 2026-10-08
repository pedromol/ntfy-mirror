import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ntfy_mirror/prefs.dart';
import 'package:ntfy_mirror/logger.dart';
import 'package:ntfy_mirror/l10n/app_localizations.dart';

class PayloadTemplateScreen extends StatefulWidget {
  const PayloadTemplateScreen({super.key});

  @override
  State<PayloadTemplateScreen> createState() => _PayloadTemplateScreenState();
}

class _PayloadTemplateScreenState extends State<PayloadTemplateScreen> {
  final TextEditingController _ctrl = TextEditingController();
  bool _useNtfyStyle = true;
  bool _dirty = false;
  String? _error;

  static const String _defaultTemplate = '''{
  "message_body": "{{body}}",
  "message_from": "{{from}}",
  "message_date": "{{date}}",
  "app": "{{app}}",
  "type": "{{type}}",
  "reception": "{{reception}}",
  "title": "{{title}}",
  "text": "{{text}}",
  "big_text": "{{bigText}}",
  "sub_text": "{{subText}}",
  "summary_text": "{{summaryText}}",
  "info_text": "{{infoText}}",
  "category": "{{category}}",
  "priority": "{{priority}}",
  "channel_id": "{{channelId}}",
  "visibility": "{{visibility}}",
  "color": "{{color}}",
  "group_key": "{{groupKey}}",
  "is_group_summary": "{{isGroupSummary}}",
  "when": "{{when}}",
  "actions": "{{actions}}",
  "people": "{{people}}",
  "badge_icon_type": "{{badgeIconType}}",
  "small_icon_base64": "{{smallIcon}}",
  "large_icon_base64": "{{largeIcon}}",
  "picture_base64": "{{picture}}"
}
''';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final tpl = await Prefs.getPayloadTemplate();
    await Logger.d('Loading template: "$tpl"');
    if (!mounted) return;
    String normalized = tpl;
    if (normalized.contains('\\n')) {
      normalized = normalized.replaceAll('\\n', '\n');
    }
    if (normalized.contains('\\"')) {
      normalized = normalized.replaceAll('\\"', '"');
    }
    final isEmpty = normalized.trim().isEmpty;
    setState(() {
      _useNtfyStyle = isEmpty;
      _ctrl.text = isEmpty ? '' : normalized;
      _dirty = false;
      _error = null;
    });
    await Logger.d('Loaded - useNtfyStyle: $_useNtfyStyle, text length: ${_ctrl.text.length}');
  }

  void _validate(String text) {
    try {
      jsonDecode(text);
      setState(() { _error = null; _dirty = true; });
    } catch (e) {
      setState(() { _error = 'Invalid JSON: ${e.toString()}'; _dirty = true; });
    }
  }

  Future<void> _save() async {
    await Logger.d('Saving - useNtfyStyle: $_useNtfyStyle, text: "${_ctrl.text}"');
    if (_useNtfyStyle) {
      await Prefs.setPayloadTemplate('');
      await Logger.d('Saved: ntfy-style enabled (empty string)');
    } else {
      final text = _ctrl.text.trim();
      try {
        if (text.isEmpty) {
          setState(() { _error = AppLocalizations.of(context)!.templateCannotBeEmpty; });
          return;
        }
        jsonDecode(text);
      } catch (e) {
        setState(() { _error = 'Invalid JSON: ${e.toString()}'; });
        return;
      }
      await Prefs.setPayloadTemplate(text);
      await Logger.d('Saved: custom template');
    }
    if (!mounted) return;
    setState(() { _dirty = false; });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_useNtfyStyle ? AppLocalizations.of(context)!.ntfyStyleEnabled : 'Template saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.data_object_rounded,
                color: colorScheme.onPrimaryContainer,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Payload Template'),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.outlineVariant, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _useNtfyStyle,
                          onChanged: (v) {
                            setState(() {
                              _useNtfyStyle = v ?? true;
                              _dirty = true;
                            });
                          },
                        ),
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context)!.useNtfyStyle,
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    if (!_useNtfyStyle) ...[
                      const SizedBox(height: 16),
                      Text('Placeholders', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text('{{body}}, {{from}}, {{date}}, {{app}}, {{type}}, {{reception}}',
                          style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                      const SizedBox(height: 8),
                      Text('Extra fields (if present): subText, summaryText, bigText, infoText, people, category, priority, channelId, actions, groupKey, visibility, color, badgeIconType, largeIcon, smallIcon, picture',
                          style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                      const SizedBox(height: 4),
                      Text('See README for full list and examples.',
                          style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.primary)),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Scrollbar(
                  child: TextField(
                    controller: _ctrl,
                    onChanged: _validate,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    keyboardType: TextInputType.multiline,
                    enabled: !_useNtfyStyle,
                    style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace', height: 1.4),
                    decoration: InputDecoration(
                      labelText: 'JSON Template',
                      alignLabelWithHint: true,
                      contentPadding: const EdgeInsets.all(12),
                      fillColor: _useNtfyStyle
                          ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.2)
                          : null,
                      filled: _useNtfyStyle,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _ctrl.text = _defaultTemplate;
                          _error = null;
                          _dirty = true;
                          _useNtfyStyle = false;
                        });
                      },
                      icon: const Icon(Icons.restore_rounded),
                      label: const Text('Restore Default'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: (_useNtfyStyle || (_dirty && _error == null)) ? _save : null,
                      icon: const Icon(Icons.save_rounded),
                      label: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
      ),
    );
  }
}


