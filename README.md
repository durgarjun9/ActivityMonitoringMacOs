# SystemMonitoring for macOS

A premium, minimalist system monitoring utility built with Flutter for the macOS menu bar. Track your Mac's performance at a glance with sleek, monochrome metrics and a modern dashboard.

## ✨ Features

- **Real-time Menu Bar Stats**: Monitor your system performance without leaving your workspace.
- **Minimalist Aesthetic**: Uses professional monochrome symbols that adapt perfectly to Light and Dark modes.
- **Comprehensive Monitoring**:
  - ⚡︎ **CPU Usage**: Live percentage and thermal level tracking.
  - 🧠 **RAM Utilization**: Real-time memory pressure monitoring.
  - ⛁ **Disk Availability**: Track available storage space on your primary drive.
  - ↓ **Network Throughput**: Real-time download (↓) and upload (↑) speeds.
- **Glassmorphism Dashboard**: A stunning, modern UI to toggle specific metrics and customize your experience.
- **Launch at Login**: Option to automatically start the app when you boot your Mac.
- **Optimized for Background**: Runs silently in the background with minimal system impact.

## 🚀 Installation

1. Clone or download the repository.
2. Build the release version:
   ```bash
   flutter build macos
   ```
3. Navigate to `build/macos/Build/Products/Release/`.
4. Drag `SystemMonitoring.app` into your **Applications** folder.

## 🛠 Tech Stack

- **Framework**: Flutter (macOS Desktop)
- **State Management**: Provider
- **System Access**: Native macOS CLI tools (`top`, `netstat`, `df`, `vm_stat`)
- **Native Integration**: `system_tray` & `launch_at_startup`

## 🎨 Icons

The application uses a minimalist design system inspired by native macOS aesthetics. You can customize the app icon by replacing `assets/icon.png`.

