# Lekcja: Triggery w SQL (MySQL)

***

## 2. Przygotowanie środowiska (10 min)

```sql
CREATE DATABASE IF NOT EXISTS lekcja_triggery;
USE lekcja_triggery;
```

3. Następnie utwórzcie wspólnie dwie tabele:

```sql
CREATE TABLE produkty (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nazwa VARCHAR(100),
    cena DECIMAL(10,2),
    stan_magazynowy INT
);

CREATE TABLE log_zmian (
    id INT AUTO_INCREMENT PRIMARY KEY,
    data_zmiany DATETIME,
    opis VARCHAR(255)
);
```


Wyjaśnij w prostych słowach:

- `produkty` – normalna tabela z towarami,
- `log_zmian` – tabela, w której będziemy zapisywać, co się stało (ktoś coś dodał/zmienił).

***

## 3. Wprowadzenie teoretyczne (10–15 min)

- Trigger to **automatyczna reakcja** bazy danych na jakieś zdarzenie.
- Zdarzeniem może być: dodanie rekordu (`INSERT`), modyfikacja (`UPDATE`), usunięcie (`DELETE`).
- Trigger uruchamia się **sam**, bez dopisywania go w każdym zapytaniu.

Możesz użyć analogii:

> Trigger jest jak czujnik ruchu w magazynie – gdy ktoś wejdzie (zdarzenie), automatycznie zapala się światło (akcja).

- „W jakich sytuacjach w firmie przydałoby się automatyczne logowanie zmian w danych?”
(np. zmiana pensji, zmiana stanu magazynu, usunięcie klienta).


> Trigger – fragment kodu SQL, który uruchamia się automatycznie **przed** lub **po** operacji `INSERT`, `UPDATE` lub `DELETE` na tabeli.

***

## 4. Składnia triggera – wersja uproszczona (10 min)

Pokaż najprostszy **szablon**:

```sql
CREATE TRIGGER nazwa_triggera
BEFORE INSERT ON nazwa_tabeli
FOR EACH ROW
BEGIN
    -- tutaj kod, który ma się wykonać
END;
```

- `CREATE TRIGGER` – tworzenie nowego triggera,
- `BEFORE` / `AFTER` – czy kod ma się wykonać **przed** czy **po** operacji,
- `INSERT / UPDATE / DELETE` – przy jakiej operacji,
- `FOR EACH ROW` – trigger uruchamia się dla **każdego** wiersza osobno,
- `BEGIN ... END` – blok kodu, w środku możemy mieć kilka instrukcji.
- `NEW` – dane nowego wiersza (który wstawiamy / po UPDATE),
- `OLD` – dane starego wiersza (przed UPDATE lub DELETE).


***

## 5. Trigger `BEFORE INSERT` – poprawianie danych (20 min)

### 5.1. Cel

Automatycznie ustawić minimalną cenę produktu (np. nie mniej niż 1.00) **zanim** rekord zostanie dodany.

### 5.2. Tworzenie triggera

```sql
DELIMITER $$

CREATE TRIGGER produkty_min_cena
BEFORE INSERT ON produkty
FOR EACH ROW
BEGIN
    IF NEW.cena < 1.00 THEN
        SET NEW.cena = 1.00;
    END IF;
END$$

DELIMITER ;
```

Wytłumacz:

- `DELIMITER $` – tymczasowo zmieniamy znak końca polecenia z `;` na `$`,
- dzięki temu możemy mieć średniki wewnątrz triggera,
- na końcu wracamy do normalnego `;`.


### 5.3. Testowanie triggera

```sql
INSERT INTO produkty (nazwa, cena, stan_magazynowy)
VALUES ('Ołówek', 0.50, 100);

INSERT INTO produkty (nazwa, cena, stan_magazynowy)
VALUES ('Zeszyt', 2.50, 50);

SELECT * FROM produkty;
```

Omów wyniki:

- cena `Ołówek` powinna być ustawiona na 1.00 (trigger poprawił z 0.50),
- `Zeszyt` pozostaje z ceną 2.50.

- „Dlaczego pierwszy produkt ma inną cenę niż wpisaliśmy?”

– odpowiedź: trigger automatycznie zabezpiecza dane.

***

## 6. Trigger `AFTER INSERT` – logowanie zmian (20 min)

### 6.1. Cel

Po dodaniu produktu zapisać informację do tabeli `log_zmian`.

### 6.2. Tworzenie triggera

```sql
DELIMITER $$

CREATE TRIGGER log_po_dodaniu_produktu
AFTER INSERT ON produkty
FOR EACH ROW
BEGIN
    INSERT INTO log_zmian (data_zmiany, opis)
    VALUES (NOW(), CONCAT('Dodano produkt: ', NEW.nazwa, ', cena: ', NEW.cena));
END$$

DELIMITER ;
```

Wyjaśnij:

- `AFTER INSERT` – trigger wykona się **po** zapisaniu produktu,
- `NOW()` – aktualna data i czas,
- `CONCAT` – łączy tekst, np. „Dodano produkt: Ołówek, cena: 1.00”.


### 6.3. Testowanie

```sql
INSERT INTO produkty (nazwa, cena, stan_magazynowy)
VALUES ('Długopis', 3.20, 80);

SELECT * FROM log_zmian;
```

Powinni zobaczyć w `log_zmian` opis dodania produktu.

***

## 7. Trigger `BEFORE UPDATE` – kontrola modyfikacji (15 min)

### 7.1. Cel

Zabronić ustawiania ujemnego stanu magazynowego.

### 7.2. Tworzenie triggera

```sql
DELIMITER $$

CREATE TRIGGER sprawdz_stan_magazynowy
BEFORE UPDATE ON produkty
FOR EACH ROW
BEGIN
    IF NEW.stan_magazynowy < 0 THEN
        SET NEW.stan_magazynowy = 0;
    END IF;
END$$

DELIMITER ;
```

- `NEW.stan_magazynowy` – nowa wartość, którą ktoś próbuje zapisać,
- jeśli jest mniejsza od 0, trigger ją poprawia na 0.


### 7.3. Testowanie

```sql
UPDATE produkty
SET stan_magazynowy = -10
WHERE nazwa = 'Długopis';

SELECT * FROM produkty WHERE nazwa = 'Długopis';
```

Omów:

- stan magazynowy powinien wynosić 0, a nie -10 – trigger poprawił błąd.

Dodatkowe ćwiczenie (jeśli zostanie czas):

- napisać prosty opis do `log_zmian` w osobnym triggerze `AFTER UPDATE` (np. „Zmieniono stan magazynowy produktu …”).

***

## 8. Proste zadania dla uczniów (15 min)

Rozdaj / wyświetl krótką listę zadań, które uczniowie wykonują samodzielnie (w parach):

1. **Zadanie 1 – logowanie aktualizacji ceny**
Utwórz trigger `AFTER UPDATE` na tabeli `produkty`, który dopisze do `log_zmian` wpis:
„Zmieniono cenę produktu: <nazwa>, stara cena: <OLD.cena>, nowa cena: <NEW.cena>”.
Podpowiedź: użyj `OLD.cena`, `NEW.cena` i `CONCAT`.
2. **Zadanie 2 – automatyczne uzupełnianie pustej nazwy**
Utwórz trigger `BEFORE INSERT`, który jeśli `NEW.nazwa` jest pusta (`''` lub `NULL`), ustawi ją na „BRAK NAZWY”.
3. **Zadanie 3 – blokowanie zbyt wysokiej ceny (dla chętnych)**
Zamiast poprawiać dane, wyświetl błąd:

```sql
SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Cena jest za wysoka';
```

Użyj `IF NEW.cena > 1000 THEN ... END IF;` wewnątrz triggera `BEFORE INSERT`.


***

## 9. Podsumowanie (5 min)

Na koniec:

- Co robi trigger?
- Jakie są trzy typy zdarzeń, na które może reagować?
- Podaj przykład sytuacji z życia, gdzie trigger byłby przydatny.

Zaproponuj krótką pracę domową:

> Wymyśl inną tabelę (np. `uczniowie`, `zamowienia`, `konto_bankowe`) i opisz w 3–4 zdaniach, jakie dwa triggery chciałbyś tam mieć i co by robiły.

***

