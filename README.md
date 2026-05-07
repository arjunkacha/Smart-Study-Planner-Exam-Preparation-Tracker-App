# 📚 Smart Study Planner & Exam Preparation Tracker

A complete, **offline-first** Flutter mobile application designed to help students manage subjects, schedule study sessions, track syllabus completion, and analyze exam preparation progress.

---

## 🎓 About the Project

**Smart Study Planner** is a feature-rich Flutter application built for college students who need an intelligent system to:
- Organize their subjects and topics
- Schedule study sessions with calendar view
- Track completion percentages per subject
- Get AI-powered topic recommendations
- Work completely offline with optional sync support

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| 📘 Subject Management | Add/Edit/Delete subjects with custom color & icon |
| 📝 Topic Tracking | Topics with estimated time, status, and last studied date |
| 📅 Study Scheduling | Calendar-based session planning with time & duration |
| 📊 Progress Dashboard | Visual progress bars, circular indicators, and stats |
| 🔍 Search & Filter | Search topics by name, filter by subject/status |
| 🔔 Notifications | Local notifications for sessions and daily reminders |
| 🌙 Dark/Light Mode | Full Material 3 theming |
| 📴 Offline-First | 100% functional without internet |
| 💡 Smart Suggestions | Recommends the next topic to study based on priority |
| 📤 Data Export | Export all data as JSON |

---

## 🏗️ Architecture

```
lib/
├── core/              # App routing (GoRouter)
├── models/            # Data models with Hive annotations
│   ├── subject_model.dart
│   ├── topic_model.dart
│   └── schedule_model.dart
├── database/          # Hive database service (CRUD operations)
├── providers/         # Riverpod state management
│   ├── subject_provider.dart
│   ├── topic_provider.dart
│   ├── schedule_provider.dart
│   ├── settings_provider.dart
│   └── connectivity_provider.dart
├── screens/           # UI screens
│   ├── splash/
│   ├── dashboard/
│   ├── subjects/
│   ├── scheduling/
│   ├── progress/
│   ├── search/
│   └── settings/
├── services/          # Business logic services
│   └── notification_service.dart
├── widgets/           # Reusable widgets
│   ├── stat_card.dart
│   ├── subject_card.dart
│   ├── topic_tile.dart
│   ├── schedule_card.dart
│   ├── bottom_nav_scaffold.dart
│   └── common_widgets.dart
├── theme/             # Material 3 theme configuration
├── utils/             # Constants, helpers, sample data
└── main.dart          # Entry point
```

---

## 📱 Screens

1. **Splash Screen** — Animated launch screen with gradient
2. **Dashboard** — Stats, circular progress, insights, recommendations
3. **Subjects Screen** — List of all subjects with completion
4. **Subject Detail** — Topics list with progress per subject
5. **Add/Edit Subject** — Color picker, icon picker
6. **Add/Edit Topic** — Estimated time slider, notes
7. **Scheduling Screen** — TableCalendar + daily session list
8. **Add/Edit Schedule** — Date/time/duration picker form
9. **Progress Screen** — Overview + per-subject breakdown tabs
10. **Search & Filter** — Combined search/filter for topics
11. **Settings Screen** — Theme, notifications, sync, data management

---

## 🛠️ Tech Stack

| Technology | Purpose |
|-----------|---------|
| **Flutter** | Cross-platform mobile framework |
| **Dart** | Programming language |
| **Riverpod 2.x** | State management |
| **Hive** | Offline-first local database |
| **GoRouter** | Declarative navigation |
| **TableCalendar** | Calendar widget |
| **FL Chart** | Data visualization |
| **flutter_animate** | Smooth animations |
| **flutter_local_notifications** | Local push notifications |
| **connectivity_plus** | Network status detection |
| **google_fonts** | Inter typeface |
| **percent_indicator** | Progress indicators |
| **shared_preferences** | Settings persistence |
| **uuid** | Unique ID generation |

---

## 📦 Installation & Setup

### Prerequisites
- Flutter SDK `>=3.0.0` installed
- Android Studio / VS Code with Flutter extension
- Android emulator or physical device (Android 5.0+)

### Steps

```bash
# 1. Navigate to project directory
cd D24IT167

# 2. Install dependencies
flutter pub get

# 3. Run the application
flutter run

# 4. Build APK (release)
flutter build apk --release
```

### Running on a device
```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device-id>
```

---

## 🗂️ Data Models

### Subject
```dart
SubjectModel {
  id: String (UUID)
  name: String
  colorValue: int (Color.value)
  iconName: String
  createdAt: DateTime
  isSynced: bool
}
```

### Topic
```dart
TopicModel {
  id: String (UUID)
  subjectId: String
  name: String
  estimatedTimeHours: double
  status: TopicStatus (notStarted | inProgress | completed)
  lastStudied: DateTime?
  createdAt: DateTime
  notes: String?
}
```

### Schedule
```dart
ScheduleModel {
  id: String (UUID)
  subjectId: String
  topicId: String
  date: DateTime
  time: String (HH:mm)
  durationHours: double
  completed: bool
  createdAt: DateTime
  notes: String?
}
```

---

## 🔔 Notifications

The app supports:
- **Session Reminder** — 15 minutes before scheduled study session
- **Daily Reminder** — Configurable time every day
- **Local only** — No external server needed

---

## 📴 Offline-First Design

All data is stored locally using **Hive** (NoSQL). The app:
- Works completely without internet
- Shows offline mode banner when disconnected
- Tracks `isSynced` flag on each record for future cloud sync
- Shows last sync time in Settings

---

## 🎨 Design System

- **Primary Color**: `#6C63FF` (Purple)
- **Secondary Color**: `#00D9AA` (Teal)
- **Accent Color**: `#FF6584` (Pink)
- **Font**: Inter (Google Fonts)
- **Design**: Material 3 with custom card styles, glassmorphism elements, gradient headers

---

## 🚀 Git Commit Stages

```bash
# Stage 1: Project Initialization
git add . && git commit -m "feat: initial Flutter project setup with dependencies"

# Stage 2: UI Implementation  
git add . && git commit -m "feat: implement all screens, widgets, and navigation"

# Stage 3: Core Logic
git add . && git commit -m "feat: add scheduling, progress tracking, and smart suggestions"

# Stage 4: Offline Storage & Final Enhancements
git add . && git commit -m "feat: offline-first Hive storage, notifications, settings, sample data"
```

---

## 📋 Dependencies

```yaml
# Core
flutter_riverpod: ^2.5.1
hive: ^2.2.3
hive_flutter: ^1.1.0
go_router: ^14.2.7

# UI
fl_chart: ^0.68.0
table_calendar: ^3.1.2
flutter_animate: ^4.5.0
percent_indicator: ^4.2.3
google_fonts: ^6.2.1

# Notifications
flutter_local_notifications: ^17.2.3
timezone: ^0.9.4

# Utilities
connectivity_plus: ^6.0.3
uuid: ^4.4.2
shared_preferences: ^2.3.2
```

---

## 👨‍💻 Developer Notes

- The project uses **pre-written Hive adapters** (`.g.dart` files) instead of code generation for simplicity
- All screens are **null-safe** and follow **MVVM-style** architecture
- The **Riverpod `StateNotifier`** pattern is used for mutable state
- **GoRouter `ShellRoute`** provides the bottom navigation wrapper

---

## 📌 College Submission Information

- **Project Name**: Smart Study Planner & Exam Preparation Tracker  
- **Framework**: Flutter  
- **Architecture**: Clean Modular (MVVM)  
- **State Management**: Riverpod  
- **Local Database**: Hive (NoSQL)  
- **Minimum SDK**: Android 21 (5.0 Lollipop)  

---

*Built with ❤️ using Flutter & Riverpod*
