#!/usr/bin/env sh
set -e

ROOT="$(cd "$(dirname "$0")" && pwd)"
npm install
npx shadow-cljs release plinko

TARGET="$ROOT/../../frontend/public/microfrontends/plinko.js"
mkdir -p "$(dirname "$TARGET")"
cat "$ROOT/dist/main.js" > "$TARGET"
