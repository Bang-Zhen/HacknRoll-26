#!/usr/bin/env sh
set -e

ROOT="$(cd "$(dirname "$0")" && pwd)"
DIST="$ROOT/dist"
mkdir -p "$DIST"

spago bundle-app --main Main --to "$DIST/mines.js"

TARGET="$ROOT/../../frontend/public/microfrontends/mines.js"
mkdir -p "$(dirname "$TARGET")"
cat "$DIST/mines.js" "$ROOT/loader.js" > "$TARGET"
