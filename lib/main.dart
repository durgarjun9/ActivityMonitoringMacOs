
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/system_monitor_service.dart';
import 'services/settings_service.dart';
import 'services/tray_manager.dart';

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
      title: 'System Monitor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),
        cardTheme: CardThemeData(
          color: const Color(0xFF2D2D2D),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      home: const SettingsPage(),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>();
    final stats = context.watch<SystemMonitorService>().stats;


    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('System Monitor', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.black.withOpacity(0.2),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Dashboard Controls',
                  style: TextStyle(color: Colors.white70, fontSize: 14, letterSpacing: 1.2),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    children: [
                      _buildGlassCard(
                        context,
                        title: 'WiFi Throughput',
                        subtitle: '↓ ${stats.downloadSpeedStr}  ↑ ${stats.uploadSpeedStr}',
                        value: settings.showWifi,
                        icon: Icons.wifi_rounded,
                        color: Colors.greenAccent,
                        onChanged: (val) => settings.setShowWifi(val),
                      ),
                      const SizedBox(height: 16),
                      _buildGlassCard(
                        context,
                        title: 'CPU Performance',
                        subtitle: '${stats.cpuUsagePercent.toStringAsFixed(1)}% Active',
                        value: settings.showCpu,
                        icon: Icons.speed_rounded,
                        color: Colors.orangeAccent,
                        onChanged: (val) => settings.setShowCpu(val),
                      ),
                      const SizedBox(height: 16),
                      _buildGlassCard(
                        context,
                        title: 'Memory Usage',
                        subtitle: '${stats.ramUsagePercent.toStringAsFixed(1)}% of total RAM',
                        value: settings.showRam,
                        icon: Icons.memory_rounded,
                        color: Colors.blueAccent,
                        onChanged: (val) => settings.setShowRam(val),
                      ),
                      const SizedBox(height: 16),
                      _buildGlassCard(
                        context,
                        title: 'Disk Storage',
                        subtitle: '${stats.diskUsedGB.toStringAsFixed(1)} GB Used of ${stats.diskTotalGB.toStringAsFixed(0)} GB',
                        value: settings.showDisk,
                        icon: Icons.storage_rounded,
                        color: Colors.purpleAccent,
                        onChanged: (val) => settings.setShowDisk(val),
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'Monitoring Active in macOS Menu Bar',
                      style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required IconData icon,
    required Color color,
    required Function(bool) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          secondary: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          subtitle: Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.6))),
          value: value,
          onChanged: onChanged,
          activeColor: color,
        ),
      ),
    );
  }
}
