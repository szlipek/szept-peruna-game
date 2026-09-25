@echo off
set "GODOT=%~dp0tools\Godot\Godot_v4.5.2-stable_win64.exe"
set "PROJECT_DIR=%~dp0."

if not exist "%GODOT%" (
  echo Nie znaleziono lokalnego Godot. Uruchom projekt z Godot 4.x.
  pause
  exit /b 1
)

start "Godot - Szept Peruna" "%GODOT%" --editor --path "%PROJECT_DIR%"
