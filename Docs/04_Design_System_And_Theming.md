# 04. Design System & Apple Health Theming

**Module ID:** `MOD-04-DESIGN`  
**Requirement Standard:** BABOK v3 / IEEE 830  
**Target Files:** `Theme.swift`, `Colors.xcassets`

---

## 1. Business Objective
Deliver an aesthetically premium, native iOS user experience compliant with Apple Human Interface Guidelines (HIG) and styled to reflect Apple's official Health and Fitness design language.

---

## 2. Functional Requirements (FR)

### [FR-DS-001] Native System Grouped Styling (Giao diện chuẩn iOS)
* **Background:** Uses `Color(.systemGroupedBackground)` (Light: Soft light gray `#F2F2F7`, Dark: Pure black `#000000`).
* **Surfaces & Cards:** Uses `Color(.secondarySystemGroupedBackground)` (Light: Pure white `#FFFFFF`, Dark: Dark elevation `#1C1C1E`).
* **Semantic Hierarchy:**
  * Primary Text: `Color(.label)` (Auto-inverts black/white).
  * Secondary Text: `Color(.secondaryLabel)` (Muted gray for subtitles and units).
  * Dynamic Accent: `Color.green` / Dynamic accent token for active states and highlights.

### [FR-DS-002] Dynamic Type & Scalable Typography
* Uses native SwiftUI Font scales (`.largeTitle`, `.title2`, `.headline`, `.subheadline`, `.caption`) supporting system-wide Accessibility and Dynamic Type text resizing.
