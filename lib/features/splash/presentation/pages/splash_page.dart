import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:glowy_wallpaper/core/ads/managers/app_open_ad_manager.dart';
import 'package:glowy_wallpaper/core/routes/routes.dart';
import 'package:glowy_wallpaper/core/widgets/app_error_widget.dart';
import 'package:glowy_wallpaper/core/di/injection_container.dart';
import 'package:glowy_wallpaper/core/theme/colors.dart';
import 'package:glowy_wallpaper/core/utils/app_assets.dart';
import 'package:glowy_wallpaper/core/utils/app_strings.dart';
import 'package:glowy_wallpaper/features/auth/presentation/cubit/subscription_cubit.dart';
import 'package:glowy_wallpaper/features/auth/presentation/cubit/subscription_state.dart';
import 'package:glowy_wallpaper/features/notifications/domain/services/notification_service.dart';
import 'package:glowy_wallpaper/features/premium/domain/usecases/get_subscription_status.dart';
import 'package:glowy_wallpaper/core/usecases/usecase.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  bool _hasError = false;
  String _errorMessage = '';

  late final AnimationController _controller;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _titleOpacity;
  late final Animation<double> _titleSlide;
  late final Animation<double> _glowOpacity;
  late final Animation<double> _taglineOpacity;
  late final Animation<double> _taglineSlide;
  late final Animation<double> _featuresOpacity;
  late final Animation<double> _featuresSlide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    // Logo: scale from 0.6 → 1.0 and fade in (0–400ms)
    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOutCubic),
      ),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.25, curve: Curves.easeOut),
      ),
    );

    // Neon glow pulse on logo (peaks at 0.3, sustains)
    _glowOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 0.45, curve: Curves.easeOut),
      ),
    );

    // Title: slide up + fade in (200–600ms)
    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.20, 0.45, curve: Curves.easeOut),
      ),
    );
    _titleSlide = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.20, 0.50, curve: Curves.easeOutCubic),
      ),
    );

    // Tagline: slide up + fade in (400–700ms)
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.58, curve: Curves.easeOut),
      ),
    );
    _taglineSlide = Tween<double>(begin: 16.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.62, curve: Curves.easeOutCubic),
      ),
    );

    // Feature pills: slide up + fade in (550–850ms)
    _featuresOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.50, 0.75, curve: Curves.easeOut),
      ),
    );
    _featuresSlide = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.50, 0.78, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();
    _initializeApp();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    try {
      final subscriptionCubit = context.read<SubscriptionCubit>();
      await subscriptionCubit.checkStatus();

      if (!mounted) return;

      final subscriptionState = subscriptionCubit.state;

      // Cold-start lapse detection: if premium, verify with server
      if (subscriptionState is SubscriptionPremium) {
        final getStatus = sl<GetSubscriptionStatus>();
        final statusResult = await getStatus(NoParams());
        statusResult.fold(
          (_) {
            // Network error — keep cached premium (optimistic)
          },
          (subscription) {
            if (!subscription.isPremium) {
              // Subscription lapsed — revert to free
              subscriptionCubit.setGuest();
            }
          },
        );
      }

      if (!mounted) return;

      // Re-read state after potential lapse detection
      final currentState = subscriptionCubit.state;

      if (currentState is SubscriptionGuest) {
        // App-open ad after splash if one is preloaded; non-blocking when
        // none is ready (US2, FR-007).
        await sl<AppOpenAdManager>().showIfAvailable(
          source: AppOpenAdManager.sourceSplash,
        );
      }

      if (mounted) {
        final notificationService = sl<NotificationService>();
        final pendingRoute = notificationService.pendingRoute;

        // Only consume pending route if user is authenticated
        final isAuthenticated = subscriptionCubit.state is! SubscriptionGuest;
        if (pendingRoute != null && isAuthenticated) {
          notificationService.clearPendingRoute();
          context.go(pendingRoute);
        } else {
          context.go(AppRoutes.home);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = AppStrings.error;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Scaffold(
        // Matches native splash background — intentionally hardcoded
        backgroundColor: AppColors.darkBackground,
        body: AppErrorWidget(
          message: _errorMessage,
          onRetry: () {
            setState(() => _hasError = false);
            _controller.forward(from: 0);
            _initializeApp();
          },
        ),
      );
    }

    return Scaffold(
      // Matches native splash background — intentionally hardcoded
      backgroundColor: AppColors.darkBackground,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Logo with neon glow ──
                Opacity(
                  opacity: _logoOpacity.value,
                  child: Transform.scale(
                    scale: _logoScale.value,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.darkPrimary.withValues(
                              alpha: 0.5 * _glowOpacity.value,
                            ),
                            blurRadius: 40 * _glowOpacity.value,
                            spreadRadius: 8 * _glowOpacity.value,
                          ),
                          BoxShadow(
                            color: AppColors.darkPrimary.withValues(
                              alpha: 0.25 * _glowOpacity.value,
                            ),
                            blurRadius: 80 * _glowOpacity.value,
                            spreadRadius: 16 * _glowOpacity.value,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24.r),
                        child: SvgPicture.asset(
                          AppAssets.logoSvg,
                          width: 100.w,
                          height: 100.w,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 28.h),

                // ── App name with neon glow text ──
                Transform.translate(
                  offset: Offset(0, _titleSlide.value),
                  child: Opacity(
                    opacity: _titleOpacity.value,
                    child: ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          AppColors.darkOnSurface,
                          AppColors.darkPrimary,
                          AppColors.darkOnSurface,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ).createShader(bounds),
                      child: AutoSizeText(
                        AppStrings.appName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 12.h),

                // ── Tagline ──
                Transform.translate(
                  offset: Offset(0, _taglineSlide.value),
                  child: Opacity(
                    opacity: _taglineOpacity.value,
                    child: AutoSizeText(
                      'Stunning wallpapers crafted for your screen',
                      style: TextStyle(
                        color: AppColors.darkOnSurface.withValues(alpha: 0.6),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                  ),
                ),

                SizedBox(height: 32.h),

                // ── Feature pills ──
                Transform.translate(
                  offset: Offset(0, _featuresSlide.value),
                  child: Opacity(
                    opacity: _featuresOpacity.value,
                    child: Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      alignment: WrapAlignment.center,
                      children: const [
                        _FeaturePill(
                          icon: Icons.hd_outlined,
                          label: 'HD & 4K Quality',
                        ),
                        _FeaturePill(
                          icon: Icons.category_outlined,
                          label: 'Curated Collections',
                        ),
                        _FeaturePill(
                          icon: Icons.download_outlined,
                          label: 'Free Downloads',
                        ),
                        _FeaturePill(
                          icon: Icons.play_circle_outline,
                          label: 'Live Wallpapers',
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 48.h),

                // ── Loading indicator ──
                Opacity(
                  opacity: _featuresOpacity.value,
                  child: SizedBox(
                    width: 24.w,
                    height: 24.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.w,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.darkPrimary.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeaturePill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.darkPrimary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: AppColors.darkPrimary),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              color: AppColors.darkOnSurface.withValues(alpha: 0.8),
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
