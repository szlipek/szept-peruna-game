# Szept Peruna — dokument startowy

## Cel aktualnego etapu

Faza A ma potwierdzić, że sama plansza logiczna jest przyjemna. Prototyp zawiera pięć krótkich poziomów, Ladę oraz tymczasowe, czytelne symbole pięciu żywiołów.

## Decyzje przyjęte na start

- Silnik: Godot 4.x i GDScript.
- Orientacja: pionowa, projektowana dla telefonu 540×960.
- Plansza: 8×8.
- Wejście: przeciągnięcie lub zamiana dwóch sąsiednich kafelków.
- Warunek zwycięstwa: wymagany wynik przed wyczerpaniem ruchów.
- Lada: kafelki liści ładują jej Strzałę Peruna; po ośmiu ładunkach gracz wybiera kolumnę, którą zdolność niszczy bez kosztu ruchu.
- Booster testowy: na początku poziomu gracz ma jeden Młot bursztynowy, niszczący obszar 3×3 bez kosztu ruchu.
- Dane poziomów: `data/levels.json`; mechanika ma awaryjną konfigurację tylko na wypadek braku lub błędu pliku danych.
- Nagrody: ukończenie poziomu przyznaje zdefiniowane w danych monety, drewno i PD. Portfel oraz odblokowany poziom są zapisywane lokalnie w `user://progress.cfg`.
- Walka, osada, reklamy i finalna oprawa: poza prototypem; zostaną dodane dopiero po teście grywalności.

## Zawartość pięciu poziomów prototypu

| Poziom | Nazwa | Ruchy | Cel punktowy |
|---:|---|---:|---:|
| 1 | Pierwszy szept | 18 | 600 |
| 2 | Ślad w mchu | 17 | 850 |
| 3 | Żar kowadła | 16 | 1050 |
| 4 | Źródło Miety | 15 | 1250 |
| 5 | Próba dębu | 14 | 1500 |

## Jak uruchomić

1. Otwórz folder projektu w Godot 4.x.
2. Uruchom scenę główną (`scenes/puzzle_level.tscn`).
3. Zamieniaj sąsiednie symbole. Pomyślne ukończenie poziomu odblokowuje kolejny i zapisuje postęp lokalnie.

## Odbiór Etapu 1

Protokół uruchomieniowy i test z nowymi graczami znajduje się w `docs/etap-1-testy.md`. Mechanika pilnuje teraz, by po losowaniu i po kaskadach plansza zawierała przynajmniej jeden prawidłowy ruch.

## Start Etapu 2

Poziom 5 jest pierwszą walką z Leszym. Kafelki ognia i run zadają obrażenia, woda leczy drużynę, a liście tworzą tarczę i ładują Strzałę Peruna. Leszy odpowiada atakiem po prawidłowym ruchu gracza. Drużyna ma trzy aktywne umiejętności: Lada niszczy kolumnę, Brun obszar 3×3 z premią do obrażeń, a Mieta zamienia wszystkie kafelki wody w leczenie.

Każdy bohater zdobywa PD po wygranym poziomie. Przycisk **Drużyna** otwiera ekran z poziomem, postępem PD i ulepszeniem za monety. Poziom bohatera zwiększa wytrzymałość drużyny lub siłę jego umiejętności.

## Start Etapu 3

Przycisk **Osada** otwiera pierwszą wersję rozbudowy Dębowego Pogranicza. Domostwa, Kuźnia, Chata Zielarki, Święty Gaj, Spichlerz i Wieża Peruna mają trwałe poziomy, koszt monety/drewno oraz premię do gry.

## Start Etapu 4

Mapa Dębowego Pogranicza pokazuje dziesięć połączonych ścieżką poziomów na dwóch stronach. Dostępne są tylko poziomy odblokowane przez ukończenie poprzedniej ścieżki. Poziom 10 zawiera walkę z Wilkiem Cienia.

Poziomy 6–10 wprowadzają korzenie, kamienie i klątwy. Przeszkoda potrzebuje odpowiednio jednego, dwóch lub trzech trafień kombinacją albo umiejętnością, zanim zniknie z planszy. Poziomy 11–20 dodają cele zbierania bursztynu i run oraz dwa kolejne starcia z przeciwnikami.

## Start Etapu 5

Tło `art/environments/environment_debowe_pogranicze_v01.png` wyznacza pierwszy wzorzec wizualny: malarskie słowiańskie lasy, bursztynowe światło, kamienne totemy oraz spokojniejszy środek pod interfejs i planszę. Rejestr źródeł assetów jest w `docs/licencje.md`.

Portret Leszego oraz panorama osady rozwijają ten sam wzorzec: naturalne drewno, mech, liście dębu, złote światło i przygaszony turkus w cieniach.

## Boostery MVP

Każdy poziom udostępnia po jednym Młocie bursztynowym (obszar 3×3), Gromie Peruna (rząd) i Wietrze Gaju (wszystkie kafelki wybranego typu). Wszystkie działają bez kosztu ruchu.

## Gwiazdki

Zwycięstwo daje 1–3 gwiazdki zależnie od liczby pozostałych ruchów. Najlepszy wynik jest zapisywany lokalnie i widoczny na mapie poziomów.

## Następny krok

Przeprowadzić krótkie testy bez instrukcji: czas zrozumienia pierwszego ruchu i aktywacji umiejętności Ledy, odsetek ukończeń poziomu 1 oraz wrażenie z kaskad. Po nich należy dostroić cele, limity ruchów i koszt umiejętności.

## Krąg treningowy

Menu główne udostępnia trzy powtarzalne walki treningowe: Mchy, Żar i Straż Gaju. Nie wymagają energii, złota ani odblokowania poziomu; porażka nie odbiera postępu. Wygrana daje przede wszystkim PD wyłącznie aktywnym bohaterom oraz małą nagrodę w monetach. To celowa ścieżka powrotu dla osoby, która utknie w kampanii — rozwój drużyny nie zależy od płatności ani wcześniejszego zapasu waluty.

Ekran porażki zawiera skrót do Kręgu treningowego, a karty drużyny pokazują poziom oraz PD wymagane do kolejnego poziomu.

Pierwsze pięć starć kampanii ma łagodniejsze zdrowie i atak wrogów oraz dodatkowe ruchy. Widoczna kombinacja przeciwnika nadal jest elementem napięcia, ale jej obrażenia zostały ograniczone do 10% wartości technicznej kaskady, aby nie kończyła walki jednym ruchem.

## Role przeciwników

Przeciwnicy mają role widoczne po przytrzymaniu portretu w walce. **Obrońca** osłania pozostałych, zmniejszając otrzymywane przez nich obrażenia o 45%, dlatego warto wyeliminować go najpierw. **Wsparcie** leczy najbardziej rannego żywego sojusznika po turze gracza. **Napastnik** zadaje wysokie obrażenia, a **zwiadowca** jest prostym celem bez dodatkowej zdolności. Przeciwnik wybiera najlepszą legalną zamianę z aktualnej planszy — nie tworzy nowych kafelków.

## Kampania rozszerzona

Kampania zawiera 70 poziomów w pięciu krainach. Co piąty poziom jest oznaczonym na mapie etapem bossa; pierwsze ukończenie takiego etapu daje Iskrę Peruna. Zwykłe starcia nie przyznają Iskier, dzięki czemu rzadka waluta zachowuje swoją wartość.

## Projekt Etapu 6 — drużyna i walka turowa

### Pętla walki

- Gracz zaczyna z jedną bohaterką: **Ladą**. Przed poziomem wybiera od 1 do 3 posiadanych bohaterów.
- Każdy prawidłowy ruch na planszy należy do kolejnego żywego bohatera w kolejności składu. Widoczny wskaźnik pokazuje, czyja trwa tura.
- Każda kombinacja zadaje obrażenia. Bazowo trzy znaki zadają 10 obrażeń, a każdy kolejny znak w grupie dodaje 5.
- Żywioł zgodny z bohaterem w turze wzmacnia obrażenia o 100%: Lada — liście, Brun — żar, Mieta — woda. Bursztyn daje +50% niezależnie od bohatera, a runa +25% oraz ładuje zdolność.
- Po ruchu i zakończeniu kaskad każdy żywy wróg atakuje drużynę. Tarcza pochłania obrażenia przed zdrowiem.
- Wygrana następuje wyłącznie po pokonaniu wszystkich jednostek przeciwnika. Porażka następuje po spadku zdrowia drużyny do zera.

### Przeciwnicy

- Poziom zawiera od 1 do 3 niezależnych przeciwników, każdy z własnym zdrowiem, atakiem, nazwą i portretem.
- Wrogowie mogą mieć role: zwykły wojownik, obrońca z tarczą i uzdrowiciel. Pierwsza wersja wdraża zdrowie oraz atak; role specjalne są kolejną iteracją.
- Cele punktowe i zbierackie zostaną przekształcone w misje bojowe, aby główny warunek wygranej był jednoznaczny.

### Bohaterowie i rekrutacja

| Bohater | Dostęp | Żywioł | Zdolność |
|---|---|---|---|
| Lada | start | liść | Strzała Peruna — niszczy kolumnę |
| Brun | 1 200 monet | żar | Uderzenie Kowala — obszar 3×3 |
| Mieta | 1 500 monet | woda | Krąg Uzdrowienia — leczenie i oczyszczenie wody |
| Żywia | 2 000 monet + drewno | bursztyn | Bursztynowa Bariera — duża tarcza drużyny |
| Radogost | nagroda z wydarzenia / żetony | runa | Pieśń Run — wzmacnia następną kombinację |
| Żmij | bohater legendarny | żar/runa | Płomień Żmija — obrażenia wszystkich wrogów |

Każda zdolność ma poziomy. Ulepszenia zwiększają obrażenia, leczenie, tarczę albo skracają ładowanie; nie będą sprzedawały obowiązkowej siły potrzebnej do ukończenia kampanii.

### Waluty

- **Monety**: rekrutacja bohaterów standardowych i ulepszenia.
- **Drewno**: rozwój osady oraz wymaganie pomocnicze przy wybranych rekrutacjach.
- **Iskry Peruna**: rzadka waluta za pierwsze pokonanie bossa, wyzwania i wydarzenia. Służy do bohaterów legendarnych oraz kosmetyków.
- Bohaterowie premium mogą być oferowani za realną płatność, ale ich alternatywna ścieżka zdobycia za Iskry Peruna musi być jawna i osiągalna w grze. Zakupy będą wdrażane dopiero razem z systemem sklepu platformy i informacją o cenie.
