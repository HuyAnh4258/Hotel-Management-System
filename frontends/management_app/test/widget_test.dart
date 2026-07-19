import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:management_app/modules/auth/view/splash_page.dart';

void main() {
  testWidgets('Management app renders splash shell', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(
        getPages: [
          GetPage(
            name: '/login',
            page: () => const Scaffold(body: Text('Login ready')),
          ),
        ],
        home: const SplashPage(),
      ),
    );

    expect(find.text('FPT Golden'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump();

    expect(find.text('Login ready'), findsOneWidget);
  });
}
