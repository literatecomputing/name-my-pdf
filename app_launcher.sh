#!/bin/bash
# app_launcher.sh: Wrapper for NameMyPdf app
# Handles menu actions, passes dropped files to normalize_filename.sh


# If no arguments, output Status Menu items for Platypus
if [ $# -eq 0 ]; then
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
 
    *)
        # Assume arguments are files, forward to normalize_filename.sh
        exec "$(dirname "$0")/normalize_filename.sh" "$@"
        ;;
esac
