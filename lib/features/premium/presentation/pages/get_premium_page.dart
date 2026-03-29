import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/app_strings.dart';
import '../cubit/premium_cubit.dart';
import '../cubit/premium_state.dart';
import '../widgets/feature_comparison_widget.dart';
import '../widgets/plan_card_widget.dart';

class GetPremiumPage extends StatefulWidget {
  const GetPremiumPage({super.key});

  @override
  State<GetPremiumPage> createState() => _GetPremiumPageState();
}

class _GetPremiumPageState extends State<GetPremiumPage> {
  @override
  void initState() {
    super.initState();
    context.read<PremiumCubit>().loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.getPremium),
        centerTitle: true,
      ),
      body: BlocConsumer<PremiumCubit, PremiumState>(
        listener: (context, state) {
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.successMessage!),
                  backgroundColor: theme.brightness == Brightness.dark
                      ? AppColors.darkSuccess
                      : AppColors.success,
                ),
              );
            context.read<PremiumCubit>().clearMessages();
          }
          if (state.errorMessage != null &&
              (state.isPurchasing == false && state.isRestoring == false)) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: theme.colorScheme.error,
                ),
              );
            context.read<PremiumCubit>().clearMessages();
          }
        },
        builder: (context, state) {
          if (state.productsStatus == Status.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.productsStatus == Status.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.errorMessage ?? AppStrings.productsError,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<PremiumCubit>().loadProducts(),
                    child: const Text(AppStrings.retry),
                  ),
                ],
              ),
            );
          }

          if (state.productsStatus == Status.empty) {
            return const Center(child: Text(AppStrings.productsError));
          }

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Column(
              children: [
                // Feature comparison
                const FeatureComparisonWidget(),
                SizedBox(height: 24.h),

                // Plan selection
                Text(
                  AppStrings.choosePlan,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: state.products.map((product) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: PlanCardWidget(
                        product: product,
                        isSelected: state.selectedProduct == product,
                        onTap: () =>
                            context.read<PremiumCubit>().selectProduct(product),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 32.h),

                // Subscribe button
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: ElevatedButton(
                      onPressed:
                          state.isPurchasing || state.selectedProduct == null
                          ? null
                          : () => context.read<PremiumCubit>().purchase(),
                      child: state.isPurchasing
                          ? SizedBox(
                              height: 24.r,
                              width: 24.r,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: theme.colorScheme.onPrimary,
                              ),
                            )
                          : const Text(AppStrings.subscribeNow),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                // Restore purchase button
                TextButton(
                  onPressed: state.isRestoring
                      ? null
                      : () => context.read<PremiumCubit>().restore(),
                  child: state.isRestoring
                      ? SizedBox(
                          height: 16.r,
                          width: 16.r,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(AppStrings.restorePurchase),
                ),
                SizedBox(height: 16.h),
              ],
            ),
          );
        },
      ),
    );
  }
}
