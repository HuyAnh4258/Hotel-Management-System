import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hms_shared/auth/auth_service.dart';
import 'package:hms_shared/auth/token_storage.dart';
import 'package:hms_shared/network/dio_client.dart';
import 'package:management_app/core/theme/app_theme.dart';
import 'package:management_app/modules/auth/viewmodel/auth_viewmodel.dart';
import 'package:management_app/modules/catalogue_management/viewmodel/inventory_viewmodel.dart';
import 'package:management_app/modules/operation_analysis/viewmodel/service_viewmodel.dart';
import 'package:management_app/core/services/websocket_service.dart';
import 'package:management_app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final tokenStorage = TokenStorage();
  final dioClient = DioClient(tokenStorage);

  await Get.putAsync(() async {
    final auth = AuthService(tokenStorage);
    await auth.init();
    return auth;
  });

  Get.put(AuthViewModel(dioClient, tokenStorage));
  Get.put(ServiceViewModel(dioClient));
  Get.put(InventoryViewModel(dioClient));
  Get.put(WebSocketService());

  runApp(const FptGoldenApp());
}

class FptGoldenApp extends StatelessWidget {
  const FptGoldenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'FPT Golden - HMS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: '/splash',
      getPages: AppPages.routes,
    );
  }
}
