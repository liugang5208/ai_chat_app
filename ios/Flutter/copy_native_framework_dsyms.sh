#!/bin/sh
set -eu

# Only needed for Xcode archive actions.
if [ "${ACTION:-}" != "install" ]; then
  exit 0
fi

PROJECT_PATH="${FLUTTER_APPLICATION_PATH:-${SOURCE_ROOT}/..}"
FLUTTER_BUILD_DIR="${FLUTTER_BUILD_DIR:-build}"
NATIVE_ASSETS_DIR="${PROJECT_PATH}/${FLUTTER_BUILD_DIR}/native_assets/ios"
APP_FRAMEWORKS_DIR="${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
HOOKS_SHARED_DIR="${PROJECT_PATH}/.dart_tool/hooks_runner/shared"

is_simulator_platform_binary() {
  BIN_PATH="$1"
  xcrun vtool -show-build "${BIN_PATH}" 2>/dev/null | grep -q "platform IOSSIMULATOR"
}

is_ios_platform_binary() {
  BIN_PATH="$1"
  xcrun vtool -show-build "${BIN_PATH}" 2>/dev/null | grep -q "platform IOS"
}

codesign_framework_if_needed() {
  FRAMEWORK_PATH="$1"
  if [ -n "${EXPANDED_CODE_SIGN_IDENTITY:-}" ]; then
    /usr/bin/codesign --force --sign "${EXPANDED_CODE_SIGN_IDENTITY}" --preserve-metadata=identifier,entitlements "${FRAMEWORK_PATH}" || true
  else
    /usr/bin/codesign --force --sign - "${FRAMEWORK_PATH}" || true
  fi
}

sanitize_embedded_frameworks() {
  if [ ! -d "${APP_FRAMEWORKS_DIR}" ]; then
    return 0
  fi

  for FRAMEWORK_DIR in "${APP_FRAMEWORKS_DIR}"/*.framework; do
    [ -d "${FRAMEWORK_DIR}" ] || continue
    FRAMEWORK_NAME="$(basename "${FRAMEWORK_DIR}" .framework)"
    FRAMEWORK_BIN="${FRAMEWORK_DIR}/${FRAMEWORK_NAME}"
    [ -f "${FRAMEWORK_BIN}" ] || continue

    if ! is_simulator_platform_binary "${FRAMEWORK_BIN}"; then
      continue
    fi

    echo "Found simulator platform binary in archive: ${FRAMEWORK_BIN}"

    REPLACED=0
    if [ -d "${HOOKS_SHARED_DIR}/${FRAMEWORK_NAME}/build" ]; then
      for CANDIDATE_BIN in "${HOOKS_SHARED_DIR}/${FRAMEWORK_NAME}/build"/*/"${FRAMEWORK_NAME}.dylib"; do
        [ -f "${CANDIDATE_BIN}" ] || continue
        if is_ios_platform_binary "${CANDIDATE_BIN}"; then
          cp -f "${CANDIDATE_BIN}" "${FRAMEWORK_BIN}"
          codesign_framework_if_needed "${FRAMEWORK_DIR}"
          REPLACED=1
          echo "Replaced with iOS device binary: ${CANDIDATE_BIN}"
          break
        fi
      done
    fi

    if [ "${REPLACED}" -eq 0 ] || is_simulator_platform_binary "${FRAMEWORK_BIN}"; then
      echo "error: ${FRAMEWORK_BIN} still targets iOS Simulator. Clean Flutter native asset cache and rebuild archive." >&2
      echo "hint: rm -rf ${PROJECT_PATH}/build/native_assets ${PROJECT_PATH}/.dart_tool/flutter_build ${PROJECT_PATH}/.dart_tool/hooks_runner/shared/${FRAMEWORK_NAME}" >&2
      exit 1
    fi
  done
}

sanitize_embedded_frameworks

if [ -z "${DWARF_DSYM_FOLDER_PATH:-}" ] || [ ! -d "${DWARF_DSYM_FOLDER_PATH}" ]; then
  exit 0
fi

if [ -d "${NATIVE_ASSETS_DIR}" ]; then
  FRAMEWORK_SEARCH_DIR="${NATIVE_ASSETS_DIR}"
elif [ -d "${APP_FRAMEWORKS_DIR}" ]; then
  FRAMEWORK_SEARCH_DIR="${APP_FRAMEWORKS_DIR}"
else
  exit 0
fi

for FRAMEWORK_DIR in "${FRAMEWORK_SEARCH_DIR}"/*.framework; do
  [ -d "${FRAMEWORK_DIR}" ] || continue

  FRAMEWORK_NAME="$(basename "${FRAMEWORK_DIR}" .framework)"
  DSYM_SOURCE="${NATIVE_ASSETS_DIR}/${FRAMEWORK_NAME}.framework.dSYM"
  APP_FRAMEWORK_BIN="${APP_FRAMEWORKS_DIR}/${FRAMEWORK_NAME}.framework/${FRAMEWORK_NAME}"
  FRAMEWORK_BIN="${FRAMEWORK_DIR}/${FRAMEWORK_NAME}"

  if [ -d "${DSYM_SOURCE}" ] && [ "${FRAMEWORK_SEARCH_DIR}" = "${NATIVE_ASSETS_DIR}" ]; then
    cp -R "${DSYM_SOURCE}" "${DWARF_DSYM_FOLDER_PATH}/"
    continue
  fi

  if [ -f "${APP_FRAMEWORK_BIN}" ]; then
    FRAMEWORK_BIN="${APP_FRAMEWORK_BIN}"
  fi

  if [ -f "${FRAMEWORK_BIN}" ]; then
    DSYM_OUTPUT="${DWARF_DSYM_FOLDER_PATH}/${FRAMEWORK_NAME}.framework.dSYM"
    rm -rf "${DSYM_OUTPUT}"
    # Some native assets don't ship a dSYM. Generate one to satisfy App Store validation.
    dsymutil "${FRAMEWORK_BIN}" -o "${DSYM_OUTPUT}" || true
  fi
done
