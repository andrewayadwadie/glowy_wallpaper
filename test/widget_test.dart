import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glowy_wallpaper/core/utils/app_strings.dart';
import 'package:glowy_wallpaper/features/home/presentation/pages/home_page.dart';

void main() {
  testWidgets('HomePage displays app name and empty content', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomePage()));

    expect(find.text(AppStrings.appName), findsOneWidget);
    expect(find.text(AppStrings.emptyContent), findsOneWidget);
  });
}
