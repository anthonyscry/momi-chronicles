@echo off
REM Test runner script for tutorial persistence tests (Windows)

echo Running Tutorial Persistence Tests...
echo.

REM Check if godot is available
where godot >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Error: godot command not found
    echo Please ensure Godot is installed and in your PATH
    exit /b 1
)

REM Run tutorial persistence tests
godot --headless tests/test_tutorial_persistence.tscn

set EXIT_CODE=%ERRORLEVEL%

if %EXIT_CODE% NEQ 0 (
    echo.
    echo Tutorial tests failed with exit code: %EXIT_CODE%
    exit /b %EXIT_CODE%
)

REM Run E2E full suite
echo.
echo Running E2E Full Suite...
godot --headless tests/e2e_full_suite.tscn

set EXIT_CODE=%ERRORLEVEL%

if %EXIT_CODE% EQU 0 (
    echo.
    echo Tests completed successfully!
) else (
    echo.
    echo Tests failed with exit code: %EXIT_CODE%
)

exit /b %EXIT_CODE%
