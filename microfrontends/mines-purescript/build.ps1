$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$dist = Join-Path $root "dist"
New-Item -ItemType Directory -Force -Path $dist | Out-Null

spago bundle-app --main Main --to (Join-Path $dist "mines.js")

$loader = Get-Content (Join-Path $root "loader.js")
$bundle = Get-Content (Join-Path $dist "mines.js")

$target = Join-Path $root "..\..\frontend\public\microfrontends\mines.js"
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $target) | Out-Null
Set-Content -Path $target -Value ($bundle + "`n" + $loader)
