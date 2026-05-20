import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../prayer/domain/entities/daily_prayer_times.dart';
import '../../../prayer/presentation/bloc/prayer_bloc.dart';
import '../../../prayer/presentation/bloc/prayer_state.dart';
import '../../../settings/presentation/settings_provider.dart';
import '../../domain/usecases/get_upcoming_schedule.dart';
import '../../domain/usecases/publish_widget_payload.dart';
import '../mapper/widget_payload_mapper.dart';

/// Publishes a 30-day schedule snapshot whenever the day or city changes.
/// Per-second countdown and day-rollover are handled natively, so this
/// bridge only fires on real schedule changes — not on every tick.
class HomeWidgetBridge extends StatefulWidget {
  final Widget child;
  const HomeWidgetBridge({super.key, required this.child});

  @override
  State<HomeWidgetBridge> createState() => _HomeWidgetBridgeState();
}

class _HomeWidgetBridgeState extends State<HomeWidgetBridge> {
  static const _mapper = WidgetPayloadMapper();
  static const int _daysAhead = 30;

  late final PrayerBloc _bloc;
  late final SettingsProvider _settingsProvider;
  late final PublishWidgetPayloadUseCase _publish;
  late final GetUpcomingScheduleUseCase _getSchedule;
  StreamSubscription<PrayerState>? _sub;
  AppLocalizations? _l;
  String _lastSig = '';
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<PrayerBloc>();
    _settingsProvider = context.read<SettingsProvider>();
    _publish = context.read<PublishWidgetPayloadUseCase>();
    _getSchedule = context.read<GetUpcomingScheduleUseCase>();
    _sub = _bloc.stream.listen(_onState);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _l = AppLocalizations.of(context);
    _onState(_bloc.state);
  }

  void _onState(PrayerState state) {
    final l = _l;
    if (l == null || _refreshing) return;
    final sig = _quickSignature(state);
    if (sig.isEmpty || sig == _lastSig) return;
    _lastSig = sig;
    _refreshing = true;
    _refreshAndPublish(state, l).whenComplete(() => _refreshing = false);
  }

  Future<void> _refreshAndPublish(
    PrayerState state,
    AppLocalizations l,
  ) async {
    final List<DailyPrayerTimes> upcoming = await _getSchedule(
      from: state.now,
      days: _daysAhead,
    );
    if (!mounted) return;
    final payload = _mapper.map(
      state: state,
      settings: _settingsProvider.settings,
      l: l,
      upcoming: upcoming,
    );
    if (payload == null) return;
    await _publish(payload);
  }

  /// Cheap fingerprint: city, day, locale. Fetching 30 days is async, so we
  /// avoid triggering it unless one of these changed.
  String _quickSignature(PrayerState state) {
    if (state.todayPrayers == null) return '';
    final s = _settingsProvider.settings;
    final today = state.now;
    final dayKey = '${today.year}-${today.month}-${today.day}';
    return '${s.selectedCountry}|${s.selectedCity}|${s.locale}|$dayKey';
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
