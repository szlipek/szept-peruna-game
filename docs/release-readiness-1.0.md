# Szept Peruna — gotowość do wydania 1.0

Stan: 25 września 2026.

## Zweryfikowane w projekcie

- Godot 4.5.2 uruchamia projekt w trybie headless bez błędów składni.
- `tools/verify-release.ps1` przechodzi poprawnie.
- Test kampanii sprawdza 2000 poziomów, ciągłość identyfikatorów, cele, krainy, nagrody, strażników i wielkich bossów.
- Test match‑3 tworzy 100 czystych, grywalnych plansz i sprawdza limit przeszkód.
- Test zapisu symuluje uszkodzone dane i potwierdza bezpieczne odzyskanie grywalnego stanu.
- Projekt ma numer `1.0.0`, ikonę aplikacji, preset Android i konfigurację pionowej orientacji.
- Gra zawiera lokalny zapis, reset postępu, pomoc w grze, przełącznik dźwięków, proceduralne SFX i dokumentację praktyk danych.

## Nieweryfikowalne bez środowiska zewnętrznego

- eksport APK/AAB: lokalnie brakuje Android export templates dla Godot 4.5.2 i Java SDK;
- podpis produkcyjny: wymaga prywatnego keystore, aliasu oraz haseł właściciela;
- testy dotykowe, wydajność i wygląd na realnych telefonach/tablecie;
- konto Google Play, unikalny identyfikator pakietu, adres kontaktowy i opublikowany adres polityki prywatności;
- zamknięty test Google Play oraz deklaracje konsoli.

## Następny krok właściciela

1. Zainstalować Android export templates dla Godot 4.5.2 i Java SDK.
2. Skonfigurować własny keystore oraz potwierdzić identyfikator pakietu.
3. Zbudować podpisany AAB według `docs/android-release.md`.
4. Przejść checklistę urządzeń w `docs/release-1.0-checklist.md`.
5. Wysłać build do zamkniętego testu Google Play.

Po wykonaniu tych kroków należy ponownie uruchomić `tools/verify-release.ps1` i przeprowadzić test na urządzeniu przed oznaczeniem artefaktu jako publicznej wersji 1.0.
