-- Tworzenie bazy danych
CREATE DATABASE IF NOT EXISTS sklep_online;
USE sklep_online;

-- Tabela: Kategorii produktów
CREATE TABLE kategorie (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nazwa VARCHAR(50) NOT NULL,
    opis TEXT
);

-- Tabela: Produkty
CREATE TABLE produkty (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nazwa VARCHAR(100) NOT NULL,
    cena DECIMAL(10, 2) NOT NULL,
    kategoria_id INT NOT NULL,
    ilosc_magazyn INT DEFAULT 0,
    data_dodania DATE,
    FOREIGN KEY (kategoria_id) REFERENCES kategorie(id)
);

-- Tabela: Klienci
CREATE TABLE klienci (
    id INT PRIMARY KEY AUTO_INCREMENT,
    imie VARCHAR(50) NOT NULL,
    nazwisko VARCHAR(50) NOT NULL,
    email VARCHAR(100),
    telefon VARCHAR(20),
    data_rejestracji DATE,
    miasto VARCHAR(50)
);

-- Tabela: Zamówienia
CREATE TABLE zamowienia (
    id INT PRIMARY KEY AUTO_INCREMENT,
    klient_id INT NOT NULL,
    data_zamowienia DATE NOT NULL,
    kwota_calkowita DECIMAL(10, 2),
    status VARCHAR(20) DEFAULT 'oczekujące',
    FOREIGN KEY (klient_id) REFERENCES klienci(id)
);

-- Tabela: Pozycje zamówienia
CREATE TABLE pozycje_zamowienia (
    id INT PRIMARY KEY AUTO_INCREMENT,
    zamowienie_id INT NOT NULL,
    produkt_id INT NOT NULL,
    ilosc INT NOT NULL,
    cena_jednostkowa DECIMAL(10, 2),
    FOREIGN KEY (zamowienie_id) REFERENCES zamowienia(id),
    FOREIGN KEY (produkt_id) REFERENCES produkty(id)
);

-- ===== WSTAWIENIE DANYCH TESTOWYCH =====

-- Kategorie
INSERT INTO kategorie VALUES
(1, 'Elektronika', 'Urządzenia elektroniczne'),
(2, 'Książki', 'Książki różnych gatunków'),
(3, 'Odzież', 'Ubrania i akcesoria'),
(4, 'Sprzęt sportowy', 'Artykuły sportowe'),
(5, 'Akcesoria', 'Różne akcesoria');

-- Produkty
INSERT INTO produkty VALUES
(1, 'Laptop DELL', 3500.00, 1, 15, '2025-01-10'),
(2, 'Mysz bezprzewodowa', 45.99, 1, 120, '2025-01-08'),
(3, 'Klawiatura mechaniczna', 250.00, 1, 45, '2025-01-12'),
(4, 'Harry Potter - Tom 1', 39.99, 2, 50, '2024-12-20'),
(5, 'Władca Pierścieni', 59.99, 2, 30, '2024-12-22'),
(6, 'T-shirt bawełniany', 49.99, 3, 200, '2025-01-05'),
(7, 'Jeansy proste', 129.99, 3, 85, '2025-01-07'),
(8, 'Buty sportowe', 199.99, 4, 60, '2024-12-28'),
(9, 'Rower górski', 1200.00, 4, 12, '2025-01-01'),
(10, 'Plecak turystyczny', 150.00, 5, 40, '2025-01-03');

-- Klienci
INSERT INTO klienci VALUES
(1, 'Jan', 'Kowalski', 'jan.kowalski@email.com', '555123456', '2024-06-15', 'Warszawa'),
(2, 'Maria', 'Nowak', 'maria.nowak@email.com', '555234567', '2024-08-20', 'Kraków'),
(3, 'Piotr', 'Lewandowski', 'piotr.lew@email.com', '555345678', '2024-09-10', 'Wrocław'),
(4, 'Anna', 'Wiśniewski', 'anna.w@email.com', '555456789', '2024-07-05', 'Poznań'),
(5, 'Tomasz', 'Szymański', 'tomasz.s@email.com', '555567890', '2025-01-02', 'Gdańsk'),
(6, 'Katarzyna', 'Kucharski', 'kasia.k@email.com', '555678901', '2024-10-12', 'Warszawa'),
(7, 'Robert', 'Jankowski', 'robert.j@email.com', '555789012', '2025-01-09', 'Łódź'),
(8, 'Joanna', 'Michalska', 'joanna.m@email.com', '555890123', '2024-11-30', 'Kraków');

-- Zamówienia
INSERT INTO zamowienia VALUES
(1, 1, '2025-01-15', 3545.99, 'opłacone'),
(2, 2, '2025-01-14', 99.98, 'wysłane'),
(3, 3, '2025-01-13', 1200.00, 'oczekujące'),
(4, 1, '2025-01-12', 250.00, 'opłacone'),
(5, 4, '2025-01-11', 179.99, 'opłacone'),
(6, 5, '2025-01-10', 4700.00, 'wysłane'),
(7, 6, '2025-01-09', 89.97, 'opłacone'),
(8, 2, '2025-01-08', 150.00, 'oczekujące'),
(9, 7, '2025-01-07', 249.99, 'opłacone'),
(10, 8, '2025-01-06', 500.00, 'wysłane'),
(11, 3, '2025-01-05', 350.00, 'opłacone'),
(12, 1, '2025-01-04', 2500.00, 'wysłane');

-- Pozycje zamówienia
INSERT INTO pozycje_zamowienia VALUES
(1, 1, 1, 1, 3500.00),
(2, 1, 2, 1, 45.99),
(3, 2, 4, 2, 39.99),
(4, 3, 9, 1, 1200.00),
(5, 4, 3, 1, 250.00),
(6, 5, 6, 1, 49.99),
(7, 5, 8, 1, 129.99),
(8, 6, 1, 1, 3500.00),
(9, 6, 2, 1, 45.99),
(10, 6, 3, 1, 154.01),
(11, 7, 7, 1, 89.97),
(12, 8, 10, 1, 150.00),
(13, 9, 8, 1, 249.99),
(14, 10, 5, 1, 500.00),
(15, 11, 2, 7, 50.00),
(16, 11, 6, 1, 49.99),
(17, 11, 7, 1, 250.01),
(18, 12, 1, 1, 2500.00);
