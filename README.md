# 🏀 Basketball Shot Tracker

A Flutter application that helps basketball players track their shooting performance using voice commands.

## Features

- 🎤 Voice-controlled shot tracking (say "good" for made shots, "miss" for missed shots)
- 📊 Real-time statistics including total shots, makes, misses, and shooting percentage
- 🔊 Audio feedback for shot registration
- 📱 Haptic feedback for better user experience
- 🔄 Easy reset functionality
- 🌙 Dark mode support

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Android Studio / Xcode (for running on emulator/device)
- A physical device with a microphone (for voice commands)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/basketball-shot-tracker.git
   cd basketball-shot-tracker
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## How to Use

1. Launch the app and grant microphone permissions when prompted
2. Tap the microphone button to start listening for voice commands
3. Say "good" when you make a shot
4. Say "miss" when you miss a shot
5. View your shooting statistics in real-time
6. Tap "Restart" to reset all counters

## Dependencies

- `speech_to_text`: For voice recognition
- `audioplayers`: For playing feedback sounds
- `vibration`: For haptic feedback
- `permission_handler`: For handling microphone permissions
- `provider`: For state management

## Screenshots

(Add screenshots of your app here)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
