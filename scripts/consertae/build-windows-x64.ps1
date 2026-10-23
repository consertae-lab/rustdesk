param(
  [Parameter(Mandatory=$true)][string]$SourceDir,
  [string]$VcpkgRoot = 'C:\vcpkg',
  [string]$OutputDir = ''
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Need([string]$Name) {
  $c = Get-Command $Name -ErrorAction SilentlyContinue
  if (-not $c) { throw "Dependência ausente: $Name" }
  return $c.Source
}

Write-Host '=== Consertaê Suporte - Windows x64 build ==='
$SourceDir = (Resolve-Path $SourceDir).Path
if (-not $OutputDir) { $OutputDir = Join-Path $SourceDir 'dist-consertae-win-x64' }

Need 'git.exe' | Out-Null
Need 'python.exe' | Out-Null
Need 'cmake.exe' | Out-Null
Need 'ninja.exe' | Out-Null
Need 'flutter.bat' | Out-Null
Need 'cargo.exe' | Out-Null
Need 'rustc.exe' | Out-Null
Need 'clang.exe' | Out-Null

$cl = Get-Command cl.exe -ErrorAction SilentlyContinue
if (-not $cl) { throw 'MSVC cl.exe não está no PATH. Execute pelo x64 Native Tools Command Prompt do Visual Studio 2022.' }
if (-not (Test-Path "$VcpkgRoot\vcpkg.exe")) { throw "vcpkg não encontrado em $VcpkgRoot" }

$flutterVersion = (& flutter --version | Select-Object -First 1) -join ''
if ($flutterVersion -notmatch 'Flutter 3\.24\.5') { throw "Flutter incorreto: $flutterVersion. Esperado 3.24.5." }
$rustVersion = (& rustc --version) -join ''
if ($rustVersion -notmatch 'rustc 1\.75\.') { throw "Rust incorreto: $rustVersion. Esperado 1.75.x." }

Set-Location $SourceDir
if ((Get-Content Cargo.toml -Raw) -notmatch 'version = "1\.4\.9"') { throw 'Source não é RustDesk 1.4.9.' }
if (-not (Select-String -Path 'flutter\windows\runner\main.cpp' -Pattern 'Consertaê Suporte' -Quiet)) { throw 'Patch visual Consertaê não encontrado.' }
if (-not (Select-String -Path 'src\core_main.rs' -Pattern 'Consertaê Suporte' -Quiet)) { throw 'Patch de dispatch Windows Consertaê não encontrado.' }

Write-Host '1/5 Flutter engine'
flutter precache --windows
$flutterRoot = Split-Path (Split-Path (Get-Command flutter.bat).Source)
$engine = Join-Path $flutterRoot 'bin\cache\artifacts\engine\windows-x64-release'
$tmpZip = Join-Path $env:TEMP 'rustdesk-windows-x64-release.zip'
$tmpDir = Join-Path $env:TEMP 'rustdesk-windows-x64-release'
Invoke-WebRequest -Uri 'https://github.com/rustdesk/engine/releases/download/main/windows-x64-release.zip' -OutFile $tmpZip
Remove-Item $tmpDir -Recurse -Force -ErrorAction SilentlyContinue
Expand-Archive $tmpZip -DestinationPath $tmpDir -Force
Copy-Item "$tmpDir\*" $engine -Recurse -Force

Write-Host '2/5 Flutter patch'
$patch = Join-Path $SourceDir '.github\patches\flutter_3.24.4_dropdown_menu_enableFilter.diff'
Push-Location $flutterRoot
$check = & git apply --check $patch 2>&1
if ($LASTEXITCODE -eq 0) { & git apply $patch }
Pop-Location

Write-Host '3/5 vcpkg'
$env:VCPKG_ROOT = $VcpkgRoot
$env:VCPKG_DEFAULT_HOST_TRIPLET = 'x64-windows-static'
$workflow = Get-Content (Join-Path $SourceDir '.github\workflows\flutter-build.yml') -Raw
if ($workflow -notmatch 'VCPKG_COMMIT_ID:\s*"([0-9a-fA-F]{40})"') { throw 'VCPKG_COMMIT_ID não encontrado no workflow oficial.' }
$vcpkgCommit = $Matches[1]
& git.exe -C $VcpkgRoot cat-file -e ("$vcpkgCommit" + "^{commit}")
if ($LASTEXITCODE -ne 0) {
    & git.exe -C $VcpkgRoot fetch origin $vcpkgCommit
    if ($LASTEXITCODE -ne 0) { throw 'git fetch do vcpkg falhou.' }
}
& git.exe -C $VcpkgRoot checkout --force $vcpkgCommit
if ($LASTEXITCODE -ne 0) { throw 'checkout do commit vcpkg oficial falhou.' }
& "$VcpkgRoot\bootstrap-vcpkg.bat" -disableMetrics
if ($LASTEXITCODE -ne 0) { throw 'bootstrap-vcpkg no commit oficial falhou.' }
& "$VcpkgRoot\vcpkg.exe" install --triplet x64-windows-static --x-install-root="$VcpkgRoot\installed"
if ($LASTEXITCODE -ne 0) { throw 'vcpkg falhou.' }

Write-Host '4/5 RustDesk / Flutter'
Push-Location (Join-Path $SourceDir 'flutter')
flutter pub get
Pop-Location
python .\build.py --portable --flutter --skip-portable-pack --hwcodec --vram
if ($LASTEXITCODE -ne 0) { throw 'build.py falhou.' }

$release = Join-Path $SourceDir 'flutter\build\windows\x64\runner\Release'
if (-not (Test-Path "$release\rustdesk.exe")) { throw 'rustdesk.exe não foi gerado.' }
Remove-Item $OutputDir -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path $OutputDir | Out-Null
Copy-Item "$release\*" $OutputDir -Recurse -Force
Rename-Item (Join-Path $OutputDir 'rustdesk.exe') 'Consertae-Suporte.exe'

Write-Host '5/5 Validação'
$exe = Join-Path $OutputDir 'Consertae-Suporte.exe'
$hash = Get-FileHash $exe -Algorithm SHA256
$hash | Format-List
Write-Host "OUTPUT=$OutputDir"
Write-Host 'QA build concluída. NÃO PUBLICAR sem assinatura Authenticode da Consertaê.'
