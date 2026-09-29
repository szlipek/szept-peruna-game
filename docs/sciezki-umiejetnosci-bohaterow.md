# Drzewka umiejętności bohaterów

Wdrożone drzewka obejmują 25 bohaterów. Każdy ma trzy nazwane gałęzie: **Moc**, **Opieka** i **Splot**. Każdy z 300 talentów ma własny rastrowy plik PNG z malowanym medalionem w stylu gry oraz od 3 do 5 wariantów rangi. Łącznie projekt zawiera 1200 wariantów ikon. W karcie bohatera przycisk `TALENTY` otwiera drzewko. Dotknięcie węzła pokazuje dokładny efekt na rangę i wymagania; dopiero przycisk `ODBLOKUJ` albo `ULEPSZ` wydaje punkt.

## Punkty i zależności

- Jeden punkt za każdy poziom od 2 do 50, niezależnie od tego, czy awans nastąpił po walce, treningu czy kupieniu poziomu za monety.
- W każdej gałęzi są cztery węzły z limitami rang `3 → 4 → 4 → 5`, razem 16 punktów. Trzy pełne gałęzie kosztują 48 punktów. Poziom 50 daje 49 punktów, więc jeden pozostaje na przyszłe rozszerzenie.
- Kolejne węzły wymagają pełnego rozwinięcia poprzedniego w tej samej gałęzi. Dodatkowe progi poziomu to 2, 10, 22 i 38. Mistrzostwa nie można kupić wcześniej niż na poziomie 38.
- Wydane punkty zapisują się lokalnie. Stary zapis dostaje puste drzewka i punkty odpowiadające już zdobytemu poziomowi. Uszkodzone lub nadmiarowe rangi są naprawiane przy wczytaniu.

## Działanie rang

Każda ranga dodaje efekt opisany przy węźle. „Własny znak” oznacza żywioł przypisany bohaterowi w tabeli. Efekty aktywnych członków drużyny sumują się podczas kombinacji. Premia do maksymalnego zdrowia jest naliczana na początku bitwy.

| Gałąź | Zalążek, poziom 2 | Wzmocnienie, poziom 10 | Przysięga, poziom 22 | Mistrzostwo, poziom 38 |
|---|---|---|---|---|
| Moc | +1 obrażenie za własny znak | +3 obrażenia przy kombinacji 4+ | +4 obrażenia w kaskadzie | +8 obrażeń za własny znak |
| Opieka | +1 tarczy za własny znak | +2 leczenia bohatera przy własnym znaku | +3 maksymalnego zdrowia | +2 tarczy i leczenia za własny znak |
| Splot | +2 punkty za własny znak | +2 obrażenia za własny znak w kombinacji 4+ | +4 punkty w kaskadzie | +4 obrażenia i punkty za własny znak |

## Gałęzie bohaterów

| Bohater | Znak | Moc | Opieka | Splot |
|---|---|---|---|---|
| Lada | liście | Łuk Gromu | Straż Dębu | Splot Korzeni |
| Brun | ogień | Żar Kowala | Pancerz Kuźni | Kowadło Burzy |
| Mieta | woda | Źródło Rosy | Krąg Życia | Wodny Szept |
| Wszebor | ogień | Ogień Straży | Żelazna Warta | Popielny Znak |
| Boruta | ogień | Rozłupanie | Kamienna Skóra | Korzeń Skały |
| Dobromir | liście | Pieśń Dębu | Osłona Korzeni | Zielony Chór |
| Milena | woda | Rosnąca Fala | Deszcz Rosy | Lustrzana Toń |
| Radomir | bursztyn | Bursztynowy Cios | Złota Warta | Blask Skarbu |
| Witosz | liście | Szept Wiatru | Lekki Krok | Wir Liści |
| Jagna | liście | Zielony Krąg | Ziołowa Opieka | Korona Gaju |
| Rada | bursztyn | Dar Bursztynu | Złota Osłona | Skarb Przodków |
| Welesa | runy | Mgiełka Bagien | Cicha Zasłona | Runiczny Zmierzch |
| Zorya | runy | Jutrzenka | Świetlista Straż | Pierwszy Znak |
| Jaromir | ogień | Przełamanie | Straż Przodków | Ostrze Rodu |
| Mściwoj | ogień | Ostrze Gromu | Tarcza Żaru | Burzowy Szlak |
| Dobrawa | runy | Tkanie Run | Runiczna Tarcza | Nić Losu |
| Perunika | runy | Piorunowa Strzała | Burzowa Osłona | Szlak Błyskawic |
| Czernik | runy | Złamanie Klątwy | Cień Kurhanu | Pieczęć Nawi |
| Mirka | woda | Dar Pokoju | Łagodna Fala | Źródło Zgody |
| Włodzimierz | bursztyn | Kamienny Znak | Mur Przodków | Skała Gromu |
| Żywia | runy | Gniew Burzy | Oddech Życia | Korona Piorunów |
| Mokosza | liście | Matka Ziemi | Opieka Gaju | Splot Żywiołów |
| Stribóg | runy | Władca Wichru | Skrzydło Wiatru | Burza Znaków |
| Swaróg | ogień | Kuźnia Słońca | Słoneczny Mur | Ognisty Krąg |
| Weles | runy | Władca Przemian | Zasłona Nawi | Splot Światów |

Obecne ruchy specjalne Lady, Bruna i Miety pozostają dostępne. Drzewka rozwijają efekty kombinacji oraz zdolność przetrwania drużyny. Nowe aktywne ruchy i ich osobny wybór wymagają późniejszego balansu interfejsu walki.
