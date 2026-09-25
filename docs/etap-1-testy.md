# Szept Peruna — odbiór Etapu 1

Etap 1 można uznać za zakończony dopiero po przejściu poniższej listy w uruchomionej wersji Godot 4.x, na myszce oraz ekranie dotykowym.

## Testy funkcjonalne

- [ ] Plansza startuje bez gotowych połączeń trzech symboli.
- [ ] Każda wygenerowana plansza ma co najmniej jeden prawidłowy ruch.
- [ ] Zmiana sąsiednich kafelków tworząca połączenie zużywa jeden ruch.
- [ ] Kafelek można zaznaczyć kliknięciem, a następnie zamienić kliknięciem na sąsiednie pole.
- [ ] Nieprawidłowa zmiana wraca na poprzednie pola i nie zużywa ruchu.
- [ ] Połączenie trzech lub większej liczby symboli znika, daje punkty i uzupełnia planszę.
- [ ] Kaskady naliczają dodatkowe punkty i po zakończeniu pozostawiają planszę z prawidłowym ruchem.
- [ ] Gdy po kaskadzie nie ma prawidłowego ruchu, pojawia się komunikat „Przetasowanie gaju”, a plansza zachowuje pulę kafelków zamiast wyglądać na reset poziomu.
- [ ] Wynik równy celowi kończy poziom zwycięstwem i odblokowuje następny poziom.
- [ ] Koniec ruchów przed celem kończy poziom porażką.
- [ ] Przycisk restartu odtwarza bieżący poziom z pełną pulą ruchów.
- [ ] Młot bursztynowy niszczy obszar 3×3 i nie zużywa ruchu.
- [ ] Liście ładują Strzałę Peruna, która niszczy wybraną kolumnę bez kosztu ruchu.
- [ ] Monety, drewno, PD i odblokowane poziomy pozostają po ponownym uruchomieniu gry.

## Szybki test z użytkownikiem

Poproś pięć osób, które nie znają gry, aby uruchomiły poziom 1 bez instrukcji słownej. Zapisz:

| Osoba | Rozumie pierwszy ruch w 30 s? | Ukończyła poziom 1? | Czy użyła boostera? | Co było niejasne? |
|---|---|---|---|---|
| 1 |  |  |  |  |
| 2 |  |  |  |  |
| 3 |  |  |  |  |
| 4 |  |  |  |  |
| 5 |  |  |  |  |

## Kryterium decyzji

Jeśli co najmniej cztery z pięciu osób wykonają pierwszy poprawny ruch w 30 sekund, a większość będzie chciała rozegrać kolejną próbę, można przejść do Etapu 2. W przeciwnym razie należy najpierw poprawić instrukcję, cele punktowe lub liczbę ruchów.

## Uwaga po rozpoczęciu Etapu 2

Poziom 5 jest już testem walki z Leszym. Sprawdź, czy ogień i runy obniżają jego zdrowie, woda leczy drużynę, liście dodają tarczę, a Leszy atakuje po poprawnym ruchu.

## Mechaniki Dębowego Pogranicza

- [ ] Korzeń znika po jednym trafieniu kombinacją lub umiejętnością.
- [ ] Kamień po pierwszym trafieniu zmienia się w korzeń, a po drugim znika.
- [ ] Klątwa po kolejnych trafieniach przechodzi przez kamień i korzeń, a następnie znika.
