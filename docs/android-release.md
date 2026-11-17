# Android — wydanie Szept Peruna 1.0.0

Projekt ma preset `Android` w `export_presets.cfg`. Jest ustawiony na pionową aplikację, nazwę **Szept Peruna**, wersję `1.0.0`, kod wersji `1` oraz architektury `armeabi-v7a` i `arm64-v8a`.

Ikona aplikacji jest ustawiona w `project.godot` jako `art/ui/app_icon_szept_peruna_v01.png`. Jest to ilustracja wykonana na potrzeby projektu i powinna zostać sprawdzona na rzeczywistym launcherze Androida przed publikacją.

## Stan lokalnego środowiska

Środowisko zawiera SDK Android 36 i szablon Gradle Godot 4.5.2. Skrypt `tools/setup_firebase_android.ps1` ustawia w lokalnym szablonie `compileSdk` i `targetSdk` na 36, Android Gradle Plugin 8.9.1 oraz zależności Firebase. Preset Godota również wymusza target SDK 36. Testowy eksport APK został zweryfikowany pod kątem API 36 i zasobów; nie zastępuje to testu na telefonie ani podpisanego AAB.

## Jednorazowe ustawienie właściciela

Przed publikacją właściciel projektu musi w Godot skonfigurować Android SDK/JDK oraz własny keystore wydania. Nie zapisujemy haseł ani prywatnego klucza w repozytorium.

1. W Godot otwórz **Editor → Editor Settings → Export → Android** i wskaż SDK oraz JDK.
2. Utwórz keystore wydania poza projektem i zachowaj go w bezpiecznym miejscu.
3. W ustawieniach eksportu Android ustaw ścieżkę keystore, alias i hasła.
4. Zweryfikuj, czy `package/unique_name` jest unikalne w Google Play. Domyślna wartość `org.szeptperuna.game` jest nazwą roboczą i należy ją potwierdzić przed pierwszą publikacją.

## Budowanie

Po konfiguracji podpisu uruchom w katalogu projektu:

```powershell
& '.\tools\Godot\Godot_v4.5.2-stable_win64_console.exe' --headless --path . --export-release Android 'builds\SzeptPeruna-1.0.0.apk'
```

Do wydania nowej gry w Google Play użyj presetu `Android AAB`, skonfiguruj podpis wydawniczy i wyeksportuj plik `.aab`. Testowy APK ani AAB podpisany kluczem debug nie są artefaktami wydawniczymi.

## Kontrola artefaktu

- instalacja na telefonie testowym;
- uruchomienie bez internetu;
- zapis postępu po zamknięciu aplikacji;
- poprawna nazwa, wersja i orientacja;
- test podpisanego artefaktu w Google Play Console.

## Rozmiar i kontrola zasobów

Preset Android wyklucza materiały robocze, arkusze źródłowe i starsze warianty zasobów. Sześć zestawów starszych grafik budynków zastępują kompletne zestawy w `art/environments/building_levels_bright`; komplet należy zachować przy ich aktualizacji. Ustawienia importu portretów bohaterów, awatarów oraz teł drzewek używają kompresji stratnej z jakością 0,9. Oryginalne pliki PNG pozostają bez zmian.

Po eksporcie sprawdź rzeczywistą paczkę APK:

```powershell
.\tools\verify_android_package.ps1 -ApkPath 'ścieżka\do\gry.apk'
```

Skrypt sprawdza zasoby odwoływane w kodzie, główne zasoby ładowane dynamicznie, muzykę, dane kampanii i biblioteki obu architektur. Nie zastępuje instalacji i testu na urządzeniu. Testową kompresję 81 tekstur można sprawdzić przez `tests/compact_textures_test.gd`; porównuje próbki z plikami źródłowymi.
