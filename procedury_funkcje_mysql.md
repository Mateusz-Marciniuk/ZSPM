# Lekcja: Procedury składowane i funkcje w MySQL (90 min)

**Środowisko:** MySQL (np. XAMPP / Docker), klient CLI lub phpMyAdmin

## 1. Wprowadzenie: procedury vs funkcje (10 min)

### Co to jest procedura składowana?

- Procedura to nazwany blok kodu SQL zapisany w bazie, uruchamiany poleceniem `CALL`, który może wykonywać wiele operacji (INSERT, UPDATE, DELETE, SELECT).[^2][^1]
- Procedury mogą mieć parametry wejściowe, wyjściowe i wejściowo‑wyjściowe (`IN`, `OUT`, `INOUT`) oraz często używa się ich do operacji biznesowych i batchowych (np. „zamknij dzień sprzedaży”).[^6][^7]


### Co to jest funkcja składowana?

- Funkcja zwraca **jedną wartość** i może być używana w `SELECT`, `WHERE`, `ORDER BY` itp., podobnie jak funkcje wbudowane (`ROUND`, `NOW`).[^4][^3]
- Funkcja w MySQL wymaga deklaracji typu zwracanego (`RETURNS DECIMAL(10,2)` itd.) i zazwyczaj nie powinna modyfikować danych (czyli nie robić INSERT/UPDATE) – służy do obliczeń.[^8][^4]


### Różnice praktyczne

| Cecha | Procedura | Funkcja |
| :-- | :-- | :-- |
| Sposób wywołania | `CALL nazwa(...)` [^1] | `SELECT nazwa(...);` [^3] |
| Zwracanie wartości | Brak lub przez parametry `OUT` [^1] | Zawsze jedna wartość przez `RETURN` [^4] |
| Użycie w SELECT | Nie (pośrednio) [^6] | Tak, w dowolnym wyrażeniu [^3] |
| Typowe zastosowanie | Operacje biznesowe, modyfikacje [^9] | Obliczenia, logika walidacyjna [^10] |


***

## 2. Przygotowanie bazy i danych (15 min)

### 2.1. Utworzenie bazy

W konsoli MySQL lub phpMyAdmin:

```sql
CREATE DATABASE sklep_proc;
USE sklep_proc;
```


### 2.2. Struktura tabel – mini „produkcja”

Tworzymy prostą bazę sprzedażową:

```sql
CREATE TABLE klienci (
    id_klienta INT AUTO_INCREMENT PRIMARY KEY,
    imie       VARCHAR(50),
    nazwisko   VARCHAR(50),
    email      VARCHAR(100),
    limit_kredytowy DECIMAL(10,2),
    aktywny    TINYINT(1) DEFAULT 1
);

CREATE TABLE produkty (
    id_produktu INT AUTO_INCREMENT PRIMARY KEY,
    nazwa       VARCHAR(100),
    cena_netto  DECIMAL(10,2),
    stawka_vat  DECIMAL(4,2) -- np. 0.23 = 23%
);

CREATE TABLE zamowienia (
    id_zamowienia INT AUTO_INCREMENT PRIMARY KEY,
    id_klienta    INT,
    data_zamowienia DATE,
    status        VARCHAR(20), -- np. 'NOWE', 'ZAPLACONE'
    FOREIGN KEY (id_klienta) REFERENCES klienci(id_klienta)
);

CREATE TABLE pozycje_zamowienia (
    id_pozycji    INT AUTO_INCREMENT PRIMARY KEY,
    id_zamowienia INT,
    id_produktu   INT,
    ilosc         INT,
    cena_netto    DECIMAL(10,2),
    FOREIGN KEY (id_zamowienia) REFERENCES zamowienia(id_zamowienia),
    FOREIGN KEY (id_produktu)   REFERENCES produkty(id_produktu)
);
```

Takie tabele odzwierciedlają typowy system zamówień w sklepie internetowym lub ERP.[^9][^11]

### 2.3. Wstawienie przykładowych danych

```sql
INSERT INTO klienci (imie, nazwisko, email, limit_kredytowy, aktywny) VALUES
('Jan', 'Kowalski', 'jan.kowalski@example.com', 5000.00, 1),
('Anna', 'Nowak', 'anna.nowak@example.com', 2000.00, 1),
('Piotr', 'Zielinski', 'piotr.z@example.com', 1000.00, 0);

INSERT INTO produkty (nazwa, cena_netto, stawka_vat) VALUES
('Laptop 15"', 3000.00, 0.23),
('Mysz bezprzewodowa', 80.00, 0.23),
('Monitor 24"', 700.00, 0.23),
('Klawiatura mechaniczna', 250.00, 0.23);

INSERT INTO zamowienia (id_klienta, data_zamowienia, status) VALUES
(1, '2025-12-10', 'NOWE'),
(1, '2025-12-11', 'ZAPLACONE'),
(2, '2025-12-11', 'NOWE');

INSERT INTO pozycje_zamowienia (id_zamowienia, id_produktu, ilosc, cena_netto) VALUES
(1, 1, 1, 3000.00),
(1, 2, 2, 80.00),
(2, 3, 1, 700.00),
(3, 4, 1, 250.00),
(3, 2, 1, 80.00);
```


***

## 3. Tworzenie procedur w MySQL (25 min)

### 3.1. Uwaga o `DELIMITER`

Przy tworzeniu procedur i funkcji trzeba tymczasowo zmienić delimiter, aby MySQL nie zakończył definicji na pierwszym `;`.[^1][^2]

```sql
DELIMITER //
```

Po definicji wracamy do `;`:

```sql
DELIMITER ;
```


### 3.2. Prosta procedura – lista aktywnych klientów

**Cel:** szybko zobaczyć wszystkich aktywnych klientów (typowe w panelu admina).[^11][^9]

```sql
DELIMITER //

CREATE PROCEDURE pokaz_aktywnych_klientow()
BEGIN
    SELECT id_klienta, imie, nazwisko, email, limit_kredytowy
    FROM klienci
    WHERE aktywny = 1;
END //

DELIMITER ;
```

Wywołanie:

```sql
CALL pokaz_aktywnych_klientow();
```


### 3.3. Procedura z parametrem IN – zamówienia klienta

**Cel:** pokazać zamówienia dla konkretnego klienta (np. w call center).[^7][^2]

```sql
DELIMITER //

CREATE PROCEDURE zamowienia_klienta(IN p_id_klienta INT)
BEGIN
    SELECT z.id_zamowienia,
           z.data_zamowienia,
           z.status,
           SUM(pz.ilosc * pz.cena_netto) AS suma_netto
    FROM zamowienia z
    JOIN pozycje_zamowienia pz ON z.id_zamowienia = pz.id_zamowienia
    WHERE z.id_klienta = p_id_klienta
    GROUP BY z.id_zamowienia, z.data_zamowienia, z.status;
END //

DELIMITER ;
```

Wywołanie:

```sql
CALL zamowienia_klienta(1);
```


### 3.4. Procedura z logiką biznesową – dodanie zamówienia

**Cel:** w jednym kroku utworzyć nowe zamówienie (nagłówek) i zwrócić jego ID.[^5][^2]

```sql
DELIMITER //

CREATE PROCEDURE utworz_zamowienie(
    IN  p_id_klienta INT,
    IN  p_data       DATE,
    OUT p_id_zamowienia INT
)
BEGIN
    INSERT INTO zamowienia (id_klienta, data_zamowienia, status)
    VALUES (p_id_klienta, p_data, 'NOWE');

    SET p_id_zamowienia = LAST_INSERT_ID();
END //

DELIMITER ;
```

Wywołanie (w CLI):

```sql
SET @nowe_id := 0;
CALL utworz_zamowienie(1, '2025-12-15', @nowe_id);
SELECT @nowe_id AS nowe_zamowienie;
```

Taki wzorzec pokazuje, jak procedury mogą zastąpić fragment backendu aplikacji (np. PHP/Java).[^12][^9]

***

## 4. Tworzenie funkcji w MySQL (25 min)

### 4.1. Funkcja – obliczanie ceny brutto produktu

**Cel:** w raportach chcemy mieć od razu cenę brutto (netto + VAT).[^10][^4]

```sql
DELIMITER //

CREATE FUNCTION cena_brutto(
    p_cena_netto DECIMAL(10,2),
    p_stawka_vat DECIMAL(4,2)
)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN p_cena_netto * (1 + p_stawka_vat);
END //

DELIMITER ;
```

Użycie funkcji:

```sql
SELECT
    nazwa,
    cena_netto,
    stawka_vat,
    cena_brutto(cena_netto, stawka_vat) AS cena_brutto
FROM produkty;
```

Deklaracja `DETERMINISTIC` informuje, że dla tych samych parametrów funkcja zawsze zwraca ten sam wynik, co pomaga optymalizatorowi.[^3][^4]

### 4.2. Funkcja – poziom klienta wg limitu kredytowego

**Cel:** klasyfikacja klientów (np. do segmentacji marketingowej, limitów rabatów).[^10][^3]

```sql
DELIMITER //

CREATE FUNCTION poziom_klienta(p_limit DECIMAL(10,2))
RETURNS VARCHAR(10)
DETERMINISTIC
BEGIN
    DECLARE poziom VARCHAR(10);

    IF p_limit >= 4000 THEN
        SET poziom = 'PREMIUM';
    ELSEIF p_limit >= 2000 THEN
        SET poziom = 'STANDARD';
    ELSE
        SET poziom = 'BASIC';
    END IF;

    RETURN poziom;
END //

DELIMITER ;
```

Użycie:

```sql
SELECT
    imie,
    nazwisko,
    limit_kredytowy,
    poziom_klienta(limit_kredytowy) AS segment
FROM klienci;
```


### 4.3. Funkcja – rabat dla klienta premium

**Cel:** obliczać cenę po rabacie w raportach (bez modyfikacji danych w tabeli).[^8][^4]

```sql
DELIMITER //

CREATE FUNCTION cena_po_rabacie(
    p_cena DECIMAL(10,2),
    p_rabat_procent DECIMAL(5,2)
)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN p_cena * (1 - p_rabat_procent / 100);
END //

DELIMITER ;
```

Przykładowe użycie: 10% rabatu dla klientów `PREMIUM`:

```sql
SELECT
    k.imie,
    k.nazwisko,
    poziom_klienta(k.limit_kredytowy) AS segment,
    p.nazwa,
    pz.ilosc,
    pz.cena_netto,
    CASE
        WHEN poziom_klienta(k.limit_kredytowy) = 'PREMIUM'
        THEN cena_po_rabacie(pz.cena_netto, 10)
        ELSE pz.cena_netto
    END AS cena_netto_po_rabacie
FROM zamowienia z
JOIN klienci k ON z.id_klienta = k.id_klienta
JOIN pozycje_zamowienia pz ON z.id_zamowienia = pz.id_zamowienia
JOIN produkty p ON pz.id_produktu = p.id_produktu;
```

Takie kombinowanie procedur/funkcji pokazuje typowe zastosowanie w raportach sprzedażowych.[^12][^11]

***

## 5. Zarządzanie procedurami i funkcjami (15 min)

### 5.1. Lista procedur i funkcji

```sql
-- wszystkie rutyny (procedures + functions) w bieżącej bazie
SHOW PROCEDURE STATUS WHERE Db = 'sklep_proc';
SHOW FUNCTION STATUS WHERE Db = 'sklep_proc';
```

Można też obejrzeć definicję:[^5][^2]

```sql
SHOW CREATE PROCEDURE zamowienia_klienta\G
SHOW CREATE FUNCTION cena_brutto\G
```


### 5.2. Modyfikacja i usuwanie

MySQL nie ma `ALTER PROCEDURE` dla zmiany treści – zwykle stosuje się `DROP` + `CREATE` ponownie.[^6][^5]

```sql
DROP PROCEDURE IF EXISTS zamowienia_klienta;
DROP FUNCTION IF EXISTS cena_brutto;
```

Następnie tworzymy na nowo zmodyfikowaną wersję (np. z dodatkowym filtrem daty).[^7][^11]

### 5.3. Uprawnienia do wykonywania

W środowisku produkcyjnym użytkownik aplikacyjny często ma tylko `EXECUTE` na procedurach/funkcjach, a nie pełne prawa do tabel.[^13][^14]

```sql
GRANT EXECUTE ON PROCEDURE sklep_proc.zamowienia_klienta TO 'app_user'@'localhost';
GRANT EXECUTE ON FUNCTION  sklep_proc.cena_brutto       TO 'app_user'@'localhost';
```

Takie podejście zwiększa bezpieczeństwo i pozwala kapsułkować logikę biznesową w bazie.[^15][^13]

***

## 6. Propozycje zadań 

1. **Procedura `raport_dnia`**
    - Parametry: `IN p_data DATE`.
    - Ma zwrócić listę zamówień z tej daty wraz z sumą netto i liczbą pozycji w zamówieniu.[^9][^11]
2. **Procedura `deaktywuj_klienta`**
    - Parametry: `IN p_id_klienta INT`.
    - Ma ustawić `aktywny = 0` oraz zwrócić info (np. przez `SELECT`) ile zamówień klienta istnieje.[^6][^2]
3. **Funkcja `wartosc_zamowienia_brutto(p_id_zamowienia)`**
    - Oblicza sumę brutto zamówienia, używając `cena_brutto`.
    - Użyj jej w zapytaniu: `SELECT id_zamowienia, wartosc_zamowienia_brutto(id_zamowienia) FROM zamowienia;`.[^4][^10]
4. **Funkcja `czy_klient_aktywny(p_id_klienta)`**
    - Zwraca `TINYINT(1)` (1/0), użyj jej w `WHERE` do filtrowania tylko aktywnych klientów.[^8][^3]



[^1]: https://www.mysqltutorial.org/mysql-stored-procedure/getting-started-with-mysql-stored-procedures/

[^2]: https://phoenixnap.com/kb/mysql-stored-procedure

[^3]: https://www.mysqltutorial.org/mysql-stored-procedure/mysql-stored-function/

[^4]: https://www.geeksforgeeks.org/mysql/mysql-creating-stored-function/

[^5]: https://dev.mysql.com/doc/refman/8.4/en/create-procedure.html

[^6]: https://dev.mysql.com/doc/refman/9.2/en/create-procedure.html

[^7]: https://mysqlcode.com/create-mysql-stored-procedure/

[^8]: https://www.tutorialspoint.com/mysql/mysql_create_function.htm

[^9]: https://www.dolthub.com/blog/2024-01-17-writing-mysql-procedures/

[^10]: https://chat2db.ai/resources/blog/mysql-functions-for-beginners

[^11]: https://www.sqlshack.com/learn-mysql-the-basics-of-mysql-stored-procedures/

[^12]: https://javanexus.com/blog/efficient-mysql-stored-procedures

[^13]: https://moldstud.com/articles/p-best-practices-for-managing-mysql-stored-procedures

[^14]: https://www.percona.com/blog/mysql-stored-procedures-problems-and-use-practices/

[^15]: https://www.site24x7.com/learn/sql-stored-procedure.html

[^16]: https://stackoverflow.com/questions/5039324/creating-a-procedure-in-mysql-with-parameters

[^17]: https://www.tutorialspoint.com/mysql/mysql_create_procedure.htm

[^18]: https://stackoverflow.com/questions/6740932/mysql-create-function-syntax

[^19]: https://mysqldesigners.co.uk/top-8-best-practices-for-stored-procedures/

[^20]: https://www.youtube.com/watch?v=oagHZwY9JJY

