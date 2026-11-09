#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# Simployer Comply — Autonomous Release & Sparkle Distribution Engine
# ==============================================================================

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_DIR"

SIGNING_IDENTITY="Developer ID Application: RASMUS PER SEBASTIAN SJÖBORG (D89525F228)"
REPO_SLUG="rasmussjoborg-dotcom/simployer-comply"

VERSION="${1:-}"
if [ -z "$VERSION" ]; then
    # Auto-detect latest git tag or default to 1.0.0
    LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "v1.0.0")
    CLEAN_VER="${LATEST_TAG#v}"
    # Bump patch version: e.g. 1.0.0 -> 1.0.1
    MAJOR=$(echo "$CLEAN_VER" | cut -d. -f1)
    MINOR=$(echo "$CLEAN_VER" | cut -d. -f2)
    PATCH=$(echo "$CLEAN_VER" | cut -d. -f3)
    VERSION="${MAJOR}.${MINOR}.$((PATCH + 1))"
    echo "📦 No version passed. Auto-incrementing patch to: v$VERSION"
else
    # Strip leading 'v' if present
    VERSION="${VERSION#v}"
fi

RELEASE_NOTES="${2:-"Prototype update: Autonomous Compliance & Norwegian Labor Law Cockpit."}"

echo "========================================================================"
echo "🚀 Building & Publishing Simployer Comply v$VERSION"
echo "   Target Repo: https://github.com/$REPO_SLUG"
echo "   Signer:      $SIGNING_IDENTITY"
echo "========================================================================"

# 1. Update project.yml and regenerate Xcode project
echo "⚙️  Updating project.yml version to $VERSION..."
sed -i '' "s/MARKETING_VERSION: \".*\"/MARKETING_VERSION: \"$VERSION\"/" project.yml
BUILD_NUM=$(date +%Y%m%d%H%M)
sed -i '' "s/CURRENT_PROJECT_VERSION: \".*\"/CURRENT_PROJECT_VERSION: \"$BUILD_NUM\"/" project.yml
xcodegen generate

# 2. Build Release configuration
echo "🔨 Compiling Release build via xcodebuild..."
rm -rf build/DerivedData
/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild \
    -scheme SimployerComplyMac \
    -configuration Release \
    -destination "platform=macOS,arch=arm64" \
    -derivedDataPath build/DerivedData \
    build

BUILT_APP="build/DerivedData/Build/Products/Release/Simployer Comply.app"
if [ ! -d "$BUILT_APP" ]; then
    echo "❌ Error: Built app bundle not found at $BUILT_APP"
    exit 1
fi

# 3. Deep Code Signing with Hardened Runtime & Developer ID
echo "🔐 Deep codesigning with Developer ID ($SIGNING_IDENTITY)..."

# Sign all nested frameworks and XPC services
if [ -d "$BUILT_APP/Contents/Frameworks" ]; then
    find "$BUILT_APP/Contents/Frameworks" -type d \( -name "*.framework" -o -name "*.xpc" \) | while read -r item; do
        codesign --force --timestamp --options runtime --sign "$SIGNING_IDENTITY" "$item"
    done
fi

# Sign the main application bundle
codesign --force --timestamp --options runtime --deep --sign "$SIGNING_IDENTITY" "$BUILT_APP"

# Verify signature
codesign --verify --deep --strict --verbose=2 "$BUILT_APP"
echo "✅ Code signature verified successfully."

# 4. Prepare releases directory
mkdir -p releases
ZIP_NAME="Simployer-Comply-$VERSION.zip"
DMG_NAME="Simployer-Comply-$VERSION.dmg"
ZIP_PATH="releases/$ZIP_NAME"
DMG_PATH="releases/$DMG_NAME"

rm -f "$ZIP_PATH" "$DMG_PATH"

# 5. Create Sparkle Update Archive (.zip)
echo "📦 Creating Sparkle update archive ($ZIP_NAME)..."
ditto -c -k --sequesterRsrc --keepParent "$BUILT_APP" "$ZIP_PATH"

# 6. Create Drag-and-Drop Installer DMG for Colleagues
echo "💿 Creating Drag-and-Drop installer DMG ($DMG_NAME)..."
TMP_DMG_DIR=$(mktemp -d /tmp/comply_dmg.XXXXXX)
cp -R "$BUILT_APP" "$TMP_DMG_DIR/Simployer Comply.app"
ln -s /Applications "$TMP_DMG_DIR/Applications"
hdiutil create -volname "Simployer Comply" -srcfolder "$TMP_DMG_DIR" -ov -format UDZO "$DMG_PATH"
rm -rf "$TMP_DMG_DIR"

# Sign the DMG
codesign --force --timestamp --sign "$SIGNING_IDENTITY" "$DMG_PATH"
codesign --verify --verbose=2 "$DMG_PATH"
echo "✅ DMG created and signed."

# 7. Generate Sparkle Appcast Feed
echo "📡 Generating Sparkle appcast feed..."
if [ ! -f .sparkle_privkey ]; then
    echo "❌ Error: .sparkle_privkey not found!"
    exit 1
fi

./bin/sparkle/bin/generate_appcast \
    --download-url-prefix "https://github.com/$REPO_SLUG/releases/download/v$VERSION/" \
    --ed-key-file .sparkle_privkey \
    releases/

# Copy appcast.xml to project root
cp -f releases/appcast.xml ./appcast.xml

# 8. Commit and Push appcast.xml & project.yml
echo "📤 Committing and pushing appcast.xml to GitHub..."
git add appcast.xml project.yml
git commit -m "chore(release): bump version to v$VERSION and update appcast.xml" || true
git push origin main

# 9. Create GitHub Release
echo "🚀 Publishing GitHub Release v$VERSION..."
# If tag already exists, delete or re-tag
git tag -f "v$VERSION"
git push -f origin "v$VERSION"

gh release create "v$VERSION" \
    "$DMG_PATH" \
    "$ZIP_PATH" \
    --title "Simployer Comply v$VERSION" \
    --notes "$RELEASE_NOTES" \
    --repo "$REPO_SLUG"

echo "========================================================================"
echo "🎉 SUCCESS: Simployer Comply v$VERSION is LIVE!"
echo "   Download Link for Colleagues:"
echo "   👉 https://github.com/$REPO_SLUG/releases/download/v$VERSION/$DMG_NAME"
echo ""
echo "   Existing installations will auto-detect this update via Sparkle!"
echo "========================================================================"
