#!/bin/sh
set -eu

# Only needed for Xcode archive actions.
if [ "${ACTION:-}" != "install" ]; then
  exit 0
fi

if [ -z "${DWARF_DSYM_FOLDER_PATH:-}" ] || [ ! -d "${DWARF_DSYM_FOLDER_PATH}" ]; then
  exit 0
fi

PROJECT_PATH="${FLUTTER_APPLICATION_PATH:-${SOURCE_ROOT}/..}"
FLUTTER_BUILD_DIR="${FLUTTER_BUILD_DIR:-build}"
NATIVE_ASSETS_DIR="${PROJECT_PATH}/${FLUTTER_BUILD_DIR}/native_assets/ios"

if [ ! -d "${NATIVE_ASSETS_DIR}" ]; then
  exit 0
fi

for FRAMEWORK_DIR in "${NATIVE_ASSETS_DIR}"/*.framework; do
  [ -d "${FRAMEWORK_DIR}" ] || continue

  FRAMEWORK_NAME="$(basename "${FRAMEWORK_DIR}" .framework)"
  DSYM_SOURCE="${NATIVE_ASSETS_DIR}/${FRAMEWORK_NAME}.framework.dSYM"
  FRAMEWORK_BIN="${FRAMEWORK_DIR}/${FRAMEWORK_NAME}"

  if [ -d "${DSYM_SOURCE}" ]; then
    cp -R "${DSYM_SOURCE}" "${DWARF_DSYM_FOLDER_PATH}/"
    continue
  fi

  if [ -f "${FRAMEWORK_BIN}" ]; then
    DSYM_OUTPUT="${DWARF_DSYM_FOLDER_PATH}/${FRAMEWORK_NAME}.framework.dSYM"
    rm -rf "${DSYM_OUTPUT}"
    # Some native assets don't ship a dSYM. Generate one to satisfy App Store validation.
    dsymutil "${FRAMEWORK_BIN}" -o "${DSYM_OUTPUT}" || true
  fi
done
