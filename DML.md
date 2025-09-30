
4. SQL DML (MySQL) – zapełnianie bazy danymi, modyfikacja danych, usuwanie danych;

# Lekcja: SQL DML (MySQL) – zapełnianie bazy danymi, modyfikacja danych, usuwanie danych

**Czas trwania: 90 minut**  
**Zgodnie z programem nauczania PiABD-2025-2026 i wymaganiami egzaminu INF.03**

---

## Struktura lekcji (90 minut)
1. **Wprowadzenie do DML** (10 min)
2. **INSERT – dodawanie danych** (25 min)
3. **UPDATE – modyfikacja danych** (25 min)
4. **DELETE – usuwanie danych** (20 min)
5. **Praktyczne ćwiczenia i podsumowanie** (10 min)

---

## Część 1: Wprowadzenie do DML (10 minut)

### Co to jest DML?
**DML (Data Manipulation Language)** – język manipulacji danymi służący do operacji na danych w bazie. Jest to część SQL odpowiedzialna za wprowadzanie, modyfikację i usuwanie rekordów.

### Podstawowe polecenia DML:
- `INSERT` – dodawanie nowych rekordów
- `UPDATE` – modyfikacja istniejących rekordów
- `DELETE` – usuwanie rekordów
- `SELECT` – pobieranie danych (DQL - Data Query Language)

### Różnica DML vs DDL
- **DML** – operacje na danych (zawartość tabel)
- **DDL** – operacje na strukturze bazy (tworzenie tabel, kolumn)

### Przygotowanie środowiska pracy

```

-- Tworzymy bazę testową
CREATE DATABASE sklep_dml;
USE sklep_dml;

-- Tworzymy strukturę tabel do ćwiczeń
CREATE TABLE klienci (
id INT PRIMARY KEY AUTO_INCREMENT,
imie VARCHAR(50) NOT NULL,
nazwisko VARCHAR(50) NOT NULL,
email VARCHAR(100) UNIQUE,
telefon VARCHAR(15),
miasto VARCHAR(50),
data_rejestracji DATE
);

CREATE TABLE produkty (
id INT PRIMARY KEY AUTO_INCREMENT,
nazwa VARCHAR(200) NOT NULL,
cena DECIMAL(10,2) NOT NULL,
ilosc_magazyn INT DEFAULT 0,
kategoria VARCHAR(50)
);

```

---

## Część 2: INSERT – dodawanie danych (25 minut)

### Podstawowa składnia INSERT

```

INSERT INTO nazwa_tabeli (kolumna1, kolumna2, ...)
VALUES (wartość1, wartość2, ...);

```

### Przykład 1: Dodanie pojedynczego rekordu

```

INSERT INTO klienci (imie, nazwisko, email, telefon, miasto, data_rejestracji)
VALUES ('Jan', 'Kowalski', 'jan.kowalski@email.com', '123456789', 'Warszawa', '2024-01-15');

```

### Przykład 2: Dodanie wielu rekordów jednocześnie

```

INSERT INTO klienci (imie, nazwisko, email, miasto, data_rejestracji) VALUES
('Anna', 'Nowak', 'anna.nowak@email.com', 'Kraków', '2024-01-16'),
('Piotr', 'Wiśniewski', 'piotr.wisniewski@email.com', 'Gdańsk', '2024-01-17'),
('Maria', 'Kowalczyk', 'maria.kowalczyk@email.com', 'Wrocław', '2024-01-18'),
('Tomasz', 'Kaczmarek', 'tomasz.kaczmarek@email.com', 'Poznań', '2024-01-19');

```

### Przykład 3: INSERT bez podawania nazw kolumn

```

-- UWAGA: Musimy podać wartości dla WSZYSTKICH kolumn w odpowiedniej kolejności
INSERT INTO produkty VALUES
(NULL, 'Laptop Dell', 2999.99, 5, 'Elektronika'),
(NULL, 'Mysz optyczna', 49.99, 20, 'Elektronika');

```

### Przykład 4: INSERT z wartościami domyślnymi

```

INSERT INTO produkty (nazwa, cena, kategoria)
VALUES ('Klawiatura mechaniczna', 299.99, 'Elektronika');
-- Kolumna ilosc_magazyn otrzyma wartość domyślną 0

```

### Przykład 5: INSERT z funkcjami

```

INSERT INTO klienci (imie, nazwisko, email, miasto, data_rejestracji)
VALUES ('Adam', 'Nowicki', 'adam.nowicki@email.com', 'Łódź', CURDATE());
-- CURDATE() wstawia bieżącą datę

```

### Sprawdzenie wstawionych danych

```

SELECT * FROM klienci;
SELECT * FROM produkty;

```

### Najczęstsze błędy przy INSERT:
- Niepodanie wartości dla kolumn NOT NULL
- Duplikowanie wartości w kolumnach UNIQUE
- Niezgodność typów danych
- Przekroczenie maksymalnej długości VARCHAR

---

## Część 3: UPDATE – modyfikacja danych (25 minut)

### Podstawowa składnia UPDATE

```

UPDATE nazwa_tabeli
SET kolumna1 = nowa_wartość1, kolumna2 = nowa_wartość2
WHERE warunek;

```

**BARDZO WAŻNE:** Zawsze używaj klauzuli WHERE, aby nie zmodyfikować wszystkich rekordów!

### Przykład 1: Modyfikacja jednego pola

```

UPDATE klienci
SET telefon = '987654321'
WHERE id = 1;

```

### Przykład 2: Modyfikacja wielu pól jednocześnie

```

UPDATE klienci
SET email = 'nowy.email@firma.com', miasto = 'Szczecin'
WHERE nazwisko = 'Kowalski';

```

### Przykład 3: UPDATE z warunkami złożonymi

```

UPDATE produkty
SET cena = cena * 0.9
WHERE kategoria = 'Elektronika' AND ilosc_magazyn > 10;
-- Obniżka o 10% dla produktów elektronicznych z dużym stanem magazynowym

```

### Przykład 4: UPDATE z funkcjami matematycznymi

```

UPDATE produkty
SET ilosc_magazyn = ilosc_magazyn + 50
WHERE nazwa LIKE '%Laptop%';
-- Zwiększenie stanu magazynowego laptopów o 50 sztuk

```

### Przykład 5: UPDATE z wykorzystaniem innych tabel

```

UPDATE klienci
SET miasto = 'Warszawa'
WHERE id IN (SELECT DISTINCT klient_id FROM zamowienia WHERE data_zamowienia > '2024-01-01');
-- Zmiana miasta dla klientów, którzy złożyli zamówienia po 1 stycznia 2024

```

### Przykład 6: UPDATE z CASE

```

UPDATE produkty
SET kategoria = CASE
WHEN cena < 100 THEN 'Tanie'
WHEN cena BETWEEN 100 AND 1000 THEN 'Średnie'
ELSE 'Drogie'
END;

```

### Sprawdzenie zmian

```

SELECT * FROM klienci WHERE id = 1;
SELECT * FROM produkty WHERE kategoria = 'Elektronika';

```

### Bezpieczne UPDATE:
```

-- Najpierw sprawdź, co zostanie zmienione
SELECT * FROM klienci WHERE miasto = 'Warszawa';

-- Potem wykonaj UPDATE
UPDATE klienci SET telefon = '111222333' WHERE miasto = 'Warszawa';

-- Sprawdź rezultat
SELECT * FROM klienci WHERE miasto = 'Warszawa';

```

---

## Część 4: DELETE – usuwanie danych (20 minut)

### Podstawowa składnia DELETE

```

DELETE FROM nazwa_tabeli
WHERE warunek;

```

**OSTRZEŻENIE:** Bez klauzuli WHERE usuniesz WSZYSTKIE rekordy z tabeli!

### Przykład 1: Usuwanie pojedynczego rekordu

```

DELETE FROM klienci
WHERE id = 5;

```

### Przykład 2: Usuwanie z warunkiem tekstowym

```

DELETE FROM klienci
WHERE email = 'adam.nowicki@email.com';

```

### Przykład 3: Usuwanie z warunkami złożonymi

```

DELETE FROM produkty
WHERE cena < 50 AND ilosc_magazyn = 0;
-- Usuwa tanie produkty, których nie ma na magazynie

```

### Przykład 4: Usuwanie z wykorzystaniem LIKE

```

DELETE FROM klienci
WHERE email LIKE '%test%';
-- Usuwa klientów z testowymi adresami email

```

### Przykład 5: Usuwanie z podzapytaniem

```

DELETE FROM produkty
WHERE kategoria IN (SELECT kategoria FROM kategorie_usuwane);
-- Usuwa produkty z określonych kategorii

```

### Przykład 6: Usuwanie z LIMIT (MySQL)

```

DELETE FROM klienci
WHERE data_rejestracji < '2024-01-01'
LIMIT 10;
-- Usuwa maksymalnie 10 najstarszych rejestracji

```

### Sprawdzenie liczby usuniętych rekordów

```

-- W MySQL możesz sprawdzić ROW_COUNT()
DELETE FROM produkty WHERE cena < 10;
SELECT ROW_COUNT(); -- Pokaże liczbę usuniętych wierszy

```

### Bezpieczne DELETE:
```

-- ZAWSZE najpierw sprawdź, co zostanie usunięte
SELECT * FROM klienci WHERE miasto = 'Testowe';

-- Jeśli wynik jest poprawny, wykonaj DELETE
DELETE FROM klienci WHERE miasto = 'Testowe';

-- Sprawdź rezultat
SELECT COUNT(*) FROM klienci;

```

### TRUNCATE vs DELETE

```

-- DELETE - usuwa rekordy jeden po drugim, można użyć WHERE
DELETE FROM produkty WHERE kategoria = 'Test';

-- TRUNCATE - usuwa wszystkie rekordy na raz, szybsze, ale bez WHERE
TRUNCATE TABLE produkty_temp;

```

---

## Część 5: Praktyczne ćwiczenia i podsumowanie (10 minut)

### Ćwiczenie praktyczne - sklep internetowy

```

-- 1. Dodaj nowych klientów
INSERT INTO klienci (imie, nazwisko, email, miasto, data_rejestracji) VALUES
('Katarzyna', 'Zielińska', 'k.zielinska@email.com', 'Lublin', CURDATE()),
('Michał', 'Szymański', 'm.szymanski@email.com', 'Katowice', CURDATE());

-- 2. Dodaj produkty
INSERT INTO produkty (nazwa, cena, ilosc_magazyn, kategoria) VALUES
('Słuchawki bezprzewodowe', 199.99, 15, 'Audio'),
('Monitor 24"', 899.99, 8, 'Elektronika'),
('Kamera internetowa', 149.99, 12, 'Elektronika');

-- 3. Zaktualizuj ceny (podwyżka o 5%)
UPDATE produkty
SET cena = cena * 1.05
WHERE kategoria = 'Elektronika';

-- 4. Zmień dane klienta
UPDATE klienci
SET telefon = '555666777'
WHERE email = 'k.zielinska@email.com';

-- 5. Usuń produkty o zerowym stanie
DELETE FROM produkty
WHERE ilosc_magazyn = 0;

-- 6. Sprawdź wyniki
SELECT 'Klienci:' as Tabela;
SELECT * FROM klienci;
SELECT 'Produkty:' as Tabela;
SELECT * FROM produkty;

```

### Najważniejsze zasady DML:

1. **Zawsze używaj WHERE** w UPDATE i DELETE
2. **Testuj na małych zbiorach** przed operacjami na całej bazie
3. **Rób kopie zapasowe** przed dużymi zmianami
4. **Sprawdzaj wyniki** po każdej operacji
5. **Używaj transakcji** dla złożonych operacji

### Często spotykane błędy na egzaminie INF.03:

- Brak klauzuli WHERE w UPDATE/DELETE
- Nieprawidłowe typy danych w INSERT
- Zapomnienie o cudzysłowach dla stringów
- Błędna składnia VALUES w INSERT
- Nieprawidłowe warunki w WHERE

### Przydatne funkcje MySQL w DML:

```

-- Funkcje daty
NOW()           -- bieżąca data i czas
CURDATE()       -- bieżąca data
DATE_ADD(data, INTERVAL 1 MONTH)  -- dodanie czasu

-- Funkcje tekstowe
UPPER(tekst)    -- wielkie litery
LOWER(tekst)    -- małe litery
CONCAT(a, b)    -- łączenie tekstów

-- Funkcje matematyczne
ROUND(liczba, 2)    -- zaokrąglenie
ABS(liczba)         -- wartość bezwzględna

```

### Zadanie do samodzielnego wykonania:

1. Stwórz tabelę `zamowienia` z kolumnami: id, klient_id, data_zamowienia, status, wartosc
2. Dodaj 5 przykładowych zamówień
3. Zaktualizuj status zamówienia o id=1 na 'wysłane'
4. Usuń zamówienia starsze niż 30 dni
5. Zwiększ wartość wszystkich zamówień o 8% VAT

**Koniec lekcji**




[^1]: https://rpubs.com/hrpunio/869461

[^2]: https://devstockacademy.pl/blog/narzedzia-i-automatyzacja/bazy-danych-sql-podstawy-narzedzia-i-najlepsze-praktyki/

[^3]: https://www.youtube.com/watch?v=nhWCvQRs8io

[^4]: https://www.cognity.pl/blog-sql-podstawy-skladnia-i-zastosowanie

[^5]: https://staff.uz.zgora.pl/agramack/files/BazyDanych/MySQL/db_lab3.pdf

[^6]: https://www.p-programowanie.pl/jezyk-programowania-sql/

[^7]: https://eitt.pl/baza-wiedzy/sql-podstawy-jezyka-zapytan-bazy-danych/

[^8]: https://icis.pcz.pl/~olga/dydaktyka/BAZYw03.p.pdf

[^9]: https://boringowl.io/blog/data-manipulation-language-klucz-do-zrozumienia-manipulacji-danymi

```