# 01. Interval Timer Engine (Static Workout & Plank)

**Module ID:** `MOD-01-TIMER`  
**Requirement Standard:** BABOK v3 / IEEE 830  
**Target Screen:** Interval Timer Tab (`IntervalTimerView.swift`, `IntervalTimerViewModel.swift`)

---

## 1. Business Objective
Provide a dedicated, low-friction interval timer tailored for static hypertrophy exercises (such as Planks) where conventional stopwatches fail to deliver dual-phase visual tracking, background accuracy, or seamless audio coexistence with background music.

---

## 2. Functional Requirements (FR)

### [FR-IT-001] Parameter Configuration (Cấu hình thông số)
* **Description:** Prior to starting an interval session, users can customize all key workout parameters.
* **Input Parameters:**
  * **Sets (Số hiệp):** Integer value between 1 and 50 (Default: `3`).
  * **Work Time (Thời gian tập):** Duration in seconds (Range: `5s` to `600s`, Default: `60s`).
  * **Rest Time (Thời gian nghỉ):** Duration in seconds (Range: `5s` to `600s`, Default: `30s`).
* **UI Controls:** Stepper buttons (`+` / `-`) for quick incremental adjustments.

### [FR-IT-002] Visual Dual-Phase State Management (Quản lý trạng thái 2 pha)
* **Description:** The UI clearly distinguishes between active exertion and rest periods using a circular progress ring and dedicated color coding:
  * **Work / Plank State:**
    * Color: High-contrast Orange/Red (`#FF453A`).
    * Indicators: Circular countdown ring, active set counter (e.g. `Set 2/4`), remaining seconds display.
  * **Rest State:**
    * Color: Active Recovery Green (`#30D158`).
    * Indicators: Rest countdown ring, "Next: Set X" preview badge.
  * **Paused State:**
    * Indicators: Pulsing visual opacity, timer display freeze.
  * **Completed State:**
    * Indicators: Full-screen celebration overlay showing aggregated total workout duration in seconds.

### [FR-IT-003] Playback Controls (Điều khiển phiên tập)
* **Start:** Validates inputs, activates audio hardware session, initializes ActivityKit, and begins countdown.
* **Pause / Resume:** Temporarily halts or resumes countdown without losing elapsed progress or set index.
* **Skip Rest:** Enables athletes who recover faster to immediately terminate the rest countdown and jump straight into the next work set.
* **Reset / Stop:** Cancels current session, ends background Live Activity, and returns to configuration screen.

### [FR-IT-004] Haptic & Multi-Sensory Feedback (Phản hồi xúc giác & Âm thanh)
* **Count-Down Beep:** At $T - 3\text{s}, 2\text{s}, 1\text{s}$ before every phase transition, a soft system chime (ID `1057` / Tink) plays.
* **Haptic Alerts:**
  * Transition countdown: `UIImpactFeedbackGenerator(style: .medium)`.
  * Phase completion / Set start: `UINotificationFeedbackGenerator.success`.
