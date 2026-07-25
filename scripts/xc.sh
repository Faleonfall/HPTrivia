#!/usr/bin/env bash
#
# Deterministic command-line build/test for HP Trivia.
#
# Removes the three sources of drift between CLI and the open Xcode session:
#   1. Simulator builds need no real signing -> signing disabled entirely.
#   2. One pinned simulator (by name) -> same destination every run.
#   3. Isolated DerivedData (./.build-cli) -> never fights the Xcode session.
#
# Usage:
#   scripts/xc.sh build   # build the app for the pinned simulator
#   scripts/xc.sh test    # run the HPTriviaTests unit suite
#   scripts/xc.sh boot    # boot the pinned simulator
#   scripts/xc.sh clean   # remove the isolated DerivedData
#   scripts/xc.sh which   # print the resolved simulator + paths
#
set -euo pipefail

PROJECT="HPTrivia.xcodeproj"
SCHEME="HPTrivia"

# Pinned simulator. Repin via HPTRIVIA_SIM; resolution is by name so it stays
# stable across machines even when the runtime gets a patch update.
DEVICE_NAME="${HPTRIVIA_SIM:-iPhone 17}"

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DERIVED="$ROOT/.build-cli/DerivedData"
LOG_DIR="$ROOT/.build-cli/logs"

# Destination is appended per-command using the resolved UDID (name matching is
# ambiguous when the runtime exposes arm64 and x86_64 entries for one device).
COMMON_ARGS=(
  -project "$PROJECT"
  -derivedDataPath "$DERIVED"
  CODE_SIGNING_ALLOWED=NO
  CODE_SIGNING_REQUIRED=NO
  CODE_SIGN_IDENTITY=""
  CODE_SIGN_STYLE=Manual
)

resolve_udid() {
  xcrun simctl list devices available \
    | grep -F "$DEVICE_NAME (" \
    | head -1 \
    | grep -oE '[0-9A-F-]{36}'
}

ensure_booted() {
  local udid; udid="$(resolve_udid)"
  if [ -z "$udid" ]; then
    echo "error: simulator '$DEVICE_NAME' not found. Set HPTRIVIA_SIM or create it." >&2
    exit 1
  fi
  if ! xcrun simctl list devices | grep "$udid" | grep -q "(Booted)"; then
    xcrun simctl boot "$udid" 2>/dev/null || true
  fi
  echo "$udid"
}

run_xcodebuild() {
  local label="$1"; shift
  mkdir -p "$LOG_DIR"
  local log="$LOG_DIR/$label.log"

  local start=$SECONDS
  set +e
  xcodebuild "$@" > "$log" 2>&1
  local rc=$?
  set -e
  local elapsed=$((SECONDS - start))

  grep -iE "(Test Case .* failed |error:|BUILD FAILED|Testing failed|recorded an issue)" "$log" | sed 's/^/  /' || true

  local passed failed
  passed=$(grep -ciE "Test Case .* passed |✔ Test .* passed" "$log" || true)
  failed=$(grep -ciE "Test Case .* failed |✘ Test .* (failed|recorded)" "$log" || true)

  local counts=""
  if [ "$label" = "test" ] || [ "$label" = "uitest" ]; then
    counts="$(printf "   %s passed, %s failed" "$passed" "$failed")"
  fi

  echo "------------------------------------------------------------"
  if [ "$rc" -eq 0 ]; then
    printf "RESULT  ok%s\n" "$counts"
  else
    printf "RESULT  FAIL%s  (exit %s)\n" "$counts" "$rc"
  fi
  printf "TIME    %dm%02ds wall\n" $((elapsed / 60)) $((elapsed % 60))
  echo "log     $log"
  return $rc
}

cmd="${1:-build}"
case "$cmd" in
  build)
    udid="$(ensure_booted)"
    echo ">> build $SCHEME on $DEVICE_NAME ($udid)"
    run_xcodebuild build "${COMMON_ARGS[@]}" -destination "platform=iOS Simulator,id=$udid" -scheme "$SCHEME" build
    ;;
  test)
    udid="$(ensure_booted)"
    echo ">> test $SCHEME on $DEVICE_NAME ($udid)"
    run_xcodebuild test "${COMMON_ARGS[@]}" -destination "platform=iOS Simulator,id=$udid" -scheme "$SCHEME" test
    ;;
  boot)
    udid="$(ensure_booted)"
    echo "booted: $DEVICE_NAME ($udid)"
    ;;
  clean)
    rm -rf "$ROOT/.build-cli"
    echo "removed .build-cli"
    ;;
  which)
    echo "device:  $DEVICE_NAME ($(resolve_udid))"
    echo "derived: $DERIVED"
    echo "project: $ROOT/$PROJECT"
    ;;
  *)
    echo "usage: scripts/xc.sh {build|test|boot|clean|which}" >&2
    exit 2
    ;;
esac
