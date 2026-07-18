import 'dart:io' show Platform;

class ApiConstants {
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080/api';
    }
    return 'http://localhost:8080/api';
  }

  // Auth
  static const String login = '/auth/login';

  // Inventory
  static const String inventoryItems = '/inventory/items';
  static const String inventoryAdjustments = '/inventory/adjustments';
  static const String inventoryLowStock = '/inventory/low-stock';
  static const String expenses = '/inventory/expenses/report';

  static String inventoryItemById(String id) => '/inventory/items/$id';
  static String inventoryItemPrice(String id) => '/inventory/items/$id/unit-price';
  static String inventoryItemDeactivate(String id) =>
      '/inventory/items/$id/deactivate';
  static String inventoryItemHistory(String id) =>
      '/inventory/items/$id/history';
  static const String services = '/services';
  static String serviceById(String id) => '/services/$id';
  static String servicePrice(String id) => '/services/$id/unit-price';
}
