-- Wstaw klasy
INSERT INTO KLASA (nazwa_klasy, rok_nauki) VALUES 
('1A', 1),
('2B', 2),
('3C', 3);

-- Wstaw nauczycieli
INSERT INTO NAUCZYCIEL (imie, nazwisko, numer_pracownika, specjalizacja) VALUES
('Jan', 'Kowalski', 'NP001', 'Matematyka'),
('Maria', 'Nowak', 'NP002', 'Historia'),
('Piotr', 'Lewandowski', 'NP003', 'Informatyka');

-- Wstaw przedmioty
INSERT INTO PRZEDMIOT (kod_przedmiotu, nazwa, liczba_godzin_tygodniowo) VALUES
('MAT01', 'Matematyka', 4),
('HIS01', 'Historia', 3),
('INF01', 'Informatyka', 2);

-- Powiąż nauczycieli z przedmiotami
INSERT INTO NAUCZYCIEL_PRZEDMIOT (id_nauczyciela, id_przedmiotu) VALUES
(1, 1),  -- Jan Kowalski uczy Matematyki
(2, 2),  -- Maria Nowak uczy Historii
(3, 3);  -- Piotr Lewandowski uczy Informatyki

-- Wstaw uczniów
INSERT INTO UCZEŃ (imie, nazwisko, pesel, email, id_klasy) VALUES
('Adam', 'Zaremba', '10123456789', 'adam.z@school.pl', 1),
('Ewa', 'Krupa', '10234567890', 'ewa.k@school.pl', 1),
('Tomasz', 'Błasiński', '10345678901', 'tomasz.b@school.pl', 2);

-- Wstaw sale
INSERT INTO SALA (numer_sali, pietro, liczba_miejsc, typ) VALUES
('101', 1, 30, 'Klasa standardowa'),
('102', 1, 30, 'Klasa standardowa'),
('LAB01', 0, 25, 'Laboratorium informatyki');

-- Wstaw zajęcia
INSERT INTO ZAJĘCIA (id_przedmiotu, id_nauczyciela, id_sali, dzien_tygodnia, godzina_poczatku, godzina_konca) VALUES
(1, 1, 1, 'Poniedziałek', '08:00', '08:45'),
(2, 2, 2, 'Wtorek', '09:00', '09:45'),
(3, 3, 3, 'Środa', '10:00', '10:45');

-- Wstaw oceny
INSERT INTO OCENA (id_ucznia, id_przedmiotu, id_nauczyciela, wartosc_oceny) VALUES
(1, 1, 1, 4),  -- Adam dostał 4 z Matematyki
(1, 2, 2, 5),  -- Adam dostał 5 z Historii
(2, 1, 1, 3),  -- Ewa dostała 3 z Matematyki
(2, 3, 3, 5);  -- Ewa dostała 5 z Informatyki
