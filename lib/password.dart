import 'package:flutter/services.dart';

class NativePasswordService {
  // The channel name must exactly match the string used in Java
  static const platform = MethodChannel('com.furahadental/password');

  static Future<String> getPassword([int length = 14]) async {
    try {
      // Pass the method name and arguments to Android
      final String result = await platform.invokeMethod(
          'generateStrongPassword',
          {"length": length}
      );
      return result;
    } on PlatformException catch (e) {
      print("Failed to generate password: '${e.message}'.");
      return "Error123456!"; // Fallback
    }
  }
}