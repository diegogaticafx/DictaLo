param(
    [switch]$NoStartup
)

$ErrorActionPreference = "Stop"
$ProjectDir = Split-Path $PSCommandPath

Write-Host "=== DictaLo Setup ===" -ForegroundColor Cyan
Write-Host ""

# 1. Create virtual environment if it doesn't exist
if (-not (Test-Path "$ProjectDir\.venv")) {
    Write-Host "[1/3] Creando entorno virtual..." -ForegroundColor Yellow
    python -m venv "$ProjectDir\.venv"
    if (-not $?) { throw "Error al crear el entorno virtual" }
} else {
    Write-Host "[1/3] Entorno virtual ya existe" -ForegroundColor Green
}

# 2. Install dependencies
Write-Host "[2/3] Instalando dependencias..." -ForegroundColor Yellow
& "$ProjectDir\.venv\Scripts\pip.exe" install -r "$ProjectDir\requirements.txt"
if (-not $?) { throw "Error al instalar dependencias" }

# 3. Create startup shortcut
Write-Host ""
$CreateStartup = Read-Host "¿Quieres que DictaLo inicie automaticamente con Windows? (S/N)"

if ($CreateStartup -match "^[sS]$") {
    Write-Host "[3/3] Creando acceso directo en inicio de Windows..." -ForegroundColor Yellow

    $StartupFolder = [Environment]::GetFolderPath("Startup")
    $ShortcutPath = Join-Path $StartupFolder "DictaLo.lnk"

    $wshell = New-Object -ComObject WScript.Shell
    $shortcut = $wshell.CreateShortcut($ShortcutPath)
    $shortcut.TargetPath = "$ProjectDir\.venv\Scripts\pythonw.exe"
    $shortcut.Arguments = "`"$ProjectDir\transcribe.py`""
    $shortcut.WorkingDirectory = "$ProjectDir"
    $shortcut.Description = "DictaLo - Dictado por voz local"
    $shortcut.Save()

    Write-Host "     Creado en: $ShortcutPath" -ForegroundColor Green
}
else {
    Write-Host "[3/3] Inicio automático omitido" -ForegroundColor Gray
}

Write-Host ""
Write-Host "=== Listo! ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Proximo paso: ejecuta 'run.bat' o reinicia Windows para que arranque solo."
Write-Host "Usa Ctrl+Shift+Space para dictar." -ForegroundColor White
