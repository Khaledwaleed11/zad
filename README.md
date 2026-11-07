# ZAD

**ZAD is an Arabic Islamic companion app** that brings Quran reading and listening, daily remembrance, prayer times, Qibla direction, Hadith, duas, and Prophets' stories into one mobile experience.

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-Mobile%20App-54C5F8?logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.10%2B-0175C2?logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Material%203-Design-735C2F" alt="Material 3" />
</p>

## The problem and the solution

Everyday Islamic resources are often spread across separate apps and websites: a Quran reader, prayer-time service, Qibla compass, Hadith collection, and reminder tools. Moving between these sources makes it harder to keep common worship tools close at hand.

ZAD brings these experiences together in one Arabic-first app. Its home screen links to the main features, while focused screens support reading, listening, searching, memorization practice, prayer planning, and personal reminders. A shared visual system and light and dark themes keep the experience consistent across those features.

## Features

- **Quran:** browse the 114 surahs, search by name or number, read ayahs, choose a reciter, and listen to recitation.
- **Memorization practice:** build a test from the full Quran, one surah, multiple surahs, or an ayah range; choose a difficulty and question count; review the score and missed ayahs afterward.
- **Azkar:** browse categories such as morning, evening, and sleep remembrance. Add, edit, and remove custom azkar.
- **Sebha:** choose a zikr and a 33 or 99 count target, track progress, and keep counter data between sessions.
- **Prayer times:** view daily timings and a calendar, and configure prayer notifications and adhan playback.
- **Qibla:** request the device location, calculate the Qibla bearing, and display live compass heading where a compass sensor is available.
- **Hadith:** browse the Hadith of the day, request another Hadith, search, and view details such as source, grade, and narrators when supplied by the service.
- **Duas:** browse written duas by category, search, and save favorites.
- **Prophets' stories:** browse sections and read story content from Wikisource.
- **Audio library:** import and manage personal Quran or adhan recordings, preview audio, and select from online adhan voices.
- **Notifications and appearance:** configure prayer, azkar, and salawat reminders, and choose the light or dark theme.

## Screenshots

All screenshot files are stored in the repository root and embedded below. Screens are grouped by feature so each flow can be viewed together.

### Splash and home

<p align="center">
  <img src="./splash.jpeg" width="220" alt="ZAD splash screen" />
  <img src="./home-overview.jpeg" width="220" alt="Home screen overview" />
  <img src="./home-quick-actions.jpeg" width="220" alt="Home screen feature shortcuts" />
</p>

### Quran and memorization test

<p align="center">
  <img src="./quran-library.jpeg" width="220" alt="Quran surah list" />
  <img src="./quran-reading.jpeg" width="220" alt="Surah reading screen" />
  <img src="./quran-reciter-selection.jpeg" width="220" alt="Quran reciter selection" />
  <img src="./quran-memorization-setup.jpeg" width="220" alt="Memorization test setup" />
  <img src="./quran-memorization-quiz.jpeg" width="220" alt="Memorization test question" />
  <img src="./quran-memorization-results.jpeg" width="220" alt="Memorization test results and missed ayahs" />
</p>

### Azkar and Sebha

<p align="center">
  <img src="./azkar.jpeg" width="220" alt="Daily azkar screen" />
  <img src="./sebha-overview.jpeg" width="220" alt="Sebha zikr and target selection" />
  <img src="./sebha-counter.jpeg" width="220" alt="Sebha counter and progress" />
</p>

### Hadith

<p align="center">
  <img src="./hadith-home.jpeg" width="220" alt="Hadith home and daily Hadith" />
  <img src="./hadith-details.jpeg" width="220" alt="Hadith details and source" />
  <img src="./hadith-library.jpeg" width="220" alt="Hadith library search" />
</p>

### Duas

<p align="center">
  <img src="./duas.jpeg" width="220" alt="Written duas" />
  <img src="./dua-categories.jpeg" width="220" alt="Dua category filter" />
</p>

### Prayer times and Qibla

<p align="center">
  <img src="./prayer-times.jpeg" width="220" alt="Prayer times and next prayer countdown" />
  <img src="./qibla.jpeg" width="220" alt="Qibla compass" />
</p>

### Prophets' stories

<p align="center">
  <img src="./prophets-stories.jpeg" width="220" alt="Prophets stories index" />
  <img src="./prophet-story-reader.jpeg" width="220" alt="Prophets story reader" />
</p>

### Settings and audio

<p align="center">
  <img src="./settings-main.jpeg" width="220" alt="Appearance and prayer settings" />
  <img src="./settings-notifications-and-audio.jpeg" width="220" alt="Notification and audio library settings" />
  <img src="./adhan-voices.jpeg" width="220" alt="Adhan voice selection and preview" />
</p>

## Technology and implementation

### Application structure

The code is organized by feature under `lib/features/`. Most feature modules separate presentation, domain, and data responsibilities:

```text
Presentation (screens, widgets, Cubits)
                 ↓
Domain (entities, repository contracts, use cases)
                 ↓
Data (repository implementations, models, data sources)
```

- **Presentation:** Flutter screens and reusable widgets render the current state and send user actions to Cubits.
- **Domain:** entities describe feature data; use cases express operations such as loading a surah, creating test questions, or scheduling a reminder. Repository contracts keep feature logic independent of storage and HTTP details.
- **Data:** local and remote data sources perform the actual reads and writes. Models parse API or storage data and map it to domain entities. Repository implementations connect those sources to the domain contracts.
- **Dependency injection:** `get_it` registers data sources, repository implementations, use cases, and Cubits in `lib/core/dependency_injection/injection_container.dart`. Screens request feature Cubits from this shared container.

This is a feature-oriented, layered design. It keeps UI, application rules, and data access easier to change independently while allowing each feature to remain discoverable in its own directory.

### State management

`flutter_bloc` and **Cubit** are used for feature state. A Cubit exposes states for loading, loaded content, and errors, and provides methods for user actions. Widgets use `BlocBuilder` or related Bloc widgets to redraw from those state changes. Examples include Quran browsing, memorization tests, prayer times, azkar, settings, and audio preview.

### Local data and persistence

**Hive** is the local key-value store. The app initializes Hive during startup and opens feature boxes for settings, Sebha, personal audio metadata, custom azkar, and salawat scheduling. Other local records include memorization-test history, Hadith-of-the-day selection, and dua favorites.

Several content sources are bundled with the app:

- `assets/quran/quran-uthmani.txt` supplies local ayahs for memorization-question generation. The loader parses the text asset, caches it in memory after its first read, and validates the expected ayah sequence and counts for all 114 surahs.
- `assets/azkar/azkar.json` and `assets/data/duas.json` provide local azkar and written-dua content.

The memorization-test generator filters local ayahs by the selected scope, shuffles eligible questions, and generates different question formats by difficulty. Easy questions offer multiple-choice answers; medium questions hide selected words; hard questions ask the user to continue an ayah. Arabic answer options are normalized before comparison to handle common orthographic and diacritic differences. Test outcomes and missed ayahs can be saved to Hive for later review.

### Network APIs and content sources

The `http` package is used by remote data sources. Responses are decoded from JSON, converted into feature models, and mapped to domain entities by repositories.

| Service | Current use in ZAD |
| --- | --- |
| [Al Quran Cloud](https://alquran.cloud/api) | Random ayah, surah list, and surah text |
| [MP3 Quran](https://mp3quran.net/api) | Reciter catalog and Quran audio metadata |
| [AlAdhan](https://aladhan.com/prayer-times-api) | Prayer timings and calendar; the current request is configured for Cairo, Egypt, calculation method 5 |
| [Bayan Alwa7i](https://bayan.alwa7i.com/) | Hadith search and Hadith details |
| [Wikisource API](https://ar.wikisource.org/) | Sections and reading text for Prophets' stories |
| [Alfurqan Online](https://alfurqan.online/) | Adhan voice catalog and audio files |

Remote reading, search, catalogs, and prayer data require network access. The local Quran text asset is used for memorization practice, and azkar and written duas are bundled with the app. Other offline behavior depends on the specific feature and any audio already saved on the device.

### Location, compass, and Qibla

`geolocator` checks that location services are enabled, requests location permission when needed, and gets the current coordinates. The Qibla repository calculates the bearing from those coordinates. `flutter_compass` supplies a heading stream to rotate or update the compass display. The screen handles unavailable sensors and location-permission errors as feature states.

### Audio and files

`just_audio` powers Quran playback and audio previews. `file_picker` lets a user select supported audio formats (`mp3`, `m4a`, `aac`, `wav`, `ogg`, or `flac`). The app copies selected files into its application documents directory using `path_provider`, then stores recording metadata in Hive. Deleting a recording removes both its saved file and its Hive entry.

Adhan voices are loaded from the remote catalog and can be downloaded to the app documents directory. The cache checks for an existing non-empty file before downloading again, and the selected voice can be used by the prayer service.

### Local notifications and time zones

`flutter_local_notifications` creates and schedules prayer notifications. `timezone` and `flutter_timezone` initialize the device's local time zone so scheduled times use local clock rules. On Android, the app checks exact-alarm availability and falls back to inexact scheduling if exact alarms are unavailable.

Azkar and salawat scheduling also use Android platform channels alongside the Flutter notification plugin. Notification payloads are routed through a navigation service so a notification tap can open the related part of the app. Notification preferences are managed through settings Cubits and local storage.

### UI, themes, and responsive layout

The app uses Flutter's **Material 3** components with a custom gold, parchment, and brown visual system. Separate light and dark `ThemeData` definitions provide coordinated colors for surfaces, text, cards, and controls. The chosen theme mode is saved in Hive.

`Responsive` exposes mobile, tablet, and desktop width breakpoints; `ResponsiveBody` constrains wide layouts to a readable maximum width (760 px by default) and centers them on larger screens. The UI also uses reusable feature widgets and Flutter animation controllers for transitions and interaction feedback.

Other packages used by feature code include:

| Package | Role |
| --- | --- |
| `equatable` | Value equality for feature state and data types |
| `hijri` | Displaying the Hijri date on the home screen |
| `share_plus` | Sharing Quran content |
| `url_launcher` | Opening external sources, such as Hadith references |
| `flutter_local_notifications`, `timezone`, `flutter_timezone` | Local reminders and time-zone-aware scheduling |

## Project layout

```text
lib/
├── app/                   # App root and main navigation
├── core/                  # Themes, constants, utilities, and dependency injection
├── features/              # Feature modules (Quran, Hadith, Azkar, prayer, and more)
├── api_services/          # Shared API service code
├── models/                # Shared models
└── services/              # Shared app services
assets/
├── azkar/                 # Bundled azkar data
├── data/                  # Bundled dua data
└── quran/                 # Local Quran text for memorization practice
```

## Run locally

Install Flutter and Dart for your development platform, then run:

```bash
git clone https://github.com/Khaledwaleed11/zad.git
cd zad
flutter pub get
flutter run
```

Build an Android release APK with:

```bash
flutter build apk --release
```

The generated APK is typically written to `build/app/outputs/flutter-apk/app-release.apk`.

## License

No license file is currently included. Contact the repository owner before reusing this project's code or assets.
