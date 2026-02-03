
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
}
