# Plan Lekcji: Optymalizacja Bazy Danych MySQL

**Skrypt startowy:**

```
DROP DATABASE IF EXISTS optymalizacja_demo;
CREATE DATABASE optymalizacja_demo;
USE optymalizacja_demo;

CREATE TABLE pracownicy (
    id INT AUTO_INCREMENT PRIMARY KEY,
    imie VARCHAR(50),
    nazwisko VARCHAR(50),
    departament VARCHAR(50),
    pensja DECIMAL(10,2),
    data_zatrudnienia DATE
);

-- Wstaw 10000 rekordów (demo z dużą ilością danych)
DELIMITER //
CREATE PROCEDURE WstawDane()
BEGIN
    DECLARE i INT DEFAULT 1;
    WHILE i <= 10000 DO
        INSERT INTO pracownicy (imie, nazwisko, departament, pensja, data_zatrudnienia)
        VALUES (CONCAT('Imie', i), CONCAT('Nazwisko', i), CONCAT('Dept', MOD(i,10)+1), RAND()*10000+2000, DATE_SUB(NOW(), INTERVAL FLOOR(RAND()*3650) DAY));
        SET i = i + 1;
    END WHILE;
END //
DELIMITER ;

CALL WstawDane();
DROP PROCEDURE WstawDane;
```

## Wstęp do Optymalizacji (10 min)

Optymalizacja bazy MySQL poprawia szybkość zapytań, gdy dane rosną.
Główne problemy: pełne skanowanie tabeli (full table scan) zamiast użycia indeksów.
Indeksy działają jak spis treści w książce – przyspieszają wyszukiwanie.

## Demo 1: Problem Bez Indeksów (15 min)

**Pokaz:** Uruchom zapytanie i zmierz czas (użyj `SET profiling=1; SHOW PROFILES;`).

```
SET profiling=1;
SELECT * FROM pracownicy WHERE nazwisko = 'Nazwisko5000';
SHOW PROFILES;
```

**Oczekiwany wynik:** Wolne (~0.1-1s), full scan (sprawdź `EXPLAIN` poniżej).

**Wyjaśnienie:** MySQL sprawdza każdy rekord (10k razy). To nie skaluje się dla milionów danych.

## Tworzenie Indeksów (15 min)

**Skrypt (wklej):**

```
CREATE INDEX idx_nazwisko ON pracownicy(nazwisko);
```

**Pokaz po indeksie:**

```
SELECT * FROM pracownicy WHERE nazwisko = 'Nazwisko5000';
```

**Czas:** Teraz błyskawiczny (~0.001s).

**Dodatkowe indeksy:**

```
CREATE INDEX idx_dept_pensja ON pracownicy(departament, pensja);
```

Indeksy przyspieszają WHERE, JOIN, ORDER BY, ale spowalniają INSERT/UPDATE.

## Narzędzie EXPLAIN (20 min)

**Pokaz (przed indeksem, usuń indeks jeśli potrzeba: `DROP INDEX idx_nazwisko ON pracownicy;`):**

```
EXPLAIN SELECT * FROM pracownicy WHERE nazwisko = 'Nazwisko5000';
```

**Interpretacja (proste):**

- `type: ALL` = full scan (złe).
- `rows: 10000` = sprawdza dużo.

**Po indeksie:**

```
EXPLAIN SELECT * FROM pracownicy WHERE nazwisko = 'Nazwisko5000';
```

- `type: ref` lub `index` = używa indeksu (dobre).
- `rows: 1` = szybkie.

**Ćwiczenie dla uczniów:** Stwórzcie zapytanie na `departament='Dept1'` i sprawdźcie EXPLAIN przed/po indeksie.

## Inne Techniki Optymalizacji (15 min)

- Unikaj SELECT * : Używaj konkretnych kolumn.

```
SELECT id, nazwisko FROM pracownicy WHERE nazwisko='Nazwisko5000';  -- Szybsze
```

- **LIMIT:** Ogranicz wyniki.

```
SELECT * FROM pracownicy LIMIT 10;
```

- **Kompozytowe indeksy:** Na wiele kolumn (lewa zasada: pierwszy kolumna musi pasować).
- **Konfiguracja:** Zwiększ `innodb_buffer_pool_size` w my.cnf (dla prod).

**Pokaz czasów z profilingiem po każdej zmianie.**

## Ćwiczenia Praktyczne (5 min)

1. Dodaj indeks na `data_zatrudnienia` i sprawdź EXPLAIN dla `WHERE data_zatrudnienia > '2020-01-01'`.
2. Porównaj czasy z/bez LIMIT 100.


## Zaawansowane Metody Optymalizacji (dodaj 10 min)

### Aktualizacja Statystyk Tabeli

Użyj `ANALYZE TABLE`, by odświeżyć statystyki indeksów po dużych zmianach danych – poprawia decyzje optimizera.
**Skrypt demo:**

```
ANALYZE TABLE pracownicy;
EXPLAIN SELECT * FROM pracownicy WHERE nazwisko = 'Nazwisko5000';  -- Lepsze rows po analyze
```

Uruchom przed/po wstawieniu nowych danych (np. INSERT 1000 rekordów). Blokuje tabelę krótko, więc off-peak.

### Defragmentacja Tabeli

`OPTIMIZE TABLE` usuwa fragmentację i zwalnia miejsce po DELETE/UPDATE.
**Skrypt:**

```
OPTIMIZE TABLE pracownicy;  -- Pokazuje status: status=OK
```

Dla InnoDB: rebuild indeksów. Używać okresowo.

### Wybór Typów Danych

Używaj najmniejszych typów: INT zamiast BIGINT, VARCHAR(20) zamiast TEXT.
**Przykład refaktoryzacji:**

```
ALTER TABLE pracownicy MODIFY nazwisko VARCHAR(30) NOT NULL;  -- Oszczędza miejsce
```

Mniejsze dane = szybsze I/O i cache.

### Log Wolnych Zapytań

Włącz w my.cnf (lub sesji): `SET GLOBAL slow_query_log=1; SET GLOBAL long_query_time=1; SET GLOBAL log_queries_not_using_indexes=1;`.
Sprawdź: `SHOW VARIABLES LIKE 'slow_query%';`. Analizuj plik slow.log narzędziami jak pt-query-digest.

### Partycjonowanie (wprowadzenie)

Dla dużych tabel (>mln rekordów): dziel na partycje po dacie/departamencie.
**Prosty przykład (nowa tabela):**

```
CREATE TABLE pracownicy_part (
    id INT AUTO_INCREMENT PRIMARY KEY,
    data_zatrudnienia DATE,
    nazwisko VARCHAR(50)
) PARTITION BY RANGE (YEAR(data_zatrudnienia)) (
    PARTITION p2010 VALUES LESS THAN (2011),
    PARTITION p2020 VALUES LESS THAN (2021),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);
```

Pruning: zapytania skanują tylko partycję.

**Ćwiczenie rozszerzone:** Uruchom ANALYZE i OPTIMIZE na tabeli, porównaj EXPLAIN. Dodaj log slow_query i przetestuj wolne zapytanie.

Te metody uzupełniają indeksy – stosuj w kolejności: query → schema → config → maintenance.
## Podsumowanie i Q\&A (5 min)

Klucz: Indeksy + EXPLAIN = podstawa optymalizacji. Monitoruj w Grafana/Zabbix (dla zaawansowanych).
**Zadanie domowe:** Zoptymalizuj zapytanie JOIN na dwóch tabelach (stwórz drugą tabelę podobnie).


