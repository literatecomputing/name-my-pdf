#!/usr/bin/env bash
# Install command-line wrapper for NameMyPdf

set -e

# Check if the app exists
APP_PATH="/Applications/NameMyPdf.app"
if [[ ! -d "$APP_PATH" ]]; then
    echo "Error: NameMyPdf.app not found in /Applications"
    echo "Please install the app first before running this installer."
    exit 1
fi

# Create symlink in /usr/local/bin
BIN_DIR="/usr/local/bin"
WRAPPER_NAME="namemypdf"
WRAPPER_PATH="$BIN_DIR/$WRAPPER_NAME"

echo "Installing namemypdf command-line tool..."

# Create the wrapper script
sudo tee "$WRAPPER_PATH" > /dev/null <<'EOF'
#!/usr/bin/env bash
# NameMyPdf command-line wrapper
# Calls the bundled script directly instead of launching the app

SCRIPT_PATH="/Applications/NameMyPdf.app/Contents/Resources/script"

if [[ ! -f "$SCRIPT_PATH" ]]; then
    echo "Error: NameMyPdf.app not found or improperly installed" >&2
    exit 1
fi

# Pass all arguments to the script
exec "$SCRIPT_PATH" "$@"
EOF

# Make it executable
sudo chmod +x "$WRAPPER_PATH"

echo "✓ Successfully installed!"
echo ""
echo "You can now use 'namemypdf' from the command line:"
echo "  namemypdf file1.pdf file2.pdf ..."
echo ""
echo "To uninstall, run:"
echo "  sudo rm $WRAPPER_PATH"
