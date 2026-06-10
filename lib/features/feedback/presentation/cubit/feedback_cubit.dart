import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/feedback_entry.dart';
import '../../domain/i_feedback_diagnostics_collector.dart';
import '../../domain/usecases/submit_feedback_usecase.dart';
import '../../../analytics/domain/i_analytics_service.dart';
import '../../../push_notifications/domain/i_install_id_provider.dart';
import '../../../rating/domain/i_rating_service.dart';
import 'feedback_state.dart';

class FeedbackCubit extends Cubit<FeedbackState> {
  FeedbackCubit(
    this._submitFeedback,
    this._collectDiagnostics, {
    IAnalyticsService? analytics,
    IRatingService? rating,
    IInstallIdProvider? installIdProvider,
  }) : _analytics = analytics,
       _rating = rating,
       _installIdProvider = installIdProvider,
       super(const FeedbackState());

  final SubmitFeedbackUseCase _submitFeedback;
  final IFeedbackDiagnosticsCollector _collectDiagnostics;
  final IAnalyticsService? _analytics;
  final IRatingService? _rating;
  final IInstallIdProvider? _installIdProvider;

  Future<void> submit({
    required String message,
    String? contact,
    Map<String, String> settingsSnapshot = const {},
  }) async {
    if (message.trim().isEmpty) return;

    // Contact (email/Telegram) is required so we can actually reply.
    final trimmedContact = contact?.trim() ?? '';
    if (trimmedContact.isEmpty) {
      emit(state.copyWith(isContactMissing: true, clearError: true));
      return;
    }

    emit(
      state.copyWith(
        isLoading: true,
        isContactMissing: false,
        clearError: true,
      ),
    );

    final device = await _collectDiagnostics.collect();
    final diagnostics = {...settingsSnapshot, ...device};
    final platform = device['deviceType'] == 'tv'
        ? 'android-tv'
        : (Platform.isAndroid ? 'android' : 'ios');
    // Resolve install-id silently — older builds without the provider, or a
    // SharedPreferences read failure, still produce a valid feedback entry.
    String? deviceId;
    final idResult = await _installIdProvider?.getOrCreate();
    deviceId = idResult?.fold((_) => null, (v) => v);

    final entry = FeedbackEntry(
      type: 'general',
      message: message.trim(),
      platform: platform,
      contact: trimmedContact,
      diagnostics: diagnostics,
      createdAt: DateTime.now(),
      deviceId: deviceId,
    );

    final result = await _submitFeedback(entry);
    result.fold(
      (failure) =>
          emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (_) {
        _analytics?.logFeedbackSubmitted('general');
        // إرسال الملاحظة = تفاعل كافٍ، لا داعي لإزعاج المستخدم بنافذة التقييم لاحقاً.
        _rating?.markAsRated();
        emit(state.copyWith(isLoading: false, isSuccess: true));
      },
    );
  }
}
