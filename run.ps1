param(
    [string]$Device = ""
)

# ──────────────────────────────────────────────
# VibeShopping — Script de ejecución.
#
# Lee configuración desde .env y ejecuta flutter
# run con --dart-define-from-file (requiere
# Flutter 3.22+ / Dart 3.4+).
#
# Funciona igual para flutter build:
#   flutter build apk --dart-define-from-file=.env
#   flutter build appbundle --dart-define-from-file=.env
#
# Uso:
#   .\run.ps1
#   .\run.ps1 -Device emulator-5554
# ──────────────────────────────────────────────

$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$EnvFile = Join-Path $ProjectRoot ".env"

# Validar que .env existe con SUPABASE_URL y SUPABASE_ANON_KEY
if (-not (Test-Path $EnvFile)) {
    Write-Host "ERROR: Falta el archivo .env en la raíz del proyecto." -ForegroundColor Red
    Write-Host "`nSolución:" -ForegroundColor Yellow
    Write-Host "  1. copy .env.example .env" -ForegroundColor White
    Write-Host "  2. notepad .env" -ForegroundColor White
    Write-Host "  3. Completa SUPABASE_URL y SUPABASE_ANON_KEY" -ForegroundColor White
    Write-Host "  4. .\run.ps1" -ForegroundColor Green
    exit 1
}

$hasUrl = $false
$hasKey = $false
Get-Content $EnvFile | ForEach-Object {
    $line = $_.Trim()
    if ($line -match '^SUPABASE_URL=(.+)') { $hasUrl = $true }
    if ($line -match '^SUPABASE_ANON_KEY=(.+)') { $hasKey = $true }
}

if (-not $hasUrl -or -not $hasKey) {
    Write-Host "ERROR: .env no contiene SUPABASE_URL o SUPABASE_ANON_KEY." -ForegroundColor Red
    Write-Host "Revisa .env y completa las variables requeridas." -ForegroundColor Yellow
    exit 1
}

# Ejecutar flutter run con --dart-define-from-file
$flutterArgs = @("run", "--dart-define-from-file=.env")
if ($Device) { $flutterArgs += @("-d", $Device) }

Write-Host "Ejecutando: flutter $($flutterArgs -join ' ')" -ForegroundColor Cyan
& "flutter" $flutterArgs
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}
