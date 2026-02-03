
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:wifi_speed_monitor/main.dart';
import 'package:wifi_speed_monitor/services/settings_service.dart';
import 'package:wifi_speed_monitor/services/system_monitor_service.dart';
import 'package:wifi_speed_monitor/models/system_stats.dart';

class MockSettingsService extends ChangeNotifier implements SettingsService {
  @override bool get showWifi => true;
  @override bool get showCpu => true;
  @override bool get showRam => true;
  @override bool get showDisk => true;
  @override bool get launchAtLogin => false;

  @override Future<void> setShowWifi(bool v) async {}
  @override Future<void> setShowCpu(bool v) async {}
  @override Future<void> setShowRam(bool v) async {}
  @override Future<void> setShowDisk(bool v) async {}
  @override Future<void> setLaunchAtLogin(bool v) async {}
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

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SettingsService>.value(value: settingsService),
          ChangeNotifierProvider<SystemMonitorService>.value(value: monitorService),
        ],
        child: const MyApp(),
      ),
    );

    expect(find.text('SystemMonitoring'), findsAtLeastNWidgets(1));
  });
}
