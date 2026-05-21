import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/mobile_theme.dart';
import '../../../domain/entities/mushaf_page.dart';

/// Modal dialog for jumping directly to a Mushaf page (1..604).
/// Returns the chosen page number, or null if the user cancels or types
/// something out of range.
class MobileMushafPageJumpDialog extends StatefulWidget {
  const MobileMushafPageJumpDialog({super.key});

  static Future<int?> show(BuildContext context) {
    return showDialog<int>(
      context: context,
      builder: (_) => const MobileMushafPageJumpDialog(),
    );
  }

  @override
  State<MobileMushafPageJumpDialog> createState() =>
      _MobileMushafPageJumpDialogState();
}

class _MobileMushafPageJumpDialogState
    extends State<MobileMushafPageJumpDialog> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final raw = _controller.text.trim();
    final n = int.tryParse(raw);
    if (n == null || n < 1 || n > MushafPage.totalPages) {
      setState(() =>
          _error = AppLocalizations.of(context).mushafJumpDialogError);
      return;
    }
    Navigator.of(context).pop(n);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l.mushafJumpDialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textAlign: TextAlign.center,
            style: MobileTextStyles.headlineMd(context),
            decoration: InputDecoration(
              hintText: l.mushafJumpDialogHint,
              errorText: _error,
              border: const OutlineInputBorder(),
            ),
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.commonCancel),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(l.mushafJumpDialogGo),
        ),
      ],
    );
  }
}
