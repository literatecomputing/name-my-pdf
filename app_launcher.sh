#!/bin/bash
# app_launcher.sh: Wrapper for NameMyPdf app
# Handles menu actions, passes dropped files to normalize_filename.sh


# Build-time placeholders (replaced by CI before packaging)
VERSION="${VERSION:-VERSION_PLACEHOLDER}"
BUILD_DATE="${BUILD_DATE:-DATE_PLACEHOLDER}"
APP_NAME="NameMyPdf"
COPYRIGHT="Copyright (C) 2025 Jay Pfaffman"

## Set FILES_RENAMED to length of ~/Library/Logs/NameMyPdf.log
if [ -f ~/Library/Logs/NameMyPdf.log ]; then
    FILES_RENAMED=$(wc -l < ~/Library/Logs/NameMyPdf.log)
else
    FILES_RENAMED=0
fi

## Set HAVE_DEBUG_LOG if ~/Library/Logs/NameMyPdf-debug.log exists
if [ -f ~/Library/Logs/NameMyPdf-debug.log ]; then
    HAVE_DEBUG_LOG=true
else
    HAVE_DEBUG_LOG=false
fi

## Set HAVE_LOGS if ~/Library/Logs/NameMyPdf.log exists
if [ -f ~/Library/Logs/NameMyPdf.log ]; then
    HAVE_LOGS=true
else
    HAVE_LOGS=false
fi


# If no arguments, output Status Menu items for Platypus
if [ $# -eq 0 ]; then
    echo "About ${APP_NAME}"
    echo "Settings..."
    echo "NameMyPdf Help"
    # echo "Open GitHub"
    if [ "$HAVE_LOGS" = true ]; then
        echo "Renamed Logs"
    fi
    if [ "$HAVE_DEBUG_LOG" = true ]; then
        echo "Debugging Logs"
    fi
    if [ "$FILES_RENAMED" -gt 0 ]; then
        echo "DISABLED|$FILES_RENAMED files renamed."
    fi
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
    "Debugging Logs")
        open -a Console ~/Library/Logs/NameMyPdf-debug.log
        exit 0
        ;;
    "Open GitHub")
        open "https://github.com/literatecomputing/name-my-pdf"
        exit 0
        ;;
    "NameMyPdf Help")
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

        # Basic about message
        BASE_MSG="${APP_NAME} v${VERSION} (${BUILD_DATE})\n\n${COPYRIGHT}"

        # Inline check: query GitHub Releases API for latest release
        LATEST_TAG=""
        LATEST_NAME=""
        LATEST_URL=""
        if command -v curl >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
            if latest_json=$(curl -fsS "https://api.github.com/repos/literatecomputing/name-my-pdf/releases/latest" 2>/dev/null); then
                LATEST_TAG=$(echo "$latest_json" | jq -r '.tag_name // empty') || LATEST_TAG=""
                LATEST_NAME=$(echo "$latest_json" | jq -r '.name // empty') || LATEST_NAME=""
                LATEST_URL=$(echo "$latest_json" | jq -r '.html_url // empty') || LATEST_URL=""
            fi
        fi

        # Semantic compare helper: return 0 if $2 > $1
        semcmp() {
            a=$(echo "$1" | sed 's/^v//')
            b=$(echo "$2" | sed 's/^v//')
            IFS=. read -r a1 a2 a3 <<EOF
$a
EOF
            IFS=. read -r b1 b2 b3 <<EOF
$b
EOF
            a1=${a1:-0}; a2=${a2:-0}; a3=${a3:-0}
            b1=${b1:-0}; b2=${b2:-0}; b3=${b3:-0}
            if [ "$b1" -gt "$a1" ]; then return 0; fi
            if [ "$b1" -lt "$a1" ]; then return 1; fi
            if [ "$b2" -gt "$a2" ]; then return 0; fi
            if [ "$b2" -lt "$a2" ]; then return 1; fi
            if [ "$b3" -gt "$a3" ]; then return 0; else return 1; fi
        }

        SHOW_UPDATE=false
        if [ -n "$LATEST_TAG" ]; then
            CUR_VER="$VERSION"
            if echo "$CUR_VER" | grep -qEi 'placeholder|^\s*$|^VERSION_PLACEHOLDER$'; then
                if git rev-parse --git-dir >/dev/null 2>&1; then
                    CUR_VER=$(git describe --tags --abbrev=0 2>/dev/null || "$CUR_VER")
                fi
            fi
            if semcmp "$CUR_VER" "$LATEST_TAG"; then
                SHOW_UPDATE=true
            fi
        fi

        if [ "$SHOW_UPDATE" = true ]; then
            MSG="${BASE_MSG}\n\nLatest: ${LATEST_TAG}${LATEST_NAME:+ - $LATEST_NAME}"
            if [ -n "$ICON_PATH" ]; then
                BUTTON=$(/usr/bin/osascript <<APPSCRIPT
try
  set theIcon to POSIX file "$ICON_PATH" as alias
  set resp to display dialog "$MSG" with title "About ${APP_NAME}" with icon theIcon buttons {"Open Release","OK"} default button "OK"
  button returned of resp
on error
  set resp to display dialog "$MSG" with title "About ${APP_NAME}" buttons {"Open Release","OK"} default button "OK"
  button returned of resp
end try
APPSCRIPT
)
            else
                BUTTON=$(/usr/bin/osascript -e "set resp to display dialog \"$MSG\" with title \"About ${APP_NAME}\" buttons {\"Open Release\",\"OK\"} default button \"OK\"" -e 'button returned of result')
            fi

            if [ "$BUTTON" = "Open Release" ]; then
                if [ -n "$LATEST_URL" ]; then
                    open "$LATEST_URL"
                else
                    open "https://github.com/literatecomputing/name-my-pdf/releases/latest"
                fi
            fi
            exit 0
        fi

        # No update (or couldn't check) - show normal About dialog
        if [ -n "$ICON_PATH" ]; then
            /usr/bin/osascript <<APPSCRIPT
try
  set theIcon to POSIX file "$ICON_PATH" as alias
  display dialog "$BASE_MSG" with title "About ${APP_NAME}" with icon theIcon buttons {"OK"} default button "OK"
on error
  display dialog "$BASE_MSG" with title "About ${APP_NAME}" buttons {"OK"} default button "OK"
end try
APPSCRIPT
        else
            /usr/bin/osascript -e "display dialog \"$BASE_MSG\" with title \"About ${APP_NAME}\" buttons {\"OK\"} default button \"OK\""
        fi

        exit 0
        ;;
 
    *)
        # Assume arguments are files, forward to normalize_filename.sh
        # send all output to /dev/null
        exec "$(dirname "$0")/normalize_filename.sh" "$@" > /dev/null 2>&1
        ;;
esac
