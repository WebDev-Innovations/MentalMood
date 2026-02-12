# MentalMood 🧠✨

---

**MentalMood** is a cross-platform mobile application designed to help users monitor their emotional well-being in a simple and intuitive way. Developed as part of my semestral project of **Module 306** at CPT Trevano, this project bridges the gap between digital self-reflection and structured data analysis. The application and the documentation is made completely in italian.

<b>
Author: Bryan Ciaponi (I3AC)
</b>

<br>
<br>

<b>
<a href="https://www.modulbaukasten.ch/module/223/3/it-IT?degree=03a95323-bf92-eb11-b1ac-000d3a831ef4&title=Realizzare-un%E2%80%99applicazione-multiutente-orientata-oggetti&tab=0](https://www.modulbaukasten.ch/module/306/4/it-IT?degree=03a95323-bf92-eb11-b1ac-000d3a831ef4&title=Realizzare-progetti-semplici-nel-proprio-ambito-professionale">
Module Link (italian): ICT Modulbaukasten - M306
</a>
</b>

---

## 🎯 Project Overview

The core objective of MentalMood is to transform fragmented emotional tracking into a structured, local database of feelings and motivations. Users can record their daily mood using emojis, add specific context (motivations), and receive personalized advice based on their recent emotional trends.

### Key Features

* **User Management:** Support for multiple profiles on a single device.
* **Emotional Logging:** Quick selection of mood levels (0-10) and associated feelings.
* **Contextual Motivations:** Link specific reasons to your emotions for better self-analysis.
* **Smart Suggestions:** A built-in algorithm calculates the average mood of the last 48 hours to provide relevant well-being tips.
* **Privacy First:** All data is stored locally on the device using a relational database.
* **Auto-Cleanup:** Configurable settings to automatically delete old history and save space.

---

## 🛠️ Tech Stack

* **Framework:** [Flutter](https://flutter.dev/) (Multi-platform UI)
* **Language:** Dart 3.10.0
* **Database (ORM):** [Drift](https://drift.simonbinder.eu/) (formerly Moor) for reactive, type-safe SQLite persistence.
* **State Management:** [Provider](https://pub.dev/packages/provider)
* **Architecture:** MVVM (Model-View-ViewModel)

---

## 🏗️ Database Structure

The application relies on a robust relational schema managed via **Drift**:

* **Users:** Stores profiles and birth dates.
* **Emotions:** Catalog of available moods and icons.
* **Motivations:** Textual tags to describe the "why" behind a feeling.
* **RegisteredEmotions:** The core link between users, their mood, and specific motivations in a point in time.
* **Settings:** User-specific configurations for data retention.

---

## 🚀 Getting Started

1. **Prerequisites:**
* Flutter SDK (3.38.2 or higher)
* Android Studio
* Android SDK 15.0+


2. **Installation:**
```bash
git clone https://github.com/NLEchap0/MentalMood.git
cd MentalMood
flutter pub get

```


3. **Generate Database Code:**
MentalMood uses code generation for the Drift database:
```bash
dart run build_runner build

```


4. **Run the App:**
```bash
flutter run

```
