# Lapislazuli
# CSCI B590 - Spring 2025  
## Final Project - FinalTeam09
**Team Members**:  
- Shahetha Shanmugam (shahshan@iu.edu)  
- Ayush Kumar Malik (aymalik@iu.edu)

---

## Purpose of the App
NotesOnGo is a speech-driven note-taking app that allows users to record notes using voice commands while on the move. It transcribes spoken content live, lets users categorize notes, and provides quick save/discard actions.

---

## Instructions to Interact with the App
1. Launch the app on a physical device or simulator.
2. Tap the **microphone button** to start recording.
3. Speak your note; it will appear in real time.
4. Tap again to stop recording.
5. Choose a category (e.g., Work or Personal).
6. Press **Save** to store the note or **Discard** to clear.
7. View saved notes in the History tab.

---

## Xcode & Device Info
- Xcode Version: 15.3  
- Tested On: iPhone 16 Pro (iOS 18.3), iPad (10th generation)

---

## Feature Completion (Lab 13 Spec Match)

| Feature                                 | Status     | File                                                                 |
|-----------------------------------------|------------|----------------------------------------------------------------------|
| 1. Recording voice & live transcription | Complete   | `GoRecordViewController.swift`, `SpeechRecognizer.swift`            |
| 2. UI for segmented categories          | Complete   | `GoRecordViewController.swift`, Storyboard                          |
| 3. Save & Discard functionality         | Complete   | `GoRecordViewController.swift`                                      |
| 4. History view for saved notes         | Complete   | `GoHistoryViewController.swift`, `GoNote.swift`, `NotesStore.swift` |
| 5. Model shared via AppDelegate         | Complete   | `AppDelegate.swift`, `NotesStore.swift`                             |
| 6. Persistence using Property List      | Complete   | `NotesStore.swift`, `PlistManager.swift`                            |

---

## Swift Files by Feature

| File                        | Purpose                                                        |
|-----------------------------|----------------------------------------------------------------|
| `GoRecordViewController.swift` | Handles UI for recording, transcribing, saving notes       |
| `SpeechRecognizer.swift`       | Manages AVAudioEngine + Speech framework for transcription |
| `GoHistoryViewController.swift`| Displays list of saved notes in table view                 |
| `GoNote.swift`                 | Note model struct                                            |
| `NotesStore.swift`             | Shared store for managing saved notes                       |
| `PlistManager.swift`           | Handles saving/loading notes to/from disk                   |
| `AppDelegate.swift`            | Initializes shared model                                    |

---

## Design Changes
- Used `UIStackView` to ensure layout adapts across iPhone and iPad.
- Wrapped main content inside a `UIScrollView` to prevent keyboard overlap.
- Centered content vertically using `Center Y` constraint instead of fixed top spacing.
- Used `Equal Spacing` distribution for consistent spacing across UI elements.

---

## Code Responsibilities

| Member              | Responsibilities                                                                 |
|---------------------|----------------------------------------------------------------------------------|
| Shahetha Shanmugam  | SpeechRecognizer, RecordViewController logic, layout restructuring, plist persistence |
| Ayush Kumar Malik   | History table view, model integration, segmented control setup, UI debugging         |
