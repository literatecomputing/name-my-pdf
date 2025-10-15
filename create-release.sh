#!/bin/bash
# create-release.sh - Build NameMyPdf app locally
set -e

echo "Building NameMyPdf app..."

# Check if Platypus is installed
if [ ! -d "/Applications/Platypus.app" ]; then
    echo "Error: Platypus is not installed. Please install it from https://sveinbjorn.org/platypus"
    exit 1
fi

# Set up Platypus command-line tool
echo "Setting up Platypus CLI..."
sudo mkdir -p /usr/local/bin
sudo mkdir -p /usr/local/share/platypus

# Copy Platypus CLI
if [ -f "/Applications/Platypus.app/Contents/Resources/platypus_clt" ]; then
    sudo cp "/Applications/Platypus.app/Contents/Resources/platypus_clt" /usr/local/bin/platypus
elif [ -f "/Applications/Platypus.app/Contents/Resources/platypus_clt.gz" ]; then
    sudo gunzip -c "/Applications/Platypus.app/Contents/Resources/platypus_clt.gz" > /tmp/platypus
    sudo mv /tmp/platypus /usr/local/bin/platypus
else
    echo "Error: Could not find Platypus CLI tool"
    exit 1
fi

# Copy ScriptExec
if [ -f "/Applications/Platypus.app/Contents/Resources/ScriptExec" ]; then
    sudo cp "/Applications/Platypus.app/Contents/Resources/ScriptExec" /usr/local/share/platypus/
elif [ -f "/Applications/Platypus.app/Contents/Resources/ScriptExec.gz" ]; then
    sudo gunzip -c "/Applications/Platypus.app/Contents/Resources/ScriptExec.gz" > /tmp/ScriptExec
    sudo mv /tmp/ScriptExec /usr/local/share/platypus/ScriptExec
fi

# Copy nib files
if [ -d "/Applications/Platypus.app/Contents/Resources/MainMenu.nib" ]; then
    sudo cp -R "/Applications/Platypus.app/Contents/Resources/MainMenu.nib" /usr/local/share/platypus/
fi

# Make executables
sudo chmod +x /usr/local/bin/platypus
if [ -f "/usr/local/share/platypus/ScriptExec" ]; then
    sudo chmod +x /usr/local/share/platypus/ScriptExec
fi

echo "Platypus CLI ready: $(platypus -v)"

# Create bundled-bin directory if it doesn't exist
mkdir -p bundled-bin

# Download and prepare bundled binaries if they don't exist
if [ ! -f "bundled-bin/jq" ] || [ ! -f "bundled-bin/pdftotext" ]; then
    echo "Downloading bundled binaries..."
    cd bundled-bin

    # Download jq binaries for both architectures
    echo "Downloading jq binaries..."
    curl -L -o jq-macos-amd64 https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-macos-amd64
    curl -L -o jq-macos-arm64 https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-macos-arm64

    # Make them executable
    chmod +x jq-macos-amd64 jq-macos-arm64

    # Create universal binary for jq
    echo "Creating universal jq binary..."
    lipo -create jq-macos-amd64 jq-macos-arm64 -output jq
    chmod +x jq

    # Verify jq
    file jq
    ./jq --version

    # Download Xpdf tools (contains pdftotext for both architectures)
    echo "Downloading Xpdf tools..."
    curl -L -o xpdf-tools-mac-4.05.tar.gz https://dl.xpdfreader.com/xpdf-tools-mac-4.05.tar.gz
    tar -xzf xpdf-tools-mac-4.05.tar.gz

    # Extract pdftotext binaries for both architectures
    echo "Extracting pdftotext binaries..."
    cp xpdf-tools-mac-4.05/bin64/pdftotext pdftotext-x86_64
    cp xpdf-tools-mac-4.05/binARM/pdftotext pdftotext-arm64

    # Make them executable
    chmod +x pdftotext-x86_64 pdftotext-arm64

    # Create universal binary for pdftotext
    echo "Creating universal pdftotext binary..."
    lipo -create pdftotext-x86_64 pdftotext-arm64 -output pdftotext
    chmod +x pdftotext

    # Verify pdftotext
    file pdftotext
    ./pdftotext -v || true  # pdftotext returns non-zero exit code when showing version

    # Clean up source files
    rm -f jq-macos-amd64 jq-macos-arm64 pdftotext-x86_64 pdftotext-arm64
    rm -rf xpdf-tools-mac-4.05 xpdf-tools-mac-4.05.tar.gz

    cd ..
fi

# Remove any pre-existing app bundle
if [ -d "NameMyPdf.app" ]; then
    echo "Removing pre-existing NameMyPdf.app"
    rm -rf NameMyPdf.app
fi

# Create dist directory
mkdir -p dist

echo "Building app with Platypus..."

# Build the app using Platypus
platypus \
    --name "NameMyPdf" \
    --app-icon "icons/icon.icns" \
    --status-item-icon "icons/icon.icns" \
    --bundle-identifier "com.literatecomputing.namemypdf" \
    --author "Jay Pfaffman" \
    --app-version "1.0.0" \
    --interface-type "Status Menu" \
    --status-item-icon "icons/icon_128x128.png" \
    --status-item-title "NameMyPdf" \
    --interpreter "/bin/bash" \
    --droppable \
    --text-droppable \
    --suffixes "pdf" \
    --uniform-type-identifiers "com.adobe.pdf" \
    --bundled-file "bundled-bin/jq" \
    --bundled-file "bundled-bin/pdftotext" \
    --bundled-file "install-cli.sh" \
    --bundled-file "normalize_filename.sh" \
    --overwrite \
    "app_launcher.sh" \
    "dist/NameMyPdf.app"

echo "App built successfully: dist/NameMyPdf.app"

# Verify the app
echo "Verifying app bundle..."
ls -la dist/NameMyPdf.app/Contents/
file dist/NameMyPdf.app/Contents/MacOS/NameMyPdf

echo "Build complete! The app is ready at: dist/NameMyPdf.app"
echo "You can now double-click the app to test the Status Menu functionality."