# MentalMood

**Enterprise-grade emotional well-being tracking.**

MentalMood is a cross-platform application designed for individuals and organizations that prioritize mental health. It provides structured mood logging, advanced analytics, and complete data privacy -- all without relying on external servers.

---

## Overview

MentalMood addresses a growing need in corporate wellness programs and personal health management: reliable, private, and actionable emotional tracking. Users log their mood on a 1-10 scale, and the app transforms raw entries into meaningful insights through interactive charts and daily summaries.

Every piece of data stays on the user's device. No cloud sync, no third-party servers, no data leaks.

---

## Features

### Mood Tracking
A responsive emoji-based interface where visuals animate in real time as the user selects their mood level. Each entry is timestamped, stored locally, and linked to the user's account.

### Advanced Analytics
Interactive line charts powered by `fl_chart` visualize emotional trends across four configurable timeframes:
- **24 hours** -- Granular view of every individual entry
- **7 days / 30 days** -- Daily averages to identify weekly and monthly patterns
- **12 months** -- Monthly averages for long-term trajectory analysis

### Intelligent Daily Summary
A dynamic overview card that calculates the day's average mood, displays a contextual status label, and provides immediate visual feedback on the user's current state.

### Security-First Authentication
User accounts with persistent sessions and BCrypt password hashing (12 salt rounds). Credentials are never stored in plaintext. Session management via encrypted local storage.

### Complete Data Sovereignty
Users maintain full control over their data at all times:
- Update personal profile information
- Clear history for specific date ranges
- Permanently delete account and all associated data

No recovery mechanism exists by design -- once deleted, data is irrecoverable.

### AI Integration (Ready)
Pre-configured connection to NVIDIA's Mistral Large language model for future deployment of personalized well-being insights and trend analysis. Requires API key configuration via environment variables.

### Adaptive Theming
Custom Sage Green design system built on Material 3 with the Quicksand typeface. Automatic light/dark mode switching based on system preference.

---

## Technology

| Component | Solution |
|-----------|----------|
| Framework | [Flutter](https://flutter.dev/) (Material 3) |
| Database | [Drift](https://drift.simonbinder.eu/) (SQLite) with reactive queries and automatic schema migrations |
| State Management | [Provider](https://pub.dev/packages/provider) |
| Architecture | Repository Pattern with clean layer separation |
| Authentication | [BCrypt](https://pub.dev/packages/bcrypt) password hashing |
| Visualization | [fl_chart](https://pub.dev/packages/fl_chart) |
| AI Backend | [flutter_dotenv](https://pub.dev/packages/flutter_dotenv) + NVIDIA API |
| Localization | Device-locale date/time formatting via [intl](https://pub.dev/packages/intl) |

---

## Architecture

```
lib/
├── DataBase/          Drift schema definitions, tables, and migration logic
├── Logic/             Business controllers (login, register, mood) and AI service
├── Repositories/      Abstracted data access layer with Drift implementations
├── Pages/             UI screens organized by feature (Access, Mood, Settings)
├── Utils/             Design system, theme definitions, and constants
└── main.dart          Application entry point and dependency injection
```

The architecture enforces strict separation of concerns:
- **Pages** render UI and delegate all logic to controllers
- **Controllers** manage application state and coordinate business rules
- **Repositories** isolate data access, making the persistence layer swappable
- **Database** handles schema versioning and migration strategies automatically

This design allows independent testing, modification, or replacement of each layer without affecting the others.

---

## Installation

### Requirements
- Flutter SDK >= 3.44.0
- Dart SDK >= 3.12.1
- Target platform: Android, iOS, macOS, Linux, Windows, or Web

### Setup

```bash
git clone https://github.com/NLEchap0/MentalMood.git
cd MentalMood/application
```

### Environment Variables

Create a `.env` file in the `application/` directory (excluded from version control):

```env
NVIDIA_API_KEY=your_api_key
NVIDIA_API_URL=https://integrate.api.nvidia.com/v1/chat/completions
NVIDIA_MODEL=mistralai/mistral-large-3-675b-instruct-2512
```

### Dependencies

```bash
flutter pub get
```

### Code Generation

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Launch

```bash
flutter run
```

---

## Use Cases

- **Corporate Wellness Programs** -- Deploy across teams to monitor employee well-being trends without compromising individual privacy
- **Healthcare Support** -- Complement therapy sessions with structured self-reported mood data
- **Personal Development** -- Track emotional patterns to identify triggers and improve self-awareness
- **Research** -- Collect anonymized local datasets for mental health studies

---

## License

Proprietary. All rights reserved. For licensing inquiries, contact the author.

---

*MentalMood -- Breathe in, breathe out.*
