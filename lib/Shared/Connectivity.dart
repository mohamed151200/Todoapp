import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:get/get.dart';

class ConnectivityController extends GetxController {
  var isConnected = true.obs;
  
  late StreamSubscription<List<ConnectivityResult>> _subscription;
  
  final Connectivity _connectivity = Connectivity();

  @override
  void onInit() {
    super.onInit();
    _checkInitialConnection();
    
_subscription = _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
  _updateConnectionStatus(results.first); 
});  }

  Future<void> _checkInitialConnection() async {
    List<ConnectivityResult> result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result.first);
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    if (result == ConnectivityResult.none) {
      isConnected.value = false;
      Get.snackbar(
        "لا يوجد إنترنت",
        "تم تفعيل وضع الأوفلاين",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } else {
      isConnected.value = true;
    }
  }
 
}