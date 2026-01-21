#!/bin/bash

# Build script for packaging WordPress plugin
# This script creates a ZIP file ready for distribution
# Usage: ./build.sh [--patch|--minor|--major]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get plugin name and version from main plugin file
PLUGIN_FILE="quotes-collection.php"

if [ ! -f "$PLUGIN_FILE" ]; then
    echo -e "${RED}Error: $PLUGIN_FILE not found in current directory${NC}"
    exit 1
fi

PLUGIN_NAME=$(grep "Plugin Name:" "$PLUGIN_FILE" | sed 's/^.*: *//' | sed 's/[^a-zA-Z0-9_-]/_/g' | xargs | sed 's/_$//')
VERSION=$(grep "Version:" "$PLUGIN_FILE" | sed 's/^.*: *//' | xargs)

if [ -z "$PLUGIN_NAME" ]; then
    echo -e "${RED}Error: Could not determine plugin name${NC}"
    exit 1
fi

if [ -z "$VERSION" ]; then
    echo -e "${RED}Error: Could not determine plugin version${NC}"
    exit 1
fi

# Parse command line arguments for version bump
BUMP_TYPE="patch"
while [[ $# -gt 0 ]]; do
    case $1 in
        --patch)
            BUMP_TYPE="patch"
            shift
            ;;
        --minor)
            BUMP_TYPE="minor"
            shift
            ;;
        --major)
            BUMP_TYPE="major"
            shift
            ;;
        --no-bump)
            BUMP_TYPE=""
            shift
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            echo "Usage: $0 [--patch|--minor|--major|--no-bump]"
            echo "  --patch    Bump patch version (default): X.Y.Z -> X.Y.Z+1"
            echo "  --minor    Bump minor version: X.Y.Z -> X.Y+1.0"
            echo "  --major    Bump major version: X.Y.Z -> X+1.0.0"
            echo "  --no-bump  Don't bump version"
            exit 1
            ;;
    esac
done

# Function to bump version
bump_version() {
    local version=$1
    local bump_type=$2
    
    # Remove any pre-release identifiers (like "alpha 1", "beta", etc.)
    local clean_version=$(echo "$version" | grep -oE '^[0-9]+\.[0-9]+\.[0-9]+')
    
    if [ -z "$clean_version" ]; then
        echo -e "${RED}Error: Could not parse version: $version${NC}"
        exit 1
    fi
    
    # Split version into major, minor, patch
    IFS='.' read -r major minor patch <<< "$clean_version"
    
    # Convert to integers for arithmetic
    major=$((10#$major))
    minor=$((10#$minor))
    patch=$((10#$patch))
    
    case $bump_type in
        patch)
            patch=$((patch + 1))
            ;;
        minor)
            minor=$((minor + 1))
            patch=0
            ;;
        major)
            major=$((major + 1))
            minor=0
            patch=0
            ;;
    esac
    
    echo "${major}.${minor}.${patch}"
}

# Bump version if needed
if [ -n "$BUMP_TYPE" ]; then
    NEW_VERSION=$(bump_version "$VERSION" "$BUMP_TYPE")
    echo -e "${YELLOW}Bumping $BUMP_TYPE version: $VERSION -> $NEW_VERSION${NC}"
    
    # Update version in plugin file
    sed -i '' "s/^ \* Version: .*/ * Version: $NEW_VERSION/" "$PLUGIN_FILE"
    
    # Update version in package.json if it exists
    if [ -f "package.json" ]; then
        sed -i '' "s/\"version\": \"[^\"]*\"/\"version\": \"$NEW_VERSION\"/" package.json
    fi
    
    VERSION=$NEW_VERSION
    echo -e "${GREEN}Version updated to $VERSION${NC}"
fi

echo -e "${GREEN}Building $PLUGIN_NAME v$VERSION...${NC}"

# Create build directory
BUILD_DIR="build"
DIST_DIR="dist"
# Plugin folder name (without version) - WordPress requires this for updates
PLUGIN_FOLDER="quotes-collection"

echo -e "${YELLOW}Cleaning up old builds...${NC}"
rm -rf "$BUILD_DIR" "$DIST_DIR"

mkdir -p "$BUILD_DIR/$PLUGIN_FOLDER"
mkdir -p "$DIST_DIR"

# Copy plugin files to build directory
echo -e "${YELLOW}Copying files...${NC}"

# Files and directories to include (no trailing slashes - preserves directory structure)
INCLUDE_PATTERNS=(
    "blocks"
    "css"
    "examples"
    "inc"
    "js"
    "languages"
    "*.php"
    "*.txt"
    "*.md"
    "LICENSE"
    "screenshot-*.png"
)

# Copy each item
for pattern in "${INCLUDE_PATTERNS[@]}"; do
    # Use shell expansion for patterns
    for item in $pattern; do
        if [ -e "$item" ]; then
            cp -r "$item" "$BUILD_DIR/$PLUGIN_FOLDER/" 2>/dev/null || true
        fi
    done
done

# Copy main plugin file if not already copied
if [ -f "$PLUGIN_FILE" ]; then
    cp "$PLUGIN_FILE" "$BUILD_DIR/$PLUGIN_FOLDER/"
fi

# Remove uninstall.php from build as it's for development
rm -f "$BUILD_DIR/$PLUGIN_FOLDER/uninstall.php"

# Remove language README (not needed in distribution)
rm -f "$BUILD_DIR/$PLUGIN_FOLDER/languages/README.md"

# Create ZIP file with lowercase name and version number (version in filename for releases)
ZIP_NAME=$(echo "${PLUGIN_NAME}-${VERSION}" | tr '[:upper:]' '[:lower:]' | tr '_' '-').zip
ZIP_PATH="$DIST_DIR/$ZIP_NAME"

echo -e "${YELLOW}Creating ZIP archive...${NC}"
cd "$BUILD_DIR"
zip -r "../$ZIP_PATH" "$PLUGIN_FOLDER"
cd ..

# Get file size
FILE_SIZE=$(du -h "$ZIP_PATH" | cut -f1)

echo -e "${GREEN}Build complete!${NC}"
echo -e "ZIP file: ${GREEN}$ZIP_PATH${NC}"
echo -e "Size: ${GREEN}$FILE_SIZE${NC}"

# Cleanup build directory
echo -e "${YELLOW}Cleaning up build directory...${NC}"
rm -rf "$BUILD_DIR"

echo -e "${GREEN}Done!${NC}"
