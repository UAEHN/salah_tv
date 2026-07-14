import 'package:flutter/material.dart';

/// kDebugMode-only launcher for `/error_test`, included at the bottom of the
/// TV settings feedback category. D-pad focusable. Developer tool —
/// intentionally not localized; the tile is compiled out of release builds
/// by its `if (kDebugMode)` include site.
class ErrorTestLauncherTile extends StatelessWidget {
  const ErrorTestLauncherTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: OutlinedButton.icon(
          icon: const Icon(Icons.bug_report_outlined),
          label: const Text('Error Reporting Test (debug)'),
          onPressed: () => Navigator.of(context).pushNamed('/error_test'),
        ),
      ),
    );
  }
}
