# Lekcja: SQL DQL (MySQL) – pozyskiwanie danych z bazy – zapytania proste i złożone, zapytania w oparciu o dane z wielu tabel, zapytania zagnieżdżone, tworzenie i korzystanie z widoków


---

## Struktura lekcji (90 minut)
1. **Wprowadzenie do DQL i podstawy SELECT** (15 min)
2. **Zapytania proste – filtrowanie, sortowanie, grupowanie** (20 min)
3. **Zapytania z wielu tabel – JOIN, UNION** (25 min)
4. **Zapytania zagnieżdżone (subqueries)** (15 min)
5. **Widoki (Views) – tworzenie i korzystanie** (10 min)
6. **Praktyczne ćwiczenia i podsumowanie** (5 min)

---

## Część 1: Wprowadzenie do DQL i podstawy SELECT (15 minut)

### Co to jest DQL?
**DQL (Data Query Language)** – język zapytań służący do pobierania danych z bazy. W MySQL składa się głównie z polecenia SELECT i jego różnych wariantów.

### Podstawowa składnia SELECT

```

SELECT kolumny
FROM tabela
WHERE warunek
GROUP BY kolumny_grupowania
HAVING warunek_grupy
ORDER BY kolumny_sortowania
LIMIT liczba_rekordów;

```

### Kolejność wykonywania klauzul:
1. `FROM` – wybór tabeli
2. `WHERE` – filtrowanie rekordów
3. `GROUP BY` – grupowanie
4. `HAVING` – filtrowanie grup
5. `SELECT` – wybór kolumn
6. `ORDER BY` – sortowanie
7. `LIMIT` – ograniczenie liczby wyników

### Przygotowanie środowiska testowego

```

-- Tworzymy bazę testową
CREATE DATABASE sklep_dql;
USE sklep_dql;

-- Tabela klienci
CREATE TABLE klienci (
id INT PRIMARY KEY AUTO_INCREMENT,
imie VARCHAR(50),
nazwisko VARCHAR(50),
email VARCHAR(100),
miasto VARCHAR(50),
wiek INT,
data_rejestracji DATE
);

-- Tabela produkty
CREATE TABLE produkty (
id INT PRIMARY KEY AUTO_INCREMENT,
nazwa VARCHAR(200),
cena DECIMAL(10,2),
kategoria VARCHAR(50),
ilosc_magazyn INT
);

-- Tabela zamowienia
CREATE TABLE zamowienia (
id INT PRIMARY KEY AUTO_INCREMENT,
klient_id INT,
data_zamowienia DATE,
status VARCHAR(20),
wartosc DECIMAL(10,2),
FOREIGN KEY (klient_id) REFERENCES klienci(id)
);

-- Wstawiamy przykładowe dane
INSERT INTO klienci (imie, nazwisko, email, miasto, wiek, data_rejestracji) VALUES
('Jan', 'Kowalski', 'jan@email.com', 'Warszawa', 30, '2024-01-15'),
('Anna', 'Nowak', 'anna@email.com', 'Kraków', 25, '2024-02-20'),
('Piotr', 'Wiśniewski', 'piotr@email.com', 'Gdańsk', 35, '2024-01-10'),
('Maria', 'Kowalczyk', 'maria@email.com', 'Warszawa', 28, '2024-03-05'),
('Tomasz', 'Kaczmarek', 'tomasz@email.com', 'Wrocław', 32, '2024-02-18');

INSERT INTO produkty (nazwa, cena, kategoria, ilosc_magazyn) VALUES
('Laptop Dell', 2999.99, 'Elektronika', 5),
('Mysz optyczna', 49.99, 'Elektronika', 20),
('Książka SQL', 89.99, 'Książki', 15),
('Monitor 24"', 899.99, 'Elektronika', 8),
('Klawiatura', 199.99, 'Elektronika', 12);

INSERT INTO zamowienia (klient_id, data_zamowienia, status, wartosc) VALUES
(1, '2024-03-01', 'wysłane', 3049.98),
(2, '2024-03-02', 'nowe', 949.98),
(3, '2024-03-03', 'wysłane', 199.99),
(1, '2024-03-04', 'anulowane', 89.99),
(4, '2024-03-05', 'wysłane', 2999.99);

```

---

## Część 2: Zapytania proste – filtrowanie, sortowanie, grupowanie (20 minut)

### Podstawowe SELECT

```

-- Wybór wszystkich kolumn
SELECT * FROM klienci;

-- Wybór konkretnych kolumn
SELECT imie, nazwisko, miasto FROM klienci;

-- Wybór z aliasami
SELECT imie AS 'Imię', nazwisko AS 'Nazwisko' FROM klienci;

```

### Filtrowanie z WHERE

```

-- Warunek prosty
SELECT * FROM klienci WHERE miasto = 'Warszawa';

-- Warunki złożone
SELECT * FROM klienci WHERE wiek > 30 AND miasto = 'Warszawa';

-- Zakres wartości
SELECT * FROM produkty WHERE cena BETWEEN 100 AND 1000;

-- Lista wartości
SELECT * FROM klienci WHERE miasto IN ('Warszawa', 'Kraków');

-- Wzorce tekstowe
SELECT * FROM klienci WHERE email LIKE '%@email.com';
SELECT * FROM produkty WHERE nazwa LIKE 'Laptop%';

-- Wartości NULL
SELECT * FROM klienci WHERE telefon IS NULL;

```

### Sortowanie z ORDER BY

```

-- Sortowanie rosnące
SELECT * FROM klienci ORDER BY nazwisko ASC;

-- Sortowanie malejące
SELECT * FROM produkty ORDER BY cena DESC;

-- Sortowanie po wielu kolumnach
SELECT * FROM klienci ORDER BY miasto ASC, wiek DESC;

-- Sortowanie z LIMIT
SELECT * FROM produkty ORDER BY cena DESC LIMIT 3;

```

### Funkcje agregujące

```

-- Liczenie rekordów
SELECT COUNT(*) FROM klienci;
SELECT COUNT(*) AS 'Liczba klientów' FROM klienci;

-- Suma, średnia, min, max
SELECT SUM(wartosc) AS 'Suma zamówień' FROM zamowienia;
SELECT AVG(cena) AS 'Średnia cena' FROM produkty;
SELECT MIN(cena), MAX(cena) FROM produkty;

-- Agregacja z warunkiem
SELECT COUNT(*) FROM klienci WHERE miasto = 'Warszawa';

```

### Grupowanie z GROUP BY

```

-- Grupowanie podstawowe
SELECT miasto, COUNT(*) AS liczba_klientow
FROM klienci
GROUP BY miasto;

-- Grupowanie z funkcjami agregującymi
SELECT kategoria, AVG(cena) AS srednia_cena, COUNT(*) AS liczba_produktow
FROM produkty
GROUP BY kategoria;

-- HAVING - filtrowanie grup
SELECT miasto, COUNT(*) AS liczba_klientow
FROM klienci
GROUP BY miasto
HAVING COUNT(*) > 1;

```

### Funkcje tekstowe i datowe

```

-- Funkcje tekstowe
SELECT UPPER(imie), LOWER(nazwisko) FROM klienci;
SELECT CONCAT(imie, ' ', nazwisko) AS 'Pełne imię' FROM klienci;
SELECT LENGTH(nazwa) FROM produkty;

-- Funkcje datowe
SELECT YEAR(data_rejestracji) FROM klienci;
SELECT MONTH(data_zamowienia), COUNT(*) FROM zamowienia GROUP BY MONTH(data_zamowienia);
SELECT DATEDIFF(NOW(), data_rejestracji) AS dni_od_rejestracji FROM klienci;

```

---

## Część 3: Zapytania z wielu tabel – JOIN, UNION (25 minut)

### INNER JOIN – złączenie wewnętrzne

```

-- Podstawowy INNER JOIN
SELECT k.imie, k.nazwisko, z.data_zamowienia, z.wartosc
FROM klienci k
INNER JOIN zamowienia z ON k.id = z.klient_id;

-- JOIN z warunkami
SELECT k.imie, k.nazwisko, z.wartosc
FROM klienci k
INNER JOIN zamowienia z ON k.id = z.klient_id
WHERE z.status = 'wysłane';

```

### LEFT JOIN – złączenie lewe

```

-- Wszyscy klienci z ich zamówieniami (także ci bez zamówień)
SELECT k.imie, k.nazwisko, z.data_zamowienia, z.wartosc
FROM klienci k
LEFT JOIN zamowienia z ON k.id = z.klient_id;

-- Klienci bez zamówień
SELECT k.imie, k.nazwisko
FROM klienci k
LEFT JOIN zamowienia z ON k.id = z.klient_id
WHERE z.id IS NULL;

```

### RIGHT JOIN – złączenie prawe

```

-- Wszystkie zamówienia z danymi klientów
SELECT k.imie, k.nazwisko, z.data_zamowienia, z.wartosc
FROM klienci k
RIGHT JOIN zamowienia z ON k.id = z.klient_id;

```

### Złączenia wielu tabel

```

-- Stwórzmy tabelę szczegółów zamówień
CREATE TABLE szczegoly_zamowienia (
id INT PRIMARY KEY AUTO_INCREMENT,
zamowienie_id INT,
produkt_id INT,
ilosc INT,
FOREIGN KEY (zamowienie_id) REFERENCES zamowienia(id),
FOREIGN KEY (produkt_id) REFERENCES produkty(id)
);

INSERT INTO szczegoly_zamowienia (zamowienie_id, produkt_id, ilosc) VALUES
(1, 1, 1), (1, 2, 1), (2, 4, 1), (3, 5, 1), (5, 1, 1);

-- JOIN trzech tabel
SELECT k.imie, k.nazwisko, p.nazwa, sz.ilosc
FROM klienci k
INNER JOIN zamowienia z ON k.id = z.klient_id
INNER JOIN szczegoly_zamowienia sz ON z.id = sz.zamowienie_id
INNER JOIN produkty p ON sz.produkt_id = p.id;

```

### UNION – łączenie wyników

```

-- UNION - łączenie bez duplikatów
SELECT imie, nazwisko, 'Klient' AS typ FROM klienci
UNION
SELECT nazwa, '', 'Produkt' AS typ FROM produkty;

-- UNION ALL - łączenie z duplikatami
SELECT miasto FROM klienci
UNION ALL
SELECT kategoria FROM produkty;

-- UNION z warunkami
SELECT imie, nazwisko FROM klienci WHERE miasto = 'Warszawa'
UNION
SELECT imie, nazwisko FROM klienci WHERE wiek > 30;

```

### Zaawansowane JOIN z agregacją

```

-- Suma zamówień dla każdego klienta
SELECT k.imie, k.nazwisko, COUNT(z.id) AS liczba_zamowien, SUM(z.wartosc) AS suma_zamowien
FROM klienci k
LEFT JOIN zamowienia z ON k.id = z.klient_id
GROUP BY k.id, k.imie, k.nazwisko;

-- Najdroższe zamówienie każdego klienta
SELECT k.imie, k.nazwisko, MAX(z.wartosc) AS najdrozsze_zamowienie
FROM klienci k
INNER JOIN zamowienia z ON k.id = z.klient_id
GROUP BY k.id, k.imie, k.nazwisko;

```

---

## Część 4: Zapytania zagnieżdżone (subqueries) (15 minut)

### Subquery w klauzuli WHERE

```

-- Klienci, którzy złożyli zamówienia
SELECT imie, nazwisko
FROM klienci
WHERE id IN (SELECT DISTINCT klient_id FROM zamowienia);

-- Produkty droższe niż średnia
SELECT nazwa, cena
FROM produkty
WHERE cena > (SELECT AVG(cena) FROM produkty);

-- Klienci z zamówieniami powyżej 1000 zł
SELECT imie, nazwisko
FROM klienci
WHERE id IN (SELECT klient_id FROM zamowienia WHERE wartosc > 1000);

```

### Subquery w klauzuli SELECT

```

-- Liczba zamówień dla każdego klienta
SELECT imie, nazwisko,
(SELECT COUNT(*) FROM zamowienia WHERE klient_id = k.id) AS liczba_zamowien
FROM klienci k;

-- Porównanie ceny z średnią w kategorii
SELECT nazwa, cena, kategoria,
(SELECT AVG(cena) FROM produkty p2 WHERE p2.kategoria = p1.kategoria) AS srednia_w_kategorii
FROM produkty p1;

```

### Subquery w klauzuli FROM

```

-- Średnia wartość zamówień według statusu
SELECT status, AVG(wartosc) AS srednia_wartosc
FROM (SELECT * FROM zamowienia WHERE wartosc > 100) AS duze_zamowienia
GROUP BY status;

```

### EXISTS i NOT EXISTS

```

-- Klienci, którzy mają zamówienia
SELECT imie, nazwisko
FROM klienci k
WHERE EXISTS (SELECT 1 FROM zamowienia z WHERE z.klient_id = k.id);

-- Klienci bez zamówień
SELECT imie, nazwisko
FROM klienci k
WHERE NOT EXISTS (SELECT 1 FROM zamowienia z WHERE z.klient_id = k.id);

```

### Subquery skorelowane

```

-- Klienci z zamówieniem o najwyższej wartości
SELECT k.imie, k.nazwisko, z.wartosc
FROM klienci k
INNER JOIN zamowienia z ON k.id = z.klient_id
WHERE z.wartosc = (SELECT MAX(z2.wartosc) FROM zamowienia z2 WHERE z2.klient_id = k.id);

```

---

## Część 5: Widoki (Views) – tworzenie i korzystanie (10 minut)

### Co to są widoki?
**Widok (View)** to wirtualna tabela utworzona na podstawie zapytania SELECT. Nie przechowuje danych, tylko definicję zapytania.

### Tworzenie widoków

```

-- Prosty widok z danymi klientów
CREATE VIEW widok_klienci AS
SELECT id, imie, nazwisko, miasto
FROM klienci;

-- Widok z JOIN
CREATE VIEW zamowienia_szczegoly AS
SELECT k.imie, k.nazwisko, z.data_zamowienia, z.wartosc, z.status
FROM klienci k
INNER JOIN zamowienia z ON k.id = z.klient_id;

-- Widok z agregacją
CREATE VIEW statystyki_klientow AS
SELECT k.id, k.imie, k.nazwisko,
COUNT(z.id) AS liczba_zamowien,
COALESCE(SUM(z.wartosc), 0) AS suma_zamowien
FROM klienci k
LEFT JOIN zamowienia z ON k.id = z.klient_id
GROUP BY k.id, k.imie, k.nazwisko;

```

### Korzystanie z widoków

```

-- Zapytanie do widoku jak do zwykłej tabeli
SELECT * FROM widok_klienci;

-- Filtrowanie w widoku
SELECT * FROM zamowienia_szczegoly WHERE status = 'wysłane';

-- Sortowanie widoku
SELECT * FROM statystyki_klientow ORDER BY suma_zamowien DESC;

```

### Modyfikacja i usuwanie widoków

```

-- Modyfikacja widoku
CREATE OR REPLACE VIEW widok_klienci AS
SELECT id, imie, nazwisko, miasto, email
FROM klienci
WHERE miasto IS NOT NULL;

-- Usuwanie widoku
DROP VIEW widok_klienci;

```

### Zalety widoków

- **Bezpieczeństwo** – ograniczenie dostępu do niektórych kolumn
- **Uproszczenie** – złożone zapytania ukryte za prostym interfejsem
- **Spójność** – ta sama logika używana w wielu miejscach
- **Niezależność** – zmiany w strukturze tabel nie wpływają na aplikacje

```

-- Przykład widoku do raportowania
CREATE VIEW raport_sprzedazy AS
SELECT
DATE_FORMAT(z.data_zamowienia, '%Y-%m') AS miesiac,
COUNT(*) AS liczba_zamowien,
SUM(z.wartosc) AS suma_sprzedazy,
AVG(z.wartosc) AS srednia_wartosc
FROM zamowienia z
WHERE z.status = 'wysłane'
GROUP BY DATE_FORMAT(z.data_zamowienia, '%Y-%m')
ORDER BY miesiac;

```

---

## Część 6: Praktyczne ćwiczenia i podsumowanie (5 minut)

### Kompleksowe ćwiczenie

```

-- 1. Znajdź klientów z Warszawy, którzy złożyli zamówienia powyżej średniej
SELECT DISTINCT k.imie, k.nazwisko, k.miasto
FROM klienci k
INNER JOIN zamowienia z ON k.id = z.klient_id
WHERE k.miasto = 'Warszawa'
AND z.wartosc > (SELECT AVG(wartosc) FROM zamowienia);

-- 2. Stwórz widok z top 3 produktami według ceny
CREATE VIEW top_produkty AS
SELECT nazwa, cena, kategoria
FROM produkty
ORDER BY cena DESC
LIMIT 3;

-- 3. Zapytanie z wieloma JOIN i subquery
SELECT k.imie, k.nazwisko,
COUNT(z.id) AS liczba_zamowien,
(SELECT nazwa FROM produkty p
INNER JOIN szczegoly_zamowienia sz ON p.id = sz.produkt_id
INNER JOIN zamowienia z2 ON sz.zamowienie_id = z2.id
WHERE z2.klient_id = k.id
ORDER BY p.cena DESC
LIMIT 1) AS najdrozszy_produkt
FROM klienci k
LEFT JOIN zamowienia z ON k.id = z.klient_id
GROUP BY k.id, k.imie, k.nazwisko;

```

### Kluczowe informacje dla egzaminu INF.03:

### Podstawowe konstrukcje SELECT:
- `SELECT * FROM tabela` – wszystkie kolumny
- `WHERE` – filtrowanie
- `ORDER BY` – sortowanie
- `GROUP BY` + `HAVING` – grupowanie
- `LIMIT` – ograniczenie wyników

### Typy JOIN:
- `INNER JOIN` – tylko pasujące rekordy
- `LEFT JOIN` – wszystkie z lewej + pasujące z prawej
- `RIGHT JOIN` – wszystkie z prawej + pasujące z lewej

### Funkcje agregujące:
- `COUNT()`, `SUM()`, `AVG()`, `MIN()`, `MAX()`

### Subqueries:
- W `WHERE` – filtrowanie
- W `SELECT` – kolumny obliczane
- `EXISTS` / `NOT EXISTS` – sprawdzanie istnienia

### Widoki:
- `CREATE VIEW` – tworzenie
- `DROP VIEW` – usuwanie

### Zadania do samodzielnego wykonania:

1. Napisz zapytanie pokazujące klientów wraz z liczbą ich zamówień
2. Stwórz widok z produktami dostępnymi na magazynie (ilosc > 0)
3. Znajdź klientów, którzy nie złożyli żadnych zamówień
4. Oblicz średnią wartość zamówień dla każdego miasta
5. Napisz zapytanie z subquery znajdującą najdroższy produkt w każdej kategorii

**Koniec lekcji**
```

<div style="text-align: center">⁂</div>

[^1]: https://www.sqlpedia.pl/select-definiowanie-wyniku/

[^2]: https://www.youtube.com/watch?v=99JAI24Zd24

[^3]: https://kajodata.com/sql/sql-select-from-table/

[^4]: https://www.cognity.pl/blog-sql-podstawy-skladnia-i-zastosowanie

[^5]: https://www.samouczekprogramisty.pl/pobieranie-danych-z-bazy-select/

[^6]: https://programistajava.pl/2025/01/11/podstawy-jezyka-sql-select-insert-update-delete/

[^7]: https://www.cognity.pl/blog-top-50-zapytan-sql

[^8]: https://www.youtube.com/watch?v=P2YT9PvflUM

[^9]: https://devstockacademy.pl/blog/narzedzia-i-automatyzacja/bazy-danych-sql-podstawy-narzedzia-i-najlepsze-praktyki/

