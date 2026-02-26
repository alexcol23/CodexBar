#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT"

CONF=${1:-release}
DIST_DIR="$ROOT/dist/internal"
APP_PATH="$ROOT/CodexBar.app"

source "$ROOT/version.env"

GIT_COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
ARTIFACT_NAME="CodexBar-internal-adhoc-v${MARKETING_VERSION}-b${BUILD_NUMBER}-${GIT_COMMIT}.zip"
ARTIFACT_PATH="$DIST_DIR/$ARTIFACT_NAME"

echo "==> Building ad-hoc signed app ($CONF)"
CODEXBAR_SIGNING=adhoc "$ROOT/Scripts/package_app.sh" "$CONF"

if [[ ! -d "$APP_PATH" ]]; then
  echo "ERROR: Expected app bundle at $APP_PATH" >&2
  exit 1
fi

mkdir -p "$DIST_DIR"
rm -f "$ARTIFACT_PATH"

echo "==> Verifying code signature"
codesign --verify --deep --strict --verbose=2 "$APP_PATH"

echo "==> Packaging zip artifact"
ditto -c -k --sequesterRsrc --keepParent "$APP_PATH" "$ARTIFACT_PATH"

SHA256=$(shasum -a 256 "$ARTIFACT_PATH" | awk '{print $1}')

echo
echo "Created internal artifact:"
echo "  $ARTIFACT_PATH"
echo "SHA256:"
echo "  $SHA256"
echo
echo "Install test (same machine):"
echo "  unzip -q \"$ARTIFACT_PATH\" -d /tmp/codexbar-internal-test"
echo "  open /tmp/codexbar-internal-test/CodexBar.app"
echo
echo "If Gatekeeper blocks the app on teammate machines, they can:"
echo "  1) Right-click the app -> Open"
echo "  2) Or run: xattr -dr com.apple.quarantine /Applications/CodexBar.app"
