# DictationKit

Native iOS voice-to-text app with a custom system keyboard, built in SwiftUI with the Deepgram API.

## Demo

![Transcription demo](Transcription%20DEMO.MP4)

## Overview

DictationKit is a portfolio-grade iOS sample that demonstrates a complete voice-dictation pipeline on iOS: record audio with AVFoundation, send it to the Deepgram speech-to-text API, surface live results in a SwiftUI interface, and persist settings and the last transcript so they're available both inside the app and from a companion custom keyboard extension.

It's intentionally small enough to read end-to-end in one sitting, but covers the architectural choices a production iOS feature would actually face: modular service layers, actor-isolated networking, App Groups for cross-process data sharing, and a clean separation between the SwiftUI app and a UIKit-based keyboard extension.

## Features

- One-tap voice recording with live state UI and animated mic button.
- Speech-to-text transcription via the Deepgram `nova-2` model.
- Configurable transcription settings: language, audio quality, auto-punctuation, auto-capitalization.
- Last transcript and user settings shared between the app and the keyboard extension via App Groups.
- Custom system keyboard extension that mirrors the app's transcription path (see *Known issues* — currently non-functional).

## Tech stack

- **UI** — SwiftUI (main app), UIKit / `UIInputViewController` (keyboard extension)
- **Concurrency** — Swift Concurrency (`actor`, `async/await`, `@MainActor`) with Combine for reactive view-model updates
- **Networking** — `URLSession` against the Deepgram REST API (`https://api.deepgram.com/v1/listen`)
- **Audio** — AVFoundation (`AVAudioRecorder`, `AVAudioSession`)
- **Persistence / IPC** — App Groups (`UserDefaults(suiteName:)`), iCloud Key-Value Store
- **Language / targets** — Swift 5, iOS 18.5+

## Architecture

The app follows an **MVVM** structure with a single source of truth on the main actor:

- **View layer (SwiftUI)** — `ContentView`, `SettingsView`, `TranscriptView`, `RecordingButton`. Views observe state through `@EnvironmentObject` injection.
- **View model / state** — `@MainActor class AppState: ObservableObject` (`DictationKit/State/AppState.swift`) owns recording state, exposes `@Published` properties, and bridges Combine subscriptions to the App Groups store.
- **Services** — `actor DeepgramService` for thread-safe network calls, `AudioSessionManager` and `AudioRecorder` for AVFoundation orchestration, `AppGroupsManager` for cross-process persistence, `SecureConfigurationManager` for credential access.
- **Models** — Plain Codable structs (`TranscriptionResult`, `UserSettings`, `AudioRecordingSettings`) with no business logic.
- **Two targets, shared models** — The main app and the keyboard extension each compile their own copy of the shared model and service files. Duplicating these by target (rather than extracting an `.xcframework` or local SPM package) is a deliberate simplification kept from the project's origin as a short take-home assignment; extracting a shared module is the obvious next step for any production codebase.

## Project structure

```
.
├── DictationKit/                  # Main app target (SwiftUI)
│   ├── DictationKitApp.swift      # @main entry point
│   ├── Views/                     # ContentView, SettingsView, TranscriptView
│   ├── Components/                # RecordingButton
│   ├── State/                     # AppState (@MainActor view model)
│   ├── Service/                   # DeepgramService (actor)
│   ├── Models/                    # TranscriptionResult, errors
│   ├── Utils/                     # AudioRecorder, AudioSessionManager,
│   │                              # AppGroupsManager, SecureConfigurationManager,
│   │                              # UserSettings, AudioRecordingSettings
│   └── Resources/                 # Assets.xcassets, entitlements
├── DictationKitKeyboard/          # Custom keyboard extension (UIKit)
│   ├── KeyboardViewController.swift
│   ├── Info.plist
│   └── (duplicated shared files: AppGroupsManager, DeepgramService, ...)
├── DictationKit.xcodeproj/
├── Transcription DEMO.MP4
└── README.md
```

## Requirements

- Xcode 16 or newer
- iOS 18.5+ (device or simulator)
- An Apple Developer team set in *Signing & Capabilities* for both targets
- A Deepgram API key ([signup](https://deepgram.com))

## Running locally

1. `open DictationKit.xcodeproj`
2. In **Signing & Capabilities** for both the `DictationKit` and `DictationKitKeyboard` targets, select your development team. Automatic signing will create new App IDs for the bundle identifiers `com.luannluna.DictationKit` and `com.luannluna.DictationKit.Keyboard`.
3. Add your Deepgram API key in `DictationKit/Utils/SecureConfigurationManager.swift` — replace the placeholder value returned from `getDeepgramApiKey()`. (Putting it through Keychain instead is one of the *next steps* below.)
4. Build and run the `DictationKit` scheme. The keyboard extension can be installed from *Settings → General → Keyboard → Keyboards*, but see the known-issue note below.

## Known issues

- **Keyboard extension transcription is non-functional.** The mic button renders inside the keyboard, but tapping it does not produce a transcript. The most likely contributing factors are the stricter sandbox iOS applies to keyboard extensions reaching the microphone (even with `RequestsOpenAccess` and `NSMicrophoneUsageDescription` set), the placeholder Deepgram credential plumbed through `SecureConfigurationManager`, and audio-session contention between the host app and the extension. The full transcription path works end-to-end in the main app.
- **No retry / no offline mode** — a failed Deepgram call surfaces as a one-shot error with no backoff or fallback transcript.
- **Shared code is duplicated between targets** — not packaged as a framework or local SPM module.
- **Repo root folder name** — the on-disk repository root is `WillowHomeAssignment/` for historical reasons; the Xcode project, both targets, and all bundle identifiers are `DictationKit`. Cloning the repo under a new directory name has no effect on the build.
- **Keyboard extension iOS deployment target** — set to a future iOS version in `project.pbxproj` (pre-existing config anomaly). The main app target is correctly set to iOS 18.5.

## What I'd do next

- Diagnose the keyboard-extension microphone path — confirm whether `RequestsOpenAccess` plus runtime permission is actually granting mic access, and instrument the failure mode with user-visible errors.
- Replace `SecureConfigurationManager`'s hardcoded credentials with Keychain-backed storage and add a Deepgram retry/backoff policy.
- Extract the duplicated services and models into a local Swift Package consumed by both targets, and add XCTest / Swift Testing coverage around `DeepgramService` and `AppGroupsManager`.

## Author

Luann Luna — [luann.marques@gmail.com](mailto:luann.marques@gmail.com)
