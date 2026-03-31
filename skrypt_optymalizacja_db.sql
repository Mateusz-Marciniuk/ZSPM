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
