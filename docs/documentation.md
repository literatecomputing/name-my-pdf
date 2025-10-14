---
layout: default
title: Documentation
nav_order: 3
description: "How to use NameMyPdf"
has_children: true
---

# Documentation

{: .no_toc }

Complete guide to using NameMyPdf.
{: .fs-6 .fw-300 }

---

## Table of Contents

{: .no_toc .text-delta }

1. TOC
   {:toc}

---

## Basic Usage

### Open With

The simplest way to use NameMyPdf:

1. Open the Finder
2. Locate and select PDF files you want to rename
3. **Right Click** and choose **Open With** and select **NameMyPdf**
4. Watch as they're automatically renamed!

A progress window will show you what's happening. The app will quit automatically when done.

---

## How It Works

NameMyPdf follows this process for each PDF:

1. **Scans** the first 2 pages of the PDF for a DOI (very old PDFs may not have this)
2. **Queries** [CrossRef API](https://www.crossref.org/documentation/retrieve-metadata/rest-api/) for metadata (author, year, title) (See [example](https://api.crossref.org/works/10.1016/j.chb.2010.04.008))
3. **Generates** a clean filename: `Author Year - Title.pdf`
4. **Renames** the file in place
5. **Logs** old and new names to `$HOME/Library/Logs/NameMyPdf.log`

---

## Filename Format

By default, files are renamed as:

```
Author Year - Title.pdf
```

**Examples:**

| Original         | Renamed                                            |
| :--------------- | :------------------------------------------------- |
| `paper.pdf`      | `Smith 2023 - Machine Learning Applications.pdf`   |
| `download.pdf`   | `Johnson 2024 - Neural Networks Deep Learning.pdf` |
| `arxiv-1234.pdf` | `Chen 2023 - Computer Vision Transformers.pdf`     |

---

## Configuration

NameMyPdf creates a configuration file at `~/.namemypdfrc` on first run (To edit later use Command+Shift+. to display hidden files in either the Finder or TextEdit)

### Configuration Options

Including your email address makes it possible for Crossref to track the number of users or contact you if you're causing a problem (like by renaming thousands of files? See [this link](https://www.crossref.org/documentation/retrieve-metadata/rest-api/tips-for-using-the-crossref-rest-api/#00831) for their explanation).

```bash
# Email for CrossRef API (recommended for heavy usage)
CROSSREF_EMAIL=you@email.com

# Convert title to lowercase
DOWNCASE_TITLE=false

# Number of words from title to include
TITLE_WORDS=7

# Separator between title words
TITLE_WORD_SEPARATOR=" "

# Separator between author and year
AUTHOR_YEAR_SEPARATOR=" "

# Separator between year and title
YEAR_TITLE_SEPARATOR=" - "

# Use abbreviated title (first letter of each word)
USE_ABBR_TITLE=false

# Remove everything after colon in title
STRIP_TITLE_POST_COLON=true

# Enable logs for debugging (probably not necesssary) and logging
DEBUG=false
LOG=true
```

### Example Configurations

**Shorter filenames:**

```bash
TITLE_WORDS=4
STRIP_TITLE_POST_COLON=true
```

Result: `Smith 2023 - Machine Learning Applications.pdf`

**Abbreviated titles:**

```bash
USE_ABBR_TITLE=true
TITLE_WORD_SEPARATOR=""
AUTHOR_YEAR_SEPARATOR=""
```

Result: `Smith2023MLA.pdf`

**All lowercase:**

```bash
DOWNCASE_TITLE=true
```

Result: `smith 2023 - machine learning applications.pdf`

---

## Command-Line Usage

For terminal users, you can install the command-line tool.

### Installation

```bash
/Applications/NameMyPdf.app/Contents/Resources/install-cli.sh
```

This creates a `namemypdf` command in `/usr/local/bin`.

### Usage

```bash
# Single file
namemypdf paper.pdf

# Multiple files
namemypdf paper1.pdf paper2.pdf paper3.pdf

# All PDFs in current directory
namemypdf *.pdf

# All PDFs in a subdirectory
namemypdf ~/Downloads/*.pdf
```

### Uninstall CLI

```bash
sudo rm /usr/local/bin/namemypdf
```

---

## Logs and Debugging

NameMyPdf logs all activity to `~/Library/Logs/NameMyPdf.log` (or "$HOME/.namemypdf.log" on non-Macs)

### Enable Debug Mode

Edit `~/.namemypdfrc` and set:

```bash
DEBUG=true
```

This will show detailed information about:

- Tool paths (pdftotext, jq, curl)
- DOI extraction
- API responses
- Filename generation

---

## Troubleshooting

### No DOI Found

**Problem:** "No DOI found in [filename], skipping"

**Solutions:**

- Make sure the PDF actually contains DOI information
- DOI should be on the first 2 pages
- If it looks like the script should have found the DOI, open an [issue](https://github.com/literatecomputing/name-my-pdf/issues) and describe why you think the script might not have found the DOI.

### Resource Not Found

**Problem:** "[DOI] --- not found"

**Explanations:**

- The DOI exists in the PDF but isn't in CrossRef database
- Try manually looking up the DOI at https://doi.org/
- The DOI might be malformed or incorrect
- Publishers are surprisingly bad at having correct data in the database. I've seen missing authors (on my own article!) and trash thrown into various fields.

There probably are no solutions.

### File Not Renamed

**Problem:** File already exists with the target name

**Solution:** NameMyPdf won't overwrite existing files. Rename or move the existing file first.

---

## FAQ

### Does this work with non-academic PDFs?

No, NameMyPdf specifically looks for DOI information, which is typically only in academic papers. PDFs without a DOI on the first two pages won't be renamed.

### Can I undo a rename?

Not automatically, but the log file shows what was renamed. You can manually rename files back if needed.

### Does it modify the PDF content?

No! NameMyPdf only renames the file. The PDF content is never modified.

### What if I have thousands of files?

NameMyPdf can handle batch processing. However, be courteous to the CrossRef API - consider adding your email to the config file if processing many files.

### Does it work offline?

No, NameMyPdf needs internet access to query the CrossRef API for metadata.

### Is my data sent anywhere?

Only the DOI is sent to the CrossRef API when you make the request for the data. No file contents or personal data is transmitted.

---

## Need More Help?

- 🐛 [Report a Bug](https://github.com/literatecomputing/name-my-pdf/issues)
- 📧 Contact: My address is in my [Github Profile](https://github.com/pfaffman)
