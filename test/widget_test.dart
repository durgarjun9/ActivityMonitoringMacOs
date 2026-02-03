// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wifi_speed_monitor/main.dart';
import 'package:provider/provider.dart';
import 'package:wifi_speed_monitor/services/settings_service.dart';
import 'package:wifi_speed_monitor/services/system_monitor_service.dart';
import 'package:wifi_speed_monitor/models/system_stats.dart';

class MockSettingsService extends ChangeNotifier implements SettingsService {
  @override bool get showWifi => true;
  @override bool get showCpu => true;
  @override bool get showRam => true;
  @override bool get showDisk => true;
  @override Future<void> setShowWifi(bool v) async {}
  @override Future<void> setShowCpu(bool v) async {}
  @override Future<void> setShowRam(bool v) async {}
  @override Future<void> setShowDisk(bool v) async {}
}

class MockMonitorService extends ChangeNotifier implements SystemMonitorService {
  @override SystemStats get stats => SystemStats();
  @override void start() {}
  @override void stop() {}
}

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    final settingsService = MockSettingsService();
    final monitorService = MockMonitorService();

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SettingsService>.value(value: settingsService),
          ChangeNotifierProvider<SystemMonitorService>.value(value: monitorService),
        ],
        child: const MyApp(),
      ),
    );

    // Verify that the app title is present.
    expect(find.text('SystemMonitoring'), findsAtLeastNWidgets(1));
  });
}
