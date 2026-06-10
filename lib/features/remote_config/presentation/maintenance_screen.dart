import 'package:flutter/material.dart';

/// Shown in place of a feature's real screen when its Remote Config flag
/// is `false`. The tab stays in the bottom navigation so the user can see
/// the feature exists; this surface explains *why* it can't be opened
/// right now.
///
/// Defaults are Arabic since the app is Arabic-first; pass [title] /
/// [message] to customise per feature if needed in the future.
class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({
    super.key,
    this.featureName,
    this.title = 'تحت الصيانة',
    this.message =
        'هذه الميزة غير متاحة حالياً.\nنعمل على تجهيزها وستعود قريباً إن شاء الله.',
  });

  /// Optional feature label shown above the title (e.g. «البوصلة»).
  final String? featureName;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.primary.withValues(alpha: 0.10),
                  ),
                  child: Icon(
                    Icons.construction_rounded,
                    size: 56,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(height: 28),
                if (featureName != null) ...[
                  Text(
                    featureName!,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.55),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.65),
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
