param(
  [Parameter(Mandatory=$true)][string]$SourceRepo,
  [Parameter(Mandatory=$true)][string]$TargetRepo,
  [Parameter(Mandatory=$true)][string]$ModulesList
)
$ErrorActionPreference = "Stop"

function Copy-IfExists($src, $dst) {
  if (Test-Path $src) {
    if (-not (Test-Path $dst)) { New-Item -ItemType Directory -Force -Path $dst | Out-Null }
    Get-ChildItem -Recurse $src | ForEach-Object {
      if (-not $_.PSIsContainer) {
        $rel = $_.FullName.Substring($src.Length).TrimStart('\','/')
        $target = Join-Path $dst $rel
        if (-not (Test-Path $target)) {
          $targetDir = Split-Path $target -Parent
          if (-not (Test-Path $targetDir)) { New-Item -ItemType Directory -Force -Path $targetDir | Out-Null }
          Copy-Item $_.FullName $target
        }
      }
    }
  }
}

if (-not (Test-Path $ModulesList)) { throw "Modules list not found: $ModulesList" }

$srcModules = Join-Path $SourceRepo "modules"
$dstModules = Join-Path $TargetRepo "modules"
$modules = Get-Content $ModulesList | Where-Object { $_ -and -not $_.StartsWith("#") } | ForEach-Object { $_.Trim() }

Write-Host "Merging modules..." -ForegroundColor Cyan
foreach ($m in $modules) {
  $src = Join-Path $srcModules $m
  $dst = Join-Path $dstModules $m
  Copy-IfExists $src $dst
}
Write-Host "Done."
