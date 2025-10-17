---
layout: home
title: Home
nav_order: 1
description: "NameMyPdf - Automatically rename academic PDFs using DOI metadata"
permalink: /
---

# NameMyPdf

{: .fs-9 }

[Automatically rename PDF files with year, author, title retrieved from DOI database](#)
{: .fs-6 .fw-300 }

[Download](/download.html){: .btn .btn-primary .fs-5 .mb-4 .mb-md-0 .mr-2 } <!-- VERSION-UPDATE-MARKER -->
[Support NameMyPdf](/donate.html){: .btn .btn-green .fs-5 .mb-4 .mb-md-0 .mr-2 }
[View on GitHub](https://github.com/literatecomputing/name-my-pdf){: .btn .fs-5 .mb-4 .mb-md-0 }

---

## Demo

<div class="home-video-wrapper" style="margin: 1.5rem 0; display:flex; justify-content:center;">
	<video autoplay muted loop playsinline preload="metadata" style="width:100%; min-width:640px; max-width:1048px; border-radius:8px; box-shadow:0 6px 18px rgba(0,0,0,0.1); outline:none;">
		<source src="/images/NameMyPdf-big.mp4" type="video/mp4">
		Your browser does not support the video tag.
	</video>
</div>

There is also a [longer demo](/demo/).

## ✨ Features

**Universal Binary**
{: .label .label-blue }
Native support for both Intel and Apple Silicon Macs

**Drag & Drop or Open-With **
{: .label .label-purple }
Simple interface - just drag PDF files onto the app icon or select and choose "open-with"

**Command Line**
{: .label .label-yellow }
Optional CLI tool for terminal users

---

## 🚀 Quick Start

1. **Download** the latest `.dmg` file from [Download Page](/download.html) <!-- VERSION-UPDATE-MARKER -->
2. **Install** by dragging NameMyPdf.app to your Applications folder
3. **Allow Access** App is not signed by Apple so you have to start it and "Open Anyway" from System "Security" (scroll to bottom) See [Download Page](/download.html) for details
4. **Edit the Configuration** The first time, you'll be presented with the configuration file in TextEdit. You can adjust the filename to your liking.
5. **Use** select files in the Finder and choose "open with ... NameMyPdf"

---

## 📖 How It Works

NameMyPdf scans your PDF files for DOI (Digital Object Identifier) information, queries the CrossRef API for metadata, and renames your files in a clean, standardized format.

**Before:**

```
downloaded-paper.pdf
arxiv-1234.5678v2.pdf
```

**After:**

```
Smith 2023 - Machine Learning Applications.pdf
Johnson 2024 - Neural Network Architecture.pdf
```

---

## 🎯 Perfect For

- 📚 Academic researchers managing paper collections
- 🎓 Graduate students organizing literature reviews
- 👨‍🏫 Professors maintaining reference libraries
- 📝 Anyone who reads lots of academic PDFs

---

## 💻 System Requirements

- macOS 10.11 (El Capitan) or later
- No additional software required - all tools are bundled!

---

## 🆓 Open Source

NameMyPdf is open source software. Contributions welcome!

[View Source Code →](https://github.com/literatecomputing/name-my-pdf)
