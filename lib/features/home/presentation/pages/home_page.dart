import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glowy_wallpaper/core/utils/app_dimens.dart';
import 'package:glowy_wallpaper/core/utils/app_strings.dart';
import 'package:glowy_wallpaper/features/auth/presentation/cubit/subscription_cubit.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(AppStrings.appName, maxLines: 1),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => _onProfileTapped(context),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(AppDimens.paddingM),
          child: AutoSizeText(
            AppStrings.emptyContent,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  void _onProfileTapped(BuildContext context) {
    final subscriptionCubit = context.read<SubscriptionCubit>();
    if (subscriptionCubit.isPremium) {
      // TODO: Navigate to profile page - will be implemented in Phase 7
    } else {
      // TODO: Show guest profile bottom sheet - will be implemented in Phase 7
    }
  }
}
