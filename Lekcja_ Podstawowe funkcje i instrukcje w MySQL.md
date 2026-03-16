# Lekcja: Podstawowe funkcje i instrukcje w MySQL

## Cele lekcji

Lekcja wprowadza kluczowe funkcje SQL w MySQL: komentarze, COALESCE, CAST, sprawdzanie constraintów i struktury, ANY oraz CONCAT. Uczniowie nauczą się ich używać w prostych zapytaniach. Czas: 45 minut.

## Przygotowanie środowiska

1. Zainstaluj XAMPP lub użyj phpMyAdmin online (np. db4free.net).
2. Utwórz bazę `lekcja_sql`: `CREATE DATABASE lekcja_sql; USE lekcja_sql;`.
3. Utwórz przykładową tabelę `pracownicy`:

```
CREATE TABLE pracownicy (
    id INT PRIMARY KEY AUTO_INCREMENT,
    imie VARCHAR(50),
    nazwisko VARCHAR(50),
    wiek INT,
    pensja DECIMAL(10,2),
    email VARCHAR(100)
);
```

4. Wstaw dane:

```
INSERT INTO pracownicy (imie, nazwisko, wiek, pensja, email) VALUES
('Jan', 'Kowalski', 30, 5000.00, NULL),
('Anna', 'Nowak', NULL, 6000.00, 'anna@example.com'),
('Piotr', 'Wiśniewski', 25, NULL, 'piotr@example.com');
```


## Instrukcje i komentarze

Komentarze wyjaśniają kod SQL i nie są wykonywane. Użyj `--` (jednowierszowy), `#` lub `/* */` (wielowierszowy).

**Przykład:**

```
SELECT * FROM pracownicy -- To jest komentarz jednowierszowy
/* Komentarz
wielowierszowy */
WHERE wiek > 20;
```

**Ćwiczenie:** Dodaj komentarze do INSERT powyżej i wykonaj.

## Funkcja COALESCE

COALESCE zwraca pierwszą nie-NULL wartość z listy. Użyteczne do zastępowania NULL domyślnymi wartościami.

**Przykład:**

```
SELECT imie, COALESCE(email, 'brak@email.com') AS email_obsluzony
FROM pracownicy;
```

Wynik: Dla Jana pokaże 'brak@email.com'.

**Ćwiczenie:** Użyj COALESCE dla pensja, domyślnie 0.00.

## Funkcja CAST

CAST konwertuje typ danych, np. tekst na liczbę lub datę.

**Przykład:**

```
SELECT CAST('123' AS UNSIGNED) AS liczba;
-- Konwertuje string '123' na int 123
```

**Ćwiczenie:** CAST wieku na VARCHAR i połącz z imieniem.

## Sprawdzanie Constraint i Struktury

- Struktura tabeli: `DESCRIBE pracownicy;` (lub DESC) – pokazuje kolumny, typy, klucze.
- Pełna struktura z constraintami: `SHOW CREATE TABLE pracownicy;`.
- Constraint: `SELECT * FROM information_schema.TABLE_CONSTRAINTS WHERE TABLE_NAME='pracownicy';` – lista ograniczeń (PRIMARY KEY itp.).

**Przykład:**

```
DESCRIBE pracownicy;
```

Wynik: Tabela z Field, Type, Null, Key itp.

**Ćwiczenie:** Dodaj CHECK (wiek > 18) do tabeli i sprawdź constraints.

## Operator ANY

ANY porównuje wartość z dowolną z podzbioru (subquery). Zwraca TRUE jeśli warunek spełniony dla choć jednej.

**Przykład:**

```
SELECT * FROM pracownicy WHERE wiek > ANY (SELECT wiek FROM pracownicy WHERE pensja > 5500);
```

**Ćwiczenie:** Znajdź pracowników starszych niż ktokolwiek z email.

## Funkcja CONCAT

CONCAT łączy stringi w jeden.

**Przykład:**

```
SELECT CONCAT(imie, ' ', nazwisko) AS pelne_imie FROM pracownicy;
```

Wynik: 'Jan Kowalski'.

**Ćwiczenie:** CONCAT imie, wiek (po CAST) i email (z COALESCE).

## Zadania domowe

1. Stwórz tabelę `studenci` z danymi, użyj wszystkich funkcji.
2. Dodaj komentarze i constraint (wiek >=16).
3. Wyślij zrzuty ekranu DESCRIBE i zapytań.

## Podsumowanie aktywności