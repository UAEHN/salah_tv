import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/update_bloc.dart';
import '../bloc/update_event.dart';
import '../bloc/update_state.dart';
import '../../domain/entities/app_version.dart';

class UpdateListenerWidget extends StatelessWidget {
  final Widget child;

  const UpdateListenerWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<UpdateBloc, UpdateState>(
      listener: (context, state) {
        if (state is UpdateAvailable) {
          _showUpdateDialog(context, state.appVersion);
        }
      },
      child: child,
    );
  }

  void _showUpdateDialog(BuildContext context, AppVersion appVersion) {
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
    );
  }
}
