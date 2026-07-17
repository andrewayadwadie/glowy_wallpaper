import 'package:flutter_test/flutter_test.dart';
import 'package:glowy_wallpaper/core/ads/consent_manager.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mocktail/mocktail.dart';

class MockConsentInformation extends Mock implements ConsentInformation {}

void main() {
  late MockConsentInformation mockConsentInformation;

  setUpAll(() {
    registerFallbackValue(ConsentRequestParameters());
  });

  setUp(() {
    mockConsentInformation = MockConsentInformation();
  });

  void stubInfoUpdateSuccess() {
    when(
      () =>
          mockConsentInformation.requestConsentInfoUpdate(any(), any(), any()),
    ).thenAnswer((invocation) {
      final success =
          invocation.positionalArguments[1]
              as OnConsentInfoUpdateSuccessListener;
      success();
    });
  }

  void stubInfoUpdateFailure() {
    when(
      () =>
          mockConsentInformation.requestConsentInfoUpdate(any(), any(), any()),
    ).thenAnswer((invocation) {
      final failure =
          invocation.positionalArguments[2]
              as OnConsentInfoUpdateFailureListener;
      failure(FormError(errorCode: 7, message: 'offline'));
    });
  }

  group('ConsentManager.gather', () {
    test(
      'shows the form (if required) after a successful info update',
      () async {
        stubInfoUpdateSuccess();
        var formRequested = false;
        final manager = ConsentManager(
          consentInformation: mockConsentInformation,
          loadAndShowConsentFormIfRequired: (listener) async {
            formRequested = true;
            listener(null);
          },
        );

        await manager.gather();

        expect(formRequested, isTrue);
      },
    );

    test('completes without showing a form when the info update fails '
        '(offline must not block launch)', () async {
      stubInfoUpdateFailure();
      var formRequested = false;
      final manager = ConsentManager(
        consentInformation: mockConsentInformation,
        loadAndShowConsentFormIfRequired: (listener) async {
          formRequested = true;
          listener(null);
        },
      );

      await manager.gather();

      expect(formRequested, isFalse);
    });

    test('completes when the form dismisses with an error', () async {
      stubInfoUpdateSuccess();
      final manager = ConsentManager(
        consentInformation: mockConsentInformation,
        loadAndShowConsentFormIfRequired: (listener) async {
          listener(FormError(errorCode: 3, message: 'form unavailable'));
        },
      );

      await expectLater(manager.gather(), completes);
    });

    test('completes (does not throw) when showing the form throws', () async {
      stubInfoUpdateSuccess();
      final manager = ConsentManager(
        consentInformation: mockConsentInformation,
        loadAndShowConsentFormIfRequired: (listener) async {
          throw StateError('boom');
        },
      );

      await expectLater(manager.gather(), completes);
    });

    test('forwards debug settings in the request parameters', () async {
      stubInfoUpdateSuccess();
      final manager = ConsentManager(
        consentInformation: mockConsentInformation,
        loadAndShowConsentFormIfRequired: (listener) async => listener(null),
      );
      final debugSettings = ConsentDebugSettings(
        debugGeography: DebugGeography.debugGeographyEea,
      );

      await manager.gather(debugSettings: debugSettings);

      final captured =
          verify(
                () => mockConsentInformation.requestConsentInfoUpdate(
                  captureAny(),
                  any(),
                  any(),
                ),
              ).captured.single
              as ConsentRequestParameters;
      expect(captured.consentDebugSettings, same(debugSettings));
    });
  });

  group('ConsentManager.canRequestAds', () {
    test('passes through the UMP value', () async {
      when(
        () => mockConsentInformation.canRequestAds(),
      ).thenAnswer((_) async => false);
      final manager = ConsentManager(
        consentInformation: mockConsentInformation,
        loadAndShowConsentFormIfRequired: (listener) async => listener(null),
      );

      expect(await manager.canRequestAds(), isFalse);
    });

    test('returns true when the UMP call throws', () async {
      when(
        () => mockConsentInformation.canRequestAds(),
      ).thenThrow(StateError('platform error'));
      final manager = ConsentManager(
        consentInformation: mockConsentInformation,
        loadAndShowConsentFormIfRequired: (listener) async => listener(null),
      );

      expect(await manager.canRequestAds(), isTrue);
    });
  });
}
