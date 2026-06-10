/// Snapshot of the OS-level push notification permission grant.
/// Used by the onboarding flow to decide whether to show the rationale prompt
/// before requesting the system permission.
enum PushPermissionStatus { granted, denied, provisional, notDetermined }
