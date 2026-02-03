
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Service responsible for managing "Launch at Login" functionality on macOS.
class LaunchService {
  static Future<void> setup() async {
    // No-op for now, just to match the structure
  }

  /// Checks if the app is currently set to launch at login.
  static Future<bool> isEnabled() async {
    if (!Platform.isMacOS) return false;

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final appName = packageInfo.appName;

      final result = await Process.run('osascript', [
        '-e',
        'tell application "System Events" to get name of every login item'
      ]);

      if (result.exitCode == 0) {
        final items = result.stdout.toString();
        return items.contains(appName);
      }
    } catch (e) {
      debugPrint('Error checking login items: $e');
    }
    return false;
  }

  /// Enables the app to launch at login.
  static Future<void> enable() async {
    if (!Platform.isMacOS) return;

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final appName = packageInfo.appName;

      String appPath = Platform.resolvedExecutable;
      if (appPath.contains('.app/Contents/MacOS/')) {
        appPath = appPath.substring(0, appPath.indexOf('.app/Contents/MacOS/') + 4);
      }

      // Check if already enabled to avoid duplicates
      if (await isEnabled()) return;

      final result = await Process.run('osascript', [
        '-e',
        'tell application "System Events" to make login item at end with properties {path:"$appPath", name:"$appName", hidden:false}'
      ]);
      
      if (result.exitCode != 0) {
        throw Exception('Failed to add login item: ${result.stderr}');
      }
    } catch (e) {
      debugPrint('Error enabling login item: $e');
      rethrow;
    }
  }

  /// Disables the app from launching at login.
  static Future<void> disable() async {
    if (!Platform.isMacOS) return;

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final appName = packageInfo.appName;

      final result = await Process.run('osascript', [
        '-e',
        'tell application "System Events" to delete login item "$appName"'
      ]);

      if (result.exitCode != 0) {
        // This might happen if it doesn't exist, which is fine
        debugPrint('Note: Could not delete login item (might not exist): ${result.stderr}');
      }
    } catch (e) {
      debugPrint('Error disabling login item: $e');
      rethrow;
    }
  }
}
