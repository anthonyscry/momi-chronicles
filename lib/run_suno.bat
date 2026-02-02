@echo off
echo ===================================================
echo Momi's Adventure - Suno Music Generator
echo ===================================================
echo.

REM Check if Python is available
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python not found! Please install Python first.
    pause
    exit /b 1
)

REM Check if playwright is installed
python -c "import playwright" >nul 2>&1
if errorlevel 1 (
    echo Installing Playwright...
    pip install playwright
    playwright install chromium
)

echo.
echo Choose what to generate:
echo   1. Essential tracks only (7 tracks - recommended first)
echo   2. Character themes (4 tracks)
echo   3. Zone variations (5 tracks)
echo   4. Combat variations (6 tracks)
echo   5. ALL tracks (22 tracks)
echo   6. List all prompts
echo   7. Exit
echo.

set /p choice="Enter choice (1-7): "

if "%choice%"=="1" (
    python suno_automation.py --category essential
) else if "%choice%"=="2" (
    python suno_automation.py --category character_themes
) else if "%choice%"=="3" (
    python suno_automation.py --category zone_variations
) else if "%choice%"=="4" (
    python suno_automation.py --category combat_variations
) else if "%choice%"=="5" (
    python suno_automation.py --category all
) else if "%choice%"=="6" (
    python suno_automation.py --list
    pause
) else if "%choice%"=="7" (
    exit /b 0
) else (
    echo Invalid choice!
)

pause
