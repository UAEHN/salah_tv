class FeedbackState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;

  /// Set when the user tried to submit without filling the contact field.
  /// Surfaced inline next to the contact input rather than as a generic
  /// banner, so the cause is unmistakable.
  final bool isContactMissing;

  const FeedbackState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
    this.isContactMissing = false,
  });

  FeedbackState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    bool clearError = false,
    bool? isContactMissing,
  }) {
    return FeedbackState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isContactMissing: isContactMissing ?? this.isContactMissing,
    );
  }
}
