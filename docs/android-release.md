# Android — wydanie Szept Peruna 1.0.0

Projekt ma preset `Android` w `export_presets.cfg`. Jest ustawiony na pionową aplikację, nazwę **Szept Peruna**, wersję `1.0.0`, kod wersji `1` oraz architektury `armeabi-v7a` i `arm64-v8a`.

Ikona aplikacji jest ustawiona w `project.godot` jako `art/ui/app_icon_szept_peruna_v01.png`. Jest to ilustracja wykonana na potrzeby projektu i powinna zostać sprawdzona na rzeczywistym launcherze Androida przed publikacją.

## Stan lokalnego środowiska

Próba eksportu z 25 września 2026 potwierdziła, że preset jest widoczny dla Godot. Zatrzymała się jednak przed budowaniem, ponieważ lokalne środowisko nie ma szablonów `android_debug.apk` i `android_release.apk` dla Godot 4.5.2 oraz nie ma skonfigurowanej ścieżki Java SDK. To zależność środowiska, nie błąd projektu.

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

Do Google Play preferowany jest pakiet AAB. Jeśli wybrany workflow tego wymaga, zmień format eksportu w Godot na Android App Bundle, zbuduj plik `.aab` i przetestuj go w zamkniętym teście Play.

## Kontrola artefaktu

- instalacja na telefonie testowym;
- uruchomienie bez internetu;
- zapis postępu po zamknięciu aplikacji;
- poprawna nazwa, wersja i orientacja;
- test podpisanego artefaktu w Google Play Console.
