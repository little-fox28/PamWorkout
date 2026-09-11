# 02. Background Processing & Live Activities

**Module ID:** `MOD-02-SYS`  
**Requirement Standard:** BABOK v3 / IEEE 830  
**Target Files:** `TimerAttributes.swift`, `IntervalTimerViewModel.swift`

---

## 1. Business Objective
Ensure the workout session remains uninterrupted and 100% accurate even when the athlete locks their device, puts it in their pocket, switches to other apps, or listens to high-bitrate music.

---

## 2. Functional Requirements (FR)

### [FR-SYS-001] Background Resiliency via Absolute Date Math (Độ chính xác nền)
* **Problem:** iOS suspends CPU execution threads and throttles `Timer.scheduledTimer` when the screen turns off.
* **Mechanism:**
  * When entering a Work or Rest phase, the ViewModel calculates a deterministic end timestamp:
    $$\text{targetEndDate} = \text{Date()} + \text{remainingSeconds}$$
  * When the app returns from the background (`scenePhase == .active`), the remaining time is recalculated instantaneously:
    $$\text{remainingSeconds} = \max(0, \text{targetEndDate.timeIntervalSince(Date())})$$
* **Outcome:** Zero second-drifting across long sessions.

### [FR-SYS-002] Live Activities & Dynamic Island (ActivityKit)
* **Description:** Provides real-time timer updates visible on the Lock Screen and in the Dynamic Island without opening the app.
* **Specifications:**
  * **Dynamic Island (Compact / Minimal):** Shows the current phase icon and countdown timer.
  * **Dynamic Island (Expanded):** Displays phase name ("Plank" / "Rest"), current Set number, and an interactive progress bar.
  * **Lock Screen Banner:** Conforms to iOS 16.1+ `Activity<TimerAttributes>`, with automated update and end handlers isolated using Swift 6 `@preconcurrency`.

### [FR-SYS-003] Audio Ducking Coexistence (Hòa trộn âm thanh)
* **Description:** Workout alert chimes must not abruptly stop or disconnect external audio (e.g. Spotify, Apple Music, YouTube Music, Podcasts).
* **Implementation:**
  * Configures `AVAudioSession.sharedInstance()` with category `.ambient` and option `.duckOthers`.
  * External music volume ducks smoothly by ~50% during the 3-second transition chime and immediately restores to 100% volume without stuttering.
