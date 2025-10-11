# NameMyPdf - Installation & Usage Guide

## Download and Install

### Step 1: Download

1. Go to the [latest release page](https://github.com/literatecomputing/name-my-pdf/releases/latest)
2. Choose your preferred download format:
   - **DMG file** (recommended): Professional installer with drag-to-Applications interface
   - **ZIP file**: Manual installation archive

### Step 2: Install

#### Option A: DMG Installation (Recommended)

1. **Download and open**: Double-click the downloaded `.dmg` file
2. **Install**: Drag the `NameMyPdf.app` icon to the Applications folder icon
3. **Eject**: Eject the disk image when installation is complete
4. **First launch security**: When you first try to open the app, macOS may show a security warning:
   - Go to **System Preferences > Security & Privacy > General**
   - Click "**Open Anyway**" next to the NameMyPdf message
   - Or right-click the app and select "**Open**" from the context menu

#### Option B: ZIP Installation

1. **Unzip the file**: Double-click the downloaded `.zip` file to extract it
2. **Move to Applications**: Drag `NameMyPdf.app` to your `/Applications` folder (optional but recommended)
3. **First launch security**: Follow the same security steps as above

## System Requirements

- **macOS**: 10.11.0 (El Capitan) or later
- **Architecture**: Universal app supporting both Intel and Apple Silicon Macs
- **Dependencies**: The app requires the following tools to be installed:
  - `poppler` (for PDF text extraction)
  - `jq` (for JSON processing)
  - `curl` (usually pre-installed)

### Install Dependencies

Open Terminal and run:

```bash
# Install Homebrew if you don't have it
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install required tools
brew install poppler jq
```

## How to Use

### Method 1: Drag and Drop

1. Locate your PDF files in Finder
2. Select the PDF files you want to rename
3. Drag and drop them onto the `NameMyPdf.app` icon
4. The app will process each file and rename it based on the DOI metadata

### Method 2: Using the App Interface

1. Double-click `NameMyPdf.app` to launch it
2. Use the file selection interface to choose PDF files
3. The app will process and rename the files automatically

## What It Does

NameMyPdf automatically renames academic PDF files using:

- **Author**: First author's last name
- **Year**: Publication year
- **Title**: First part of the article title (up to 5 words or text before colon)

**Example**: A PDF with DOI `10.1000/182` might be renamed to:
`Smith 2023 - Machine Learning Applications.pdf`

## How It Works

1. **Extracts DOI**: Scans the first 2 pages of the PDF for DOI information
2. **Fetches Metadata**: Queries the CrossRef API to get publication details
3. **Generates Filename**: Creates a clean, standardized filename
4. **Renames File**: Updates the file with the new name

## Troubleshooting

### "App can't be opened because it is from an unidentified developer"

This is normal for unsigned apps. Follow the security steps in the installation section above.

### "Missing required tools" error

Install the dependencies using Homebrew as described in the System Requirements section.

### No DOI found

Some PDFs may not contain DOI information. In this case, the file will not be renamed.

### Network errors

The app requires internet access to query the CrossRef API for metadata.

## Privacy & Data

- The app only sends DOI information to the CrossRef API
- No personal information or PDF content is transmitted
- All processing happens locally on your Mac

## Support

For issues or questions, please visit the project repository or contact the developer.

## License

© 2025 Jay Pfaffman. See the project repository for license details.
