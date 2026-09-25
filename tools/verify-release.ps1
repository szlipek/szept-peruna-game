param(
    [switch]$SkipGodot
)

$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$Failures = [System.Collections.Generic.List[string]]::new()

function Test-Requirement {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) {
        $Failures.Add($Message)
    }
}

$RequiredFiles = @(
    'project.godot',
    'export_presets.cfg',
    'scenes/puzzle_level.tscn',
    'scripts/puzzle_level.gd',
    'data/levels.json',
    'art/ui/battle_header_oak_v01.png',
    'art/ui/battle_board_roots_v02.png',
    'art/ui/app_icon_szept_peruna_v01.png',
    'art/characters/hero_lada_portrait_v05.png',
    'art/characters/hero_brun_portrait_v05.png',
    'art/characters/hero_mieta_portrait_v05.png'
)

foreach ($RelativePath in $RequiredFiles) {
    Test-Requirement (Test-Path -LiteralPath (Join-Path $ProjectRoot $RelativePath)) "Brakuje wymaganego pliku: $RelativePath"
}

try {
    $Levels = Get-Content -LiteralPath (Join-Path $ProjectRoot 'data/levels.json') -Raw | ConvertFrom-Json
    Test-Requirement ($Levels.Count -ge 100) 'data/levels.json powinien zawierać co najmniej 100 ręcznie przygotowanych poziomów.'
    $Ids = @($Levels | ForEach-Object { [int]$_.id })
    Test-Requirement (($Ids | Select-Object -Unique).Count -eq $Ids.Count) 'data/levels.json zawiera powielone identyfikatory poziomów.'
    Test-Requirement (($Ids | Measure-Object -Minimum).Minimum -eq 1) 'Pierwszy poziom kampanii powinien mieć identyfikator 1.'
} catch {
    $Failures.Add("Nie można odczytać data/levels.json: $($_.Exception.Message)")
}

if (-not $SkipGodot) {
    $Godot = Join-Path $ProjectRoot 'tools/Godot/Godot_v4.5.2-stable_win64_console.exe'
    if (-not (Test-Path -LiteralPath $Godot)) {
        $Failures.Add('Nie znaleziono lokalnego Godot 4.5.2. Użyj -SkipGodot tylko do kontroli plików.')
    } else {
        $Output = & $Godot --headless --path $ProjectRoot --quit-after 1 2>&1
        if ($LASTEXITCODE -ne 0 -or ($Output -match 'SCRIPT ERROR|Parse Error')) {
            $Failures.Add("Godot zgłosił błąd przy uruchomieniu w trybie headless.`n$Output")
        }
        $SmokeOutput = & $Godot --headless --path $ProjectRoot --script (Join-Path $ProjectRoot 'tests/release_smoke_test.gd') 2>&1
        if ($LASTEXITCODE -ne 0 -or ($SmokeOutput -match 'ERROR: RELEASE SMOKE TEST|SCRIPT ERROR|Parse Error')) {
            $Failures.Add("Test spójności kampanii nie przeszedł.`n$SmokeOutput")
        }
    }
}

if ($Failures.Count -gt 0) {
    $Failures | ForEach-Object { Write-Error $_ }
    exit 1
}

Write-Host 'Release verification passed: pliki, dane kampanii i Godot są poprawne.' -ForegroundColor Green
