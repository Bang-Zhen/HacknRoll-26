#!/usr/bin/env sh
set -e

ROOT="$(cd "$(dirname "$0")" && pwd)"
npm install
npx fable "$ROOT/src" --outDir "$ROOT/dist" --define:PRODUCTION

TARGET="$ROOT/../../frontend/public/microfrontends/blackjack.js"
mkdir -p "$(dirname "$TARGET")"
cat "$ROOT/dist/Blackjack.js" > "$TARGET"
