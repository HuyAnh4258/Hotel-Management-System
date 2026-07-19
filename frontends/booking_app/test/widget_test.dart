import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:booking_app/modules/auth/viewmodel/auth_viewmodel.dart';
import 'package:booking_app/modules/booking/view/booking_home_page.dart';
import 'package:booking_app/modules/booking/viewmodel/booking_viewmodel.dart';

void main() {
  tearDown(Get.reset);

  testWidgets('Booking app renders home shell', (WidgetTester tester) async {
    Get.put(AuthViewModel());

    await tester.pumpWidget(
      GetMaterialApp(
        home: BookingHomePage(
          homepageFuture: Future.value(HomepageData.empty()),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Hotel Booking'), findsOneWidget);
  });
}
