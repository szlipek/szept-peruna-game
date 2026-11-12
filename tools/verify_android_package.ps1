param(
    [Parameter(Mandatory = $true)]
    [string]$ApkPath
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem
$projectRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$resolvedApk = (Resolve-Path -LiteralPath $ApkPath).Path
$archive = [System.IO.Compression.ZipFile]::OpenRead($resolvedApk)
try {
    $entries = @{}
    foreach ($entry in $archive.Entries) { $entries[$entry.FullName] = $entry }
    $expected = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    $sourceFiles = @(Get-ChildItem -LiteralPath (Join-Path $projectRoot 'scripts') -Filter '*.gd' -File) +
        @(Get-ChildItem -LiteralPath (Join-Path $projectRoot 'scenes') -Filter '*.tscn' -File)
    foreach ($file in $sourceFiles) {
        $content = [System.IO.File]::ReadAllText($file.FullName)
        foreach ($match in [regex]::Matches($content, 'res://art/[A-Za-z0-9_./-]+\.(?:png|svg|ogg)')) {
            $relative = $match.Value.Substring(6)
            if (Test-Path -LiteralPath (Join-Path $projectRoot $relative) -PathType Leaf) {
                [void]$expected.Add($relative)
            }
        }
    }
    $dynamicDirs = @(
        'art/skills', 'art/avatars', 'art/skill_backgrounds',
        'art/characters/normal_enemies', 'art/environments/expeditions',
        'art/environments/building_levels_bright', 'art/environments/building_levels/dwor_wiecowy'
    )
    foreach ($dir in $dynamicDirs) {
        $folder = Join-Path $projectRoot $dir
        if (-not (Test-Path -LiteralPath $folder)) { throw "Brak katalogu: $dir" }
        $files = if ($dir -eq 'art/skills') {
            Get-ChildItem -LiteralPath $folder -Filter '*.png' -File
        } else {
            Get-ChildItem -LiteralPath $folder -Filter '*.png' -File -Recurse
        }
        foreach ($file in $files) {
            $relative = [System.IO.Path]::GetRelativePath($projectRoot, $file.FullName).Replace('\', '/')
            [void]$expected.Add($relative)
        }
    }
    foreach ($file in Get-ChildItem -LiteralPath (Join-Path $projectRoot 'art/characters') -Filter 'hero_*_portrait_v06.png' -File) {
        [void]$expected.Add('art/characters/' + $file.Name)
    }
    $catalog = Get-Content -LiteralPath (Join-Path $projectRoot 'art/audio/music/catalog.json') -Raw | ConvertFrom-Json
    foreach ($group in @($catalog.music, $catalog.stings)) {
        foreach ($property in $group.PSObject.Properties) {
            if ([string]$property.Value -like 'res://*.ogg') { [void]$expected.Add(([string]$property.Value).Substring(6)) }
        }
    }
    $missing = [System.Collections.Generic.List[string]]::new()
    foreach ($relative in $expected) {
        $import = $entries['assets/' + $relative + '.import']
        if ($null -eq $import) { $missing.Add($relative + ' (brak metadanych)'); continue }
        $reader = [System.IO.StreamReader]::new($import.Open())
        try { $content = $reader.ReadToEnd() } finally { $reader.Dispose() }
        $match = [regex]::Match($content, '(?m)^path="res://([^"]+)"')
        if (-not $match.Success -or -not $entries.ContainsKey('assets/' + $match.Groups[1].Value)) {
            $missing.Add($relative + ' (brak zasobu po imporcie)')
        }
    }
    foreach ($required in @('assets/data/levels.json', 'assets/art/audio/music/catalog.json', 'lib/armeabi-v7a/libgodot_android.so', 'lib/arm64-v8a/libgodot_android.so')) {
        if (-not $entries.ContainsKey($required)) { $missing.Add($required) }
    }
    if ($missing.Count -gt 0) { throw "Brakuje $($missing.Count) zasobów:`n$($missing -join "`n")" }
    Write-Output "OK: $($expected.Count) zasobów graficznych i audio, dane kampanii oraz obie architektury są obecne w APK."
} finally {
    $archive.Dispose()
}
