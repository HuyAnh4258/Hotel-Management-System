import 'package:get/get.dart';
import 'package:management_app/modules/auth/view/forgot_password_page.dart';
import 'package:management_app/modules/auth/view/login_page.dart';
import 'package:management_app/modules/auth/view/splash_page.dart';
import 'package:management_app/modules/dashboard/view/dashboard_page.dart';
import 'package:management_app/modules/operation_analysis/view/pricing_page.dart';
import 'package:management_app/modules/catalogue_management/view/inventory_page.dart';
import 'package:management_app/modules/operation_analysis/view/services_page.dart';

class AppPages {
  static final routes = [
    GetPage(name: '/splash', page: () => const SplashPage()),
    GetPage(name: '/login', page: () => LoginPage()),
    GetPage(name: '/forgot-password', page: () => const ForgotPasswordPage()),
    GetPage(name: '/dashboard', page: () => const DashboardPage()),
    GetPage(name: '/pricing', page: () => const PricingPage()),
    GetPage(name: '/inventory', page: () => const InventoryPage()),
    GetPage(name: '/services', page: () => const ServicesPage()),
  ];
}
