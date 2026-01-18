$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
npx rescript build

$target = Join-Path $root "..\..\frontend\public\microfrontends\roulette.js"
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $target) | Out-Null

$main = Get-Content (Join-Path $root "src\Main.bs.js")
$ffi = Get-Content (Join-Path $root "src\Main.js")
Set-Content -Path $target -Value ($main + "`n" + $ffi)
