### Lekcja: Zaawansowane transakcje w MySQL 8 – ACID, poziomy izolacji i praktyczne transfery z błędami

---

## Cele lekcji

Po zakończeniu lekcji uczeń będzie potrafił:

1. **Wyjaśnić zasady ACID** i ich znaczenie w systemach transakcyjnych
2. **Stosować polecenia transakcyjne** (START TRANSACTION, COMMIT, ROLLBACK, SAVEPOINT) w praktycznych scenariuszach
3. **Konfigurować poziomy izolacji transakcji** (READ UNCOMMITTED, READ COMMITTED, REPEATABLE READ, SERIALIZABLE) i rozumieć różnice między nimi
4. **Identyfikować i debugować problemy** związane z współbieżnością (deadlocki, brudne odczyty, phantom reads)
5. **Implementować bezpieczne transfery bankowe** z obsługą błędów i wycofywaniem zmian

---

## Przebieg lekcji

**Agenda:**
- 0-10 min: Wprowadzenie, logowanie do MySQL
- 10-30 min: Teoria ACID i poziomy izolacji
- 30-80 min: Praktyka – transfery, błędy, współbieżność
- 80-90 min: Podsumowanie i zadanie domowe

**Zadanie:**  
Zalogujcie się do swoich maszyn i sprawdźcie połączenie z MySQL:

```bash
mysql -u uczen01 -p
```

*Hasło: Pass123!*

```sql
SHOW DATABASES;
USE bank_test;
SHOW TABLES;
```


---

### 2. Teoria – Zasady ACID i poziomy izolacji (20 minut)

#### 2.1 Czym jest transakcja?

Transakcja to sekwencja operacji SQL traktowana jako **pojedyncza jednostka pracy**. Albo wykonują się wszystkie operacje, albo żadna.

**Przykład klasyczny:**  
Przelew 100 zł z konta A na konto B:

```sql
UPDATE konto SET saldo = saldo - 100 WHERE id = 1; -- konto A
UPDATE konto SET saldo = saldo + 100 WHERE id = 2; -- konto B
```

Jeśli między tymi operacjami wystąpi błąd (np. zanik zasilania), **bez transakcji** może dojść do sytuacji, gdzie z konta A zniknie 100 zł, ale na konto B nic nie wpłynie!

**Z transakcją:**

```sql
START TRANSACTION;
UPDATE konto SET saldo = saldo - 100 WHERE id = 1;
UPDATE konto SET saldo = saldo + 100 WHERE id = 2;
COMMIT; -- dopiero teraz zmiany są trwałe
```

Albo:

```sql
ROLLBACK; -- cofnij wszystko, jeśli coś poszło nie tak
```

#### 2.2 Zasady ACID

| Zasada | Angielski | Opis | Przykład |
|--------|-----------|------|----------|
| **A** | Atomicity | Niepodzielność – wszystko albo nic | Transfer: oba UPDATE albo żaden |
| **C** | Consistency | Spójność – baza zawsze w stanie poprawnym | Suma sald przed = suma sald po |
| **I** | Isolation | Izolacja – transakcje nie "widzą" swoich niepełnych zmian | Transakcja A nie widzi UPDATE z transakcji B przed jej COMMIT |
| **D** | Durability | Trwałość – po COMMIT dane przetrwają awarię | Po COMMIT restart serwera nie straci danych |

Skrót **ACID** – to podstawa każdej rozmowy o bazach transakcyjnych.

#### 2.3 Poziomy izolacji transakcji

MySQL (InnoDB) oferuje 4 poziomy izolacji, zgodnie ze standardem SQL:

| Poziom | Brudne odczyty | Niepowtarzalne odczyty | Fantomowe wiersze | Wydajność |
|--------|----------------|------------------------|-------------------|-----------|
| **READ UNCOMMITTED** | TAK (możliwe) | TAK | TAK | Najwyższa |
| **READ COMMITTED** | NIE | TAK | TAK | Wysoka |
| **REPEATABLE READ** (domyślny) | NIE | NIE | NIE (w InnoDB!) | Średnia |
| **SERIALIZABLE** | NIE | NIE | NIE | Najniższa |

**Definicje:**
- **Brudny odczyt (dirty read):** Odczyt niezatwierdzonych zmian z innej transakcji
- **Niepowtarzalny odczyt (non-repeatable read):** Ten sam SELECT zwraca inne wartości w tej samej transakcji
- **Fantomowe wiersze (phantom read):** Ten sam SELECT zwraca różną liczbę wierszy

Domyślnie MySQL używa **REPEATABLE READ**. To dobry kompromis między wydajnością a bezpieczeństwem. 

#### 2.4 Polecenia MySQL

```sql
-- Rozpoczęcie transakcji
START TRANSACTION;
-- lub
BEGIN;

-- Zatwierdzenie zmian
COMMIT;

-- Wycofanie zmian
ROLLBACK;

-- Punkt zapisu (częściowe wycofanie)
SAVEPOINT nazwa_punktu;
ROLLBACK TO SAVEPOINT nazwa_punktu;

-- Ustawienie poziomu izolacji (dla następnej transakcji)
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- Ustawienie poziomu dla sesji
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;

-- Sprawdzenie poziomu
SELECT @@transaction_isolation;
```

**Uwaga:** Niektóre operacje DDL (CREATE, DROP, ALTER) wykonują **implicit commit** – automatycznie zatwierdzają poprzednią transakcję!

Przygotujcie dwa okna terminala – będziemy symulować dwóch użytkowników

---

### 3. Praktyka – Transfery i izolacja (50 minut)

#### 3.1 Przygotowanie środowiska (5 minut)

Wykonać poniższy skrypt na **jednym** terminalu, żeby stworzyć tabelę kont:

```sql
USE bank_test;

DROP TABLE IF EXISTS konto;

CREATE TABLE konto (
    id INT PRIMARY KEY AUTO_INCREMENT,
    wlasciciel VARCHAR(100) NOT NULL,
    saldo DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    CHECK (saldo >= 0)
) ENGINE=InnoDB;

INSERT INTO konto (wlasciciel, saldo) VALUES
('Jan Kowalski', 1000.00),
('Anna Nowak', 500.00),
('Piotr Wiśniewski', 2500.00),
('Maria Zielińska', 100.00);

SELECT * FROM konto;
```

**Oczekiwany wynik:**

```
+----+-------------------+---------+
| id | wlasciciel        | saldo   |
+----+-------------------+---------+
|  1 | Jan Kowalski      | 1000.00 |
|  2 | Anna Nowak        |  500.00 |
|  3 | Piotr Wiśniewski  | 2500.00 |
|  4 | Maria Zielińska   |  100.00 |
+----+-------------------+---------+
```

 `CHECK (saldo >= 0)` – to constraint zapobiegający debetowi. Teraz wyłączmy autocommit:

```sql
SET autocommit = 0;
SELECT @@autocommit; -- powinno być 0
```

**Zrzut ekranu 1:** Terminal MySQL z wynikiem `SELECT * FROM konto` pokazujący 4 konta z saldami początkowymi.

---

#### 3.2 Podstawowy transfer z COMMIT/ROLLBACK (10 minut)

**Ćwiczenie 1: Udany transfer**

Jan (id=1) przelewa 200 zł Annie (id=2). 

```sql
START TRANSACTION;

UPDATE konto SET saldo = saldo - 200 WHERE id = 1;
UPDATE konto SET saldo = saldo + 200 WHERE id = 2;

-- Sprawdźmy stan PRZED zatwierdzeniem
SELECT * FROM konto WHERE id IN (1, 2);
```

**Wynik:**

```
+----+---------------+--------+
| id | wlasciciel    | saldo  |
+----+---------------+--------+
|  1 | Jan Kowalski  | 800.00 |
|  2 | Anna Nowak    | 700.00 |
+----+---------------+--------+
```

Teraz otwórzcie **drugie okno terminala**, zalogujcie się do MySQL i wykonajcie:

```sql
USE bank_test;
SELECT * FROM konto WHERE id IN (1, 2);
```

**Pytanie:** Co widzicie? Stare wartości (1000 i 500) czy nowe (800 i 700)?

Domyślny poziom REPEATABLE READ chroni przed brudnymi odczytami. Wróćmy do pierwszego terminala i zatwierdźmy:

```sql
COMMIT;
```

Teraz w drugim terminalu:

```sql
SELECT * FROM konto WHERE id IN (1, 2);
```

Teraz widzicie nowe wartości!

**Ćwiczenie 2: Transfer z ROLLBACK**

Piotr (id=3) próbuje przelać 3000 zł Marii (id=4), ale ma tylko 2500 zł. Co się stanie?

Terminal 1:

```sql
START TRANSACTION;

UPDATE konto SET saldo = saldo - 3000 WHERE id = 3;
-- ERROR 3819 (HY000): Check constraint 'konto_chk_1' is violated.
```

Constraint blokuje operację! Ale transakcja wciąż trwa. Sprawdźmy:

```sql
SELECT * FROM konto WHERE id = 3;
```

Wartość się nie zmieniła (2500). Wycofajmy transakcję:

```sql
ROLLBACK;
```

**Alternatywny scenariusz** (bez constrainta):

```sql
START TRANSACTION;

UPDATE konto SET saldo = saldo - 300 WHERE id = 3;
UPDATE konto SET saldo = saldo + 300 WHERE id = 4;

-- Ups, pomyłka! Chcieliśmy 30, nie 300
ROLLBACK;

SELECT * FROM konto WHERE id IN (3, 4);
-- Wartości jak przed transakcją
```

---

#### 3.3 SAVEPOINT – częściowe wycofanie (8 minut)

Czasem chcemy wycofać tylko część operacji. Służą do tego punkty zapisu (savepoints).

**Scenariusz:** Wykonujemy 3 przelewy, ale trzeci jest błędny:

```sql
START TRANSACTION;

-- Przelew 1: Jan -> Anna (100 zł)
UPDATE konto SET saldo = saldo - 100 WHERE id = 1;
UPDATE konto SET saldo = saldo + 100 WHERE id = 2;
SAVEPOINT przelew1;

-- Przelew 2: Anna -> Piotr (50 zł)
UPDATE konto SET saldo = saldo - 50 WHERE id = 2;
UPDATE konto SET saldo = saldo + 50 WHERE id = 3;
SAVEPOINT przelew2;

-- Przelew 3: Piotr -> Maria (BŁĘDNA KWOTA 5000 zł)
UPDATE konto SET saldo = saldo - 5000 WHERE id = 3;
-- ERROR!

-- Wycofujemy tylko przelew 3
ROLLBACK TO SAVEPOINT przelew2;

-- Zatwierdzamy przelewy 1 i 2
COMMIT;

SELECT * FROM konto;
```

**Oczekiwany wynik:**  
Jan: 700 (było 800 - 100)  
Anna: 750 (było 700 + 100 - 50)  
Piotr: 2550 (było 2500 + 50)  
Maria: 100 (bez zmian)

Dzięki SAVEPOINT uratowaliśmy dwa prawidłowe przelewy, nie tracąc całej transakcji!

**Zrzut ekranu 2:** Terminal pokazujący sekwencję poleceń z SAVEPOINT i końcowy SELECT z nowymi saldami.

---

#### 3.4 Poziomy izolacji w praktyce (15 minut)

Przygotujcie DWA terminale obok siebie. Oznaczymy je jako **Terminal A** i **Terminal B**.

**Eksperyment 1: READ UNCOMMITTED (brudne odczyty)**

Terminal A:

```sql
SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
START TRANSACTION;
SELECT * FROM konto WHERE id = 1;
-- Jan ma 700 zł
```

Terminal B:

```sql
SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
START TRANSACTION;
UPDATE konto SET saldo = saldo + 5000 WHERE id = 1;
-- JAN dostaje "premię" 5000 zł (jeszcze nie zatwierdzone!)
```

Terminal A:

```sql
SELECT * FROM konto WHERE id = 1;
-- Co widzicie? 5700 zł (brudny odczyt!)
```

Terminal B:

```sql
ROLLBACK; -- Ups, pomyłka, anulujemy premię
```

Terminal A:

```sql
SELECT * FROM konto WHERE id = 1;
-- Znowu 700 zł! Dane "zniknęły"
COMMIT;
```

Problem? Terminal A widział dane, które **nigdy nie zostały zatwierdzone**. To brudny odczyt. W aplikacji bankowej to byłaby katastrofa!

**Eksperyment 2: REPEATABLE READ (ochrona przed niepowtarzalnymi odczytami)**

Terminal A:

```sql
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
START TRANSACTION;
SELECT saldo FROM konto WHERE id = 1;
-- 700 zł
```

Terminal B:

```sql
START TRANSACTION;
UPDATE konto SET saldo = saldo + 100 WHERE id = 1;
COMMIT;
```

Terminal A:

```sql
SELECT saldo FROM konto WHERE id = 1;
-- Wciąż 700 zł! (snapshot z początku transakcji)
COMMIT;

SELECT saldo FROM konto WHERE id = 1;
-- Teraz 800 zł (widać zmianę po naszym COMMIT)
```

REPEATABLE READ gwarantuje, że w ramach jednej transakcji ten sam SELECT zawsze zwraca te same wartości. To tzw. **snapshot isolation**.

**Eksperyment 3: Phantom reads (fantomowe wiersze)**

Terminal A:

```sql
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
START TRANSACTION;
SELECT COUNT(*) FROM konto WHERE saldo > 1000;
-- Załóżmy wynik: 1 (tylko Piotr z 2550)
```

Terminal B:

```sql
START TRANSACTION;
INSERT INTO konto (wlasciciel, saldo) VALUES ('Tomasz Nowak', 1500.00);
COMMIT;
```

Terminal A:

```sql
SELECT COUNT(*) FROM konto WHERE saldo > 1000;
-- Teraz wynik: 2 (pojawił się "fantom"!)
COMMIT;
```

W READ COMMITTED nowe wiersze (phantom rows) mogą się pojawić. W REPEATABLE READ w MySQL (InnoDB) to nie wystąpi dzięki Next-Key Locks!

**Tabela porównawcza do dyskusji:**

```
Scenariusz testowy (2 terminale):
A: START TRANSACTION; SELECT saldo FROM konto WHERE id=1;
B: UPDATE konto SET saldo=9999 WHERE id=1; COMMIT;
A: SELECT saldo FROM konto WHERE id=1;

READ UNCOMMITTED:  Może pokazać 9999 nawet przed COMMIT w B
READ COMMITTED:    Pokaże starą wartość, po COMMIT B: 9999
REPEATABLE READ:   Pokaże starą wartość nawet po COMMIT B
SERIALIZABLE:      Jak REPEATABLE READ + blokady
```

**Zrzut ekranu 3:** Dwa terminale obok siebie – jeden z `SELECT` pokazującym starą wartość, drugi z `UPDATE` i `COMMIT`.

---

#### 3.5 Deadlock – symulacja konfliktu (12 minut)

Deadlock to sytuacja, w której dwie transakcje nawzajem się blokują, czekając na zwolnienie zasobów. MySQL automatycznie wykrywa deadlocki i wycofuje jedną z transakcji.

**Symulacja:**

Terminal A:

```sql
START TRANSACTION;
UPDATE konto SET saldo = saldo - 100 WHERE id = 1;
-- Transakcja A trzyma blokadę na wierszu id=1
```

Terminal B:

```sql
START TRANSACTION;
UPDATE konto SET saldo = saldo - 50 WHERE id = 2;
-- Transakcja B trzyma blokadę na wierszu id=2
```

Terminal A:

```sql
UPDATE konto SET saldo = saldo + 100 WHERE id = 2;
-- Czeka na zwolnienie blokady przez B...
```

Terminal B:

```sql
UPDATE konto SET saldo = saldo + 50 WHERE id = 1;
-- Próbuje uzyskać blokadę na id=1, którą trzyma A
-- ERROR 1213 (40001): Deadlock found when trying to get lock; 
-- try restarting transaction
```

MySQL wykrył deadlock i wycofał transakcję B! Terminal A może teraz dokończyć:

Terminal A:

```sql
-- UPDATE na id=2 się wykonuje
COMMIT;
```

**Jak uniknąć deadlocków?**
1. Zawsze aktualizuj wiersze w tej samej kolejności (np. rosnąco po id)
2. Trzymaj transakcje krótkie
3. Używaj odpowiednich indeksów (zmniejszają czas blokad)

**Analiza deadlocka:**

```sql
SHOW ENGINE INNODB STATUS\G
```

W sekcji `LATEST DETECTED DEADLOCK` znajdziecie szczegóły konfliktu.

Kto widzi w swoim statusie deadlock? Skopiujcie fragment do notatek – to przydatne przy debugowaniu!

**Zrzut ekranu 4:** Fragment wyniku `SHOW ENGINE INNODB STATUS` z sekcją LATEST DETECTED DEADLOCK.

---

#### 3.6 Praktyczny skrypt transferu z obsługą błędów (ostatnie minuty praktyki)

Na koniec – jak w prawdziwej aplikacji – skrypt z obsługą wyjątków. W MySQL Workbench lub pliku .sql:

```sql
DELIMITER //

CREATE PROCEDURE transfer_bezpieczny(
    IN from_id INT,
    IN to_id INT,
    IN kwota DECIMAL(10,2)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Transfer nieudany - wycofano zmiany' AS status;
    END;
    
    START TRANSACTION;
    
    -- Sprawdź saldo
    IF (SELECT saldo FROM konto WHERE id = from_id) < kwota THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Niewystarczające środki';
    END IF;
    
    -- Wykonaj transfer
    UPDATE konto SET saldo = saldo - kwota WHERE id = from_id;
    UPDATE konto SET saldo = saldo + kwota WHERE id = to_id;
    
    COMMIT;
    SELECT 'Transfer udany' AS status;
END //

DELIMITER ;

-- Test:
CALL transfer_bezpieczny(1, 2, 100);
CALL transfer_bezpieczny(4, 1, 500); -- Powinno się nie udać (Maria ma 100 zł)
```

Ten wzorzec używa `DECLARE EXIT HANDLER` do automatycznego ROLLBACK przy błędzie. To wzorzec produkcyjny!

---

### 4. Podsumowanie i ewaluacja (10 minut)



**Szybki quiz (ustnie):**
1. Co oznacza "A" w ACID? *(Atomicity – niepodzielność)*
2. Który poziom izolacji jest domyślny w MySQL? *(REPEATABLE READ)*
3. Co to jest deadlock? *(Wzajemna blokada transakcji)*
4. Jak wycofać tylko część transakcji? *(SAVEPOINT + ROLLBACK TO SAVEPOINT)*
5. Czy po `ALTER TABLE` trzeba COMMIT? *(Nie – implicit commit!)*

**Kluczowe wnioski:**
- Transakcje = bezpieczeństwo danych (ACID)
- Poziomy izolacji = kompromis między wydajnością a spójnością
- Deadlocki się zdarzają – trzeba je obsługiwać
- W produkcji: zawsze używaj EXIT HANDLER lub try-catch w kodzie aplikacji


---

## Ćwiczenia podsumowujące

### Ćwiczenie rozszerzone (na lekcji lub jako praca domowa):

**Zadanie:** Stwórz system logowania transakcji.

1. Utwórz tabelę `transfer_log`:

```sql
CREATE TABLE transfer_log (
    id INT PRIMARY KEY AUTO_INCREMENT,
    from_id INT,
    to_id INT,
    kwota DECIMAL(10,2),
    status ENUM('sukces', 'błąd'),
    data_czas TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    opis VARCHAR(255)
) ENGINE=InnoDB;
```

2. Zmodyfikuj procedurę `transfer_bezpieczny`, żeby logowała każdy transfer (udany i nieudany)

3. Przetestuj z różnymi scenariuszami:
   - Udany transfer
   - Niewystarczające środki
   - Próba transferu ujemnej kwoty (dodaj walidację!)

---

## Zadanie domowe

**Zadanie główne:**  
Napisz skrypt SQL (plik `transfer_system.sql`), który:

1. Tworzy bazę `moj_bank` z tabelami:
   - `konta` (id, nazwa_klienta, saldo, waluta)
   - `historia_transferow` (id, from_konta_id, to_konta_id, kwota, status, timestamp)

2. Implementuje procedurę składowaną `multi_transfer`, która:
   - Przyjmuje jako parametr JSON z listą transferów (np. `[{from: 1, to: 2, kwota: 100}, {from: 2, to: 3, kwota: 50}]`)
   - Wykonuje wszystkie transfery w jednej transakcji
   - Jeśli którykolwiek się nie powiedzie, wycofuje wszystko
   - Loguje każdy transfer do `historia_transferow`

3. Testuje procedurę z minimum 3 scenariuszami:
   - Wszystkie transfery poprawne
   - Jeden transfer z niewystarczającymi środkami (całość się wycofuje)
   - Deadlock (symulacja dwóch sesji)
---

## Materiały dodatkowe i źródła

### Dokumentacja:
- [MySQL 8.0 Reference Manual – Transakcje](https://dev.mysql.com/doc/refman/8.0/en/commit.html)
- [InnoDB Transaction Model](https://dev.mysql.com/doc/refman/8.0/en/innodb-transaction-model.html)
- [Isolation Levels](https://dev.mysql.com/doc/refman/8.0/en/innodb-transaction-isolation-levels.html)

### Polecane narzędzia do praktyki:
- **Docker MySQL:** `docker run --name mysql-lab -e MYSQL_ROOT_PASSWORD=root -p 3306:3306 -d mysql:8.0`
- **MySQL Workbench** – GUI do wizualizacji transakcji
- **Percona Toolkit** – pt-deadlock-logger do analizy deadlocków

### Ciekawostki:
- W PostgreSQL domyślny poziom to READ COMMITTED (nie REPEATABLE READ jak w MySQL)
- Oracle używa Multi-Version Concurrency Control (MVCC) podobnie jak InnoDB
- Deadlocki w dużych systemach (np. banki) monitoruje się w czasie rzeczywistym
---


### Typowe problemy i rozwiązania:

**Problem:** Uczniowie nie widzą zmian w drugim terminalu.  
**Rozwiązanie:** Sprawdź `autocommit` (powinno być 0) i czy wykonali START TRANSACTION.

**Problem:** "ERROR 3819: Check constraint violated"  
**Rozwiązanie:** To dobrze! Pokazuje działanie constrainta. Wyjaśnij, że to właśnie ochrona przed debetami.

**Problem:** Deadlock nie występuje.  
**Rozwiązanie:** Upewnij się, że oba terminale wykonują UPDATE w przeciwnej kolejności (A: 1→2, B: 2→1).

**Problem:** Uczniowie gubią się w eksperymentach z izolacją.  
**Rozwiązanie:** Narysuj na tablicy timeline transakcji A i B z momentami START/COMMIT/SELECT. Wizualizacja bardzo pomaga!
---
