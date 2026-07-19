import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'modules/booking/view/booking_home_page.dart';
import 'modules/booking/view/intro_page.dart';
import 'modules/auth/view/login_page.dart';
import 'modules/auth/view/splash_page.dart';
import 'modules/auth/viewmodel/auth_viewmodel.dart';

class BookingApp extends StatelessWidget {
  const BookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Booking App',
      debugShowCheckedModeBanner: false,
      initialBinding: BindingsBuilder(() {
        Get.put(AuthViewModel(), permanent: true);
      }),
      initialRoute: '/intro',
      getPages: [
        GetPage(name: '/splash', page: () => const SplashPage()),
        GetPage(name: '/login', page: () => const LoginPage()),
        GetPage(name: '/intro', page: () => const IntroPage()),
        GetPage(name: '/dashboard', page: () => const BookingHomePage()),
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6F8FC),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}
