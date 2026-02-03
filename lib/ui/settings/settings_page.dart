
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/settings_service.dart';
import '../../services/system_monitor_service.dart';
import '../../services/launch_service.dart';
import '../../widgets/glass_card.dart';
import '../../core/app_theme.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>();
    final monitorService = context.watch<SystemMonitorService>();
    final stats = monitorService.stats;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('SystemMonitoring'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppTheme.backgroundGradient,
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
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    children: [
                      GlassCard(
                        title: 'WiFi Throughput',
                        subtitle: '↓ ${stats.downloadSpeedStr}  ↑ ${stats.uploadSpeedStr}',
                        value: settings.showWifi,
                        icon: Icons.wifi_rounded,
                        color: Colors.greenAccent,
                        onChanged: (val) => settings.setShowWifi(val),
                      ),
                      const SizedBox(height: 16),
                      GlassCard(
                        title: 'CPU Performance',
                        subtitle: '${stats.cpuUsagePercent.toStringAsFixed(1)}% Active',
                        value: settings.showCpu,
                        icon: Icons.speed_rounded,
                        color: Colors.orangeAccent,
                        onChanged: (val) => settings.setShowCpu(val),
                      ),
                      const SizedBox(height: 16),
                      GlassCard(
                        title: 'Memory Usage',
                        subtitle: '${stats.ramUsagePercent.toStringAsFixed(1)}% of total RAM',
                        value: settings.showRam,
                        icon: Icons.memory_rounded,
                        color: Colors.blueAccent,
                        onChanged: (val) => settings.setShowRam(val),
                      ),
                      const SizedBox(height: 16),
                      GlassCard(
                        title: 'Disk Storage',
                        subtitle:
                            '${stats.diskAvailableGB.toStringAsFixed(1)} GB Available of ${stats.diskTotalGB.toStringAsFixed(0)} GB',
                        value: settings.showDisk,
                        icon: Icons.storage_rounded,
                        color: Colors.purpleAccent,
                        onChanged: (val) => settings.setShowDisk(val),
                      ),
                      const SizedBox(height: 16),
                      GlassCard(
                        title: 'Launch at Login',
                        subtitle: 'Automatically start app on system boot',
                        value: settings.launchAtLogin,
                        icon: Icons.launch_rounded,
                        color: Colors.redAccent,
                        onChanged: (val) => _handleLaunchAtLogin(context, settings, val),
                      ),
                    ],
                  ),
                ),
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text(
                      'Monitoring Active in macOS Menu Bar',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
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

  Future<void> _handleLaunchAtLogin(
    BuildContext context,
    SettingsService settings,
    bool val,
  ) async {
    try {
      if (val) {
        await LaunchService.enable();
      } else {
        await LaunchService.disable();
      }
      await settings.setLaunchAtLogin(val);
    } catch (e) {
      debugPrint('Failed to update launch at login: $e');
      // Even if OS level fails, we might want to keep the pref sync or not.
      // Current implementation in main.dart keeps it.
      await settings.setLaunchAtLogin(val);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not update system login setting: $e')),
        );
      }
    }
  }
}
