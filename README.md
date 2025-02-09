# Task Management App: Acme

A Flutter-based task management application with offline-first capabilities, implementing real-time synchronization between local storage (Hive) and Firebase.

## Features

- Create, update, and delete tasks
- Offline-first architecture using Hive local storage
- Real-time synchronization with Firebase when online
- Conflict resolution for cross-device updates
- Clean and intuitive user interface
- Optimistic UI updates

## Architecture

### Technical Stack
- **Flutter**: UI framework
- **Hive**: Local data persistence
- **Firebase Firestore**: Cloud synchronization
- **Provider**: State management

### Key Components
- **Repository Pattern**: Abstracts data operations
- **Provider Pattern**: Manages application state
- **Offline-First Design**: Prioritizes local operations
- **Sync Strategy**: Timestamp-based conflict resolution

## Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK
- Firebase account
- Android Studio / VS Code

### Installation

1. Clone the repository:
```bash
git clone https://github.com/Stanely254/acme.git
cd acme
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure Firebase:
   - Create a new Firebase project
   - Add Android/iOS apps in Firebase console
   - Download and add configuration files:
     - Android: `google-services.json` to `android/app`
     - iOS: `GoogleService-Info.plist` to `ios/Runner`

4. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart
├── models/
│   ├── task.dart
│   └── task_status.dart
├── repositories/
│   ├── task_repository.dart
│   └── task_repository_impl.dart
├── controllers/
│   └── task_controller.dart
└── views/
    ├── home/
    │   ├── home_screen.dart
    │   └── widgets/
    │       ├── task_list_item.dart
    │       └── add_task_dialog.dart
    └── detail/
        └── detail_screen.dart
```

## Testing

The project includes several types of tests:

1. Widget Tests:
```bash
flutter test test/widget_test
```

2. Integration Tests:
```bash
flutter test integration_test
```

## Performance Optimizations

- Efficient Firestore queries with pagination
- Local caching to minimize Firebase reads
- Optimistic UI updates for better UX
- Proper memory management with Hive adapters

## Sync Strategy

The app implements a robust synchronization strategy:

1. Local-First Operations:
   - All operations are performed locally first
   - Changes are immediately reflected in UI
   - Data is persisted in Hive

2. Background Sync:
   - Changes are synced to Firebase when online
   - Conflicts are resolved using timestamp-based strategy
   - Failed syncs are retried automatically

3. Conflict Resolution:
   - Latest update wins based on timestamps
   - Local changes are preserved until sync is complete
   - User is notified of sync status

## Screenshots

[Add your screenshots here]

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details

## Acknowledgments

- Flutter team for the amazing framework
- Firebase for the backend infrastructure
- Hive for the local storage solution

## Contact

Your Name - [stanelymyuga.12@gmail.com](mailto:stanelymyuga.12@gmail.com)

Project Link: [https://github.com/Stanely254/acme.git](https://github.com/Stanely254/acme.git)