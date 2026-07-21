import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:management_app/modules/catalogue_management/viewmodel/inventory_viewmodel.dart';
import 'package:management_app/modules/catalogue_management/viewmodel/service_viewmodel.dart';

class WebSocketService extends GetxService {
  StompClient? _client;

  String get _wsUrl {
    if (kIsWeb) return 'ws://localhost:8080/ws';
    try {
      if (Platform.isAndroid) return 'ws://10.0.2.2:8080/ws';
    } catch (_) {}
    return 'ws://localhost:8080/ws';
  }

  @override
  void onInit() {
    super.onInit();
    _connect();
  }

  void _connect() {
    _client = StompClient(
      config: StompConfig(
        url: _wsUrl,
        onConnect: _onConnect,
        onWebSocketError: (dynamic e) =>
            print('WebSocket connection error: $e'),
        onStompError: (StompFrame frame) =>
            print('STOMP protocol error: ${frame.body}'),
        onDisconnect: (frame) => print('WebSocket disconnected'),
        reconnectDelay: const Duration(seconds: 5),
      ),
    );
    _client?.activate();
  }

  void _onConnect(StompFrame frame) {
    print('WebSocket connected successfully');

    // Subscribe to inventory catalogue updates (e.g. price change)
    _client?.subscribe(
      destination: '/topic/inventory-updates',
      callback: (StompFrame frame) {
        if (frame.body != null) {
          try {
            print('WS Received Inventory Update: ${frame.body}');
            if (Get.isRegistered<InventoryViewModel>()) {
              Get.find<InventoryViewModel>().fetchItems();
            }
          } catch (e) {
            print('Error handling WS inventory frame: $e');
          }
        }
      },
    );

    // Subscribe to service catalogue updates (e.g. price change)
    _client?.subscribe(
      destination: '/topic/service-updates',
      callback: (StompFrame frame) {
        if (frame.body != null) {
          try {
            print('WS Received Service Update: ${frame.body}');
            if (Get.isRegistered<ServiceViewModel>()) {
              Get.find<ServiceViewModel>().fetchServices();
            }
          } catch (e) {
            print('Error handling WS service frame: $e');
          }
        }
      },
    );
  }

  @override
  void onClose() {
    _client?.deactivate();
    super.onClose();
  }
}
