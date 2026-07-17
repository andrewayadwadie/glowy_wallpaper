import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glowy_wallpaper/core/ads/widgets/anchored_adaptive_banner.dart';
import 'package:glowy_wallpaper/features/auth/domain/entities/user_entity.dart';
import 'package:glowy_wallpaper/features/auth/presentation/cubit/subscription_cubit.dart';
import 'package:glowy_wallpaper/features/auth/presentation/cubit/subscription_state.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class MockSubscriptionCubit extends MockCubit<SubscriptionState>
    implements SubscriptionCubit {}

class _TestLoadAdError extends LoadAdError {
  _TestLoadAdError(super.code, super.domain, super.message, super.responseInfo);
}

/// A [BannerAd] stand-in whose [load] immediately reports failure.
class _FailingBannerAd extends Fake implements BannerAd {
  _FailingBannerAd(this.listener);

  @override
  final BannerAdListener listener;

  bool disposed = false;

  @override
  Future<void> load() async {
    listener.onAdFailedToLoad?.call(
      this,
      _TestLoadAdError(3, 'gma', 'No fill.', null),
    );
  }

  @override
  Future<void> dispose() async {
    disposed = true;
  }
}

const _premiumUser = UserEntity(
  id: 'u1',
  displayName: 'Test',
  email: 'test@example.com',
  isPremium: true,
);

Widget _wrap(SubscriptionCubit cubit, Widget child) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    builder: (_, _) => MaterialApp(
      home: BlocProvider<SubscriptionCubit>.value(
        value: cubit,
        child: Scaffold(body: Center(child: child)),
      ),
    ),
  );
}

void main() {
  late MockSubscriptionCubit subscriptionCubit;

  setUp(() {
    subscriptionCubit = MockSubscriptionCubit();
  });

  testWidgets('premium: renders no slot at all', (tester) async {
    whenListen(
      subscriptionCubit,
      const Stream<SubscriptionState>.empty(),
      initialState: const SubscriptionState.premium(user: _premiumUser),
    );

    await tester.pumpWidget(
      _wrap(
        subscriptionCubit,
        AnchoredAdaptiveBanner(
          sizeResolver: (_) async => AdSize.banner,
          adBuilder: (size, listener) => _FailingBannerAd(listener),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AdWidget), findsNothing);
    expect(tester.getSize(find.byType(AnchoredAdaptiveBanner)), Size.zero);
  });

  testWidgets('load failure (after one retry): slot collapses, no grey box', (
    tester,
  ) async {
    whenListen(
      subscriptionCubit,
      const Stream<SubscriptionState>.empty(),
      initialState: const SubscriptionState.guest(),
    );

    final createdAds = <_FailingBannerAd>[];
    await tester.pumpWidget(
      _wrap(
        subscriptionCubit,
        AnchoredAdaptiveBanner(
          sizeResolver: (_) async => AdSize.banner,
          adBuilder: (size, listener) {
            final ad = _FailingBannerAd(listener);
            createdAds.add(ad);
            return ad;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    // One initial attempt + one retry, then collapse (FR-012).
    expect(createdAds.length, 2);
    expect(find.byType(AdWidget), findsNothing);
    expect(tester.getSize(find.byType(AnchoredAdaptiveBanner)), Size.zero);
  });

  testWidgets('unresolvable adaptive size: slot collapses', (tester) async {
    whenListen(
      subscriptionCubit,
      const Stream<SubscriptionState>.empty(),
      initialState: const SubscriptionState.guest(),
    );

    await tester.pumpWidget(
      _wrap(
        subscriptionCubit,
        AnchoredAdaptiveBanner(
          sizeResolver: (_) async => null,
          adBuilder: (size, listener) => _FailingBannerAd(listener),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.getSize(find.byType(AnchoredAdaptiveBanner)), Size.zero);
  });
}
