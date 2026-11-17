$ErrorActionPreference = 'Stop'
$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$dir = Join-Path $root '.local-signing'
$log = Join-Path $root 'tmp/signing-access-repair.log'
try {
    $current = [Security.Principal.WindowsIdentity]::GetCurrent()
    $admin = [Security.Principal.WindowsPrincipal]::new($current)
    if (-not $admin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { throw 'Naprawa musi zostać uruchomiona jako administrator.' }
    & takeown.exe /F $dir /A 2>&1 | Out-File -LiteralPath $log -Encoding utf8
    if ($LASTEXITCODE -ne 0) { throw 'Nie udało się przejąć właściciela katalogu.' }
    $sid = $current.User.Value
    & icacls.exe $dir /grant "*${sid}:(OI)(CI)F" 2>&1 | Out-File -LiteralPath $log -Append -Encoding utf8
    if ($LASTEXITCODE -ne 0) { throw 'Nie udało się nadać dostępu właścicielowi.' }
    foreach ($name in @('szept-peruna-upload.p12', 'upload-password.txt')) {
        $file = Join-Path $dir $name
        if (!(Test-Path -LiteralPath $file -PathType Leaf)) { throw "Brak pliku $name." }
        & takeown.exe /F $file /A 2>&1 | Out-File -LiteralPath $log -Append -Encoding utf8
        if ($LASTEXITCODE -ne 0) { throw "Nie udało się przejąć właściciela pliku $name." }
        & icacls.exe $file /grant "*${sid}:F" 2>&1 | Out-File -LiteralPath $log -Append -Encoding utf8
        if ($LASTEXITCODE -ne 0) { throw "Nie udało się nadać dostępu do pliku $name." }
    }
    Add-Content -LiteralPath $log -Value 'OK: dostęp do obu plików potwierdzony.'
} catch {
    Add-Content -LiteralPath $log -Value ("BŁĄD: " + $_.Exception.Message)
    exit 1
}
