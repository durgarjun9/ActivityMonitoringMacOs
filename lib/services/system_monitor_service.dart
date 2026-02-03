
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/system_stats.dart';

/// Service responsible for monitoring system resources like WiFi, RAM, CPU, and Disk.
class SystemMonitorService extends ChangeNotifier {
  SystemStats _stats = SystemStats();

  /// Current system statistics.
  SystemStats get stats => _stats;

  Timer? _timer;
  int _prevInBytes = 0;
  int _prevOutBytes = 0;
  DateTime _prevTime = DateTime.now();

  String _interface = "en0";

  SystemMonitorService() {
    _init();
  }

  Future<void> _init() async {
    await _findWifiInterface();
    start();
  }

  /// Finds the primary WiFi interface name (e.g., en0).
  Future<void> _findWifiInterface() async {
    try {
      final result = await Process.run('networksetup', ['-listallhardwareports']);
      if (result.exitCode != 0) return;

      final lines = result.stdout.toString().split('\n');
      for (int i = 0; i < lines.length; i++) {
        if (lines[i].contains('Wi-Fi')) {
          if (i + 1 < lines.length && lines[i + 1].contains('Device:')) {
            _interface = lines[i + 1].split('Device:')[1].trim();
            break;
          }
        }
      }
    } catch (e) {
      debugPrint('Error finding WiFi interface: $e');
      _interface = "en0";
    }
  }

  /// Starts the periodic update timer.
  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateStats();
    });
  }

  /// Stops the periodic update timer.
  void stop() {
    _timer?.cancel();
  }

  Future<void> _updateStats() async {
    try {
      final wifi = await _getWifiSpeed();
      final ram = await _getRamUsage();
      final diskData = await _getDetailedDiskUsage();
      final cpuUsage = await _getCpuUsage();
      final temp = await _getCpuTemp();

      _stats = SystemStats(
        downloadSpeed: wifi.download,
        uploadSpeed: wifi.upload,
        ramUsagePercent: ram,
        diskUsagePercent: diskData.percent,
        diskUsedGB: diskData.usedGB,
        diskAvailableGB: diskData.availableGB,
        diskTotalGB: diskData.totalGB,
        cpuUsagePercent: cpuUsage,
        cpuTemp: temp,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating stats: $e');
    }
  }

  /// Calculates WiFi download and upload speeds in bytes per second.
  Future<({double download, double upload})> _getWifiSpeed() async {
    try {
      final result = await Process.run('netstat', ['-I', _interface, '-b', '-n']);
      if (result.exitCode != 0) return (download: 0.0, upload: 0.0);

      final lines = result.stdout.toString().split('\n');
      if (lines.length < 2) return (download: 0.0, upload: 0.0);

      final dataLine = lines.firstWhere((l) => l.startsWith(_interface), orElse: () => "");
      if (dataLine.isEmpty) return (download: 0.0, upload: 0.0);

      final parts = dataLine.split(RegExp(r'\s+'));
      if (parts.length < 10) return (download: 0.0, upload: 0.0);

      // columns 6 and 9 (0-indexed) are Ibytes and Obytes
      int currentIn = int.tryParse(parts[6]) ?? 0;
      int currentOut = int.tryParse(parts[9]) ?? 0;
      DateTime currentTime = DateTime.now();

      if (_prevInBytes == 0) {
        _prevInBytes = currentIn;
        _prevOutBytes = currentOut;
        _prevTime = currentTime;
        return (download: 0.0, upload: 0.0);
      }

      double seconds = currentTime.difference(_prevTime).inMilliseconds / 1000.0;
      if (seconds <= 0) return (download: 0.0, upload: 0.0);

      double downSpeed = (currentIn - _prevInBytes) / seconds;
      double upSpeed = (currentOut - _prevOutBytes) / seconds;

      _prevInBytes = currentIn;
      _prevOutBytes = currentOut;
      _prevTime = currentTime;

      return (
        download: downSpeed < 0 ? 0.0 : downSpeed,
        upload: upSpeed < 0 ? 0.0 : upSpeed,
      );
    } catch (e) {
      debugPrint('Error getting WiFi speed: $e');
      return (download: 0.0, upload: 0.0);
    }
  }

  /// Calculates RAM usage percentage using vm_stat.
  Future<double> _getRamUsage() async {
    try {
      final result = await Process.run('vm_stat', []);
      if (result.exitCode != 0) return 0.0;

      final lines = result.stdout.toString().split('\n');
      int free = 0;
      int active = 0;
      int inactive = 0;
      int speculative = 0;
      int wired = 0;
      int compressed = 0;

      for (var line in lines) {
        if (line.contains('Pages free:')) {
          free = _parseVmStatLine(line);
        } else if (line.contains('Pages active:')) {
          active = _parseVmStatLine(line);
        } else if (line.contains('Pages inactive:')) {
          inactive = _parseVmStatLine(line);
        } else if (line.contains('Pages speculative:')) {
          speculative = _parseVmStatLine(line);
        } else if (line.contains('Pages wired down:')) {
          wired = _parseVmStatLine(line);
        } else if (line.contains('Pages occupied by compressor:')) {
          compressed = _parseVmStatLine(line);
        }
      }

      int totalUsed = active + wired + compressed;
      int totalFree = free + inactive + speculative;
      int total = totalUsed + totalFree;

      if (total == 0) return 0.0;
      return (totalUsed / total) * 100.0;
    } catch (e) {
      debugPrint('Error getting RAM usage: $e');
      return 0.0;
    }
  }

  int _parseVmStatLine(String line) {
    final parts = line.split(':');
    if (parts.length < 2) return 0;
    return int.tryParse(parts[1].replaceAll('.', '').trim()) ?? 0;
  }

  /// Gets detailed disk usage for the root partition.
  Future<({double percent, double usedGB, double availableGB, double totalGB})> _getDetailedDiskUsage() async {
    try {
      final result = await Process.run('df', ['-k', '/']);
      if (result.exitCode != 0) {
        return (percent: 0.0, usedGB: 0.0, availableGB: 0.0, totalGB: 0.0);
      }

      final lines = result.stdout.toString().trim().split('\n');
      if (lines.length < 2) {
        return (percent: 0.0, usedGB: 0.0, availableGB: 0.0, totalGB: 0.0);
      }

      final parts = lines[1].split(RegExp(r'\s+'));
      if (parts.length < 5) {
        return (percent: 0.0, usedGB: 0.0, availableGB: 0.0, totalGB: 0.0);
      }

      double totalK = double.tryParse(parts[1]) ?? 0.0;
      double usedK = double.tryParse(parts[2]) ?? 0.0;
      double availableK = double.tryParse(parts[3]) ?? 0.0;

      if (totalK == 0) totalK = usedK + availableK;

      String capacityStr = parts[4].replaceAll('%', '');
      double percent = double.tryParse(capacityStr) ?? (totalK > 0 ? (usedK / totalK) * 100 : 0.0);

      return (
        percent: percent,
        usedGB: usedK / (1024 * 1024),
        availableGB: availableK / (1024 * 1024),
        totalGB: totalK / (1024 * 1024),
      );
    } catch (e) {
      debugPrint('Error getting disk usage: $e');
      return (percent: 0.0, usedGB: 0.0, availableGB: 0.0, totalGB: 0.0);
    }
  }

  /// Gets CPU usage percentage using top.
  Future<double> _getCpuUsage() async {
    try {
      final result = await Process.run('top', ['-l', '1', '-n', '0']);
      if (result.exitCode != 0) return 0.0;

      final lines = result.stdout.toString().split('\n');
      final cpuLine = lines.firstWhere((l) => l.contains('CPU usage:'), orElse: () => "");
      if (cpuLine.isEmpty) return 0.0;

      final regExp = RegExp(r'(\d+(?:\.\d+)?)%\s+user,\s+(\d+(?:\.\d+)?)%\s+sys');
      final match = regExp.firstMatch(cpuLine);
      if (match != null) {
        double user = double.tryParse(match.group(1)!) ?? 0.0;
        double sys = double.tryParse(match.group(2)!) ?? 0.0;
        return user + sys;
      }
    } catch (e) {
      debugPrint('Error getting CPU usage: $e');
    }
    return 0.0;
  }

  /// Gets CPU thermal level using sysctl.
  Future<double> _getCpuTemp() async {
    try {
      final result = await Process.run('sysctl', ['-n', 'machdep.xcpm.cpu_thermal_level']);
      if (result.exitCode == 0) {
        return double.tryParse(result.stdout.toString().trim()) ?? 0.0;
      }
    } catch (e) {
      debugPrint('Error getting CPU temp: $e');
    }
    return 0.0;
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}
