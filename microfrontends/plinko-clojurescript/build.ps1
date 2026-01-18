$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
npm install
npx shadow-cljs release plinko

$target = Join-Path $root "..\..\frontend\public\microfrontends\plinko.js"
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $target) | Out-Null
Copy-Item -Path (Join-Path $root "dist\main.js") -Destination $target -Force
