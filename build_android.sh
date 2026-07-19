#!/usr/bin/env bash

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GODOT_BIN="${GODOT_BIN:-/Applications/Godot.app/Contents/MacOS/Godot}"
ANDROID_SDK_DIR="${ANDROID_HOME:-${HOME}/Library/Android/sdk}"
JAVA_SDK_DIR="${JAVA_HOME:-/Applications/Android Studio.app/Contents/jbr/Contents/Home}"
TEMPLATE_DIR="${HOME}/Library/Application Support/Godot/export_templates/4.6.1.stable"
BUILD_DIR="${PROJECT_DIR}/build/android"
APK_PATH="${BUILD_DIR}/echo-runner.apk"

fail() {
	printf 'CHYBA: %s\n' "$1" >&2
	exit 1
}

[[ -x "${GODOT_BIN}" ]] || fail "Godot nebyl nalezen: ${GODOT_BIN}"
GODOT_VERSION="$(${GODOT_BIN} --version)"
[[ "${GODOT_VERSION}" == 4.6.1* ]] || fail "Je vyžadován Godot 4.6.1, nalezeno: ${GODOT_VERSION}"

[[ -f "${TEMPLATE_DIR}/android_debug.apk" ]] || fail "Chybí Android debug export template pro Godot 4.6.1."
[[ -f "${TEMPLATE_DIR}/android_release.apk" ]] || fail "Chybí Android release export template pro Godot 4.6.1."
[[ -x "${JAVA_SDK_DIR}/bin/java" ]] || fail "JDK nebylo nalezeno: ${JAVA_SDK_DIR}"
JAVA_VERSION_OUTPUT="$("${JAVA_SDK_DIR}/bin/java" -version 2>&1)"
JAVA_MAJOR="$(printf '%s\n' "${JAVA_VERSION_OUTPUT}" | sed -nE '1s/.*version "([0-9]+).*/\1/p')"
[[ -n "${JAVA_MAJOR}" && "${JAVA_MAJOR}" -ge 17 ]] || fail "Je vyžadováno JDK 17 nebo novější."

[[ -d "${ANDROID_SDK_DIR}/platforms/android-35" ]] || fail "Chybí Android SDK Platform 35."
[[ -x "${ANDROID_SDK_DIR}/build-tools/35.0.1/aapt2" ]] || fail "Chybí Android Build Tools 35.0.1 (aapt2)."
[[ -x "${ANDROID_SDK_DIR}/build-tools/35.0.1/apksigner" ]] || fail "Chybí Android Build Tools 35.0.1 (apksigner)."

export JAVA_HOME="${JAVA_SDK_DIR}"
export ANDROID_HOME="${ANDROID_SDK_DIR}"
export ANDROID_SDK_ROOT="${ANDROID_SDK_DIR}"

mkdir -p "${BUILD_DIR}"
rm -f "${APK_PATH}"

printf 'Nastavuji Android SDK a JDK pro Godot exporter...\n'
"${GODOT_BIN}" --headless --editor --path "${PROJECT_DIR}" \
	--log-file "${BUILD_DIR}/godot-android-setup.log" \
	--script "${PROJECT_DIR}/tools/android_export_setup.gd"

printf 'Kontrola projektu v Godot %s...\n' "${GODOT_VERSION}"
"${GODOT_BIN}" --headless --path "${PROJECT_DIR}" \
	--log-file "${BUILD_DIR}/godot-runtime.log" --quit-after 10

printf 'Sestavuji Android APK...\n'
"${GODOT_BIN}" --headless --path "${PROJECT_DIR}" \
	--log-file "${BUILD_DIR}/godot-export.log" \
	--export-debug "Android" "${APK_PATH}"

[[ -s "${APK_PATH}" ]] || fail "Godot nedokončil export: ${APK_PATH} neexistuje nebo je prázdný."
printf 'Hotovo: %s\n' "${APK_PATH}"
