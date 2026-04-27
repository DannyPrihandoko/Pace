import 'package:storage_space/storage_space.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class StorageUtils {
  /// Minimum storage required to perform an operation (in MB)
  static const int minRequiredMb = 5;

  /// Checks if the device has enough storage space.
  /// Returns true if space is sufficient, false otherwise.
  static Future<bool> hasEnoughSpace() async {
    if (kIsWeb) return true; // Web storage is handled by the browser
    
    try {
      StorageSpace space = await getStorageSpace(
        lowOnSpaceThreshold: 100 * 1024 * 1024, // 100MB
        fractionDigits: 1,
      );
      
      // Convert free space to MB
      double freeMb = space.freeSize / (1024 * 1024);
      
      return freeMb > minRequiredMb;
    } catch (e) {
      debugPrint('Error checking storage space: $e');
      // If check fails, we assume it's okay but log the error
      return true; 
    }
  }
}
