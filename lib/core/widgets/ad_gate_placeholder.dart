/// Placeholder for Phase 5 rewarded ad gate.
/// For free users, calls [onProceed] directly (auto-proceeds without an ad).
/// In Phase 5, this will be replaced with a rewarded ad flow.
Future<void> adGatePlaceholder({
  required Future<void> Function() onProceed,
}) async {
  // In Phase 5, check subscription state and show a rewarded ad for free users.
  // For now, auto-proceed for all users.
  await onProceed();
}
