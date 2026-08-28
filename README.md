# 🌙 ZAD

  تطبيق إسلامي حديث يجمع القرآن والأذكار ومواقيت الصلاة والقبلة والسبحة في تجربة واحدة بسيطة وأنيقة.

</p>

<p align="center">

  <img src="https://img.shields.io/badge/Flutter-5B4B9A?style=for-the-badge&logo=flutter&logoColor=white">
  <img src="https://img.shields.io/badge/Dart-8B7CC8?style=for-the-badge&logo=dart&logoColor=white">
  <img src="https://img.shields.io/badge/Material_3-6C5BAA?style=for-the-badge">
  <img src="https://img.shields.io/badge/Platform-Android-7B6FB2?style=for-the-badge&logo=android&logoColor=white">

</p>

---

## ✨ Overview

**ZAD** is a modern Islamic mobile application built with **Flutter**.

The goal of the project is to provide the most important daily worship tools in one place while maintaining a clean, modern, and comfortable user experience.

The application combines useful Islamic content with thoughtful **UI/UX, animations, local persistence, API integration, and device sensors**.

---

# 🚀 Highlights

### 📖 Quran

Browse and search all Quran Surahs with a dedicated reading experience.

- Arabic search
- English search
- Surah number search
- Arabic text normalization
- Surah reading screen
- Share Quran content

### 🤲 Azkar

A complete daily Azkar experience with separate categories.

- Morning Azkar
- Evening Azkar
- Sleep Azkar
- Interactive Zikr cards
- Animated category switching
- Smooth scrolling experience

### 📿 Sebha

An interactive digital Sebha designed around smooth user interaction.

- Multiple Azkar
- 33 / 99 targets
- Animated progress ring
- Counter animations
- Ripple feedback
- Glow effects
- Completion animation
- Automatic progress saving

### 🕌 Prayer Times

View daily prayer times and know the upcoming prayer.

- Fajr
- Dhuhr
- Asr
- Maghrib
- Isha
- Sunrise
- Sunset
- Live countdown
- Upcoming prayer detection

### 🧭 Qibla

Use your device sensors to determine the Qibla direction.

- Compass integration
- Location detection
- Qibla bearing
- Direction indicator
- Real-time updates

### 🌗 Theme

A complete custom design system supporting:

- Light Mode
- Dark Mode
- Indigo & Lavender visual identity
- Consistent components
- Responsive UI

---

# 📱 Screenshots

## 🌙 Splash Screen

<p align="center">
  <img width="350" height="700" alt="zad_splash" src="https://github.com/user-attachments/assets/7b07e91d-345e-415b-b655-e085d59a1739" />

</p>

---

## 🏠 Home
<p align="center">

<img width="350" height="700" alt="zad_home" src="https://github.com/user-attachments/assets/019637e2-b896-427d-b5b7-608bb71dc6f1" />

</p>

---

## 📖 Quran
<p align="center">

<img width="350" height="700" alt="zad_quraan" src="https://github.com/user-attachments/assets/cea546b5-39e8-4912-b184-d00d8c36ba62" />

</p>

---

## 📜 Surah Reading
<p align="center">

<img width="350" height="700" alt="zad_surah" src="https://github.com/user-attachments/assets/27270cb9-eefd-43b9-8ba5-3141ec324158" />

</p>

---

## 🤲 Azkar
<p align="center">

<img width="350" height="700" alt="zad_azkar" src="https://github.com/user-attachments/assets/cfeb26c1-83cd-46e8-8dc5-55a73caac69d" />

</p>

---

## 📿 Sebha
<p align="center">

<img width="" height="700" alt="zad_sebha" src="https://github.com/user-attachments/assets/5f1fc920-7454-4fe3-b3b6-8e2005b44c47" />

</p>

---

## 🧭 Qibla
<p align="center">

<img width="350" height="700" alt="zad_qibla" src="https://github.com/user-attachments/assets/b2e06c96-be7a-4e86-9217-94d1112006f3" />

</p>

---

## 🕌 Prayer Times
<p align="center">

<img width="350" height="700" alt="zad_prayer" src="https://github.com/user-attachments/assets/26b2c03d-1857-4571-9342-395d45bd0d85" />

</p>

---

## ⚙️ Settings
<p align="center">

<img width="350" height="700" alt="zad_setting" src="https://github.com/user-attachments/assets/15aa2504-1104-43f9-b2e0-d51c643a97d9" />

</p>

---

# 🎨 Design

ZAD follows a custom **Indigo & Lavender** design system.

### Light Mode

```text
Background : #F7F7FC
Surface    : #FFFFFF
Primary    : #5B4B9A
Accent     : #8B7CC8
````

### Dark Mode

```text
Background : #0D0C14
Surface    : #171620
Primary    : #B5A7F4
Accent     : #9E8EDA
```

The design system focuses on:

**Consistency • Readability • Motion • Simplicity**

---

# 🧩 Architecture

The project follows a clean and reusable Flutter structure:

```text
lib/
│
├── api_services/
│
├── models/
│
├── screens/
│
├── services/
│
├── theme/
│
├── utils/
│
└── widgets/
```

### Architecture idea

```text
UI
 ↓
Screens
 ↓
Services
 ↓
API / Local Storage
```

Reusable components are separated into widgets to keep the project maintainable and scalable.

---

# 💾 Local Persistence

**Hive** is used for local storage.

Currently used for important application data such as:

* Sebha progress
* Selected Zikr
* Target count
* Saved user state

This allows progress to remain available after closing the application.

---

# 🌐 API & Device Integration

ZAD integrates external APIs and device capabilities for dynamic functionality.

### API

* Quran data
* Prayer Times

### Device

* Geolocation
* Compass sensors

### Additional

* Share functionality
* Local persistence

---

# 🛠️ Tech Stack

| Technology      | Usage                 |
| --------------- | --------------------- |
| Flutter         | Application framework |
| Dart            | Programming language  |
| Material 3      | UI system             |
| Hive            | Local storage         |
| Geolocator      | Location services     |
| Flutter Compass | Qibla direction       |
| Share Plus      | Sharing content       |
| REST APIs       | Remote data           |

---

# 🚀 Getting Started

### 1. Clone the project

```bash
git clone https://github.com/Khaledwaleed11/zad
```

### 2. Open the project

```bash
cd zad
```

### 3. Install dependencies

```bash
flutter pub get
```

### 4. Run the application

```bash
flutter run
```

---

# 📦 Build APK

Create a release APK using:

```bash
flutter build apk --release
```

The generated APK will be available at:

```text
build/app/outputs/flutter-apk/app-release.apk
```

---

# 🎯 What I Practiced

This project helped me practice and implement:

* Flutter UI development
* Responsive layouts
* Material 3
* REST API integration
* JSON parsing
* Local storage with Hive
* State management using Flutter state
* Device location
* Compass sensors
* Reusable widgets
* Light & Dark themes
* Animations and micro-interactions
* Navigation architecture

---

# 👨‍💻 Developer

### Khaled Waleed

Flutter Developer | .NET Developer

---

<p align="center">

<strong>Made with ❤️ using Flutter</strong>

  <br>

  <br>

🌙 <strong>ZAD — زادك في طريقك إلى الله</strong> 🌙

</p>
```
