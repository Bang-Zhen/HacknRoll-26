#!/usr/bin/env sh
set -e

ROOT="$(cd "$(dirname "$0")" && pwd)"
DIST="$ROOT/dist"
mkdir -p "$DIST"

elm make "$ROOT/src/Main.elm" --optimize --output "$DIST/elm.js"

TARGET="$ROOT/../../frontend/public/microfrontends/coinflip.js"
mkdir -p "$(dirname "$TARGET")"
cat "$DIST/elm.js" "$ROOT/loader.js" > "$TARGET"
