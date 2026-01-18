$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
npm install
npx fable (Join-Path $root "src") --outDir (Join-Path $root "dist") --define:PRODUCTION

$target = Join-Path $root "..\..\frontend\public\microfrontends\blackjack.js"
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $target) | Out-Null
Copy-Item -Path (Join-Path $root "dist\Blackjack.js") -Destination $target -Force
