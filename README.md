# Szept Peruna

Rozwijana wersja 1.0 gry 2D match-3 RPG w Godot 4. Kampania łączy ręcznie zaprojektowane pierwsze 100 poziomów z kolejnymi etapami, treningiem bohaterów, osadą i walką turową.

## Szybkie uruchomienie

- Dwuklik na `uruchom-gre.bat` uruchamia prototyp.
- Dwuklik na `otworz-w-godot.bat` otwiera projekt w edytorze Godot.
- W edytorze użyj `F5`, aby uruchomić grę, albo `F6`, aby uruchomić bieżącą scenę.

Po uruchomieniu wybierz **GRAJ**, aby kontynuować od ostatnio odblokowanego poziomu, albo otwórz mapę krainy.

Lokalny Godot 4.5.2 znajduje się w `tools/Godot/`. To przenośna instalacja — nie wymaga instalatora ani konta administratora.

## Sterowanie

- przeciągnij kafelek na sąsiednie pole **albo** kliknij kafelek, a potem sąsiedni, aby utworzyć połączenie co najmniej trzech symboli;
- **Lada**: po zebraniu ośmiu liści wybierz kolumnę do zniszczenia;
- **Brun**: po zebraniu siedmiu ogni wybierz środek obszaru 3×3;
- **Mieta**: po zebraniu siedmiu wód usuwa wszystkie kafelki wody i leczy drużynę;
- **Boostery**: przycisk na dole otwiera trzy jednorazowe efekty: Młot (3×3), Grom Peruna (rząd) i Wiatr Gaju (wszystkie znaki wybranego typu).

Na poziomie 5 walczysz z Leszym: ogień i runy zadają mu obrażenia, woda odnawia zdrowie drużyny, a liście wzmacniają tarczę.

Gra ma lekkie proceduralne efekty dźwiękowe dla ruchów, kombinacji, leczenia, obrażeń i zwycięstwa. Nie korzystają one z zewnętrznych plików audio, więc działają także offline.
W menu `?` można je wyłączyć; ustawienie zostaje zapamiętane lokalnie.

Przycisk **Osada ›** pozwala wydać monety i drewno na trwałe ulepszenia budynków.

W menu głównym wybierz **Trening bohaterów**, aby rozegrać jedną z trzech powtarzalnych walk bez energii i bez ryzyka dla postępu. PD trafiają wyłącznie do aktywnego składu, więc można przygotować drużynę przed trudniejszą wyprawą.

Na karcie posiadanego bohatera przycisk **TALENTY** otwiera drzewko trzech umiejętności. Każdy poziom od 2 do 50 daje punkt; kolejne węzły wymagają rozwinięcia poprzednich. Dotknięcie talentu pokazuje efekt i wymagania, a osobny przycisk odblokowuje go lub ulepsza. Wszystkie 300 węzłów mają własne ikony PNG i łącznie 1200 wariantów rang. Szczegóły 25 drzewek są w `docs/sciezki-umiejetnosci-bohaterow.md`.

## Reset lokalnego postępu

W prawym górnym rogu menu głównego wybierz **RESET**, a następnie **POTWIERDŹ**. Resetuje to wyłącznie lokalny zapis: poziomy, waluty, bohaterów, budynki i gwiazdki. Nie można go cofnąć.

Przycisk **Mapa** na dole ekranu otwiera Dębowe Pogranicze i pozwala wybrać odblokowany poziom. Pierwsza kraina zawiera obecnie 20 poziomów na czterech stronach mapy.

Po ukończeniu poziomu wynik jest oceniany od jednej do trzech gwiazdek zależnie od pozostałych ruchów.

## Testy i wydanie

Scenariusze odbioru planszy: `docs/etap-1-testy.md`. Lista funkcji oraz testów wymaganych przed wydaniem: `docs/release-1.0-checklist.md`.
Zakres lokalnego zapisu i brak funkcji sieciowych w wersji 1.0 opisuje `docs/data-practices-1.0.md`.
Gotowa treść polskiej karty Google Play znajduje się w `docs/google-play-listing-pl.md`.
Aktualny podział na elementy zweryfikowane i wymagające środowiska wydaniowego: `docs/release-readiness-1.0.md`.
