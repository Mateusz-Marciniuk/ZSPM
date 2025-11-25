-- 1. TABELA: KLASA
CREATE TABLE KLASA (
    id_klasy INT PRIMARY KEY AUTO_INCREMENT,
    nazwa_klasy VARCHAR(10) NOT NULL UNIQUE,
    rok_nauki INT NOT NULL CHECK (rok_nauki IN (1, 2, 3, 4)),
    liczba_uczniow INT DEFAULT 0,
    DATA_UTWORZENIA TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. TABELA: UCZEŃ
CREATE TABLE UCZEŃ (
    id_ucznia INT PRIMARY KEY AUTO_INCREMENT,
    imie VARCHAR(50) NOT NULL,
    nazwisko VARCHAR(50) NOT NULL,
    pesel CHAR(11) NOT NULL UNIQUE,
    email VARCHAR(100) UNIQUE,
    telefon VARCHAR(12),
    id_klasy INT NOT NULL,
    data_urodzenia DATE,
    status VARCHAR(20) DEFAULT 'aktywny',
    FOREIGN KEY (id_klasy) REFERENCES KLASA(id_klasy) ON DELETE RESTRICT
);

-- 3. TABELA: NAUCZYCIEL
CREATE TABLE NAUCZYCIEL (
    id_nauczyciela INT PRIMARY KEY AUTO_INCREMENT,
    imie VARCHAR(50) NOT NULL,
    nazwisko VARCHAR(50) NOT NULL,
    numer_pracownika VARCHAR(20) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE,
    specjalizacja VARCHAR(100),
    data_zatrudnienia DATE,
    status VARCHAR(20) DEFAULT 'aktywny'
);

-- 4. TABELA: PRZEDMIOT
CREATE TABLE PRZEDMIOT (
    id_przedmiotu INT PRIMARY KEY AUTO_INCREMENT,
    kod_przedmiotu CHAR(5) UNIQUE NOT NULL,
    nazwa VARCHAR(100) NOT NULL,
    liczba_godzin_tygodniowo INT NOT NULL CHECK (liczba_godzin_tygodniowo > 0),
    opis TEXT,
    liczba_punktow_ects INT DEFAULT 0
);

-- 5. TABELA ASOCJACYJNA: NAUCZYCIEL_PRZEDMIOT
CREATE TABLE NAUCZYCIEL_PRZEDMIOT (
    id_nauczyciela INT NOT NULL,
    id_przedmiotu INT NOT NULL,
    data_przydziału DATE DEFAULT CURRENT_DATE,
    PRIMARY KEY (id_nauczyciela, id_przedmiotu),
    FOREIGN KEY (id_nauczyciela) REFERENCES NAUCZYCIEL(id_nauczyciela) ON DELETE CASCADE,
    FOREIGN KEY (id_przedmiotu) REFERENCES PRZEDMIOT(id_przedmiotu) ON DELETE CASCADE
);

-- 6. TABELA: SALA
CREATE TABLE SALA (
    id_sali INT PRIMARY KEY AUTO_INCREMENT,
    numer_sali VARCHAR(10) NOT NULL UNIQUE,
    pietro INT CHECK (pietro >= 0),
    liczba_miejsc INT NOT NULL CHECK (liczba_miejsc > 0),
    typ VARCHAR(50),
    wyposażenie TEXT
);

-- 7. TABELA: ZAJĘCIA
CREATE TABLE ZAJĘCIA (
    id_zajęc INT PRIMARY KEY AUTO_INCREMENT,
    id_przedmiotu INT NOT NULL,
    id_nauczyciela INT NOT NULL,
    id_sali INT NOT NULL,
    dzien_tygodnia ENUM('Poniedziałek','Wtorek','Środa','Czwartek','Piątek','Sobota') NOT NULL,
    godzina_poczatku TIME NOT NULL,
    godzina_konca TIME NOT NULL,
    liczba_uczniow INT DEFAULT 0,
    FOREIGN KEY (id_przedmiotu) REFERENCES PRZEDMIOT(id_przedmiotu) ON DELETE RESTRICT,
    FOREIGN KEY (id_nauczyciela) REFERENCES NAUCZYCIEL(id_nauczyciela) ON DELETE RESTRICT,
    FOREIGN KEY (id_sali) REFERENCES SALA(id_sali) ON DELETE RESTRICT,
    UNIQUE KEY unique_harmonogram (id_sali, dzien_tygodnia, godzina_poczatku)
);

-- 8. TABELA: OCENA
CREATE TABLE OCENA (
    id_oceny INT PRIMARY KEY AUTO_INCREMENT,
    id_ucznia INT NOT NULL,
    id_przedmiotu INT NOT NULL,
    id_nauczyciela INT NOT NULL,
    wartosc_oceny INT NOT NULL CHECK (wartosc_oceny BETWEEN 1 AND 6),
    data_wystawienia DATETIME DEFAULT CURRENT_TIMESTAMP,
    opis_oceny TEXT,
    waga_oceny DECIMAL(3,2) DEFAULT 1.0,
    FOREIGN KEY (id_ucznia) REFERENCES UCZEŃ(id_ucznia) ON DELETE CASCADE,
    FOREIGN KEY (id_przedmiotu) REFERENCES PRZEDMIOT(id_przedmiotu) ON DELETE CASCADE,
    FOREIGN KEY (id_nauczyciela) REFERENCES NAUCZYCIEL(id_nauczyciela) ON DELETE RESTRICT
);

-- INDEKSY dla poprawy wydajności
CREATE INDEX idx_uczeń_klasa ON UCZEŃ(id_klasy);
CREATE INDEX idx_ocena_ucznia ON OCENA(id_ucznia);
CREATE INDEX idx_ocena_przedmiotu ON OCENA(id_przedmiotu);
CREATE INDEX idx_zajęcia_nauczyciela ON ZAJĘCIA(id_nauczyciela);
CREATE INDEX idx_zajęcia_sali ON ZAJĘCIA(id_sali);
