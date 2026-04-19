import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../domain/i_rating_service.dart';
import 'widgets/rating_dialog.dart';

/// Wraps [child] and shows [RatingDialog] after an 8-second delay.
/// The delay ensures the splash screen, navigation, and prayer data
/// are all fully settled before the dialog appears.
class RatingTrigger extends StatefulWidget {
  const RatingTrigger({super.key, required this.child});

  final Widget child;

  @override
  State<RatingTrigger> createState() => _RatingTriggerState();
}

class _RatingTriggerState extends State<RatingTrigger> {
  late final IRatingService _service;
  // Static so all instances share the same flag — prevents double-show
  // if MobileShell is recreated during the same app session.
  static bool _sessionShown = false;

  @override
  void initState() {
    super.initState();
    _service = GetIt.I<IRatingService>();
    _service.recordFirstLaunchIfNeeded();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 8), _maybeShow);
    });
  }

  Future<void> _maybeShow() async {
    if (!mounted || _sessionShown) return;
    final shouldShow = await _service.shouldShowDialog();
    if (!shouldShow || !mounted) return;

    _sessionShown = true;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => RatingDialog(service: _service),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
