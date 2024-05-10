import 'package:flutter/services.dart';

class BackgroundService {
  static const platform = MethodChannel('com.yourapp/background');

  static Future<void> startEsmTestLogCheck() async {
    try {
      await platform.invokeMethod('startCheckEsmTestLog');
    } on PlatformException catch (e) {
      print("Failed to start esm test log check: '${e.message}'.");
    }
  }
}
