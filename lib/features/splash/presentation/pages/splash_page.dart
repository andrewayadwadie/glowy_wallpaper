import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:glowy_wallpaper/core/routes/routes.dart';
import 'package:glowy_wallpaper/core/widgets/app_error_widget.dart';
import 'package:glowy_wallpaper/features/auth/presentation/cubit/subscription_cubit.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      final subscriptionCubit = context.read<SubscriptionCubit>();
      await subscriptionCubit.checkStatus();
      if (mounted) {
        context.go(AppRoutes.home);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Something went wrong';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Scaffold(
        // Matches native splash background - intentionally hardcoded
        backgroundColor: const Color(0xFF121212),
        body: AppErrorWidget(
          message: _errorMessage,
          onRetry: () {
            setState(() => _hasError = false);
            _initializeApp();
          },
        ),
      );
    }

    return Scaffold(
      // Matches native splash background - intentionally hardcoded
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AutoSizeText(
              'Glowy Wallpapers',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}
