import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/feedback_entry.dart';
import '../../domain/usecases/submit_feedback_usecase.dart';
import '../../../analytics/domain/i_analytics_service.dart';
import '../../../rating/domain/i_rating_service.dart';
import 'feedback_state.dart';

class FeedbackCubit extends Cubit<FeedbackState> {
  FeedbackCubit(
    this._submitFeedback, {
    IAnalyticsService? analytics,
    IRatingService? rating,
  })  : _analytics = analytics,
        _rating = rating,
        super(const FeedbackState());

  final SubmitFeedbackUseCase _submitFeedback;
  final IAnalyticsService? _analytics;
  final IRatingService? _rating;

  Future<void> submit(String message) async {
    if (message.trim().isEmpty) return;
    emit(state.copyWith(isLoading: true, clearError: true));

    final entry = FeedbackEntry(
      type: 'general',
      message: message.trim(),
      platform: Platform.isAndroid ? 'android' : 'ios',
      createdAt: DateTime.now(),
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
