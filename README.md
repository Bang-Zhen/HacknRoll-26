# GoBroke.com (Localhost Only)

Virtual credits only. No real money or payments.

## Prereqs

- Node.js 18+
- SQLite (bundled via Prisma)

## Setup

```bash
npm install
```

### Backend

Create `backend/.env`:

```
DATABASE_URL="file:./dev.db"
JWT_SECRET="change-me"
CLIENT_ORIGIN="http://localhost:3000"
PORT=4000
```

Run migrations + generate client:

```bash
cd backend
npm run prisma:generate
npm run prisma:migrate
```

Seed demo users + group:

```bash
npm run seed
```

Start the backend:

```bash
npm run dev
```

### Polyglot game engines (optional)

Coinflip can run from a Zig engine. The backend will automatically fall back to the
TypeScript implementation if the external engine is missing or fails.

Build the Zig engine:

```bash
cd engines/zig/coinflip
zig build-exe coinflip.zig -O ReleaseSafe -femit-bin=coinflip
```

Enable it when running the backend:

```bash
COINFLIP_ENGINE=zig COINFLIP_ENGINE_BIN=./engines/zig/coinflip/coinflip npm run dev
```

Blackjack can run from a Nim engine (same fallback behavior).

Build the Nim engine:

```bash
cd engines/nim/blackjack
nim c -d:release -o:blackjack blackjack.nim
```

Enable it when running the backend:

```bash
BLACKJACK_ENGINE=nim BLACKJACK_ENGINE_BIN=./engines/nim/blackjack/blackjack npm run dev
```

Roulette can run from an OCaml engine (same fallback behavior).

Build the OCaml engine:

```bash
cd engines/ocaml/roulette
ocamlc -o roulette roulette.ml
```

Enable it when running the backend:

```bash
ROULETTE_ENGINE=ocaml ROULETTE_ENGINE_BIN=./engines/ocaml/roulette/roulette npm run dev
```

Mines can run from a Prolog engine (same fallback behavior).

Build the Prolog engine (SWI-Prolog):

```bash
cd engines/prolog/mines
swipl -q -g main -o mines -c mines.pl
```

Enable it when running the backend:

```bash
MINES_ENGINE=prolog MINES_ENGINE_BIN=./engines/prolog/mines/mines npm run dev
```

Plinko can run from a Crystal engine (same fallback behavior).

Build the Crystal engine:

```bash
cd engines/crystal/plinko
crystal build plinko.cr -o plinko --release
```

Enable it when running the backend:

```bash
PLINKO_ENGINE=crystal PLINKO_ENGINE_BIN=./engines/crystal/plinko/plinko npm run dev
```

Poker can run from a D engine (same fallback behavior).

Build the D engine (DMD):

```bash
cd engines/d/poker
dmd -O -release -of=poker poker.d
```

Enable it when running the backend:

```bash
POKER_ENGINE=d POKER_ENGINE_BIN=./engines/d/poker/poker npm run dev
```

Invite codes can run from a Lua engine (same fallback behavior).

Use the Lua engine:

```bash
INVITE_ENGINE=lua INVITE_ENGINE_BIN=lua INVITE_ENGINE_SCRIPT=./engines/lua/invite/invite.lua npm run dev
```

Spider chart stats can run from an R engine (same fallback behavior).

Use the R engine:

```bash
SPIDER_ENGINE=r SPIDER_ENGINE_BIN=Rscript SPIDER_ENGINE_SCRIPT=./engines/r/spider/stats.R npm run dev
```

Roulette bet resolution can run from a Racket engine (same fallback behavior).

Use the Racket engine:

```bash
ROULETTE_RESOLVE_ENGINE=racket ROULETTE_RESOLVE_ENGINE_BIN=racket ROULETTE_RESOLVE_ENGINE_SCRIPT=./engines/racket/roulette_resolve/resolve.rkt npm run dev
```

Roulette red/black multiplier can run through a Brainfuck program (same fallback behavior).
This only affects red/black bets and keeps green/straight resolution in JS.

```bash
ROULETTE_RESOLVE_ENGINE=bf ROULETTE_MULTIPLIER_BF_PATH=./engines/brainfuck/roulette/multiplier.bf npm run dev
```

Coinflip UI can load an optional microfrontend bundle (fallbacks to the React page).

Set the URL for a microfrontend bundle:

```bash
NEXT_PUBLIC_COINFLIP_MFE_URL=http://localhost:3000/microfrontends/coinflip.js npm run dev
```

Elm coinflip microfrontend source lives in `microfrontends/coinflip-elm`.

Build the Elm bundle:

```bash
cd microfrontends/coinflip-elm
./build.sh
```

Windows (PowerShell):

```bash
cd microfrontends/coinflip-elm
.\build.ps1
```

Mines UI can load an optional microfrontend bundle (fallbacks to the React page).

```bash
NEXT_PUBLIC_MINES_MFE_URL=http://localhost:3000/microfrontends/mines.js npm run dev
```

PureScript mines microfrontend source lives in `microfrontends/mines-purescript`.

Build the PureScript bundle:

```bash
cd microfrontends/mines-purescript
./build.sh
```

Windows (PowerShell):

```bash
cd microfrontends/mines-purescript
.\build.ps1
```

Roulette UI can load an optional microfrontend bundle (fallbacks to the React page).

```bash
NEXT_PUBLIC_ROULETTE_MFE_URL=http://localhost:3000/microfrontends/roulette.js npm run dev
```

ReScript roulette microfrontend source lives in `microfrontends/roulette-rescript`.

Build the ReScript bundle:

```bash
cd microfrontends/roulette-rescript
./build.sh
```

Windows (PowerShell):

```bash
cd microfrontends/roulette-rescript
.\build.ps1
```

Plinko UI can load an optional microfrontend bundle (fallbacks to the React page).

```bash
NEXT_PUBLIC_PLINKO_MFE_URL=http://localhost:3000/microfrontends/plinko.js npm run dev
```

ClojureScript plinko microfrontend source lives in `microfrontends/plinko-clojurescript`.

Build the ClojureScript bundle:

```bash
cd microfrontends/plinko-clojurescript
./build.sh
```

Windows (PowerShell):

```bash
cd microfrontends/plinko-clojurescript
.\build.ps1
```

Blackjack UI can load an optional microfrontend bundle (fallbacks to the React page).

```bash
NEXT_PUBLIC_BLACKJACK_MFE_URL=http://localhost:3000/microfrontends/blackjack.js npm run dev
```

Fable blackjack microfrontend source lives in `microfrontends/blackjack-fable`.

Build the Fable bundle:

```bash
cd microfrontends/blackjack-fable
./build.sh
```

Windows (PowerShell):

```bash
cd microfrontends/blackjack-fable
.\build.ps1
```

Poker UI can load an optional microfrontend bundle (fallbacks to the React page).

```bash
NEXT_PUBLIC_POKER_MFE_URL=http://localhost:3000/microfrontends/poker.js npm run dev
```

Scala.js poker microfrontend source lives in `microfrontends/poker-scalajs`.

Build the Scala.js bundle:

```bash
cd microfrontends/poker-scalajs
./build.sh
```

Windows (PowerShell):

```bash
cd microfrontends/poker-scalajs
.\build.ps1
```

### Frontend

In another terminal:

```bash
cd frontend
npm install
npm run dev
```

Frontend: `http://localhost:3000`
Backend: `http://localhost:4000`

## Monorepo Dev

From repo root:

```bash
npm run dev
```

## Demo Accounts (seed)

- `alex@example.com` / `password123`
- `sam@example.com` / `password123`

## Game Logic

Unit-testable logic is kept in `backend/src/services/games`.
