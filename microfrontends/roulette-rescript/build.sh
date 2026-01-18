#!/usr/bin/env sh
set -e

ROOT="$(cd "$(dirname "$0")" && pwd)"
DIST="$ROOT/dist"
mkdir -p "$DIST"

npx rescript build

TARGET="$ROOT/../../frontend/public/microfrontends/roulette.js"
mkdir -p "$(dirname "$TARGET")"
cat "$ROOT/src/Main.bs.js" "$ROOT/src/Main.js" > "$TARGET"
