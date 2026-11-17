$ErrorActionPreference = 'Stop'
$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$dir = Join-Path $root '.local-signing'
$key = Join-Path $dir 'szept-peruna-upload.p12'
$passwordFile = Join-Path $dir 'upload-password.txt'
if ((Test-Path -LiteralPath $key) -or (Test-Path -LiteralPath $passwordFile)) {
    throw 'Plik klucza lub hasła już istnieje. Nie nadpisuję go.'
}
$keytool = 'C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe'
if (!(Test-Path -LiteralPath $keytool)) { throw 'Nie znaleziono keytool w Android Studio.' }
$interactiveName = (Get-CimInstance Win32_ComputerSystem).UserName
if ([string]::IsNullOrWhiteSpace($interactiveName)) { throw 'Nie znaleziono zalogowanego użytkownika Windows. Nie tworzę klucza bez możliwości nadania mu dostępu.' }
$interactiveSid = ([System.Security.Principal.NTAccount]::new($interactiveName)).Translate([System.Security.Principal.SecurityIdentifier])
New-Item -ItemType Directory -Force -Path $dir | Out-Null
$identity = [System.Security.Principal.WindowsIdentity]::GetCurrent().User
$security = [System.Security.AccessControl.DirectorySecurity]::new()
$security.SetAccessRuleProtection($true, $false)
$inherit = [System.Security.AccessControl.InheritanceFlags]::ContainerInherit -bor [System.Security.AccessControl.InheritanceFlags]::ObjectInherit
$security.AddAccessRule([System.Security.AccessControl.FileSystemAccessRule]::new($identity, 'FullControl', $inherit, 'None', 'Allow'))
if ($interactiveSid -ne $identity) {
    $security.AddAccessRule([System.Security.AccessControl.FileSystemAccessRule]::new($interactiveSid, 'FullControl', $inherit, 'None', 'Allow'))
}
$security.AddAccessRule([System.Security.AccessControl.FileSystemAccessRule]::new([System.Security.Principal.SecurityIdentifier]::new('S-1-5-18'), 'FullControl', $inherit, 'None', 'Allow'))
Set-Acl -LiteralPath $dir -AclObject $security
$bytes = [byte[]]::new(32)
[System.Security.Cryptography.RandomNumberGenerator]::Fill($bytes)
$env:SZEPT_UPLOAD_PASSWORD = [Convert]::ToBase64String($bytes)
try {
    [IO.File]::WriteAllText($passwordFile, $env:SZEPT_UPLOAD_PASSWORD, [Text.UTF8Encoding]::new($false))
    & $keytool -genkeypair -keystore $key -storetype PKCS12 -alias szept-peruna-upload -keyalg RSA -keysize 3072 -validity 10000 -dname 'CN=Szept Peruna, OU=Games, O=SP-Media, L=Sepolno Krajenskie, C=PL' -storepass:env SZEPT_UPLOAD_PASSWORD -keypass:env SZEPT_UPLOAD_PASSWORD
    if ($LASTEXITCODE -ne 0) { throw 'Nie udało się wygenerować klucza. Sprawdź katalog przed ponowieniem.' }
    Write-Output 'Utworzono lokalny klucz upload i plik hasła. Zrób bezpieczną kopię obu plików poza tym komputerem.'
} finally {
    Remove-Item Env:SZEPT_UPLOAD_PASSWORD -ErrorAction SilentlyContinue
}
