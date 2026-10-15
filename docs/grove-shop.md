# Sklep Gaju

Wejście do sklepu: piąta ikona dolnego menu. `scripts/grove_shop.gd` zawiera cztery oferty premium i cztery zakupy za monety.

Zakupy za monety działają: drewno trafia do portfela, PD do portfela oraz wybranego składu według istniejącego podziału doświadczenia. Każdy zakup wymaga potwierdzenia, sprawdza stan monet ponownie i zapisuje postęp. Przy braku monet nic nie jest odejmowane ani przyznawane.

Pakiety premium są katalogiem z planowanymi cenami, oznaczonym Wkrótce. Nie są pobierane pieniądze ani przyznawane płatne nagrody. Projekt nie zawiera integracji płatności platformy. Przed uruchomieniem sprzedaży trzeba utworzyć produkty w sklepie platformy, podłączyć dostawcę płatności, pobierać jego lokalizowane ceny i weryfikować transakcje. Nagrody mogą być przyznawane dopiero po weryfikacji; ponowne dostarczenie tej samej transakcji nie może ponownie przyznać pakietu. Zakup trwałego usunięcia reklam wymaga przywracania zakupów i integracji z systemem reklam.

| ID oferty | Planowana cena | Zawartość |
| --- | --- | --- |
| first_journey | 9,99 zł | 1500 monet, 150 drewna, 300 PD |
| amber_treasure | 19,99 zł | 5000 monet, 400 drewna |
| perun_power | 24,99 zł | 8 Iskier Peruna, 600 PD |
| remove_ads | 19,99 zł | Trwałe wyłączenie reklam przerywających grę |

## Grafika

Ikonka: `art/ui/shop_navigation_icon_v01.png`, wygenerowana wbudowanym ImageGen z przezroczystym tłem. Referencja stylu: `art/ui/home_navigation_icons_v01.png`.

Grafika pakietu Pierwsza wyprawa: `art/ui/shop_first_journey_v01.png`, wygenerowana osobno wbudowanym ImageGen z przezroczystym tłem.

Prompt pakietu:

```text
Use case: stylized-concept. Asset type: one transparent square game store bundle illustration for Szept Peruna, Slavic woodland fantasy. First Journey starter bundle: a compact beautiful open carved oak and bronze treasure chest with glowing amber gold coins, a small dark green leather travel satchel with oak leaf embroidery, bundled logs, a rolled parchment with subtle turquoise magical experience sparks. Detailed realistic hand painted RPG inventory art, antique gold, forest green and warm bronze matching a richly illustrated Slavic forest game. Centered compact arrangement readable at 90 pixels. Entire objects contained, natural irregular silhouette and generous transparent margin. No circular frame, no rectangular border, no landscape backdrop, no writing, numbers, watermark. Genuine transparent alpha background, no black or white background.
```

Typografia wszystkich ekranów: `scripts/game_typography.gd`. Odstęp spacji zwiększony o 3 px; rysowanie oraz pomiary szerokości korzystają z tej samej czcionki. Karty sklepu powiększono o 30 px, a ilustracje, nazwy i opisy przesunięto lokalnie o 20 px. Cena zachowuje dotychczasowe położenie wewnątrz karty.

Prompt:

```text
Use case: stylized-concept. Generate ONE square transparent mobile fantasy game shop navigation icon, matching the attached reference's ornate circular gold and antique bronze medallion style. In the medallion: a charming Slavic woodland merchant stall under a dark green fabric canopy with a small treasure chest, gold coins, amber crystals and bundled herbs, warm lantern glow. Dark forest green interior, realistic hand-painted high detail, carved oak leaf trim and subtle runic ornaments, clear simple silhouette legible at 65px. Entire circular medallion contained with transparent padding, genuine alpha outside ring. No text, letters, price, watermark, white backdrop or icon sheet.
```

Podglądy i kontrolę zakupów w pamięci, bez naruszania zapisu gracza, uruchamia `tools/capture_shop.gd`. Podgląd przesuniętego o 40 px przycisku Anuluj: `tools/capture_opening.gd`, plik wynikowy `.godot/opening-avatar_edit.png`.
