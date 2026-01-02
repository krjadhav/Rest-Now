# RestNow

A lightweight macOS menu bar app that reminds you to take breaks and rest your eyes during long work sessions.

**Website:** [https://krjadhav.github.io/restnowapp/](https://krjadhav.github.io/restnowapp/)

## Screenshots

<div align="center">
  <img src="https://imagedelivery.net/j_zap_BNzPItCoMGioj9aA/ae2989f3-c83b-40a7-496a-73e0c1f7b900/public" alt="RestNow Settings" width="400">
  <img src="https://imagedelivery.net/j_zap_BNzPItCoMGioj9aA/956ebf8e-6846-4348-7dff-bd71c100d000/public" alt="RestNow Menu Bar" width="400">
  <img src="https://imagedelivery.net/j_zap_BNzPItCoMGioj9aA/31ace15e-f0d3-4b5a-6324-48cc550b5500/public" alt="RestNow Break Screen" width="600">
</div>

## Features

- **Customizable Work/Rest Cycles**: Choose from 1, 5, 10, 20, 30, or 60-minute intervals for both work and rest periods
- **Full-Screen Break Reminders**: When it's time to rest, RestNow displays a full-screen overlay across all displays to ensure you take a break
- **Menu Bar Integration**: Lightweight menu bar presence showing countdown timer and current phase
- **Flexible Controls**: Pause, reset, skip breaks, or start a break early - you're in control
- **Multi-Monitor Support**: Break overlay spans across all connected displays
- **Keyboard Shortcuts**: Quick access to common actions via menu bar shortcuts
- **Minimal & Native**: Built with SwiftUI for a modern macOS experience

## Installation

### Homebrew (Recommended)

```bash
brew tap krjadhav/restnow/restnow
```

### Manual Installation

1. Download the latest `RestNow.dmg` from the [Releases](https://github.com/krjadhav/Rest-Now/releases) page
2. Open the DMG file
3. Drag `RestNow.app` to your Applications folder
4. Launch RestNow from your Applications folder

## Requirements

- macOS Sequoia (15.0) or later

## Usage

1. **First Launch**: Set your preferred work and rest durations
2. **Menu Bar**: Click the eye icon in your menu bar to access controls:
   - **Pause/Resume Cycle** (⌘P): Temporarily pause the timer
   - **Reset Cycle** (⌘R): Restart the work phase
   - **Start Break Now** (⌘B): Immediately begin a break
   - **Skip Break** (⌘S): End the current break early
   - **Settings** (⌘,): Adjust work and rest durations
3. **Break Screen**: When a break starts, a full-screen overlay appears. You can skip it if needed, but we encourage you to rest!

## Building from Source

### Prerequisites

- Xcode 15 or later
- macOS Sequoia or later
- Apple Developer account (for code signing)

### Build Steps

1. Clone the repository:
   ```bash
   git clone https://github.com/krjadhav/Rest-Now.git
   cd Rest-Now
   ```

2. Open the project in Xcode:
   ```bash
   open restnow.xcodeproj
   ```

3. Select the `restnow` scheme and build (⌘B)

4. Run the app (⌘R) or archive for distribution

### Creating a Release

1. Archive the app in Xcode:
   ```bash
   xcodebuild archive -project restnow.xcodeproj -scheme restnow -archivePath build/RestNow.xcarchive
   ```

2. Export the app:
   ```bash
   xcodebuild -exportArchive -archivePath build/RestNow.xcarchive -exportPath build -exportOptionsPlist ExportOptions.plist
   ```

3. Create a DMG (you'll need to set up the build directory structure)

4. Notarize the app:
   ```bash
   ./notarize.sh
   ```

5. Update the Homebrew formula (`restnow.rb`) with the new version and SHA256 hash

## Project Structure

- **restnowApp.swift**: Main app entry point
- **AppDelegate.swift**: Menu bar setup, session management, and window coordination
- **RestNowSession.swift**: Core timer logic and state management
- **BreakOverlayWindowManager.swift**: Multi-screen overlay window management
- **BreakOverlayView.swift**: Break screen UI
- **OnboardingView.swift**: Settings interface for duration configuration
- **ContentView.swift**: Legacy view (unused in menu bar mode)

## Contributing

Contributions are welcome! Feel free to:
- Report bugs
- Suggest new features
- Submit pull requests

Visit the [GitHub repository](https://github.com/krjadhav/Rest-Now) to get started.

## License

See the LICENSE file for details.

## Author

Made by Kausthub Jadhav

**Website:** [https://krjadhav.github.io/restnowapp/](https://krjadhav.github.io/restnowapp/)
