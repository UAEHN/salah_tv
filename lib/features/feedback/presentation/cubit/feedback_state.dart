class FeedbackState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;

  const FeedbackState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  FeedbackState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    bool clearError = false,
  }) {
    return FeedbackState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
