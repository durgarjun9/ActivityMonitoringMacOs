
import 'dart:io';
import 'package:system_tray/system_tray.dart';
import 'system_monitor_service.dart';
import 'settings_service.dart';

/// Manages the macOS system tray (menu bar) icon and menu.
class TrayManager {
  final SystemMonitorService _monitorService;
  final SettingsService _settingsService;

  final SystemTray _mainTray = SystemTray();
  final AppWindow _appWindow = AppWindow();
  bool _isInitialized = false;

  TrayManager(this._monitorService, this._settingsService);

  /// Initializes the system tray and starts listening for changes.
  Future<void> init() async {
    if (_isInitialized) return;

    await _mainTray.initSystemTray(
      title: '...',
      iconPath: 'assets/icons/wifi.png',
    );

    final Menu menu = Menu();
    await menu.buildFrom([
      MenuItemLabel(label: 'Open Settings', onClicked: (menuItem) => _appWindow.show()),
      MenuSeparator(),
      MenuItemLabel(label: 'Quit', onClicked: (menuItem) => exit(0)),
    ]);
    await _mainTray.setContextMenu(menu);

    _mainTray.registerSystemTrayEventHandler((eventName) {
      if (eventName == kSystemTrayEventClick || eventName == kSystemTrayEventRightClick) {
        _mainTray.popUpContextMenu();
      }
    });

    _monitorService.addListener(_updateTray);
    _settingsService.addListener(_updateTray);

    _updateTray();
    _isInitialized = true;
  }

  /// Updates the tray title and icon based on current stats and settings.
  void _updateTray() {
    final stats = _monitorService.stats;
    final settings = _settingsService;
    
    final List<String> parts = [];

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
