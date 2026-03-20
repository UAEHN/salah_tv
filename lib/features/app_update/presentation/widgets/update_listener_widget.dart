import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/update_bloc.dart';
import '../bloc/update_event.dart';
import '../bloc/update_state.dart';
import '../../domain/entities/app_version.dart';

class UpdateListenerWidget extends StatefulWidget {
  final Widget child;

  const UpdateListenerWidget({super.key, required this.child});

  @override
  State<UpdateListenerWidget> createState() => _UpdateListenerWidgetState();
}

class _UpdateListenerWidgetState extends State<UpdateListenerWidget> {
  Timer? _checkTimer;
  static bool _isDialogShowing = false;

  @override
  void initState() {
    super.initState();
    // Delay the update check so it never interrupts the splash screen or
    // the initial home-screen render.
    _checkTimer = Timer(const Duration(seconds: 5), () {
      if (!mounted) return;
      // Skip if another widget instance already found an update or started a
      // download. This prevents Flutter's auto-pushed '/' route (created before
      // the splash screen) from firing a duplicate check after the splash
      // navigates to '/', which would recreate UpdateListenerWidget and re-trigger
      // the UpdateChecking → UpdateAvailable cycle — showing the dialog again
      // after the user had already dismissed it.
      final s = context.read<UpdateBloc>().state;
      final alreadyActive = s is UpdateAvailable ||
          s is UpdateDownloading ||
          s is UpdateInstalling;
      if (!alreadyActive) {
        context.read<UpdateBloc>().add(CheckForUpdateEvent());
      }
    });
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UpdateBloc, UpdateState>(
      listenWhen: (prev, curr) =>
          curr is UpdateAvailable && prev is UpdateChecking,
      listener: (context, state) {
        if (state is UpdateAvailable && !_isDialogShowing) {
          _showUpdateDialog(context, state.appVersion);
        }
      },
      child: widget.child,
    );
  }

  void _showUpdateDialog(BuildContext context, AppVersion appVersion) {
    _isDialogShowing = true;
    showDialog(
      context: context,
      barrierDismissible: !appVersion.isMandatory,
      builder: (_) => PopScope(
        canPop: !appVersion.isMandatory,
        child: AlertDialog(
          title: const Text('تحديث جديد متوفر'),
          content: BlocBuilder<UpdateBloc, UpdateState>(
            builder: (context, state) {
              if (state is UpdateDownloading) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('جاري تحميل التحديث...'),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(value: state.progress),
                    const SizedBox(height: 8),
                    Text(
                      '${(state.progress * 100).toStringAsFixed(1)}%',
                    ),
                  ],
                );
              }
              if (state is UpdateInstalling) {
                return const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('جاري تثبيت التحديث...'),
                  ],
                );
              }
              if (state is UpdateError) {
                return Text(
                  'حدث خطأ: ${state.message}',
                );
              }
              return Text(
                'الإصدار ${appVersion.version} متوفر.'
                ' هل تريد التحديث الآن؟',
              );
            },
          ),
          actions: [
            BlocBuilder<UpdateBloc, UpdateState>(
              builder: (context, state) {
                if (state is UpdateDownloading ||
                    state is UpdateInstalling) {
                  return const SizedBox.shrink();
                }

                final isError = state is UpdateError;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (!appVersion.isMandatory)
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('لاحقاً'),
                      ),
                    ElevatedButton(
                      onPressed: () {
                        context.read<UpdateBloc>().add(
                              StartDownloadEvent(appVersion.apkUrl),
                            );
                      },
                      child: Text(
                        isError ? 'إعادة المحاولة' : 'تحديث الآن',
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    ).whenComplete(() {
      if (mounted) {
        setState(() => _isDialogShowing = false);
      }
    });
  }
}
