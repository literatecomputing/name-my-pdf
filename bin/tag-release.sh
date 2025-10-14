#!/bin/bash
# tag-release.sh: Tag and push a new release, and update DMG/ZIP links in docs and README.
# Usage:
#   ./tag-release.sh [tagname]
# If [tagname] is omitted, prints the most recent tag.

set -e

if [ "$1" = "" ]; then
    # Show the most recent tag
    git describe --tags --abbrev=0
    exit 0
fi

TAG="$1"
DMG="NameMyPdf-$TAG.dmg"
ZIP="NameMyPdf-$TAG.zip"
RELEASE_URL="https://github.com/literatecomputing/name-my-pdf/releases/download/$TAG"

# Update DMG/ZIP links in README.md
sed -i "/VERSION-UPDATE-START/,/VERSION-UPDATE-END/c\\
<!-- VERSION-UPDATE-START -->\n- **Download DMG**: [$DMG]($RELEASE_URL/$DMG)\n- **Download ZIP**: [$ZIP]($RELEASE_URL/$ZIP)\n<!-- VERSION-UPDATE-END -->" README.md

# Update DMG/ZIP links in docs/download.md
sed -i "/VERSION-UPDATE-START/,/VERSION-UPDATE-END/c\\
[Download DMG (Recommended)]($RELEASE_URL/$DMG){: .btn .btn-primary .btn-purple } <!-- VERSION-UPDATE-START -->\n[Download ZIP]($RELEASE_URL/$ZIP){: .btn } <!-- VERSION-UPDATE-END -->" docs/download.md

# Update quick start and button in docs/index.md
sed -i "s|\[Download Latest Release\](/download.html).*VERSION-UPDATE-MARKER.*|[Download Latest Release](/download.html){: .btn .btn-primary .fs-5 .mb-4 .mb-md-0 .mr-2 } <!-- VERSION-UPDATE-MARKER -->|" docs/index.md
sed -i "s|Download\*\* the latest .dmg file from \[Download Page\](/download.html).*VERSION-UPDATE-MARKER.*|Download** the latest .dmg file from [Download Page](/download.html) <!-- VERSION-UPDATE-MARKER -->|" docs/index.md

# Commit, tag, and push

git add README.md docs/download.md docs/index.md

git commit -m "Release $TAG and update DMG/ZIP links"
git tag "$TAG"
git push origin main --tags
