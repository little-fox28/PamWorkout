# 06. DevOps Engine & Hybrid Deployment Automation

**Module ID:** `MOD-06-DEVOPS`  
**Requirement Standard:** BABOK v3 / IEEE 830  
**Target Files:** `deploy.sh`, `xtool.yml`, `.gitignore`

---

## 1. Business Objective
Enable single-command, zero-friction compilation, signing, packaging, and deployment of the iOS app from a non-macOS workstation (Linux/WSL) onto physical iPhone devices via both USB cable and Wi-Fi network.

---

## 2. Functional Requirements (FR)

### [FR-OPS-001] Dual-Mode Device Discovery (USB & Wi-Fi)
* Automatically checks device presence across two channels:
  * **Wired USB:** Detects device via `ideviceinfo` / `usbmuxd`.
  * **Wireless Wi-Fi:** Detects network-paired iPhone via `ideviceinfo -n`.
* When wired, the script automatically enables Wi-Fi lockdown (`idevicepair wifi on`) for future wireless sessions.

### [FR-OPS-002] Single-Time Windows Administrator Elevation (UAC)
* Seamless integration with Windows `usbipd-win`:
  * **Initial Setup (`Not shared`):** Runs `usbipd bind` with Admin elevation (UAC prompt) **exactly once**.
  * **Subsequent Runs (`Shared`):** Runs `usbipd attach` in user space **without** any Admin prompt.
  * **Already Attached:** Completely skips `usbipd` execution.

### [FR-OPS-003] End-to-End Build & Signing Pipeline
* Runs `xtool dev build --sign --ipa` to compile Swift 6 code, package into `.ipa`, and sign with developer credentials.
* Installs onto target device via `ideviceinstaller` (or `ideviceinstaller -n` for Wi-Fi).
* Completes full cycle in under 15 seconds.
