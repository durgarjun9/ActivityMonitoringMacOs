
import 'dart:io';
import 'package:system_tray/system_tray.dart';
import 'system_monitor_service.dart';
import 'settings_service.dart';

class TrayManager {
  final SystemMonitorService _monitorService;
  final SettingsService _settingsService;

  final SystemTray _mainTray = SystemTray();
  bool _isInitialized = false;

  TrayManager(this._monitorService, this._settingsService);

  Future<void> init() async {
    if (_isInitialized) return;

    // Use a generic monitor icon or the first one available
    await _mainTray.initSystemTray(
      title: 'Monitor',
      iconPath: 'assets/icons/wifi.png', // Fallback icon
    );

    final Menu menu = Menu();
    await menu.buildFrom([
      MenuItemLabel(label: 'Show Settings', onClicked: (menuItem) => AppWindow().show()),
      MenuSeparator(),
      MenuItemLabel(label: 'Exit', onClicked: (menuItem) => exit(0)),
    ]);
    await _mainTray.setContextMenu(menu);

    _monitorService.addListener(_updateTray);
    _settingsService.addListener(_updateTray);

    _updateTray();
    
    _isInitialized = true;
  }

  void _updateTray() {
    final stats = _monitorService.stats;
    final settings = _settingsService;
    
    List<String> parts = [];

    if (settings.showWifi) {
      parts.add("↓${stats.downloadSpeedStr} ↑${stats.uploadSpeedStr}");
    }

    if (settings.showCpu) {
      String cpuDisplay = "CPU:${stats.cpuUsagePercent.toStringAsFixed(1)}%";
      // If thermal level is significant, show it, otherwise just %
      if (stats.cpuTemp > 0) {
        cpuDisplay += "(L${stats.cpuTemp.toStringAsFixed(0)})";
      }
      parts.add(cpuDisplay);
    }

    if (settings.showRam) {
      parts.add("RAM:${stats.ramUsagePercent.toStringAsFixed(1)}%");
    }

    if (settings.showDisk) {
      parts.add("Disk:${stats.diskUsedGB.toStringAsFixed(0)}GB");
    }

    String title = parts.join("  |  ");
    if (title.isEmpty) title = "Monitoring Off";

    _mainTray.setSystemTrayInfo(
      title: title,
      // We can also dynamically change the icon based on what's most important, 
      // but keeping it stable for now is better for the menu bar.
      iconPath: _getBestIcon(settings),
    );
  }

  String _getBestIcon(SettingsService settings) {
    if (settings.showWifi) return 'assets/icons/wifi.png';
    if (settings.showCpu) return 'assets/icons/cpu.png';
    if (settings.showRam) return 'assets/icons/ram.png';
    if (settings.showDisk) return 'assets/icons/disk.png';
    return 'assets/icons/wifi.png';
  }
}

