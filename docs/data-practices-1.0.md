# Szept Peruna 1.0 — praktyki danych

Stan dokumentu: 15 października 2026. Dokument opisuje aktualny kod projektu i jest materiałem dla właściciela projektu podczas wypełniania deklaracji Google Play.

## Co zapisuje gra

Gra zapisuje lokalnie na urządzeniu plik postępu Godot (`user://progress.cfg`). Zawiera on wyłącznie dane rozgrywki:

- odblokowany poziom, gwiazdki i ukończone wprowadzenia do krain;
- monety, drewno, doświadczenie, Iskry Peruna i Znaki wydarzenia;
- stan rekrutacji, poziomy, doświadczenie oraz aktywny skład bohaterów;
- poziomy budynków;
- preferencję włączenia efektów dźwiękowych.

## Integracja reklam

Projekt zawiera integrację Google Mobile Ads SDK przez plugin Godot AdMob. W edytorze i na platformach bez natywnego pluginu reklamy są niedostępne. Konfiguracja Androida używa identyfikatorów demonstracyjnych Google (`is_real = false`), więc nie generuje przychodu.

Po dodaniu własnych identyfikatorów AdMob SDK będzie wysyłać żądania reklamowe. Google Mobile Ads może przetwarzać dane urządzenia i identyfikatory używane do emisji, pomiaru i ochrony przed nadużyciami zgodnie z ustawieniami wydawcy, zgodą użytkownika i polityką Google. Gra pyta SDK o status zgody UMP przed inicjalizacją; jeśli wymagana zgoda nie może zostać uzyskana, reklamy pozostają wyłączone w tej sesji.

Nagroda z reklamy przyznawana jest wyłącznie po sygnale SDK potwierdzającym obejrzenie reklamy. Lokalny postęp nadal jest zapisywany w `user://progress.cfg`; gra nie ma własnego konta gracza ani własnego serwera.

## Pozostałe dane

Gra nie wymaga e-maila i nie zbiera lokalizacji, kontaktów, zdjęć ani dźwięku z mikrofonu. Nie ma własnej analityki ani logowania.

## Kontrola gracza

W menu głównym gracz może wybrać `RESET`, a następnie `POTWIERDŹ`. Usuwa to lokalny postęp gry i rozpoczyna kampanię od początku. Preferencja dźwięków pozostaje lokalnie zachowana.

## Przed publikacją

Właściciel projektu powinien opublikować zaktualizowaną politykę pod własnym adresem, skonfigurować komunikaty prywatności i sprawdzić aktualne odpowiedzi Google Play Data safety dla użytej wersji SDK i regionów dystrybucji. Włączenie prawdziwych reklam (`is_real = true`) wymaga uzupełnienia identyfikatorów aplikacji i jednostek reklamowych. Integracja płatności i synchronizacji chmurowej nie jest obecnie aktywna; ich dodanie wymaga kolejnej aktualizacji polityki i deklaracji.
