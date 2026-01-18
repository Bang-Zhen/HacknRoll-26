$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$dist = Join-Path $root "dist"
New-Item -ItemType Directory -Force -Path $dist | Out-Null

$elmOutput = Join-Path $dist "elm.js"
elm make (Join-Path $root "src/Main.elm") --optimize --output $elmOutput

$loader = Get-Content (Join-Path $root "loader.js")
$elm = Get-Content $elmOutput

$target = Join-Path $root "..\..\frontend\public\microfrontends\coinflip.js"
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $target) | Out-Null
Set-Content -Path $target -Value ($elm + "`n" + $loader)
