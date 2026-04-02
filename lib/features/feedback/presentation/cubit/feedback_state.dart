class FeedbackState {
  final String selectedType;
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;

  const FeedbackState({
    this.selectedType = 'bug',
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  FeedbackState copyWith({
    String? selectedType,
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    bool clearError = false,
  }) {
    return FeedbackState(
      selectedType: selectedType ?? this.selectedType,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
