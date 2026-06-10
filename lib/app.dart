import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:glowy_wallpaper/core/ads/ad_gatekeeper.dart';
import 'package:glowy_wallpaper/core/ads/managers/app_open_ad_manager.dart';
import 'package:glowy_wallpaper/core/di/injection_container.dart';
import 'package:glowy_wallpaper/core/theme/app_theme.dart';
import 'package:glowy_wallpaper/core/routes/app_router.dart';
import 'package:glowy_wallpaper/core/utils/app_strings.dart';
import 'package:glowy_wallpaper/features/auth/presentation/cubit/subscription_cubit.dart';
import 'package:glowy_wallpaper/features/auth/presentation/cubit/subscription_state.dart';

class GlowyApp extends StatefulWidget {
  const GlowyApp({super.key});

  @override
  State<GlowyApp> createState() => _GlowyAppState();
}

class _GlowyAppState extends State<GlowyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App-open ad on foreground resume, ≥4-min cap enforced by the manager
    // (US2, FR-010a).
    if (state == AppLifecycleState.resumed) {
      sl<AppOpenAdManager>().showIfAvailable(
        source: AppOpenAdManager.sourceResume,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => BlocProvider(
        create: (_) => sl<SubscriptionCubit>(),
        child: BlocListener<SubscriptionCubit, SubscriptionState>(
          // Premium ⇒ zero ads: keep the context-free gatekeeper in sync
          // for managers that can't read the cubit (FR-018, R10).
          listener: (context, state) {
            sl<AdGatekeeper>().shouldShowAds = state is! SubscriptionPremium;
          },
          child: MaterialApp.router(
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.dark,
            routerConfig: AppRouter.router,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
          ),
        ),
      ),
    );
  }
}
