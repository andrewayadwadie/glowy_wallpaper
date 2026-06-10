import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glowy_wallpaper/core/utils/app_strings.dart';
import 'package:glowy_wallpaper/features/auth/domain/entities/user_entity.dart';
import 'package:glowy_wallpaper/features/auth/presentation/cubit/subscription_cubit.dart';
import 'package:glowy_wallpaper/features/auth/presentation/cubit/subscription_state.dart';
import 'package:glowy_wallpaper/features/home/presentation/cubit/home_cubit.dart';
import 'package:glowy_wallpaper/features/home/presentation/cubit/home_state.dart';
import 'package:glowy_wallpaper/features/home/presentation/pages/home_page.dart';
import 'package:mocktail/mocktail.dart';

class MockSubscriptionCubit extends MockCubit<SubscriptionState>
    implements SubscriptionCubit {}

class MockHomeCubit extends MockCubit<HomeState> implements HomeCubit {}

const _premiumUser = UserEntity(
  id: 'u1',
  displayName: 'Test',
  email: 'test@example.com',
  isPremium: true,
);

void main() {
  testWidgets('HomePage smoke test: renders the app bar title', (
    WidgetTester tester,
  ) async {
    final subscriptionCubit = MockSubscriptionCubit();
    final homeCubit = MockHomeCubit();
    // Premium user: no banner slot, so the test needs no ad DI/SDK setup.
    whenListen(
      subscriptionCubit,
      const Stream<SubscriptionState>.empty(),
      initialState: const SubscriptionState.premium(user: _premiumUser),
    );
    when(() => subscriptionCubit.isPremium).thenReturn(true);
    whenListen(
      homeCubit,
      const Stream<HomeState>.empty(),
      initialState: const HomeState(),
    );

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, _) => MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<SubscriptionCubit>.value(value: subscriptionCubit),
              BlocProvider<HomeCubit>.value(value: homeCubit),
            ],
            child: const HomePage(),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text(AppStrings.appNameHome), findsOneWidget);
  });
}
