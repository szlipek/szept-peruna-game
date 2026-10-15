# Szept Peruna

Gra 2D match-3 RPG w Godot 4. Kampania prowadzi przez krainy pełne wrogów i bossów: każda wyprawa kończy się pokonaniem przeciwników albo porażką drużyny. Rozwijaj bohaterów, dobieraj skład, odkrywaj bestiariusz i rozbudowuj osadę.

## Szybkie uruchomienie

- Dwuklik na `uruchom-gre.bat` uruchamia grę.
- Dwuklik na `otworz-w-godot.bat` otwiera projekt w edytorze Godot.
- W edytorze użyj `F5`, aby uruchomić grę, albo `F6`, aby uruchomić bieżącą scenę.

Po uruchomieniu wybierz **GRAJ**, aby kontynuować od ostatniego odblokowanego poziomu, albo otwórz mapę i wybierz odblokowaną walkę.

Lokalny Godot 4.5.2 znajduje się w `tools/Godot/` i działa bez instalatora.

## Początek przygody

Nowy gracz przechodzi krótki, możliwy do pominięcia wstęp i wybiera jeden z 30 kosmetycznych awatarów. Pierwsza wyprawa rozpoczyna się z Ladą. Samouczek uczy dopasowywania znaków, atakowania, leczenia i ochrony drużyny.

Pierwsze pięć poziomów ma łagodniejszy wzrost zdrowia i siły wrogów. Po poziomie 1 można bezpłatnie dołączyć Bruna albo Miętę, a po poziomie 5 kolejnego towarzysza. Awatar, skład i postęp zapisują się lokalnie.

## Walka

Każdy poziom kampanii jest walką z wrogami. Zwyciężasz po pokonaniu wszystkich przeciwników; porażka następuje po utracie całego zdrowia drużyny. Jedna kasacja zadaje obrażenia wybranemu wrogowi, a nadmiar obrażeń nie przechodzi na kolejnego przeciwnika. Obrońcy osłaniają sojuszników, zwiadowcy atakują rannych bohaterów, a wsparcie leczy wrogów.

- Przeciągnij kafelek na sąsiednie pole **albo** wybierz dwa sąsiednie kafelki, aby połączyć co najmniej trzy takie same znaki.
- Czwórki, piątki, kwadraty i kaskady zadają dodatkowe obrażenia.
- **Lada** ładuje Strzałę Peruna liśćmi, **Brun** ładuje Uderzenie Kowala ogniem, a **Mięta** ładuje Krąg Uzdrowienia wodą.
- Boostery Młot, Grom Peruna i Wiatr Gaju pomagają przełamać obronę wrogów.
- Zwycięstwo daje trzy gwiazdki przy co najmniej 75% zdrowia drużyny, dwie przy co najmniej 40%, a jedną poniżej 40%. Najlepszy wynik pozostaje zapisany.

### Cele dodatkowe

Każda walka kampanii ma jeden opcjonalny cel: utworzyć kombinację co najmniej czterech znaków, użyć zdolności lub boostera albo wygrać z co najmniej 70% zdrowia drużyny. Pierwsze zaliczenie celu na danym poziomie daje 150 monet. Cel nie zastępuje zwycięstwa nad wrogami i nie jest wymagany do przejścia poziomu.

### Synergie drużyny

Niektóre pary bohaterów wzmacniają się w aktywnym składzie. Każda aktywna synergia zwiększa obrażenia o 8% oraz dodaje premię do leczenia i tarczy. Dostępne zestawienia są opisane na kartach bohaterów; liczba aktywnych synergii pojawia się w nagłówku walki.

## Dziennik bestii i krain

Otwórz ikonę księgi w menu głównym, aby przeglądać wpisy dla każdej krainy. Pierwszy udany ruch w walce odnotowuje spotkanie z przeciwnikiem, a zwycięstwo zwiększa licznik pokonań. Pełne odkrycie wrogów danej krainy przyznaje jednorazowo 250 monet. Wpisy i nagrody zapisują się lokalnie.

## Rozwój drużyny i osady

Menu **DRUŻYNA** pozwala zmieniać aktywny skład, rozwijać bohaterów i otwierać ich drzewka talentów. Każdy poziom bohatera od 2 do 50 daje punkt umiejętności; kolejne węzły wymagają rozwinięcia poprzednich. Szczegóły 25 drzewek są w `docs/sciezki-umiejetnosci-bohaterow.md`.

W **OSADZIE** wydawaj monety i drewno na trwałe ulepszenia budynków. **Krąg Treningowy** oferuje dodatkowe walki z przeciwnikami, które dają PD aktywnemu składowi.

## Powroty do gry i reklamy

Dzienny Dar Gaju daje regularną nagrodę bez kar za opuszczenie dnia. Dziennik, cele dodatkowe, gwiazdki, synergie i rozwój drużyny dodają opcjonalne cele między kolejnymi walkami.

Reklamy są skonfigurowane testowo. Pierwsze pięć poziomów nie wyświetla reklam; później reklama pełnoekranowa może pojawić się po czterech wygranych, najwyżej dwa razy dziennie. Od poziomu 6 dostępna jest dobrowolna reklama za dodatkowe 50% monet z nagrody, maksymalnie raz dziennie. Reklamy nie są wymagane do gry. Testowe identyfikatory Google nie generują przychodu; przed wydaniem potrzebne są własne identyfikatory AdMob i konfiguracja zgody. Instrukcję i politykę danych opisują `docs/monetyzacja-i-retencja.md` oraz `docs/data-practices-1.0.md`.

## Sterowanie i dźwięk

Ruch wykonasz przeciągnięciem znaku albo klikając dwa sąsiednie pola. Skład zmienisz w **DRUŻYNIE**, poziom wybierzesz na **MAPIE**, a budynki ulepszysz w **OSADZIE**. Menu `?` pozwala wyłączyć proceduralne efekty dźwiękowe; wybór zostaje zapamiętany lokalnie.

## Reset lokalnego postępu

W prawym górnym rogu menu głównego wybierz **RESET**, a następnie **POTWIERDŹ**. Reset usuwa poziomy, waluty, bohaterów, budynki, gwiazdki, postęp bestiariusza i nagrody za cele dodatkowe. Nie można go cofnąć.

## Dokumentacja

- Scenariusze planszy: `docs/etap-1-testy.md`.
- Lista funkcji i wydania: `docs/release-1.0-checklist.md`.
- Polityka danych: `docs/data-practices-1.0.md`.
- Karta Google Play: `docs/google-play-listing-pl.md`.
- Monetyzacja i dalszy rozwój: `docs/monetyzacja-i-retencja.md`.
- Gotowość wydania: `docs/release-readiness-1.0.md`.
