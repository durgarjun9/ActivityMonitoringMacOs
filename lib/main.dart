
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/app_theme.dart';
import 'services/system_monitor_service.dart';
import 'services/settings_service.dart';
import 'services/tray_manager.dart';
import 'ui/settings/settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  final settingsService = SettingsService(prefs);
  final monitorService = SystemMonitorService();
  
  final trayManager = TrayManager(monitorService, settingsService);
  await trayManager.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settingsService),
        ChangeNotifierProvider.value(value: monitorService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SystemMonitoring',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SettingsPage(),
    );
  }
}
