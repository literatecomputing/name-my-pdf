#!/bin/bash
# app_launcher.sh: Wrapper for NameMyPdf app
# Handles menu actions, passes dropped files to normalize_filename.sh


# Build-time placeholders (replaced by CI before packaging)
VERSION="${VERSION:-VERSION_PLACEHOLDER}"
BUILD_DATE="${BUILD_DATE:-DATE_PLACEHOLDER}"
APP_NAME="NameMyPdf"
COPYRIGHT="Copyright (C) 2025 Jay Pfaffman"

# If no arguments, output Status Menu items for Platypus
if [ $# -eq 0 ]; then
    echo "About ${APP_NAME}"
    echo "Settings..."
    echo "View Documentation"
    echo "Open GitHub"
    echo "Logs"
    echo "Donate"
    exit 0
fi


echo "[DEBUG] Arguments: $@" >> /tmp/name-my-pdf-debug.log
echo "[DEBUG] ENV: action='$action'" >> /tmp/name-my-pdf-debug.log
action="${action:-$1}"
arg="$(printf '%s' "$action" | sed 's/%20/ /g')"
echo "[DEBUG] Parsed action: $arg" >> /tmp/name-my-pdf-debug.log
case "$arg" in
    "Settings...")
        open -e ~/.namemypdfrc
        exit 0
        ;;
    "Logs")
        open -a Console ~/Library/Logs/NameMyPdf.log
        exit 0
        ;;
    "Open GitHub")
        open "https://github.com/literatecomputing/name-my-pdf"
        exit 0
        ;;
    "View Documentation")
        open "https://www.namemypdf.com/documentation.html"
        exit 0
        ;;
    "Donate")
        open "https://www.namemypdf.com/donate.html"
        exit 0
        ;;
    "About ${APP_NAME}")
        # Try to locate a bundled icon in the same directory or resources
        SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
        ICON_PATH=""
        for candidate in "${SCRIPT_DIR}/icons/icon.icns" "${SCRIPT_DIR}/icons/icon.png" "${SCRIPT_DIR}/AppIcon.icns" "${SCRIPT_DIR}/icon.icns" "${SCRIPT_DIR}/icon.png"; do
            if [ -f "$candidate" ]; then
                ICON_PATH="$candidate"
                break
            fi
        done

        # Build the message (multi-line)
        MESSAGE="${APP_NAME} v${VERSION} (${BUILD_DATE})\n\n${COPYRIGHT}"

        if [ -n "$ICON_PATH" ]; then
            /usr/bin/osascript <<APPSCRIPT
try
  set theIcon to POSIX file "$ICON_PATH" as alias
  display dialog "$MESSAGE" with title "About ${APP_NAME}" with icon theIcon buttons {"OK"} default button "OK"
on error
  display dialog "$MESSAGE" with title "About ${APP_NAME}" buttons {"OK"} default button "OK"
end try
APPSCRIPT
        else
            /usr/bin/osascript -e "display dialog \"$MESSAGE\" with title \"About ${APP_NAME}\" buttons {\"OK\"} default button \"OK\""
        fi

        exit 0
        ;;
 
    *)
        # Assume arguments are files, forward to normalize_filename.sh
        exec "$(dirname "$0")/normalize_filename.sh" "$@"
        ;;
esac
