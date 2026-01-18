$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$dist = Join-Path $root "dist"
New-Item -ItemType Directory -Force -Path $dist | Out-Null

scala-cli package (Join-Path $root "poker.scala") --js -o (Join-Path $dist "poker.js")

$target = Join-Path $root "..\..\frontend\public\microfrontends\poker.js"
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $target) | Out-Null
Copy-Item -Path (Join-Path $dist "poker.js") -Destination $target -Force
