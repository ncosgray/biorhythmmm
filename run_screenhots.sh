#!/bin/bash

# Integration test settings
APP_ID="com.nathanatos.Biorhythmmm"
LOCALES=("en-US" "de-DE" "es-ES" "fr-FR" "ja-JP" "pt-PT" "zh-Hans")
TEST_NAME="screenshots_test.dart"

# Function to run screenshots on a specified Android AVD
run_tests_on_avd() {
    local AVD_NAME="$1"
    local LOCALE="$2"
    
    echo "--- Starting screenshots on AVD: $AVD_NAME for locale: $LOCALE ---"
    
    # Kill any existing emulator instance to start fresh
    echo "Stopping any running emulators..."
    adb devices | grep emulator | cut -f1 | while read line; do adb -s $line emu kill; done

    # Start the emulator in the background, suppressing GUI
    echo "Starting emulator for $AVD_NAME..."
    emulator -avd "$AVD_NAME" -no-snapshot-load -no-snapshot-save -no-window > /dev/null 2>&1 &

    # Wait for the emulator to fully boot
    echo "Waiting for emulator to finish booting..."
    adb wait-for-device shell 'while [ "$(getprop sys.boot_completed | tr -d '\r')" != "1" ]; do sleep 1; done'
    adb shell input keyevent 82 # Unlock the screen

    # Set device locale properties
    echo "Applying locale $LOCALE and then rebooting..."
    adb shell "content insert --uri content://settings/system --bind name:s:system_locales --bind value:s:$LOCALE"
    adb shell "settings put System system_locales $LOCALE"
    adb shell "am broadcast -a com.android.intent.action.LOCALE_CHANGED --es com.android.intent.extra.LOCALE $LOCALE"
    adb reboot
    adb wait-for-device shell 'while [ "$(getprop sys.boot_completed | tr -d '\r')" != "1" ]; do sleep 1; done'
    adb shell input keyevent 82 # Unlock the screen

    # Confirm the device is ready
    echo "Emulator is ready. Running screenshots..."
    adb devices

    # Run Flutter integration tests
    export DEVICE_NAME="$AVD_NAME"
    export TEST_LOCALE="$LOCALE"
    adb uninstall $APP_ID
    sleep 5
    flutter drive --driver=integration_test/integration_test_driver.dart \
                  --target=integration_test/$TEST_NAME \
                  -d "sdk gphone64 arm64"

    # Kill the emulator after tests are done
    echo "Screenshots complete. Shutting down emulator..."
    adb devices | grep emulator | cut -f1 | while read line; do adb -s $line emu kill; done

    sleep 5
    echo "--- Finished screenshots on AVD: $AVD_NAME for locale: $LOCALE ---"
}

# Function to run screenshots on a specified iOS simulator
run_tests_on_ios() {
    local SIMULATOR_NAME="$1"
    local LOCALE="$2"
    local LANG_CODE=$(echo "$LOCALE" | cut -d'-' -f1)
    if [ ${#LOCALE} -gt 5 ]; then
        LANG_CODE="$LOCALE" # Override for locales like zh-Hans
    fi

    echo "--- Starting tests on iOS Simulator: $SIMULATOR_NAME for locale: $LOCALE ---"

    # Get the UDID for the specified simulator name
    local UDID=$(xcrun simctl list devices available --json | jq --raw-output '.devices | flatten | .[] | select(.name == "'"$SIMULATOR_NAME"'") | .udid')
    if [[ -z "$UDID" ]]; then
        echo "Error: Simulator named \"$SIMULATOR_NAME\" not found. Exiting."
        return 1
    fi

    # Shut down all other running simulators to ensure isolation
    echo "Shutting down all other simulators..."
    xcrun simctl shutdown all > /dev/null 2>&1

    # Boot the specific simulator
    echo "Booting simulator: $SIMULATOR_NAME with UDID $UDID..."
    xcrun simctl boot "$UDID" > /dev/null 2>&1

    # Wait for the simulator to be ready using bootstatus
    echo "Waiting for simulator to finish booting..."
    xcrun simctl bootstatus "$UDID" -b

    # Set device locale properties
    echo "Applying locale $LOCALE using defaults write..."
    xcrun simctl spawn "$UDID" defaults write "Apple Global Domain" AppleLanguages -array $LANG_CODE
    xcrun simctl spawn "$UDID" defaults write "Apple Global Domain" AppleLocale -string $LOCALE
    killall -HUP SpringBoard
    
    # Run Flutter integration tests
    echo "Simulator is ready. Running screenshots..."
    export DEVICE_NAME="$SIMULATOR_NAME"
    export TEST_LOCALE="$LOCALE"
    sleep 5
    flutter drive --driver=integration_test/integration_test_driver.dart \
                  --target=integration_test/$TEST_NAME \
                  -d "$UDID"

    # Shut down the specific simulator after tests are done
    echo "Screenshots complete. Shutting down $SIMULATOR_NAME..."
    xcrun simctl shutdown "$UDID" > /dev/null 2>&1

    sleep 5
    echo "--- Finished screenshots on iOS Simulator: $SIMULATOR_NAME for locale: $LOCALE ---"
}

# Cleanup the screenshots directory
rm -rf screenshots-output

for LOCALE in "${LOCALES[@]}"; do
    # Android screenshots
    run_tests_on_avd "Pixel_9_API_36" "$LOCALE"
    run_tests_on_avd "Pixel_C_Tablet_API_33" "$LOCALE"

    # iOS screenshots
    run_tests_on_ios "iPhone 16 Plus" "$LOCALE"
    run_tests_on_ios "iPad Air 13-inch (M3)" "$LOCALE"
done

echo "All screenshots completed."