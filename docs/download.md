---
layout: default
title: Download
nav_order: 2
description: "Download NameMyPdf for macOS"
---

# Download NameMyPdf
{: .no_toc }

Get the latest version of NameMyPdf for macOS.
{: .fs-6 .fw-300 }

---

## Latest Release

<div class="code-example" markdown="1">
**Current Version:** Check [releases page](https://github.com/literatecomputing/name-my-pdf/releases/latest) for the latest version

**Last Updated:** See [releases](https://github.com/literatecomputing/name-my-pdf/releases/latest)
</div>

[Download DMG (Recommended)](https://github.com/literatecomputing/name-my-pdf/releases/latest/download/NameMyPdf-latest.dmg){: .btn .btn-primary .btn-purple }
[Download ZIP](https://github.com/literatecomputing/name-my-pdf/releases/latest/download/NameMyPdf-latest.zip){: .btn }
[View All Releases](https://github.com/literatecomputing/name-my-pdf/releases){: .btn }

---

## Installation Instructions

### DMG Installation (Recommended)

1. **Download** the `.dmg` file from above
2. **Open** the downloaded file to mount the disk image
3. **Drag** `NameMyPdf.app` to the Applications folder icon
4. **Eject** the disk image
5. **Launch** the app:
   - Find NameMyPdf in your Applications folder
   - **Right-click** and select **"Open"** (first time only)
   - Click **"Open"** in the security dialog

{: .note }
> The right-click → Open step is required the first time because the app is not code-signed. After the first launch, you can open it normally.

### ZIP Installation

1. **Download** the `.zip` file from above
2. **Extract** the ZIP file (usually automatic)
3. **Move** `NameMyPdf.app` to your Applications folder
4. **Launch** using the same right-click method above

---

## What's Included

✅ **Universal Binary** - Runs natively on both Intel and Apple Silicon Macs  
✅ **Bundled Tools** - Includes jq and pdftotext (no Homebrew needed)  
✅ **GUI App** - Drag-and-drop interface  
✅ **CLI Installer** - Optional command-line tool (see [Documentation]({{ site.baseurl }}{% link documentation.md %}))  

---

## System Requirements

| Requirement | Details |
|:------------|:--------|
| **OS** | macOS 10.11 (El Capitan) or later |
| **Architecture** | Intel or Apple Silicon |
| **Internet** | Required for DOI metadata lookup |
| **Dependencies** | None - everything is bundled! |

---

## Verify Your Download

{: .highlight }
For security-conscious users, you can verify the integrity of your download by checking the SHA256 checksums provided in the release notes.

---

## Troubleshooting

### "App is damaged and can't be opened"

This is a Gatekeeper issue. Run this command in Terminal:

```bash
xattr -cr /Applications/NameMyPdf.app
```

Then try opening the app again with right-click → Open.

### App won't open / crashes immediately

Check the log file for errors:

```bash
cat ~/Library/Logs/NameMyPdf.log
```

If you see errors, please [open an issue](https://github.com/literatecomputing/name-my-pdf/issues) on GitHub.

---

## Need Help?

- 📖 Read the [Documentation]({{ site.baseurl }}{% link documentation.md %})
- 🐛 Report issues on [GitHub](https://github.com/literatecomputing/name-my-pdf/issues)
- 💬 Ask questions in [Discussions](https://github.com/literatecomputing/name-my-pdf/discussions)
