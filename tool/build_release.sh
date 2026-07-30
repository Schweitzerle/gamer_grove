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

if command -v sentry-cli >/dev/null 2>&1 && [ -n "${SENTRY_AUTH_TOKEN:-}" ]; then
  echo "==> Uploading symbols to Sentry"
  sentry-cli debug-files upload --include-sources "$SYMBOLS"
else
  cat <<'MSG'
==> Sentry upload skipped
    Crashes from this build will arrive obfuscated and unreadable until the
    symbols in build/symbols are uploaded. Install sentry-cli and set
    SENTRY_AUTH_TOKEN, then re-run, or upload that directory by hand.
MSG
fi

echo
echo "Bundle: $AAB (build $BUILD)"
