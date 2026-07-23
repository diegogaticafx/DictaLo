param(
    [switch]$Force
)

$ErrorActionPreference = "Stop"
$ProjectDir = Split-Path $PSCommandPath

Write-Host "=== whisperlocal Uninstall ===" -ForegroundColor Cyan
Write-Host ""

# 1. Kill any running pythonw process from this project
Write-Host "[1/3] Deteniendo whisperlocal..." -ForegroundColor Yellow
$target = Resolve-Path "$ProjectDir\.venv\Scripts\pythonw.exe" -ErrorAction SilentlyContinue
if ($target) {
    Get-Process -Name "pythonw" -ErrorAction SilentlyContinue | Where-Object {
        $_.Path -eq $target.Path
    } | Stop-Process -Force -ErrorAction SilentlyContinue
}
Write-Host "     OK" -ForegroundColor Green

# 2. Remove startup shortcut
Write-Host "[2/3] Eliminando acceso directo de inicio de Windows..." -ForegroundColor Yellow
$StartupFolder = [Environment]::GetFolderPath("Startup")
$ShortcutPath = Join-Path $StartupFolder "whisperlocal.lnk"
if (Test-Path $ShortcutPath) {
    Remove-Item $ShortcutPath -Force
    Write-Host "     Eliminado: $ShortcutPath" -ForegroundColor Green
} else {
    Write-Host "     No existe" -ForegroundColor Gray
}

# 3. Remove project (optional)
Write-Host "[3/3] Eliminar proyecto completo?" -ForegroundColor Yellow
if ($Force) {
    $confirm = "y"
} else {
    $confirm = Read-Host "Esto eliminara TODO '$ProjectDir' (incluyendo .venv y scripts). Continuar? (y/N)"
}

if ($confirm -eq "y") {
    Write-Host "     Eliminando $ProjectDir ..." -ForegroundColor Red
    $parent = Split-Path $ProjectDir -Parent
    Set-Location $parent
    Remove-Item $ProjectDir -Recurse -Force
    Write-Host "     Proyecto eliminado." -ForegroundColor Green
    Write-Host ""
    Write-Host "=== whisperlocal ha sido desinstalado ===" -ForegroundColor Cyan
} else {
    Write-Host "     Proyecto conservado en: $ProjectDir" -ForegroundColor Gray
    Write-Host "     Para iniciarlo manualmente: .\run.bat" -ForegroundColor Gray
    Write-Host ""
    Write-Host "=== Uninstall completado (proyecto intacto) ===" -ForegroundColor Cyan
    Write-Host "=== Por ultimo si deseas eliminar la cache de LLm manualmente entra a  user\.cache\huggingface\hub\ ===" -ForegroundColor Cyan
}
