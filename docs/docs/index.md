---
layout: default
title: Documentation
---

# NameMyPDF Documentation

Welcome to the NameMyPDF documentation. This tool automatically renames academic PDF files using metadata from DOI databases.

## Installation

### macOS

1. Download the latest release from [GitHub Releases](https://github.com/literatecomputing/name-my-pdf/releases/latest)
2. Open the DMG file
3. Drag NameMyPDF to your Applications folder
4. Launch NameMyPDF from Applications

### System Requirements

- macOS 10.15 (Catalina) or later
- Internet connection for DOI lookups

## Usage

### Basic Usage

1. **Launch the app** - Open NameMyPDF from your Applications folder
2. **Drag and drop** - Select one or more PDF files and drag them onto the app icon
3. **Wait for processing** - The app will extract DOI information and rename your files
4. **Done!** - Your files are now renamed in the format: `Author Year - Title.pdf`

### Batch Processing

NameMyPDF can process multiple files at once:

- Select multiple PDFs in Finder
- Drag them all onto the NameMyPDF icon
- The app will process each file sequentially

## How It Works

1. **DOI Extraction**: The app scans your PDF for Digital Object Identifiers (DOI)
2. **Metadata Lookup**: It queries the DOI database for complete citation information
3. **File Renaming**: Your file is renamed using the standardized format

## Supported Formats

NameMyPDF works with any PDF that contains a DOI. This includes:

- Academic journal articles
- Conference papers
- Technical reports
- Preprints with DOIs

## Troubleshooting

### File wasn't renamed

- **Check for DOI**: Ensure your PDF contains a DOI
- **Internet connection**: The app requires internet to look up DOI information
- **File permissions**: Make sure you have write permissions for the file

### App won't open

- **Security settings**: Go to System Preferences → Security & Privacy and allow the app
- **Quarantine attribute**: Run `xattr -cr /Applications/NameMyPDF.app` in Terminal

## Privacy

NameMyPDF respects your privacy:

- Only DOI information is sent to CrossRef API for metadata lookup
- No PDF content is uploaded
- No tracking or analytics
- Completely open source

## Support

- **Issues**: [GitHub Issues](https://github.com/literatecomputing/name-my-pdf/issues)
- **Source Code**: [GitHub Repository](https://github.com/literatecomputing/name-my-pdf)

## License

NameMyPDF is open source software licensed under the MIT License.
