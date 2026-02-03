
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService extends ChangeNotifier {
  static const String _keyShowWifi = 'show_wifi';
  static const String _keyShowCpu = 'show_cpu';
  static const String _keyShowRam = 'show_ram';
  static const String _keyShowDisk = 'show_disk';

  bool _showWifi = true;
  bool _showCpu = true;
  bool _showRam = true;
  bool _showDisk = true;

  bool get showWifi => _showWifi;
  bool get showCpu => _showCpu;
  bool get showRam => _showRam;
  bool get showDisk => _showDisk;

  final SharedPreferences _prefs;

  SettingsService(this._prefs) {
    _showWifi = _prefs.getBool(_keyShowWifi) ?? true;
    _showCpu = _prefs.getBool(_keyShowCpu) ?? true;
    _showRam = _prefs.getBool(_keyShowRam) ?? true;
    _showDisk = _prefs.getBool(_keyShowDisk) ?? true;
  }

  Future<void> setShowWifi(bool value) async {
    _showWifi = value;
    await _prefs.setBool(_keyShowWifi, value);
    notifyListeners();
  }

  Future<void> setShowCpu(bool value) async {
    _showCpu = value;
    await _prefs.setBool(_keyShowCpu, value);
    notifyListeners();
  }

  Future<void> setShowRam(bool value) async {
    _showRam = value;
    await _prefs.setBool(_keyShowRam, value);
    notifyListeners();
  }

  Future<void> setShowDisk(bool value) async {
    _showDisk = value;
    await _prefs.setBool(_keyShowDisk, value);
    notifyListeners();
  }
}
