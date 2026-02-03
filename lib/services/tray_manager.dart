
import 'dart:io';
import 'package:system_tray/system_tray.dart';
import 'system_monitor_service.dart';
import 'settings_service.dart';

class TrayManager {
  final SystemMonitorService _monitorService;
  final SettingsService _settingsService;

  final SystemTray _mainTray = SystemTray();
  final AppWindow _appWindow = AppWindow();
  bool _isInitialized = false;

  TrayManager(this._monitorService, this._settingsService);

  Future<void> init() async {
    if (_isInitialized) return;

    // Use a generic monitor icon or the first one available
    await _mainTray.initSystemTray(
      title: '...',
      iconPath: 'assets/icons/wifi.png', // Fallback icon
    );

    final Menu menu = Menu();
    await menu.buildFrom([
      MenuItemLabel(label: 'Open', onClicked: (menuItem) => _appWindow.show()),
      MenuSeparator(),
      MenuItemLabel(label: 'Quit', onClicked: (menuItem) => exit(0)),
    ]);
    await _mainTray.setContextMenu(menu);

    // Register event handler to show menu on both left and right clicks
    _mainTray.registerSystemTrayEventHandler((eventName) {
      if (eventName == kSystemTrayEventClick) {
        _mainTray.popUpContextMenu();
      } else if (eventName == kSystemTrayEventRightClick) {
        _mainTray.popUpContextMenu();
      }
    });

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
      String cpuDisplay = "⚡︎${stats.cpuUsagePercent.toStringAsFixed(0)}%";
      if (stats.cpuTemp > 0) {
        cpuDisplay += "(L${stats.cpuTemp.toStringAsFixed(0)})";
      }
      parts.add(cpuDisplay);
    }

    if (settings.showRam) {
      parts.add("⑇${stats.ramUsagePercent.toStringAsFixed(0)}%");
    }

    if (settings.showDisk) {
      parts.add("⛁${stats.diskAvailableGB.toStringAsFixed(0)}GB");
    }

    String title = parts.join("  ");
    if (title.isEmpty) title = "SystemMonitoring";

    _mainTray.setSystemTrayInfo(
      title: title,
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

