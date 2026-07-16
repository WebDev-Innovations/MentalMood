# MentalMood 🧠🍃

**MentalMood** is a modern, cross-platform application designed to help users monitor their emotional well-being through an intuitive and relaxing interface. Developed as a semestral project for **Module 306** at CPT Trevano, it combines digital self-reflection with advanced data visualization and local privacy.

<b>Author: Bryan Ciaponi (I3AC)</b>

<br>

<b>
<a href="https://www.modulbaukasten.ch/module/306/4/it-IT?degree=03a95323-bf92-eb11-b1ac-000d3a831ef4&title=Realizzare-progetti-semplici-nel-proprio-ambito-professionale">
Module Link (Italian): ICT Modulbaukasten - M306
</a>
</b>

---

## 🎯 Project Vision

MentalMood transforms fragmented emotional tracking into a structured, secure, and beautiful journey. The app focuses on a "Privacy-First" approach, keeping all sensitive data locally on your device while providing professional-grade insights into your mood trends.

### ✨ Key Features

*   **Secure Authentication**: Personal accounts with persistent login and **BCrypt** password hashing for maximum security.
*   **Interactive Mood Logging**: A unique, responsive emoji-based selection system. Watch emojis come to life as you slide through mood levels (1-10).
*   **Dynamic Analytics**: Beautiful, high-performance line charts using `fl_chart`. Visualize your journey across different timeframes:
    *   **24h**: Detailed view of every entry.
    *   **7d / 30d**: Daily averages to spot weekly and monthly trends.
    *   **Year**: Monthly averages for long-term emotional tracking.
*   **Smart Overview**: A dynamic daily summary that greets you with an analysis of your current day's progress.
*   **Aesthetic Excellence**: A custom-designed **Sage Green theme** (Light & Dark modes) featuring the Quicksand font and ultra-smooth **Ease In-Out animations** for a stress-free experience.
*   **Data Sovereignty**: Full control over your data. Update your profile, clear specific history ranges, or delete your entire account and data with one click.
*   **AI-Ready**: Architecture pre-configured for integration with **NVIDIA's Mistral Large AI** for future personalized well-being insights.

---

## 🛠️ Tech Stack

*   **UI Framework**: [Flutter](https://flutter.dev/) (Material 3)
*   **Database**: [Drift](https://drift.simonbinder.eu/) (SQLite) with reactive persistence and automated migrations.
*   **State Management**: [Provider](https://pub.dev/packages/provider) for clean logic-UI separation.
*   **Architecture**: **Repository Pattern** for a modular and maintainable backend-frontend split.
*   **Security**: [BCrypt](https://pub.dev/packages/bcrypt) for secure credential storage.
*   **Graphics**: [fl_chart](https://pub.dev/packages/fl_chart) for advanced data visualization.
*   **Internationalization**: Fully localized date and time formatting based on device settings.

---

## 🏗️ Folder Structure

```text
lib/
├── DataBase/      # Drift schema and database definitions
├── Logic/         # Business logic (Controllers and AI Services)
├── Repositories/  # Data access abstraction layer
├── Pages/         # UI Screens (Access, Mood selection, Settings)
├── Utils/         # Design System, Themes, and Constants
└── main.dart      # App entry point and Provider configuration
```

---

## 🚀 Getting Started

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/NLEchap0/MentalMood.git
    cd MentalMood/application
    ```

2.  **Environment Setup**:
    Create a `.env` file in the `application/` folder (it is ignored by git for security):
    ```env
    NVIDIA_API_KEY=your_key_here
    NVIDIA_API_URL=https://integrate.api.nvidia.com/v1/chat/completions
    NVIDIA_MODEL=mistralai/mistral-large-3-675b-instruct-2512
    ```

3.  **Install dependencies**:
    ```bash
    flutter pub get
    ```

4.  **Generate Database code**:
    ```bash
    flutter pub run build_runner build --delete-conflicting-outputs
    ```

5.  **Run the application**:
    ```bash
    flutter run
    ```

---

*MentalMood - Breathe in, breathe out.*
