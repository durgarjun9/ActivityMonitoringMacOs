
class SystemStats {
  final double uploadSpeed; // B/s
  final double downloadSpeed; // B/s
  final double cpuTemp; // Thermal level or Temp if available
  final double cpuUsagePercent;
  final double ramUsagePercent;
  final double diskUsagePercent;
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

  String get downloadSpeedStr => _formatSpeed(downloadSpeed);
  String get uploadSpeedStr => _formatSpeed(uploadSpeed);

  String _formatSpeed(double bytesPerSecond) {
    if (bytesPerSecond < 1024) return "${bytesPerSecond.toStringAsFixed(0)}B";
    if (bytesPerSecond < 1024 * 1024) return "${(bytesPerSecond / 1024).toStringAsFixed(1)}K";
    return "${(bytesPerSecond / (1024 * 1024)).toStringAsFixed(1)}M";
  }
}
