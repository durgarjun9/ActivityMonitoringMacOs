
/// Model representing system statistics.
class SystemStats {
  final double uploadSpeed; // Bytes per second
  final double downloadSpeed; // Bytes per second
  final double cpuTemp; // Thermal level or Celsius if available
  final double cpuUsagePercent; // 0.0 to 100.0
  final double ramUsagePercent; // 0.0 to 100.0
  final double diskUsagePercent; // 0.0 to 100.0
  final double diskUsedGB;
  final double diskAvailableGB;
  final double diskTotalGB;

  SystemStats({
    this.uploadSpeed = 0,
    this.downloadSpeed = 0,
    this.cpuTemp = 0,
    this.cpuUsagePercent = 0,
    this.ramUsagePercent = 0,
    this.diskUsagePercent = 0,
    this.diskUsedGB = 0,
    this.diskAvailableGB = 0,
    this.diskTotalGB = 0,
  });

  SystemStats copyWith({
    double? uploadSpeed,
    double? downloadSpeed,
    double? cpuTemp,
    double? cpuUsagePercent,
    double? ramUsagePercent,
    double? diskUsagePercent,
    double? diskUsedGB,
    double? diskAvailableGB,
    double? diskTotalGB,
  }) {
    return SystemStats(
      uploadSpeed: uploadSpeed ?? this.uploadSpeed,
      downloadSpeed: downloadSpeed ?? this.downloadSpeed,
      cpuTemp: cpuTemp ?? this.cpuTemp,
      cpuUsagePercent: cpuUsagePercent ?? this.cpuUsagePercent,
      ramUsagePercent: ramUsagePercent ?? this.ramUsagePercent,
      diskUsagePercent: diskUsagePercent ?? this.diskUsagePercent,
      diskUsedGB: diskUsedGB ?? this.diskUsedGB,
      diskAvailableGB: diskAvailableGB ?? this.diskAvailableGB,
      diskTotalGB: diskTotalGB ?? this.diskTotalGB,
    );
  }

  /// Formatted download speed (e.g., 1.5M, 200K).
  String get downloadSpeedStr => _formatSpeed(downloadSpeed);

  /// Formatted upload speed (e.g., 1.5M, 200K).
  String get uploadSpeedStr => _formatSpeed(uploadSpeed);

  String _formatSpeed(double bytesPerSecond) {
    if (bytesPerSecond < 1024) {
      return "${bytesPerSecond.toStringAsFixed(0)}B";
    } else if (bytesPerSecond < 1024 * 1024) {
      return "${(bytesPerSecond / 1024).toStringAsFixed(1)}K";
    } else {
      return "${(bytesPerSecond / (1024 * 1024)).toStringAsFixed(1)}M";
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SystemStats &&
          runtimeType == other.runtimeType &&
          uploadSpeed == other.uploadSpeed &&
          downloadSpeed == other.downloadSpeed &&
          cpuTemp == other.cpuTemp &&
          cpuUsagePercent == other.cpuUsagePercent &&
          ramUsagePercent == other.ramUsagePercent &&
          diskUsagePercent == other.diskUsagePercent &&
          diskUsedGB == other.diskUsedGB &&
          diskAvailableGB == other.diskAvailableGB &&
          diskTotalGB == other.diskTotalGB;

  @override
  int get hashCode =>
      uploadSpeed.hashCode ^
      downloadSpeed.hashCode ^
      cpuTemp.hashCode ^
      cpuUsagePercent.hashCode ^
      ramUsagePercent.hashCode ^
      diskUsagePercent.hashCode ^
      diskUsedGB.hashCode ^
      diskAvailableGB.hashCode ^
      diskTotalGB.hashCode;
}
