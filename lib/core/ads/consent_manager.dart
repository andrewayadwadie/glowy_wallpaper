import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Seam for [ConsentForm.loadAndShowConsentFormIfRequired] (static — not
/// mockable directly).
typedef LoadAndShowConsentFormIfRequired =
    Future<void> Function(OnConsentFormDismissedListener listener);

/// Google UMP consent flow (FR-025–FR-027, research R5).
///
/// Consent state itself is persisted by the UMP SDK — this class only
/// orchestrates the gather sequence and exposes `canRequestAds`.
/// Non-blocking semantics: every error path is swallowed (logged) so a
/// consent failure can never block app launch (FR-026).
class ConsentManager {
  ConsentManager({
    ConsentInformation? consentInformation,
    LoadAndShowConsentFormIfRequired? loadAndShowConsentFormIfRequired,
  }) : _consentInformation = consentInformation ?? ConsentInformation.instance,
       _loadAndShowConsentFormIfRequired =
           loadAndShowConsentFormIfRequired ??
           ConsentForm.loadAndShowConsentFormIfRequired;

  final ConsentInformation _consentInformation;
  final LoadAndShowConsentFormIfRequired _loadAndShowConsentFormIfRequired;

  /// Requests a consent info update and, when a form is required and
  /// available, loads and shows it (the SDK shows it only if required).
  ///
  /// Completes when consent is resolved or determined unnecessary. Never
  /// throws: offline / SDK errors resolve immediately and the app proceeds
  /// at the personalization level current consent permits (FR-026).
  ///
  /// Pass [debugSettings] (forced geography + test device ids) to test the
  /// prompt outside the EEA (FR-027).
  Future<void> gather({ConsentDebugSettings? debugSettings}) {
    final completer = Completer<void>();
    final params = ConsentRequestParameters(
      consentDebugSettings: debugSettings,
    );

    _consentInformation.requestConsentInfoUpdate(
      params,
      () async {
        try {
          await _loadAndShowConsentFormIfRequired((formError) {
            if (formError != null) {
              debugPrint(
                'Consent form error: ${formError.errorCode} '
                '${formError.message}',
              );
            }
            if (!completer.isCompleted) completer.complete();
          });
        } catch (e) {
          debugPrint('Consent form exception: $e');
          if (!completer.isCompleted) completer.complete();
        }
      },
      (FormError error) {
        debugPrint(
          'Consent info update failed: ${error.errorCode} ${error.message}',
        );
        if (!completer.isCompleted) completer.complete();
      },
    );

    return completer.future;
  }

  /// Whether ads may currently be requested (UMP `canRequestAds`).
  /// Returns `true` on error so an SDK failure never silences ads for
  /// regions where consent is not required.
  Future<bool> canRequestAds() async {
    try {
      return await _consentInformation.canRequestAds();
    } catch (e) {
      debugPrint('canRequestAds failed: $e');
      return true;
    }
  }
}
