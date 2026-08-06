#!/usr/bin/env bash
# Builds the release bundle the way a release is supposed to be built.
#
# Every build since the first one was made with a bare `flutter build
# appbundle --release`, which ships Dart symbol names in the binary: class and
# method names, and with them a readable map of how the app talks to IGDB and
# Supabase. Obfuscation is one flag, and the flag is easy to forget — which is
# why it lives in a script rather than in someone's memory.
#
# The debug symbols it strips out are what makes a crash report readable, so
# they are kept per version and uploaded to Sentry. Without that step
# obfuscation trades a small security gain for unreadable crashes, which is a
# bad trade.
#
# Usage: tool/build_release.sh
set -euo pipefail

cd "$(dirname "$0")/.."

VERSION="$(grep '^version:' pubspec.yaml | awk '{print $2}')"
BUILD="${VERSION##*+}"
SYMBOLS="build/symbols/$VERSION"

echo "==> Building $VERSION"
mkdir -p "$SYMBOLS"

flutter build appbundle --release \
  --obfuscate \
  --split-debug-info="$SYMBOLS"

AAB=build/app/outputs/bundle/release/app-release.aab
[ -f "$AAB" ] || { echo "no bundle at $AAB"; exit 1; }

echo "==> Checking the symbols really are gone"
# A handful of the app's own class names. If these still appear in the binary
# the obfuscation flag did not take, and shipping would be worse than not
# building at all — it would look done.
LEAKED=0
for NAME in GameDetailPage UmamiAnalyticsService ActivationTracker; do
  if unzip -p "$AAB" base/lib/arm64-v8a/libapp.so | grep -qa "$NAME"; then
    echo "    !! $NAME is still in the binary"
    LEAKED=1
  fi
done
[ "$LEAKED" -eq 0 ] && echo "    none of the sampled names survive"

echo "==> Symbols kept in $SYMBOLS"
ls -1 "$SYMBOLS" | sed 's/^/    /'

# The token is an organization auth token, kept outside the repo. It is read
# from a file rather than baked in for the obvious reason, and the org is on
# Sentry's German region, whose API lives on its own hostname — the default
# sentry.io host accepts the token and then cannot find the project.
export PATH="$HOME/.local/bin:$PATH"
TOKEN_FILE="$HOME/.gg-sentry-token"

# Missing tooling used to print a warning and let the build finish. A warning
# in the middle of several hundred lines of Gradle output is a warning nobody
# reads, and what came out the other end looked like a finished bundle. It was
# not: obfuscated without symbols means every crash report from that build is
# unreadable, which is a worse trade than not obfuscating at all.
#
# So it fails instead. A release that cannot be diagnosed is not a release.
# Set GG_ALLOW_MISSING_SYMBOLS=1 to build one anyway (a local smoke test, say).
if ! command -v sentry-cli >/dev/null 2>&1 || [ ! -r "$TOKEN_FILE" ]; then
  cat >&2 <<MSG

!! Cannot upload debug symbols — refusing to finish this build.
   Crashes from an obfuscated build without symbols are unreadable.
     sentry-cli   $(command -v sentry-cli >/dev/null 2>&1 && echo present || echo "not installed — https://docs.sentry.io/cli/installation/")
     token file   $([ -r "$TOKEN_FILE" ] && echo present || echo "missing: $TOKEN_FILE")
   The bundle at $AAB is left in place; symbols are in $SYMBOLS.
   Upload them by hand and re-run, or set GG_ALLOW_MISSING_SYMBOLS=1 if this
   build is not going to a store.
MSG
  [ "${GG_ALLOW_MISSING_SYMBOLS:-0}" = "1" ] || exit 1
  echo "   GG_ALLOW_MISSING_SYMBOLS=1 — continuing without symbols." >&2
else
  echo "==> Uploading symbols to Sentry"
  SENTRY_AUTH_TOKEN="$(cat "$TOKEN_FILE")" \
  SENTRY_URL="https://de.sentry.io" \
  SENTRY_ORG="schweizerlelab" \
  SENTRY_PROJECT="gamergrove" \
    sentry-cli debug-files upload --include-sources "$SYMBOLS"

  # An upload that reports success but lands nothing is the failure mode this
  # whole block exists to prevent, so the result is read back from the server.
  #
  # `sentry-cli debug-files check` only inspects the LOCAL file — it says
  # nothing about what arrived. The debug id it prints is the join key, so the
  # id goes to the API and the answer has to come back non-empty.
  echo "==> Verifying the symbols arrived"
  for SYM in "$SYMBOLS"/*.symbols; do
    [ -e "$SYM" ] || continue

    DEBUG_ID="$(sentry-cli debug-files check "$SYM" --json 2>/dev/null \
      | python3 -c 'import json,sys; print(json.load(sys.stdin)["variants"][0]["debug_id"])')"
    [ -n "$DEBUG_ID" ] || {
      echo "    !! no debug id in $(basename "$SYM")" >&2; exit 1; }

    FOUND="$(curl -sf -H "Authorization: Bearer $(cat "$TOKEN_FILE")" \
      "https://de.sentry.io/api/0/projects/schweizerlelab/gamergrove/files/dsyms/?query=$DEBUG_ID" \
      | python3 -c 'import json,sys; d=json.load(sys.stdin); print(len(d) if isinstance(d,list) else 0)')"

    if [ "${FOUND:-0}" -gt 0 ]; then
      echo "    ok  $(basename "$SYM")  $DEBUG_ID"
    else
      echo "    !! $(basename "$SYM") ($DEBUG_ID) is not on the server" >&2
      exit 1
    fi
  done
fi

echo
echo "Bundle: $AAB (build $BUILD)"
