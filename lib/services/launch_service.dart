import 'dart:io';
import 'package:package_info_plus/package_info_plus.dart';

class LaunchService {
  static Future<void> setup() async {
    // No-op for now, just to match the structure
  }

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
      print('Error checking login items: $e');
    }
    return false;
  }

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

      await Process.run('osascript', [
        '-e',
        'tell application "System Events" to make login item at end with properties {path:"$appPath", name:"$appName", hidden:false}'
      ]);
    } catch (e) {
      print('Error enabling login item: $e');
      rethrow;
    }
  }

  static Future<void> disable() async {
    if (!Platform.isMacOS) return;

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final appName = packageInfo.appName;

      await Process.run('osascript', [
        '-e',
        'tell application "System Events" to delete login item "$appName"'
      ]);
    } catch (e) {
      print('Error disabling login item: $e');
      rethrow;
    }
  }
}
