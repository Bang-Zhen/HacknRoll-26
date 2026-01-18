#!/usr/bin/env sh
set -e

ROOT="$(cd "$(dirname "$0")" && pwd)"
DIST="$ROOT/dist"
mkdir -p "$DIST"

scala-cli package "$ROOT/poker.scala" --js -o "$DIST/poker.js"

TARGET="$ROOT/../../frontend/public/microfrontends/poker.js"
mkdir -p "$(dirname "$TARGET")"
cat "$DIST/poker.js" > "$TARGET"
