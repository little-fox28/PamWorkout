# 05. Settings, User Profile & Localization

**Module ID:** `MOD-05-SETTINGS`  
**Requirement Standard:** BABOK v3 / IEEE 830  
**Target Files:** `Setting.swift`, `Localizable.xcstrings`, `CoreBundle.swift`

---

## 1. Business Objective
Provide a centralized settings hub for user profile management, health metrics calculation (BMI), theme switching, and seamless localization across international markets.

---

## 2. Functional Requirements (FR)

### [FR-SET-001] User Profile & Health Metrics (Hồ sơ & Chỉ số BMI)
* **Profile Card:** Displays user avatar, full name, and real-time Body Mass Index (`BMI`).
* **BMI Metric Classification:** Computes BMI category based on international standards (e.g. `23.5 - Khỏe mạnh`).

### [FR-SET-002] Appearance & Color Scheme Toggle (Chế độ hiển thị)
* **Mode Selection:** Supports 3 distinct appearance options via `.preferredColorScheme()`:
  * **System (Hệ thống):** Automatically adapts to device iOS system dark/light schedule.
  * **Light (Sáng):** Forces light mode styling.
  * **Dark (Tối):** Forces OLED-optimized pure dark mode styling.

### [FR-SET-003] Multi-Language Localization Engine (Đa ngôn ngữ)
* **Supported Locales:**
  * `vi` (Tiếng Việt - Default).
  * `en` (English).
* **Architecture:** Uses Apple's modern `.xcstrings` catalog format for string cataloging and `CoreBundle` lookup.
