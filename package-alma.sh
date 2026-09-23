#!/usr/bin/env bash
set -euo pipefail

# Run from the customModule project root.
# Each env file should define INST_ID, VIEW_ID, and VIEW_PACKAGE_DIR.
# Example: VIEW_PACKAGE_DIR=template_package/standard ./package-alma.sh

ENV_FILE="${ENV_FILE:-build-settings.env}"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Missing $ENV_FILE" >&2
  exit 1
fi

set -a
source "$ENV_FILE"
set +a

: "${INST_ID:?Set INST_ID in $ENV_FILE}"
: "${VIEW_ID:?Set VIEW_ID in $ENV_FILE}"
VIEW_PACKAGE_DIR="${VIEW_PACKAGE_DIR:-template_package/$VIEW_ID}"

if [[ ! -d "$VIEW_PACKAGE_DIR" ]]; then
  echo "Missing template package: $VIEW_PACKAGE_DIR" >&2
  echo "Set VIEW_PACKAGE_DIR in $ENV_FILE to the extracted customization folder." >&2
  exit 1
fi

BUILD_DIR="dist/${INST_ID}-${VIEW_ID}"
OUT_DIR="dist/alma-package"
ZIP_FILE="dist/${INST_ID}-${VIEW_ID}-alma.zip"

rm -rf "$OUT_DIR" "$ZIP_FILE"

echo "Building Angular customization..."
npm run build

if [[ ! -d "$BUILD_DIR" ]]; then
  echo "Expected build output not found: $BUILD_DIR" >&2
  echo "Inspect dist/ and adjust BUILD_DIR if your build uses a different output path." >&2
  exit 1
fi

mkdir -p "$OUT_DIR/$VIEW_ID"
cp -R "$VIEW_PACKAGE_DIR"/. "$OUT_DIR/$VIEW_ID/"
cp -R "$BUILD_DIR"/. "$OUT_DIR/$VIEW_ID/"

(
  cd "$OUT_DIR"
  zip -qr "../$(basename "$ZIP_FILE")" "$VIEW_ID" -x '*.DS_Store'
)

printf '\nCreated: %s\n' "$ZIP_FILE"
printf 'Top-level contents:\n'
unzip -l "$ZIP_FILE" | sed -n '1,25p'
