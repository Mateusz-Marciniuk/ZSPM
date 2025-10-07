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
