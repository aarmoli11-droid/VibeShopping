@echo off
REM ──────────────────────────────────────────────
REM VibeShopping — Script de ejecución (cmd.exe).
REM
REM Lee configuración desde .env y ejecuta flutter
REM run con --dart-define-from-file.
REM
REM Uso:
REM   run.bat
REM ──────────────────────────────────────────────

if not exist .env (
    echo ERROR: Falta el archivo .env en la raiz del proyecto.
    echo.
    echo Solucion:
    echo   1. copy .env.example .env
    echo   2. notepad .env
    echo   3. Completa SUPABASE_URL y SUPABASE_ANON_KEY
    echo   4. run.bat
    exit /b 1
)

findstr /b "SUPABASE_URL=" .env >nul || (
    echo ERROR: .env no contiene SUPABASE_URL.
    exit /b 1
)

findstr /b "SUPABASE_ANON_KEY=" .env >nul || (
    echo ERROR: .env no contiene SUPABASE_ANON_KEY.
    exit /b 1
)

echo Ejecutando: flutter run --dart-define-from-file=.env
flutter run --dart-define-from-file=.env
if errorlevel 1 (
    echo Error: flutter run fallo con codigo %errorlevel%
    exit /b %errorlevel%
)
