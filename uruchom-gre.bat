@echo off
set "GODOT=%~dp0tools\Godot\Godot_v4.5.2-stable_win64.exe"
set "PROJECT_DIR=%~dp0."

if not exist "%GODOT%" (
  echo Nie znaleziono lokalnego Godot. Uruchom projekt z Godot 4.x.
  pause
  exit /b 1
)

"%GODOT%" --path "%PROJECT_DIR%"

if errorlevel 1 (
  echo.
  echo Gra zakonczyla sie z bledem. Skopiuj komunikat z tego okna.
  pause
)
