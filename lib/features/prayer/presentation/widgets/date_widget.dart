import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/localization/date_localizer.dart';
import '../../../settings/presentation/settings_provider.dart';
import '../bloc/prayer_bloc.dart';

class DateWidget extends StatefulWidget {
  final AccentPalette palette;
  final bool compact;

  const DateWidget({super.key, required this.palette, this.compact = false});

  @override
  State<DateWidget> createState() => _DateWidgetState();
}

class _DateWidgetState extends State<DateWidget> {
  bool _isShowingHijri = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      setState(() => _isShowingHijri = !_isShowingHijri);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = context.select(
      (PrayerBloc b) =>
          DateTime(b.state.now.year, b.state.now.month, b.state.now.day),
    );
    final isDark = context.watch<SettingsProvider>().settings.isDarkMode;
    final tc = ThemeColors.of(isDark);
    final screenH = MediaQuery.of(context).size.height;
    final l = AppLocalizations.of(context);

    final text = _isShowingHijri
        ? formatHijriDateLocalized(l, now)
        : formatGregorianDateLocalized(l, now);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: child,
      ),
      child: Text(
        text,
        key: ValueKey(text),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: screenH * (widget.compact ? 0.032 : 0.048),
          fontWeight: FontWeight.w500,
          color: tc.textSecondary,
        ),
      ),
    );
  }
}
