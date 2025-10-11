#!/bin/bash

# Release script for NameMyPdf
# Usage: ./create-release.sh 1.1.0

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <version>"
    echo "Example: $0 1.1.0"
    exit 1
fi

VERSION="$1"
TAG="v$VERSION"

echo "Creating release for version $VERSION..."

# Check if we're on main branch
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ]; then
    echo "Warning: You're not on the main branch (currently on: $CURRENT_BRANCH)"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Check if tag already exists
if git tag --list | grep -q "^$TAG$"; then
    echo "Error: Tag $TAG already exists"
    exit 1
fi

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo "Error: You have uncommitted changes"
    git status --short
    exit 1
fi

# Update version in files if needed
echo "Updating version references..."

# Create and push the tag
echo "Creating tag $TAG..."
git tag -a "$TAG" -m "Release version $VERSION"

echo "Pushing tag to trigger GitHub Actions build..."
git push origin "$TAG"

echo ""
echo "✅ Release $TAG has been created!"
echo ""
echo "🔄 GitHub Actions will now:"
echo "   - Build the app using Platypus"
echo "   - Create ZIP and DMG packages"
echo "   - Generate a GitHub release"
echo ""
echo "📱 Monitor the build progress at:"
echo "   https://github.com/literatecomputing/name-my-pdf/actions"
echo ""
echo "📦 Once complete, the release will be available at:"
echo "   https://github.com/literatecomputing/name-my-pdf/releases/tag/$TAG"
