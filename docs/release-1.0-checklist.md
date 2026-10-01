# Szept Peruna — kontrola wydania 1.0

Ten dokument rozdziela elementy, które można sprawdzić automatycznie w projekcie, od testów wymagających prawdziwego telefonu i testera.

## Zakres wersji 1.0

- kampania 1–2000 z ręcznie przygotowanymi poziomami 1–100 oraz dalszymi etapami opartymi na zasadach;
- walka turowa, drużyna, trening, osada, boostery i lokalny zapis;
- cele: walka, przetrwanie, oczyszczenie, zbieranie bursztynu/run oraz wynik;
- dziesięć krain, walki strażników krain i wielkich bossów;
- reset lokalnego postępu dostępny z menu;
- polski interfejs w pionowej orientacji telefonu.

## Kontrola przed kompilacją

- [ ] Godot uruchamia projekt bez `SCRIPT ERROR` i `Parse Error`.
- [ ] `tools/verify-release.ps1` potwierdza składnię oraz spójność 2000 poziomów kampanii.
- [ ] Poziomy 1, 20, 21, 50, 100, 101, 125, 150, 200 i 300 można otworzyć po odblokowaniu.
- [ ] Każdy z pięciu celów poziomu może zostać ukończony.
- [x] Dane poziomu są zgodne z pętlą gry: etap z przeciwnikami używa celu `defeat_enemy`, a poziom zadaniowy nie zawiera przeciwników.
- [ ] Prawidłowy ruch nigdy nie resetuje planszy; nieprawidłowy nie zużywa ruchu.
- [x] Automatyczny test tworzy 100 plansz i potwierdza brak gotowych połączeń, legalny ruch oraz limit 48 przeszkód nawet dla bardzo późnego poziomu.
- [ ] Po ruchu gracza plansza kończy spadanie kafelków przed ruchem przeciwnika; po ruchu przeciwnika — przed odblokowaniem wejścia gracza.
- [ ] Obrońca, mistyk, zwiadowca i napastnik zachowują się zgodnie z opisem.
- [ ] Nagrody, gwiazdki, Iskry, Znaki wydarzenia, poziomy bohaterów i osada pozostają po restarcie aplikacji.
- [x] Automatyczny test symuluje stary/uszkodzony zapis: Lada pozostaje dostępna, skład ma 1–3 posiadanych bohaterów, a waluty i poziomy są bezpiecznie ograniczone.
- [ ] Reset wymaga drugiego dotknięcia i zeruje cały lokalny zapis.
- [ ] Przycisk `?` w menu otwiera czytelną instrukcję, a `ROZUMIEM` zamyka ją bez rozpoczęcia ani resetowania poziomu.
- [ ] Efekty dźwiękowe poprawnego/błędnego ruchu, kombinacji, obrażeń, leczenia i zwycięstwa są słyszalne, ale nie są zbyt głośne.
- [ ] W instrukcji `?` przełącznik `DŹWIĘKI` włącza i wyłącza efekty, a ustawienie pozostaje po restarcie gry.

## Testy urządzeń

- [ ] Android 8+ / słabszy telefon: 10 kolejnych poziomów bez zawieszenia.
- [ ] Telefon 16:9 oraz wysoki 20:9: bez obciętych przycisków, tekstów i portretów.
- [ ] Tablet: plansza oraz nakładki zachowują czytelność.
- [ ] Dotyk: wybór dwóch kafelków, przeciąganie, boostery, umiejętności i przyciski wyników.
- [ ] Osoba testująca bez instrukcji słownej potrafi znaleźć `?`, rozumie pierwszy ruch i wraca z instrukcji do menu.
- [ ] Wznowienie aplikacji po zablokowaniu ekranu oraz po powrocie z tła.
- [ ] Gra w trybie offline, ponowne uruchomienie i zachowanie zapisu.
- [ ] Gra uruchamia się bez zewnętrznych plików audio; proceduralne efekty dźwiękowe działają także offline.

## Materiały publikacyjne — wymagają decyzji właściciela projektu

- [x] ikona aplikacji jest podłączona w `project.godot` (`art/ui/app_icon_szept_peruna_v01.png`); przed publikacją sprawdź wygląd w launcherze Androida;
- [ ] podpisany klucz wydania Android oraz identyfikator pakietu;
- [ ] preset Android został skonfigurowany zgodnie z `docs/android-release.md` i daje się wyeksportować jako podpisany artefakt;
- [ ] lokalny Godot ma zainstalowane szablony eksportu Android 4.5.2 oraz skonfigurowane Java SDK;
- [ ] zrzuty ekranu sklepu i opis gry;
- [ ] polityka prywatności oraz adres kontaktowy;
- [x] Zaktualizowano opis faktycznych praktyk danych dla wersji offline: `docs/data-practices-1.0.md`.
- [ ] potwierdzenie źródeł/licencji wszystkich assetów;
- [ ] test zamknięty Google Play i wypełniona ankieta bezpieczeństwa danych.
- [x] Przygotowano polską treść karty sklepowej i plan zrzutów: `docs/google-play-listing-pl.md`.

## Kryterium wydania

Wersję 1.0 można oznaczyć jako gotową po zaliczeniu kontroli przed kompilacją i testów urządzeń. Materiały publikacyjne, konto Google Play i klucz podpisujący wymagają danych właściciela projektu — nie są tworzone automatycznie przez grę.
