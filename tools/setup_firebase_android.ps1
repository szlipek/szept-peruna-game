$ErrorActionPreference = 'Stop'
$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$build = Join-Path $root 'android/build'
$config = Join-Path $root 'android/firebase/google-services.json'
if (!(Test-Path -LiteralPath (Join-Path $build 'build.gradle')) -or !(Test-Path -LiteralPath $config)) {
    throw 'Najpierw zainstaluj szablon Android Godot i pobierz android/firebase/google-services.json.'
}
$json = Get-Content -LiteralPath $config -Raw | ConvertFrom-Json
if (@($json.client | Where-Object { $_.client_info.android_client_info.package_name -eq 'org.szeptperuna.game' }).Count -ne 1) {
    throw 'Plik konfiguracji Firebase nie zawiera właściwego pakietu Android.'
}
function Replace-Required([string]$value, [string]$old, [string]$new, [string]$name) {
    if ($value.Contains($new)) { return $value }
    if (!$value.Contains($old)) { throw "Nie znaleziono oczekiwanego fragmentu: $name" }
    return $value.Replace($old, $new)
}
$settingsPath = Join-Path $build 'settings.gradle'
$gradlePath = Join-Path $build 'build.gradle'
$manifestPath = Join-Path $build 'AndroidManifest.xml'
$configGradlePath = Join-Path $build 'config.gradle'
$settings = [IO.File]::ReadAllText($settingsPath)
$gradle = [IO.File]::ReadAllText($gradlePath)
$manifest = [IO.File]::ReadAllText($manifestPath)
$configGradle = [IO.File]::ReadAllText($configGradlePath)
$configGradle = Replace-Required $configGradle "androidGradlePlugin: '8.6.1'" "androidGradlePlugin: '8.9.1'" 'Android Gradle Plugin'
$configGradle = Replace-Required $configGradle 'compileSdk         : 35' 'compileSdk         : 36' 'compileSdk'
$configGradle = Replace-Required $configGradle 'targetSdk          : 35' 'targetSdk          : 36' 'targetSdk'
$configGradle = Replace-Required $configGradle "buildTools         : '35.0.1'" "buildTools         : '36.0.0'" 'build tools'
$settings = Replace-Required $settings "id 'com.android.application' version versions.androidGradlePlugin" "id 'com.android.application' version versions.androidGradlePlugin`n        id 'com.google.gms.google-services' version '4.4.2'`n        id 'com.google.firebase.crashlytics' version '3.0.3'" 'settings plugins'
$gradle = Replace-Required $gradle "id 'com.android.application'" "id 'com.android.application'`n    id 'com.google.gms.google-services'`n    id 'com.google.firebase.crashlytics'" 'application plugins'
$firebaseDependencies = "    implementation platform('com.google.firebase:firebase-bom:33.16.0')`n    implementation 'com.google.firebase:firebase-analytics'`n    implementation 'com.google.firebase:firebase-crashlytics'`n    implementation 'com.google.firebase:firebase-crashlytics-ndk'"
$gradle = Replace-Required $gradle 'dependencies {' "dependencies {`n$firebaseDependencies" 'dependencies'
if (!$gradle.Contains("implementation 'com.google.android.ump:user-messaging-platform:3.2.0'")) {
    $gradle = Replace-Required $gradle $firebaseDependencies "$firebaseDependencies`n    implementation 'com.google.android.ump:user-messaging-platform:3.2.0'" 'UMP dependency'
}
$gradle = Replace-Required $gradle "java.srcDirs = ['src']" "java.srcDirs = ['src', '../firebase/src']" 'source directories'
$metadata = @'
        <meta-data android:name="org.godotengine.plugin.v2.GameFirebase" android:value="org.szeptperuna.firebase.GameFirebase" />
        <meta-data android:name="firebase_analytics_collection_enabled" android:value="false" />
        <meta-data android:name="firebase_crashlytics_collection_enabled" android:value="false" />
        <meta-data android:name="google_analytics_adid_collection_enabled" android:value="false" />
        <meta-data android:name="google_analytics_default_allow_ad_personalization_signals" android:value="false" />
'@
$manifest = Replace-Required $manifest '<profileable' ($metadata + "`n        <profileable") 'manifest metadata'
Copy-Item -LiteralPath $config -Destination (Join-Path $build 'google-services.json') -Force
[IO.File]::WriteAllText($settingsPath, $settings)
[IO.File]::WriteAllText($gradlePath, $gradle)
[IO.File]::WriteAllText($manifestPath, $manifest)
[IO.File]::WriteAllText($configGradlePath, $configGradle)
Write-Output 'Firebase Android: skonfigurowano lokalny szablon Gradle.'
