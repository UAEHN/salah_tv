import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../core/app_colors.dart';
import '../bloc/prayer_bloc.dart';
import '../bloc/prayer_state.dart';

/// Non-silent, TV-readable status banner over the home screen for background
/// Quran: a loading spinner while a surah buffers (slow network) and an error
/// message when it fails to load/play. Both are driven by transient engine
/// flags via a scoped selector (no 1 Hz rebuild — CLAUDE.md §7); error takes
/// priority over loading.
class QuranStatusBanner extends StatelessWidget {
  final AccentPalette palette;
  const QuranStatusBanner({required this.palette, super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return BlocSelector<PrayerBloc, PrayerState, ({bool error, bool loading})>(
      selector: (state) =>
          (error: state.hasQuranError, loading: state.isQuranLoading),
      builder: (context, status) {
        final Widget child;
        if (status.error) {
          child = _banner(
            key: 'quran-error',
            leading: Icon(
              Icons.wifi_off_rounded,
              color: palette.primary,
              size: 30,
            ),
            text: l.quranNetworkError,
          );
        } else if (status.loading) {
          child = _banner(
            key: 'quran-loading',
            leading: SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation(palette.primary),
              ),
            ),
            text: l.quranLoading,
          );
        } else {
          child = const SizedBox.shrink(key: ValueKey('quran-status-none'));
        }
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: child,
        );
      },
    );
  }

  Widget _banner({
    required String key,
    required Widget leading,
    required String text,
  }) {
    return Align(
      key: ValueKey(key),
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 48),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: palette.primary, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 24,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              leading,
              const SizedBox(width: 16),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
