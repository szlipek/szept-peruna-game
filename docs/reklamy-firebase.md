# Reklamy i Firebase — przygotowanie wydania Android

## Stan

- Gra używa przykładowego identyfikatora aplikacji AdMob i testowych jednostek. `is_real = false`; nie są to reklamy produkcyjne.
- Reklama za nagrodę po zwycięstwie daje 50% monet z nagrody; nagroda zostaje przyznana tylko po sygnale SDK. Dzieli dzienny limit z reklamą skrzyni premium.
- Reklama pełnoekranowa jest dostępna po czterech zwycięstwach kampanii od poziomu 6, maksymalnie dwa razy dziennie. Licznik zużywa się po potwierdzeniu wyświetlenia.
- Firebase nie jest zintegrowany: brak projektu konfiguracyjnego, natywnego SDK i mostu Godot. Postęp jest lokalny; synchronizacja w chmurze wymaga osobnego wdrożenia.

## AdMob przed publikacją

1. W AdMob zarejestrować aplikację Android i przygotować jednostki **Interstitial** i **Rewarded**. Potwierdzić nazwę pakietu `org.szeptperuna.game` przed pierwszą publikacją.
2. W scenie `scenes/puzzle_level.tscn`, na węźle `Admob`, uzupełnić `android_real_application_id`, `android_real_interstitial_id` i `android_real_rewarded_id`. Włączyć `is_real` dopiero dla kontrolowanego przygotowania wydania. To ustawienie dotyczy węzła, więc przed testowaniem zwrócić szczególną uwagę na konfigurację trybu testowego i urządzeń testowych. Identyfikator aplikacji musi być uwzględniony również w manifeście generowanym przy eksporcie; zweryfikować gotowy pakiet.
3. W AdMob skonfigurować komunikaty prywatności, politykę prywatności i odpowiedzi w Google Play zgodnie z faktycznym działaniem aplikacji i jej odbiorcami.
4. **Blokada publikacji:** obecna wtyczka `AdmobPlugin` udostępnia podstawowy formularz zgody, ale w jej interfejsie nie znaleziono funkcji wyświetlania opcji prywatności UMP. Zaktualizować lub rozszerzyć natywną wtyczkę o sprawdzenie `privacyOptionsRequirementStatus` i `showPrivacyOptionsForm`, a następnie dodać przycisk do ustawień gry, widoczny wtedy, gdy jest wymagany. Nie zastępować go resetowaniem zgody.
5. Na telefonie z usługami Google Play sprawdzić formularz, odmowę, zmianę wyboru, brak internetu, powrót do gry, dzienny limit, zamknięcie reklamy bez nagrody, poprawną nagrodę i nieudane wyświetlenie. Podczas prac używać wyłącznie reklam testowych lub urządzeń testowych: https://developers.google.com/admob/android/test-ads

## Firebase

1. Wybrać usługi i zakres danych. Rozsądny pierwszy etap to Analytics i/lub Crashlytics; żadna z tych usług nie jest jeszcze wbudowana. Zapis w chmurze wymaga osobnej decyzji, logowania, reguł dostępu i obsługi konfliktów z lokalnym zapisem.
2. Utworzyć lub wybrać projekt Firebase, zarejestrować aplikację Android z ostatecznym identyfikatorem `org.szeptperuna.game` i pobrać `google-services.json`. Instrukcja Google: https://firebase.google.com/docs/android/setup
3. Dobrać zgodny z Godot 4.5.2 natywny most Android, podłączyć wybrane SDK i plik konfiguracji do rzeczywistego procesu Gradle, a następnie sprawdzić pakiet i urządzenie. Samo dodanie pliku JSON nie uruchamia usług Firebase.
4. Przed włączeniem zbierania danych ustalić wymagane zgody i wprowadzić odpowiednią obsługę; nie wysyłać postępu lub identyfikatorów gracza bez zaprojektowania tej funkcji. Sprawdzić raport zdarzeń/błędów na urządzeniu testowym oraz zaktualizować politykę prywatności i deklarację danych w Play Console.

## Test lokalnej logiki

```powershell
.\tools\Godot\Godot_v4.5.2-stable_win64_console.exe --headless --path . --script res://tests/ads_flow_test.gd
```

Test korzysta z zastępczego dostawcy reklam; nie potwierdza działania SDK, sieci ani zgód na Androidzie.
