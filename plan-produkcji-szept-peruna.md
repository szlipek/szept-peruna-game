# Szept Peruna — plan produkcji gry

## 1. Założenia projektu

**Gatunek:** 2D puzzle RPG z rozwojem osady  
**Platforma:** Android jako pierwsza, później iOS  
**Roboczy tytuł:** Szept Peruna  
**Klimat:** słowiańskie lasy, duchy, bursztyn, święte gaje, Nawia i osady inspirowane folklorem  
**Model:** free-to-play z reklamami nagradzanymi i opcjonalnymi zakupami  
**Docelowa długość:** około 500 godzin zawartości po pełnej rozbudowie  

Główna pętla gry:

> Rozwiąż planszę logiczną → zdobądź surowce → ulepsz bohatera lub osadę → odblokuj kolejne poziomy.

Pierwszym celem nie jest stworzenie 500 godzin gry. Najpierw należy zbudować mały, kompletny fragment, który da się przetestować.

---

## 2. Zakres pierwszej wersji gry

Pierwsza grywalna wersja powinna zawierać:

- 20–30 poziomów logicznych;
- 1 region: Dębowe Pogranicze;
- 1 bossa: Leszy;
- 3 bohaterów;
- 5 rodzajów elementów na planszy;
- 3 boostery;
- 5–6 budynków osady;
- mapę poziomów;
- prosty system nagród;
- zapis postępu;
- jedną reklamę nagradzaną;
- podstawową muzykę i efekty dźwiękowe.

To jest wersja MVP, czyli minimalna wersja, która pozwala sprawdzić, czy gra jest przyjemna.

---

## 3. Etap 0 — decyzje projektowe

**Cel:** zamknąć podstawowe założenia przed produkcją.

### Do ustalenia

- silnik: Godot;
- rozdzielczość i orientacja ekranu;
- styl grafiki: ręcznie malowane 2D, bardziej komiksowy albo realistyczny;
- dokładna mechanika planszy;
- zdrowie i atak przeciwników na poziomie;
- sposób zdobywania surowców;
- nazwy walut;
- system energii i żyć;
- styl narracji;
- grupa docelowa.

### Rezultat etapu

Powstaje krótki dokument projektowy zawierający:

- opis gry w jednym akapicie;
- główną pętlę rozgrywki;
- opis pierwszych 30 poziomów;
- listę ekranów;
- listę pierwszych assetów;
- prosty schemat ekonomii.

---

## 4. Etap 1 — prototyp planszy logicznej

**Cel:** sprawdzić, czy sama rozgrywka logiczna działa.

### Do zaprogramowania

- plansza 7×7 lub 8×8;
- przesuwanie elementów;
- łączenie 3 lub więcej symboli;
- znikanie elementów i uzupełnianie planszy;
- liczenie punktów;
- walka do pokonania wrogów lub utraty zdrowia drużyny;
- warunki zwycięstwa;
- warunki przegranej;
- restart poziomu;
- jeden prosty booster.

Na tym etapie można używać kolorowych kwadratów i tymczasowych ikon. Nie należy jeszcze inwestować w finalne ilustracje.

### Kryterium ukończenia

Nowa osoba powinna w ciągu 30 sekund zrozumieć, co należy zrobić, a po kilku minutach chcieć rozegrać kolejny poziom.

---

## 5. Etap 2 — system RPG

**Cel:** połączyć wynik układanki z rozwojem bohaterów.

### Pierwsi bohaterowie

1. **Lada** — zwiadowczyni, wzmacnia liście i naturę.
2. **Brun** — kowal, wzmacnia ogień i niszczenie przeszkód.
3. **Mieta** — zielarka, leczy drużynę i wzmacnia wodę.

### Do zaprogramowania

- poziom bohatera;
- doświadczenie;
- punkty życia;
- siła drużyny;
- jedna umiejętność aktywna na bohatera;
- ekran wyboru drużyny;
- ekran szczegółów bohatera;
- prosty system ulepszania.

### Przykładowe działanie

- element ognia zadaje obrażenia;
- element wody leczy;
- liść daje ochronę;
- bursztyn ładuje umiejętność specjalną;
- runa tworzy kombinacje i wzmacnia relikty.

### Umiejętności niszczące kafelki

Bohaterowie powinni wpływać bezpośrednio na planszę, a nie tylko zwiększać statystyki. Każda aktywna umiejętność ma koszt energii, zasięg działania oraz premiowany typ kafelków.

Przykładowe umiejętności MVP:

- **Lada — Strzała Peruna:** niszczy cały pionowy rząd; każdy zniszczony kafelek ognia daje dodatkowe obrażenia.
- **Brun — Uderzenie Kowala:** niszczy wybrany kafelek i pola wokół niego; kamienie dają dodatkową energię.
- **Mieta — Krąg Uzdrowienia:** zamienia wodne kafelki w leczenie; większa kombinacja oznacza większe leczenie.

Docelowo można dodać:

- bohaterów usuwających konkretne przeszkody, np. lód, korzenie lub klątwy;
- premie punktowe za określone kafelki;
- umiejętności niszczące rzędy, kolumny albo obszary;
- zamianę jednego typu kafelka w inny;
- zamrażanie kafelków i późniejsze niszczenie ich za podwójną nagrodę;
- łączenie umiejętności dwóch bohaterów;
- specjalne zdolności skuteczne tylko przeciw konkretnym bossom.

Przykładowa zasada punktacji:

```text
obrażenia = liczba zniszczonych kafelków × siła bohatera
bonus żywiołu = liczba kafelków zgodnych z umiejętnością × mnożnik
duża kombinacja = dodatkowy łańcuch lub booster
```

Gracz powinien wybierać, czy użyć zdolności od razu, czy zachować ją na lepszą kombinację albo fazę bossa. Dzięki temu drużyna i wybór bohatera zmieniają sposób rozwiązywania planszy.

---

## 6. Etap 3 — pierwsza osada

**Cel:** dać graczowi długoterminowy cel poza pojedynczym poziomem.

### Budynki MVP

- Domostwa;
- Kuźnia;
- Chata Zielarki;
- Święty Gaj;
- Spichlerz;
- Wieża Peruna.

### Każdy budynek powinien mieć

- poziomy rozwoju;
- koszt ulepszenia;
- czas budowy albo natychmiastową nagrodę;
- wpływ na grę;
- własną ilustrację;
- prostą animację.

Przykład: Kuźnia zwiększa siłę boosterów, a Święty Gaj zwiększa liczbę punktów za elementy natury.

---

## 7. Etap 4 — mapa i pierwsza kraina

**Cel:** stworzyć wrażenie podróży i odkrywania świata.

### Dębowe Pogranicze

Pierwsza kraina powinna zawierać:

- 30 poziomów;
- 3 typy przeszkód;
- 2 zwykłych przeciwników;
- 1 minibossa;
- 1 bossa końcowego;
- 5 zadań fabularnych;
- 3 skrzynie z ukrytymi nagrodami;
- 1 relikt specjalny.

### Kolejne regiony pełnej wersji

1. Dębowe Pogranicze;
2. Święty Gaj;
3. Bagna Welesa;
4. Góry Peruna;
5. Jeziora Rusałek;
6. Ziemie Marzanny;
7. Kraina Żmijów;
8. Nawia;
9. Prawia;
10. Korona Drzewa Świata.

Każdy region powinien wprowadzać nową mechanikę, przeciwników, budynki, muzykę i fragment fabuły.

---

## 8. Etap 5 — grafiki

### Grafiki potrzebne do MVP

#### Ekrany

- ekran główny;
- mapa świata;
- plansza logiczna;
- ekran zwycięstwa;
- ekran przegranej;
- lista bohaterów;
- szczegóły bohatera;
- ekwipunek;
- kuźnia;
- osada;
- zadania;
- ustawienia.

#### Bohaterowie

- 3 portrety;
- 3 ilustracje pełnej postaci;
- ikony umiejętności;
- proste animacje ataku, obrony i zwycięstwa;
- portret Leszego;
- ilustracja Leszego w walce.

#### Świat

- tło osady;
- tło lasu;
- tło bagien;
- mapa Dębowego Pogranicza;
- kuźnia;
- chata zielarki;
- święty dąb;
- kamienie i totemy;
- skrzynie;
- przeszkody na planszy.

#### Elementy interfejsu

- przyciski;
- ramki kart;
- paski życia;
- ikony walut;
- ikony surowców;
- ikony boosterów;
- ikony budynków;
- komunikaty nagród;
- efekty zaznaczenia.

### Zasady produkcji grafiki

- najpierw przygotować jeden ekran wzorcowy;
- zatwierdzić paletę kolorów;
- zatwierdzić wygląd ramek i przycisków;
- dopiero potem produkować resztę assetów;
- zachować spójny rozmiar i format plików;
- nie używać finalnych grafik bez sprawdzonej licencji.

---

## 9. Etap 6 — muzyka i dźwięki

### Muzyka MVP

- motyw osady;
- motyw planszy;
- motyw walki z Leszym;
- motyw Nawi;
- zwycięstwo;
- przegrana.

### Efekty dźwiękowe MVP

- kliknięcie kafelka;
- połączenie elementów;
- duża kombinacja;
- eksplozja;
- obrażenia;
- leczenie;
- zdobycie monety;
- otwarcie skrzyni;
- ulepszenie budynku;
- odblokowanie poziomu;
- użycie boostera;
- kliknięcie przycisku.

Przy każdym zakupie lub pobraniu dźwięku należy zachować licencję w folderze `docs/licencje`.

---

## 10. Etap 7 — monetyzacja

Najpierw należy wdrożyć wyłącznie reklamy nagradzane:

- podwojenie nagrody;
- darmowa skrzynia;
- natychmiastowe ukończenie budynku;
- dodatkowy booster.

Później można dodać:

- pakiet bez reklam;
- kosmetyczne dekoracje osady;
- sezonową ścieżkę nagród;
- pakiety surowców;
- specjalne skórki bohaterów.

Reklama powinna być dobrowolna i jasno opisana. Gracz nie powinien być zmuszany do oglądania reklam, aby móc normalnie grać.

---

## 11. Etap 8 — testy

### Testy funkcjonalne

- czy plansza zawsze się uzupełnia;
- czy poziom można wygrać;
- czy zapis nie znika;
- czy nagrody są przyznawane poprawnie;
- czy reklama daje właściwą nagrodę;
- czy aplikacja nie zawiesza się po utracie internetu;
- czy działa na słabszym telefonie.

### Testy użytkowników

Minimum 10 osób powinno zagrać bez instrukcji.

Należy sprawdzić:

- czy rozumieją pierwszą planszę;
- czy wiedzą, co ulepszać;
- czy mapa jest czytelna;
- czy nagrody są satysfakcjonujące;
- czy chcą zagrać kolejny poziom;
- czy reklama nagradzana jest zrozumiała.

---

## 12. Etap 9 — przygotowanie pełnej zawartości

Po pozytywnych testach MVP można rozbudowywać grę.

### Docelowa zawartość

- 2 000–3 000 poziomów;
- 10 krain;
- 30–40 bohaterów;
- 100+ reliktów;
- 50+ budynków i ulepszeń;
- 100+ przeciwników;
- 50 bossów;
- wydarzenia sezonowe;
- tryb nieskończonego lasu;
- wyprawy do Nawi;
- system osiągnięć;
- kolekcja dekoracji.

Nie należy tworzyć całej zawartości z góry. Najlepiej produkować ją seriami po jednej krainie i mierzyć wyniki graczy.

---

## 13. Proponowana kolejność prac

1. Zamknąć dokument koncepcji.
2. Zbudować prototyp planszy bez finalnej grafiki.
3. Przetestować planszę z kilkoma osobami.
4. Dodać bohaterów i bossa.
5. Dodać pierwszą osadę.
6. Dodać mapę 30 poziomów.
7. Przygotować finalny styl graficzny.
8. Podmienić grafiki tymczasowe na docelowe.
9. Dodać muzykę i efekty.
10. Dodać reklamy nagradzane.
11. Przeprowadzić testy urządzeń.
12. Wydać zamkniętą wersję testową.
13. Poprawić retencję i balans.
14. Dopiero wtedy produkować kolejne krainy.

---

## 14. Kryteria ukończenia MVP

MVP można uznać za gotowe, gdy:

- nowy gracz rozumie grę bez pomocy;
- można ukończyć minimum 20 poziomów;
- działają nagrody, bohaterowie i osada;
- zapis postępu działa poprawnie;
- gra nie ma błędów blokujących;
- grafiki mają spójny styl;
- muzyka i efekty nie przeszkadzają w rozgrywce;
- reklama nagradzana działa zgodnie z opisem;
- co najmniej 10 osób chce zagrać ponownie następnego dnia.

## 15. Minimalny zespół

Na początek wystarczy:

- programista Godot/GDScript;
- projektant gry;
- grafik 2D/UI;
- osoba od muzyki i efektów — może pracować zewnętrznie;
- testerzy z grupy znajomych lub małej społeczności.

Jedna osoba może łączyć kilka ról, ale grafika, programowanie i projektowanie gry powinny być planowane osobno.

## 17. Założenia techniczne dla Godot

Godot jest głównym silnikiem tego projektu, ponieważ gra będzie w całości 2D i będzie składała się przede wszystkim z plansz logicznych, ekranów interfejsu, mapy świata oraz osady.

### Rekomendowany stos

- Godot 4.x;
- GDScript;
- renderowanie 2D;
- osobne sceny dla każdego głównego ekranu;
- dane poziomów przechowywane w plikach JSON albo zasobach Godot;
- system zapisu lokalnego na potrzeby MVP;
- eksport na Androida;
- reklamy i analityka dopiero po ukończeniu działającego MVP.

### Proponowany podział scen

```text
scenes/
├── main_menu.tscn
├── world_map.tscn
├── puzzle_level.tscn
├── battle_result.tscn
├── village.tscn
├── heroes.tscn
├── inventory.tscn
└── settings.tscn
```

### Proponowany podział skryptów

```text
scripts/
├── puzzle_board.gd
├── level_manager.gd
├── hero_manager.gd
├── village_manager.gd
├── inventory_manager.gd
├── reward_manager.gd
├── save_manager.gd
└── audio_manager.gd
```

Unity pozostaje wyłącznie alternatywą awaryjną, gdyby późniejsze integracje reklam, zakupów lub analityki okazały się łatwiejsze w tym silniku. Nie należy rozpoczynać projektu równocześnie w obu silnikach.

## 16. Organizacja plików

```text
szept-peruna/
├── docs/
│   ├── game-design-document.md
│   ├── fabula.md
│   ├── poziomy.md
│   ├── ekonomia.md
│   └── licencje.md
├── art/
│   ├── characters/
│   ├── environments/
│   ├── ui/
│   ├── tiles/
│   └── vfx/
├── audio/
│   ├── music/
│   └── sfx/
├── design/
│   ├── wireframes/
│   └── references/
└── game/
    ├── scenes/
    ├── scripts/
    ├── data/
    └── builds/
```

## Najważniejsza zasada

Najpierw trzeba udowodnić, że przyjemne jest samo rozwiązywanie planszy. RPG, osada, fabuła i monetyzacja powinny wzmacniać tę zabawę, a nie przykrywać nudną mechanikę.

---

## 18. GDD — szczegółowy opis gry

### Główna obietnica gry

Gracz rozwiązuje krótkie, satysfakcjonujące łamigłówki, aby rozwijać bohaterów, odbudować słowiańską osadę i odkrywać świat podzielony na Jawię, Nawię i Prawię.

### Długość sesji

- szybka sesja: 3–5 minut;
- zwykła sesja: 10–20 minut;
- długa sesja: 30–60 minut;
- codzienny cel: 3–8 rozegranych poziomów.

### Pętla pojedynczego poziomu

1. Gracz wybiera poziom na mapie.
2. Wybiera drużynę i booster.
3. Rozwiązuje planszę logiczną.
4. Kafelki ładują umiejętności bohaterów.
5. Bohaterowie atakują, leczą lub kontrolują planszę.
6. Gracz otrzymuje gwiazdki, surowce i doświadczenie.
7. Wynik wpływa na rozwój osady oraz odblokowanie mapy.

### Typy celów poziomów

- pokonaj przeciwnika;
- usuń określoną liczbę kafelków;
- zbierz bursztyn lub runy;
- uwolnij uwięzionego bohatera;
- usuń korzenie, lód albo klątwy;
- doprowadź wodę do świętego drzewa;
- przetrwaj określoną liczbę tur;
- zdobądź minimalną liczbę punktów.

---

## 19. Specyfikacja poziomów

### Struktura kampanii

Pełna kampania składa się z 10 krain. Każda kraina zawiera około 180–250 poziomów oraz odrębny zestaw mechanik.

#### Kraina 1: Dębowe Pogranicze

- poziomy 1–30;
- nauka podstaw przesuwania i łączenia;
- bursztyn, ogień, woda, liście i runy;
- przeciwnicy: wilk cienia i zbłąkany duch;
- boss: Leszy;
- pierwsza osada i trzy podstawowe budynki.

#### Kraina 2: Święty Gaj

- poziomy 31–60;
- korzenie i pola zablokowane;
- cele związane z ochroną drzew;
- boss: Strażnik Dębu.

#### Kraina 3: Bagna Welesa

- poziomy 61–90;
- trucizna, mgła i zmieniające się kafelki;
- przeciwnicy: utopce i błotne duchy;
- boss: Żmij Bagienny.

#### Kraina 4: Góry Peruna

- poziomy 91–120;
- kamienie, pioruny i plansze z lawiną;
- boss: Kamienny Gromowładca.

#### Kraina 5: Jeziora Rusałek

- poziomy 121–150;
- woda, wiry i przesuwające się wyspy;
- boss: Król Topielców.

#### Kraina 6: Ziemie Marzanny

- poziomy 151–180;
- lód, zamrożone kafelki i klątwy;
- boss: Pani Zimy.

#### Kraina 7: Kraina Żmijów

- poziomy 181–210;
- jaskinie, skarby i łańcuchy;
- boss: Matka Żmijów.

#### Kraina 8: Nawia

- poziomy 211–240;
- duchy, wspomnienia i odwrócone działanie kafelków;
- boss: Przewoźnik.

#### Kraina 9: Prawia

- poziomy 241–270;
- wymagające kombinacje kilku mechanik;
- boss: Strażnik Równowagi.

#### Kraina 10: Korona Drzewa Świata

- poziomy 271–300;
- finałowa kampania;
- powrót wszystkich głównych mechanik;
- finałowy wybór dotyczący losu świata.

Pozostałe poziomy do celu 2 000–3 000 powstają jako wyzwania, wydarzenia, tryb nieskończony, wyprawy i kolejne sezony.

### Zasady tempa trudności

- nowa mechanika pojawia się najpierw bez presji czasu;
- następnie występuje w prostych poziomach;
- potem łączy się z wcześniejszymi mechanikami;
- boss sprawdza konkretną mechanikę krainy;
- co 10 poziomów pojawia się poziom odpoczynkowy lub nagrodowy;
- co 25–30 poziomów pojawia się większe wyzwanie.

---

## 20. Ekonomia gry

### Waluty

- **Monety** — podstawowe ulepszenia i zwykłe zakupy;
- **Bursztyn** — rzadsza waluta, relikty i specjalne ulepszenia;
- **Drewno** — budynki i rozbudowa osady;
- **Kamień** — mury, drogi i konstrukcje;
- **Zioła** — mikstury i leczenie;
- **Energia** — wejście do poziomu specjalnego lub wydarzenia.

### Zasada ekonomii

Każdy poziom musi dawać odczuwalną nagrodę. Gracz powinien mieć możliwość regularnego ulepszania czegoś bez płacenia.

### Przykładowe koszty MVP

| Element | Koszt początkowy | Kolejny poziom |
|---|---:|---:|
| Domostwa | 500 monet, 80 drewna | +25% |
| Kuźnia | 800 monet, 120 drewna | +30% |
| Chata Zielarki | 600 monet, 60 ziół | +30% |
| Święty Gaj | 1 000 monet, 5 bursztynów | +35% |
| Ulepszenie bohatera | 300 monet | +20% |
| Relikt podstawowy | 3 bursztyny | zależnie od rzadkości |

Wartości są startowe i muszą zostać sprawdzone podczas testów.

### Reklamy nagradzane

Reklama może dawać:

- podwojenie nagrody;
- jedną darmową skrzynię dziennie;
- skrócenie budowy;
- dodatkowy booster;
- drugą próbę wydarzenia.

Reklama nie powinna być wymagana do przejścia kampanii.

---

## 21. Bohaterowie i system drużyny

### Kategorie bohaterów

- **Wojownik** — obrażenia i niszczenie przeszkód;
- **Zwiadowca** — kombinacje i precyzyjne ataki;
- **Zielarz** — leczenie i ochrona;
- **Druid** — kontrola natury i planszy;
- **Rzemieślnik** — wzmacnianie boosterów;
- **Strażnik Nawi** — klątwy i duchy.

### Pierwsze postacie

#### Lada — Zwiadowczyni

- żywioł: liść;
- zdolność: niszczy pionowy rząd;
- bonus: każdy zniszczony liść zwiększa siłę kolejnej umiejętności;
- pasywna cecha: premia do tarczy po dużej kombinacji.

#### Brun — Kowal

- żywioł: ogień;
- zdolność: niszczy obszar 3×3;
- bonus: kamienie ładują zdolność szybciej;
- pasywna cecha: większe obrażenia przeciw przeszkodom.

#### Mieta — Zielarka

- żywioł: woda;
- zdolność: zamienia wodne kafelki w leczenie;
- bonus: większa kombinacja daje większe leczenie;
- pasywna cecha: drużyna zaczyna poziom z częściowo naładowaną umiejętnością.

### Rozwój bohatera

- poziom doświadczenia;
- trzy umiejętności;
- sześć miejsc na relikty;
- poziom rzadkości;
- relacje z innymi bohaterami;
- skórki kosmetyczne;
- specjalne premie zależne od krainy.

---

## 22. Fabuła i świat

### Ton

Baśniowy, tajemniczy i przygodowy. Świat nie powinien być wyłącznie mroczny. Obok groźnych bagien i Nawi muszą istnieć bezpieczne wioski, święta, targi, ogniska i humor.

### Główne postacie

- **Jaruś** — młody strażnik osady i główny bohater;
- **Mieta** — zielarka i przewodniczka;
- **Brun** — kowal, który zna tajemnice starego oręża;
- **Lada** — zwiadowczyni;
- **Szepta** — bajarz prowadzący narrację;
- **Perun** — strażnik porządku;
- **Weles** — władca przemian i podziemnych ścieżek;
- **Mokosz** — opiekunka ziemi i ludzi;
- **Marzanna** — siła końca i zimowego cyklu.

### Zasada fabularna

Nie przedstawiać bogów wyłącznie jako prostych „dobrych” i „złych”. Konflikt powinien dotyczyć różnych wizji równowagi świata.

### Format dialogów

- krótkie dialogi przed poziomem;
- jedna scena po większym bossie;
- zadania poboczne mieszkańców;
- fragmenty legend do odblokowania;
- dziennik świata z kolekcjonowanymi wpisami.

---

## 23. Biblia graficzna

### Paleta

- głęboka zieleń lasu;
- granat nocnego nieba;
- bursztynowy pomarańcz;
- ciepły brąz drewna;
- przygaszona czerwień ognia;
- chłodny błękit wody i Nawi.

### Materiały wizualne

- drewno;
- kamień;
- len;
- żelazo;
- bursztyn;
- korzenie;
- pióra;
- kora dębu;
- światło ogniska.

### Minimalny standard assetu

Każdy asset powinien mieć:

- nazwę pliku;
- wersję;
- źródło lub licencję;
- rozmiar;
- format;
- informację, gdzie jest używany.

### Nazewnictwo

```text
hero_lada_portrait_v01.png
tile_fire_idle_v01.png
building_smithy_level_01.png
ui_button_primary_v01.png
boss_leszy_attack_v01.png
```

---

## 24. Architektura techniczna Godot

### Główne sceny

```text
main_menu.tscn
world_map.tscn
puzzle_level.tscn
result_screen.tscn
village.tscn
hero_roster.tscn
hero_detail.tscn
inventory.tscn
crafting.tscn
quests.tscn
events.tscn
settings.tscn
```

### Główne systemy

- `PuzzleBoard` — kafelki, ruchy, kombinacje i cele;
- `LevelManager` — wczytywanie poziomów i nagród;
- `HeroManager` — statystyki i umiejętności;
- `VillageManager` — budynki i ulepszenia;
- `InventoryManager` — surowce i relikty;
- `RewardManager` — nagrody, skrzynie i codzienne bonusy;
- `SaveManager` — zapis lokalny i kopie bezpieczeństwa;
- `AudioManager` — muzyka i efekty;
- `AnalyticsManager` — późniejsze zdarzenia analityczne.

### Dane poziomu

Każdy poziom powinien mieć osobny rekord danych:

```json
{
  "id": 1,
  "region": "debowepogranicze",
  "goal_type": "defeat_boss",
  "goal_value": 500,
  "blocked_tiles": ["stone"],
  "available_elements": ["fire", "water", "leaf", "amber", "rune"],
  "rewards": {
    "coins": 120,
    "wood": 20,
    "experience": 40
  }
}
```


---

## 25. Analityka i wskaźniki

Po uruchomieniu testów należy mierzyć:

- ilu graczy kończy pierwszy poziom;
- ilu wraca następnego dnia;
- na którym poziomie gracze odpadają;
- ile razy używają zdolności bohaterów;
- ile reklam nagradzanych oglądają;
- które poziomy są zbyt łatwe lub trudne;
- ile czasu spędzają w osadzie;
- które budynki ulepszają najczęściej.

Nie należy balansować gry wyłącznie na podstawie własnych odczuć.

---

## 26. Testy jakości i publikacja

### Testy urządzeń

Testować należy co najmniej:

- mały telefon z Androidem;
- średni telefon;
- starszy telefon;
- tablet;
- różne proporcje ekranu;
- tryb offline;
- powrót do gry po przerwaniu reklamy.

### Przygotowanie Google Play

- ikona aplikacji;
- zrzuty ekranu;
- krótki opis;
- pełny opis;
- polityka prywatności;
- lista używanych SDK;
- deklaracja reklam;
- system zgód i ochrony danych;
- kontakt do pomocy technicznej;
- wersja testowa zamknięta.

### Kryteria publikacji MVP

- brak błędów blokujących;
- działający zapis;
- działająca reklama nagradzana;
- jasne zasady zakupów;
- wszystkie użyte assety mają licencję;
- gra działa bez konta;
- użytkownik może usunąć lub zresetować dane zgodnie z wymaganiami platformy.

---

## 27. Realistyczna kolejność produkcji

### Faza A — prototyp

Plansza logiczna, 5 poziomów, jeden bohater, tymczasowa grafika.

### Faza B — MVP

30 poziomów, 3 bohaterów, boss, osada, mapa, zapis i podstawowe dźwięki.

### Faza C — test zamknięty

Testy użytkowników, poprawa trudności, ekonomii i interfejsu.

### Faza D — pierwsza wersja publiczna

60–100 poziomów, reklamy nagradzane, pierwsze wydarzenie i podstawowa analityka.

### Faza E — regularna produkcja

Nowa kraina co kilka miesięcy, wydarzenia sezonowe, nowe bohaterowie i kolejne tryby.

500 godzin powinno powstać stopniowo dzięki kampanii, wydarzeniom, kolekcjom i aktualizacjom, a nie poprzez tworzenie całej zawartości przed pierwszym testem.
