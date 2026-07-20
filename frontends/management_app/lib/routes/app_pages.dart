import 'package:get/get.dart';
import 'package:management_app/modules/auth/view/forgot_password_page.dart';
import 'package:management_app/modules/auth/view/login_page.dart';
import 'package:management_app/modules/auth/view/splash_page.dart';
import 'package:management_app/modules/dashboard/view/dashboard_page.dart';
import 'package:management_app/modules/operation_analysis/view/pricing_page.dart';
import 'package:management_app/modules/catalogue_management/view/inventory_page.dart';
import 'package:management_app/modules/catalogue_management/view/voucher_page.dart';
import 'package:management_app/modules/catalogue_management/view/services_page.dart';
import 'package:management_app/modules/booking_management/view/receptionist_home_page.dart';

// New imported pages
import 'package:management_app/modules/employee_management/view/account_list_page.dart';
import 'package:management_app/modules/booking_management/view/room_list_page.dart';
import 'package:management_app/modules/operation_analysis/view/order_list_page.dart';
import 'package:management_app/modules/operation_analysis/view/owner_dashboard_page.dart';
import 'package:management_app/modules/profile/view/profile_page.dart';
import 'package:management_app/modules/property_management/view/property_page.dart';

class AppPages {
  static final routes = [
    GetPage(name: '/splash', page: () => const SplashPage()),
    GetPage(name: '/login', page: () => LoginPage()),
    GetPage(name: '/forgot-password', page: () => const ForgotPasswordPage()),
    GetPage(name: '/dashboard', page: () => const DashboardPage()),
    GetPage(name: '/pricing', page: () => const PricingPage()),
    GetPage(name: '/inventory', page: () => const InventoryPage()),
    GetPage(name: '/vouchers', page: () => const VoucherPage()),
    GetPage(name: '/services', page: () => const ServicesPage()),
    GetPage(name: '/receptionist', page: () => const ReceptionistHomePage()),
    
    // New pages from branch tien
    GetPage(name: '/accounts', page: () => const AccountListPage()),
    GetPage(name: '/housekeeper', page: () => const RoomListPage()),
    GetPage(name: '/service-staff', page: () => const OrderListPage()),
    GetPage(name: '/owner-dashboard', page: () => const OwnerDashboardPage()),
    GetPage(name: '/profile', page: () => const ProfilePage()),
    GetPage(name: '/property', page: () => const PropertyPage()),
  ];
}
