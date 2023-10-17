DROP DATABASE IF EXISTS Policija;
CREATE DATABASE Policija;
USE Policija;

# TABLICE
CREATE TABLE Osoba (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    ImePrezime VARCHAR(255) NOT NULL,
    DatumRodjenja DATE NOT NULL,
    Spol VARCHAR(10) NOT NULL,
    Adresa VARCHAR(255) NOT NULL,
    Fotografija BLOB,
    Telefon VARCHAR(20) NOT NULL,
    Email VARCHAR(255) NOT NULL UNIQUE,
    NadređeniID INT, 
    FOREIGN KEY (NadređeniID) REFERENCES Osoba(ID)
);

CREATE TABLE Uloge (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    TipUloge VARCHAR(255) NOT NULL,
    DodatneInformacije TEXT
);

CREATE TABLE Odjeli (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Naziv VARCHAR(255) NOT NULL UNIQUE,
    Opis TEXT
);



CREATE TABLE Vozilo (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Marka VARCHAR(255) NOT NULL,
    Model VARCHAR(255) NOT NULL,
    Registracija VARCHAR(20) NOT NULL UNIQUE,
    GodinaProizvodnje INT NOT NULL,
    VlasnikID INT,
    FOREIGN KEY (VlasnikID) REFERENCES Osoba(ID)
);

CREATE TABLE PodrucjeUprave (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Naziv VARCHAR(255) NOT NULL UNIQUE,
    Zupanija VARCHAR(255) NOT NULL
);

CREATE TABLE Mjesto (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Naziv VARCHAR(255) NOT NULL,
    IDPodrucjeUprave INT,
    FOREIGN KEY (IDPodrucjeUprave) REFERENCES PodrucjeUprave(ID)
);

CREATE TABLE Predmet (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Naziv VARCHAR(255) NOT NULL,
    IDMjestoPronalaska INT,
    FOREIGN KEY (IDMjestoPronalaska) REFERENCES Mjesto(ID)
);

CREATE TABLE Slucaj (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Naziv VARCHAR(255) NOT NULL,
    Opis TEXT,
    Pocetak DATETIME NOT NULL,
    Zavrsetak DATETIME NOT NULL,
    Status VARCHAR(20),
    IzvjestiteljID INT,
    VoditeljID INT,
    DokazID INT,
    UkupnaVrijednostZapljena INT,
    FOREIGN KEY (IzvjestiteljID) REFERENCES Osoba(ID),
    FOREIGN KEY (VoditeljID) REFERENCES Osoba(ID),
    FOREIGN KEY (DokazID) REFERENCES Predmet(ID)
);

CREATE TABLE EvidencijaDogadjaja (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    SlucajID INT,
    OsumnjicenikID INT,
    OpisDogadjaja TEXT NOT NULL,
    DatumVrijeme DATETIME NOT NULL,
    Lokacija VARCHAR(255) NOT NULL,
    FOREIGN KEY (SlucajID) REFERENCES Slucaj(ID),
    FOREIGN KEY (OsumnjicenikID) REFERENCES Osoba(ID)
);

CREATE TABLE KaznenaDjela (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Naziv VARCHAR(255) NOT NULL UNIQUE,
    Opis TEXT NOT NULL,
    Predviđena_kazna INT
);

CREATE TABLE KaznenoDjelo_u_Slucaju (
    SlucajID INT,
    KaznenoDjeloID INT,
    FOREIGN KEY (SlucajID) REFERENCES Slucaj(ID),
    FOREIGN KEY (KaznenoDjeloID) REFERENCES KaznenaDjela(ID)
);


CREATE TABLE VrstaZgrade (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    OpisVrste VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE Zgrada (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Adresa VARCHAR(255) NOT NULL,
    MjestoID INT,
    VrstaZgradeID INT,
    FOREIGN KEY (MjestoID) REFERENCES Mjesto(ID),
    FOREIGN KEY (VrstaZgradeID) REFERENCES VrstaZgrade(ID)
);

CREATE TABLE Izvjestaji (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Naslov VARCHAR(255) NOT NULL,
    Sadržaj TEXT,
    AutorID INT,
    SlucajID INT,
    FOREIGN KEY (AutorID) REFERENCES Osoba(ID),
    FOREIGN KEY (SlucajID) REFERENCES Slucaj(ID)
);

CREATE TABLE Zapljene (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Opis TEXT,
    Vrijednost INT,
    SlucajID INT,
    PredmetID INT,
    FOREIGN KEY (SlucajID) REFERENCES Slucaj(ID),
    FOREIGN KEY (PredmetID) REFERENCES Predmet(ID)
);

# TRIGERI
DELIMITER //
CREATE TRIGGER AzurirajVrijednostZapljena
AFTER INSERT ON Zapljene
FOR EACH ROW
BEGIN
    DECLARE ukupno DECIMAL(10, 2);
    
    SELECT SUM(P.Vrijednost) INTO ukupno
    FROM Predmet P
    WHERE P.ID = NEW.PredmetID;

    UPDATE Slucaj
    SET UkupnaVrijednostZapljena = ukupno
    WHERE ID = NEW.SlucajID;
END;
//
DELIMITER ;

DELIMITER //
CREATE TRIGGER PremjestiZavrseneSlucajeve
AFTER UPDATE ON Slucaj
FOR EACH ROW
BEGIN
    IF NEW.Status = 'Završeno' THEN
        INSERT INTO Arhiva (SlucajID) VALUES (OLD.ID);
        DELETE FROM Slucaj WHERE ID = OLD.ID;
    END IF;
END;
//
DELIMITER ;

DELIMITER //
CREATE TRIGGER ProvjeraHijerarhije
BEFORE INSERT ON Osoba
FOR EACH ROW
BEGIN
    IF NEW.NadređeniID IS NOT NULL AND NEW.NadređeniID = NEW.ID THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Nadređeni ne može biti ista osoba kao i podređeni.';
    END IF;
END;
//
DELIMITER ;

# UPITI
# Ispišimo sve voditelje slučajeva
SELECT O.ImePrezime, S.Naziv AS 'Naziv slučaja'
FROM Osoba O
JOIN Slucaj S ON O.ID = S.VoditeljID;

# Ispišimo slučajeve i evidencije za određenu osobu (osumnjičenika)
SELECT S.Naziv AS 'Naziv slučaja', ED.OpisDogadjaja, ED.DatumVrijeme, ED.Lokacija
FROM Slucaj S
JOIN EvidencijaDogadjaja ED ON S.ID = ED.SlucajID
WHERE ED.OsumnjicenikID = (SELECT ID FROM Osoba WHERE ImePrezime = 'Ime Prezime');

# Ispišimo sve osobe koje su osumnjičene za neko KD
SELECT DISTINCT O.ImePrezime
FROM Osoba O
JOIN EvidencijaDogadjaja ED ON O.ID = ED.OsumnjicenikID
JOIN KaznenoDjelo_u_Slucaju KD ON ED.SlucajID = KD.SlucajID
JOIN KaznenaDjela K ON KD.KaznenoDjeloID = K.ID
WHERE K.Naziv = 'Naziv kaznenog djela';

# Pronađimo sve slučajeve koji sadrže KD i nisu riješeni
SELECT Slucaj.Naziv, KaznenaDjela.Naziv AS KaznenoDjelo
FROM Slucaj
INNER JOIN KaznenoDjelo_u_Slucaju ON Slucaj.ID = KaznenoDjelo_u_Slucaju.SlucajID
INNER JOIN KaznenaDjela ON KaznenoDjelo_u_Slucaju.KaznenoDjeloID = KaznenaDjela.ID
WHERE Slucaj.Status = 'Aktivan';

# Izračunajmo iznos zapljene za svaki pojedini slučaj
SELECT Slucaj.Naziv, SUM(Zapljene.Vrijednost) AS UkupnaVrijednostZapljena
FROM Slucaj
LEFT JOIN Zapljene ON Slucaj.ID = Zapljene.SlucajID
GROUP BY Slucaj.ID;

# Pokušaj transakcije
START TRANSACTION;

-- Unesite ID slučaja za izvješće
SET @SlucajID = 1; -- Zamijenite sa stvarnim ID-em slučaja koji želite izvijestiti

-- Provjera postoji li slučaj s tim ID-om
IF EXISTS (SELECT 1 FROM Slucaj WHERE ID = @SlucajID) THEN
    -- Dohvaćanje podataka o slučaju
    SELECT 
        Slucaj.Naziv AS 'Naziv slučaja',
        Slucaj.Opis,
        Slucaj.Pocetak,
        Slucaj.Zavrsetak,
        Slucaj.Status,
        Osoba.ImePrezime AS 'Izvjestitelj',
        Voditelj.ImePrerezime AS 'Voditelj',
        Predmet.Naziv AS 'Dokaz',
        Slucaj.UkupnaVrijednostZapljena
    FROM Slucaj
    LEFT JOIN Osoba ON Slucaj.IzvjestiteljID = Osoba.ID
    LEFT JOIN Osoba AS Voditelj ON Slucaj.VoditeljID = Voditelj.ID
    LEFT JOIN Predmet ON Slucaj.DokazID = Predmet.ID
    WHERE Slucaj.ID = @SlucajID;
ELSE
    -- Slučaj s tim ID-om ne postoji, odustajanje od transakcije
    ROLLBACK;
    SELECT 'Slučaj s ID-om ' + CAST(@SlucajID AS CHAR) + ' ne postoji.';
END IF;

-- Kraj transakcije
COMMIT;
