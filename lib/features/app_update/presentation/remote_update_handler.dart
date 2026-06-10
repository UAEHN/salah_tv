import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../core/platform_config.dart';
import '../domain/entities/update_status.dart';
import '../domain/usecases/check_for_update_usecase.dart';
import 'widgets/mobile_force_update_dialog.dart';
import 'widgets/mobile_optional_update_dialog.dart';
import 'widgets/tv_force_update_dialog.dart';
import 'widgets/tv_optional_update_dialog.dart';

/// Bridge helper used by [AppUpdateTrigger]. Runs the remote version check
/// and shows the matching platform-specific dialog (TV vs mobile).
class RemoteUpdateHandler {
  RemoteUpdateHandler({CheckForUpdateUseCase? useCase})
    : _useCase = useCase ?? GetIt.I<CheckForUpdateUseCase>();

  final CheckForUpdateUseCase _useCase;

  Future<UpdateDecision?> evaluate() async {
    final result = await _useCase();
    return result.fold((_) => null, (d) => d);
  }

  Future<void> showForced(BuildContext context, UpdateDecision d) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => kIsTV
          ? TvForceUpdateDialog(
              storeUrl: d.info.storeUrl,
              messageAr: d.info.messageAr,
            )
          : MobileForceUpdateDialog(
              storeUrl: d.info.storeUrl,
              messageAr: d.info.messageAr,
            ),
    );
  }

  Future<void> showOptional(BuildContext context, UpdateDecision d) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => kIsTV
          ? TvOptionalUpdateDialog(
              storeUrl: d.info.storeUrl,
              messageAr: d.info.messageAr,
              onDismiss: () => Navigator.of(ctx).pop(),
            )
          : MobileOptionalUpdateDialog(
              storeUrl: d.info.storeUrl,
              messageAr: d.info.messageAr,
              onDismiss: () => Navigator.of(ctx).pop(),
            ),
    );
  }
}
