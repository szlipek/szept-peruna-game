# Reklamy i Firebase — przygotowanie wydania Android

## Stan

- Gra używa przykładowego identyfikatora aplikacji AdMob i testowych jednostek. `is_real = false`; nie są to reklamy produkcyjne.
- Reklama za nagrodę po zwycięstwie daje 50% monet z nagrody; nagroda zostaje przyznana tylko po sygnale SDK. Dzieli dzienny limit z reklamą skrzyni premium.
- Reklama pełnoekranowa jest dostępna po czterech zwycięstwach kampanii od poziomu 6, maksymalnie dwa razy dziennie. Licznik zużywa się po potwierdzeniu wyświetlenia.
- Aplikacja Android `org.szeptperuna.game` została zarejestrowana w projekcie Firebase **Spmedia Games** (`dig-deeper-515de`). Pobrany plik konfiguracji znajduje się lokalnie w `android/firebase/google-services.json` i nie jest zapisywany w Git. Przygotowano most SDK Analytics i Crashlytics oraz zdarzenia gry; uruchomienie i raporty na telefonie wymagają jeszcze weryfikacji. Postęp pozostaje wyłącznie lokalny, bez logowania i chmury.

## AdMob przed publikacją

1. W AdMob zarejestrować aplikację Android i przygotować jednostki **Interstitial** i **Rewarded**. Potwierdzić nazwę pakietu `org.szeptperuna.game` przed pierwszą publikacją.
2. W scenie `scenes/puzzle_level.tscn`, na węźle `Admob`, uzupełnić `android_real_application_id`, `android_real_interstitial_id` i `android_real_rewarded_id`. Włączyć `is_real` dopiero dla kontrolowanego przygotowania wydania. To ustawienie dotyczy węzła, więc przed testowaniem zwrócić szczególną uwagę na konfigurację trybu testowego i urządzeń testowych. Identyfikator aplikacji musi być uwzględniony również w manifeście generowanym przy eksporcie; zweryfikować gotowy pakiet.
3. W AdMob skonfigurować komunikaty prywatności, politykę prywatności i odpowiedzi w Google Play zgodnie z faktycznym działaniem aplikacji i jej odbiorcami.
4. Przygotowano natywny most `privacyOptionsRequirementStatus` i `showPrivacyOptionsForm` oraz przycisk widoczny w ustawieniach, gdy UMP go wymaga. Po jego użyciu reklamy pozostają wyłączone do ponownego uruchomienia, aby nie wyświetlić reklamy pobranej przed zmianą wyboru. **Przed publikacją sprawdzić na urządzeniu**, że przycisk i formularz działają w wymaganym regionie i przy zmianie wyboru.
5. Na telefonie z usługami Google Play sprawdzić formularz, odmowę, zmianę wyboru, brak internetu, powrót do gry, dzienny limit, zamknięcie reklamy bez nagrody, poprawną nagrodę i nieudane wyświetlenie. Podczas prac używać wyłącznie reklam testowych lub urządzeń testowych: https://developers.google.com/admob/android/test-ads

## Firebase

1. Wybrany zakres to Analytics i Crashlytics, bez kont i synchronizacji chmurowej. Obie usługi są domyślnie wyłączone i mają osobne przełączniki w ustawieniach gry.
2. Rejestracja aplikacji i pobranie `google-services.json` są wykonane. Przy odtwarzaniu środowiska pobrać aktualny plik z ustawień projektu Firebase. Instrukcja Google: https://firebase.google.com/docs/android/setup
3. Po instalacji lub odtworzeniu szablonu Gradle Godota uruchomić z katalogu projektu `powershell -File tools/setup_firebase_android.ps1`. Skrypt modyfikuje lokalny, ignorowany przez Git szablon i kopiuje do niego konfigurację. Następnie wyeksportować APK przez Godot. Jeśli w Windows Norton filtruje HTTPS i Java nie ufa jego certyfikatowi, użyć magazynu zaufania z certyfikatem pochodzącym z systemowego magazynu Windows; nie wyłączać sprawdzania certyfikatów.
4. Na urządzeniu sprawdzić domyślne wyłączenie, włączanie i cofanie obu ustawień, zdarzenia w DebugView oraz testową awarię po ponownym uruchomieniu aplikacji. Zweryfikować też czytelność raportów natywnych i symboli Godota. Przed publikacją uzupełnić politykę prywatności i deklarację danych w Play Console. Samo dodanie pliku JSON lub pomyślna kompilacja nie potwierdzają działania usług.

## Test lokalnej logiki

```powershell
.\tools\Godot\Godot_v4.5.2-stable_win64_console.exe --headless --path . --script res://tests/ads_flow_test.gd
```

Test korzysta z zastępczego dostawcy reklam; nie potwierdza działania SDK, sieci ani zgód na Androidzie.
