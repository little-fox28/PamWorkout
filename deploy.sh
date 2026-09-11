#!/usr/bin/env bash
set -e

# Ensure swiftly / swift toolchain is in PATH
if [ -d "$HOME/.local/share/swiftly/bin" ]; then
    export PATH="$HOME/.local/share/swiftly/bin:$PATH"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=== [1/3] Checking iOS Device Connection ==="

# Step 1: Check if iPhone is already reachable via lockdownd
if ! ideviceinfo -k DeviceName >/dev/null 2>&1; then
    if command -v usbipd.exe >/dev/null 2>&1; then
        echo "🔍 Device not attached to WSL. Attempting attach via usbipd (Admin elevation if needed)..."
        
        # Try normal attach first; if failed, trigger UAC Admin elevation via PowerShell
        if ! usbipd.exe attach --wsl --busid 2-2 2>/dev/null; then
            echo "⚡ Yêu cầu quyền Administrator trên Windows để attach USB (busid 2-2)..."
            powershell.exe -Command "Start-Process usbipd -ArgumentList 'attach --wsl --busid 2-2' -Verb RunAs -Wait" 2>/dev/null || true
        fi
        
        # Wait up to 5 seconds for the USB device to show up in Linux
        for i in {1..5}; do
            if lsusb 2>/dev/null | grep -qi "05ac:"; then
                break
            fi
            sleep 1
        done
    fi

    # Restart usbmuxd to ensure clean socket connection
    sudo systemctl restart usbmuxd 2>/dev/null || (sudo pkill -9 usbmuxd 2>/dev/null || true; sudo usbmuxd --user usbmux)
    sleep 1
fi

# Step 2: Verify device connectivity
if ! ideviceinfo -k DeviceName >/dev/null 2>&1; then
    echo "❌ Error: No iOS device detected!"
    echo "👉 Please make sure:"
    echo "   1. iPhone is plugged in via USB and unlocked."
    echo "   2. 'Trust This Computer' prompt has been confirmed on your iPhone."
    exit 1
fi

DEVICE_NAME=$(ideviceinfo -k DeviceName 2>/dev/null || echo "iPhone")
DEVICE_OS=$(ideviceinfo -k ProductVersion 2>/dev/null || echo "Unknown")
echo "📱 Connected to: $DEVICE_NAME (iOS $DEVICE_OS)"

echo ""
echo "=== [2/3] Building and Signing IPA with xtool ==="
xtool dev build --sign --ipa

IPA_FILE="$SCRIPT_DIR/xtool/PamWorkout.ipa"
if [ ! -f "$IPA_FILE" ]; then
    echo "❌ Error: $IPA_FILE was not created!"
    exit 1
fi

echo ""
echo "=== [3/3] Installing onto $DEVICE_NAME via ideviceinstaller ==="
ideviceinstaller install "$IPA_FILE"

# --- AUTO OPEN/RUN APP (Optional) ---
# Nếu bạn muốn app tự động **mở lên** sau khi cài đặt (giống Xcode), hãy bỏ comment các dòng dưới đây:
#
# FULL_BUNDLE_ID=$(ideviceinstaller list --xml | grep -o 'XTL-.*\.com\.example\.PamWorkout' | head -1)
# if [ -z "$FULL_BUNDLE_ID" ]; then
#     FULL_BUNDLE_ID="XTL-3U78NS5ZP9.com.example.PamWorkout" # Fallback
# fi
# echo "🚀 Đang tự động mở app ($FULL_BUNDLE_ID)..."
# nohup idevicedebug run "$FULL_BUNDLE_ID" >/dev/null 2>&1 &

echo ""
echo "✅ Deployment complete! You can now open PamWorkout on your iPhone."
