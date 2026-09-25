# Szept Peruna 1.0 — praktyki danych

Stan dokumentu: 25 września 2026. Dokument opisuje aktualny kod wersji 1.0 i jest materiałem dla właściciela projektu podczas wypełniania deklaracji Google Play.

## Co zapisuje gra

Gra zapisuje lokalnie na urządzeniu plik postępu Godot (`user://progress.cfg`). Zawiera on wyłącznie dane rozgrywki:

- odblokowany poziom, gwiazdki i ukończone wprowadzenia do krain;
- monety, drewno, doświadczenie, Iskry Peruna i Znaki wydarzenia;
- stan rekrutacji, poziomy, doświadczenie oraz aktywny skład bohaterów;
- poziomy budynków;
- preferencję włączenia efektów dźwiękowych.

## Czego wersja 1.0 nie robi

Na podstawie przeglądu kodu projektu wersja 1.0:

- nie zawiera żądań sieciowych ani połączeń z serwerem;
- nie używa analityki, reklam, identyfikatorów reklamowych ani zewnętrznych SDK;
- nie tworzy konta gracza i nie wymaga adresu e-mail;
- nie zbiera lokalizacji, kontaktów, zdjęć, mikrofonu ani danych wrażliwych;
- nie przesyła lokalnego postępu poza urządzenie.

## Kontrola gracza

W menu głównym gracz może wybrać `RESET`, a następnie `POTWIERDŹ`. Usuwa to lokalny postęp gry i rozpoczyna kampanię od początku. Preferencja dźwięków pozostaje lokalnie zachowana.

## Przed publikacją

Właściciel projektu powinien opublikować tę treść pod własnym adresem polityki prywatności oraz ponownie zweryfikować deklarację, jeżeli do gry zostaną dodane reklamy, analityka, logowanie, płatności lub synchronizacja chmurowa. Każda z tych funkcji zmienia zakres wymaganych deklaracji i polityki.
