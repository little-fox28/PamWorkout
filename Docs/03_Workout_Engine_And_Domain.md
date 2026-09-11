# 03. Workout Engine & Clean Architecture Domain

**Module ID:** `MOD-03-WORKOUT`  
**Requirement Standard:** BABOK v3 / IEEE 830  
**Target Files:** `WorkoutSession.swift`, `WorkoutRepository.swift`, `WorkoutCycleUseCase.swift`, `WorkoutRepositoryImpl.swift`, `WorkoutView.swift`

---

## 1. Business Objective
Provide a clean, robust, and extensible enterprise architecture (Clean Architecture + MVVM) managing the hypertrophy bodybuilding workout cycle with strict business rule enforcement.

---

## 2. Functional Requirements (FR)

### [FR-WO-001] Push-Pull-Legs Split Cycle Engine (Chu trình tập luyện)
* **Description:** Manages the sequential progression of workout days to optimize muscular hypertrophy and recovery:
  $$\text{Push (Ngực/Vai/Tay sau)} \longrightarrow \text{Pull (Lưng/Tay trước)} \longrightarrow \text{Legs (Chân/Bụng)} \longrightarrow \text{Rest (Nghỉ ngơi)}$$
* **Use Case Implementation:** `WorkoutCycleUseCase` evaluates the current workout state, determines the next day in the cycle, and persists session logs.

### [FR-WO-002] Cardio Elimination Logic (Loại bỏ Cardio)
* **Description:** Enforces strict domain rules tailored for bodybuilding hypertrophy, actively filtering out cardio-heavy exercises from the recommendation engine.

### [FR-WO-003] Clean Architecture Layering (Phân lớp kiến trúc)
* **Domain Layer (Pure Business Rules):** Independent of SwiftUI/UIKit or any external database.
* **Data Layer (Repository Implementation):** Manages data persistence and abstraction interfaces.
* **Presentation Layer (SwiftUI + MVVM):** High-performance UI rendering isolated from domain logic.
* **Dependency Injection (AppDIContainer):** Centralized dependency container assembling all use cases and views.
