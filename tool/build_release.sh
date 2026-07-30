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

if command -v sentry-cli >/dev/null 2>&1 && [ -r "$TOKEN_FILE" ]; then
  echo "==> Uploading symbols to Sentry"
  SENTRY_AUTH_TOKEN="$(cat "$TOKEN_FILE")" \
  SENTRY_URL="https://de.sentry.io" \
  SENTRY_ORG="schweizerlelab" \
  SENTRY_PROJECT="gamergrove" \
    sentry-cli debug-files upload --include-sources "$SYMBOLS"
else
  cat <<MSG
==> Sentry upload SKIPPED — crashes from this build will be unreadable
    Obfuscation without symbols is a worse trade than no obfuscation: the
    binary is harder to read and so is every crash report. Missing:
      sentry-cli   $(command -v sentry-cli >/dev/null 2>&1 && echo present || echo "not installed")
      token file   $([ -r "$TOKEN_FILE" ] && echo present || echo "$TOKEN_FILE")
    Fix that and re-run, or upload $SYMBOLS by hand before releasing.
MSG
fi

echo
echo "Bundle: $AAB (build $BUILD)"
