DROP DATABASE IF EXISTS Policija;
CREATE DATABASE Policija;
USE Policija;

# TABLICE
CREATE TABLE Osoba (
    Id INT AUTO_INCREMENT PRIMARY KEY,
    Ime_Prezime VARCHAR(255) NOT NULL,
    Datum_rodjenja DATE NOT NULL,
    Spol VARCHAR(10) NOT NULL,
    Adresa VARCHAR(255) NOT NULL,
    Fotografija BLOB,
    Telefon VARCHAR(20) NOT NULL,
    Email VARCHAR(255) NOT NULL UNIQUE,
    Datum_dolaska_u_zgradu DATETIME,
    Datum_odlaska_iz_zgrade DATETIME,# zatvor/postaja/bolnica i sl
    Nadređeni_id INT, 
    Radno_mjesto_id INT,
    Odjel_id INT,
    Zgrada_id INT,
    Mjesto_id INT,
    FOREIGN KEY (Nadređeni_id) REFERENCES Osoba(Id),
    FOREIGN KEY (Radno_mjesto_id) REFERENCES Radno_mjesto (Id),
    FOREIGN KEY (Odjel_id) REFERENCES Odjeli (Id),
    FOREIGN KEY (Zgrada_id) REFERENCES Zgrada (Id), # ovo je tipa zatvor di se nalazi/postaja di dela itd.
    FOREIGN KEY (Mjesto_id) REFERENCES Mjesto(Id)
    );

CREATE TABLE  Radno_mjesto(
    Id INT AUTO_INCREMENT PRIMARY KEY,
    Vrsta VARCHAR(255) NOT NULL,
    Dodatne_informacije TEXT
);

CREATE TABLE Odjeli (
    Id INT AUTO_INCREMENT PRIMARY KEY,
    Naziv VARCHAR(255) NOT NULL UNIQUE,
    Opis TEXT
);

CREATE TABLE Vozilo (
    Id INT AUTO_INCREMENT PRIMARY KEY,
    Marka VARCHAR(255) NOT NULL,
    Model VARCHAR(255) NOT NULL,
    Registracija VARCHAR(20) NOT NULL UNIQUE,
    Godina_proizvodnje INT NOT NULL,
    Vlasnik_id INT,
    FOREIGN KEY (Vlasnik_id) REFERENCES Osoba(Id)
);

CREATE TABLE Podrucje_uprave (
    Id INT AUTO_INCREMENT PRIMARY KEY,
    Naziv VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE Mjesto (
    Id INT AUTO_INCREMENT PRIMARY KEY,
    Naziv VARCHAR(255) NOT NULL,
    Id_Podrucje_Uprave INT,
    FOREIGN KEY (Id_Podrucje_Uprave) REFERENCES Podrucje_uprave(Id)
);

CREATE TABLE Predmet (
    Id INT AUTO_INCREMENT PRIMARY KEY,
    Naziv VARCHAR(255) NOT NULL,
    Id_Mjesto_Pronalaska INT,
    FOREIGN KEY (Id_Mjesto_Pronalaska) REFERENCES Mjesto(Id)
);

CREATE TABLE Pas (
	Id INTEGER AUTO_INCREMENT PRIMARY KEY,
    Id_vlasnik INTEGER,
    Ime VARCHAR(255),
    Id_kaznjivo_djelo INTEGER, # dali je pas za drogu/ljude/oružje itd.
    FOREIGN KEY (Id_vlasnik) REFERENCES Osoba(Id),
    FOREIGN KEY (Id_kaznjivo_djelo) REFERENCES Kaznjivo_djelo(id)
    );

CREATE TABLE Slucaj (
    Id INT AUTO_INCREMENT PRIMARY KEY,
    Naziv VARCHAR(255) NOT NULL,
    Opis TEXT,
    Pocetak DATETIME NOT NULL,
    Zavrsetak DATETIME NOT NULL,
    Status VARCHAR(20),
    PociniteljID INT,
    IzvjestiteljID INT,
    VoditeljID INT,
    DokazID INT,
    UkupnaVrijednostZapljena INT,
    Pas_id INT,
    Osoba_id INT,
    FOREIGN KEY (IzvjestiteljID) REFERENCES Osoba(Id),
    FOREIGN KEY (VoditeljID) REFERENCES Osoba(Id),
    FOREIGN KEY (DokazID) REFERENCES Predmet(Id),
    FOREIGN KEY (PociniteljID) REFERENCES Osoba(Id),
    FOREIGN KEY (Pas_id) REFERENCES Pas(Id),
    FOREIGN KEY (Svjedok_id) REFERENCES Osoba(Id)
);

CREATE TABLE EvidencijaDogadaja (
    Id INT AUTO_INCREMENT PRIMARY KEY,
    SlucajID INT,
    OsumnjicenikID INT,
    OpisDogadjaja TEXT NOT NULL,
    DatumVrijeme DATETIME NOT NULL,
    MjestoId VARCHAR(255) NOT NULL,
    FOREIGN KEY (SlucajID) REFERENCES Slucaj(Id),
    FOREIGN KEY (OsumnjicenikID) REFERENCES Osoba(Id),
    FOREIGN KEY (MjestoId) REFERENCES Mjesto(Id)
);

CREATE TABLE KaznjivaDjela (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Naziv VARCHAR(255) NOT NULL UNIQUE,
    Opis TEXT NOT NULL,
    Predviđena_kazna INT
);

CREATE TABLE KaznjivaDjela_u_Slucaju (
    SlucajID INT,
    KaznjivoDjeloID INT,
    FOREIGN KEY (SlucajID) REFERENCES Slucaj(ID),
    FOREIGN KEY (KaznjivoDjeloID) REFERENCES KaznjivaDjela(ID)
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

CREATE TABLE Sredstvo_utvrdivanja_istine ( # ovo je tipa poligraf, alkotest i sl.
	Id INT AUTO_INCREMENT PRIMARY KEY,
    Naziv VARCHAR(100) NOT NULL
);

CREATE TABLE Sui_slucaj (
	ID INT AUTO_INCREMENT PRIMARY KEY,
    Id_sui INT,
    Id_slucaj INT,
    FOREIGN KEY (Id_sui) REFERENCES Sredstvo_utvrdivanja_istine (Id),
    FOREIGN KEY (Id_slucaj) REFERENCES Slucaj (Id)
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

# Nađimo sva kažnjiva djela koja su se dogodila ne nekom mjestu (mijenjamo id_mjesto_pronalaska)
SELECT K.Naziv, K.Opis
FROM KaznjivaDjela_u_Slucaju KS
JOIN KaznjivaDjela K ON KS.KaznjivoDjeloID = K.ID
JOIN Slucaj S ON KS.SlucajID = S.Id
WHERE S.Id_Mjesto_Pronalaska = 1; # ovaj id promijenimo ovisno koje nam mjesto treba; moremo ih dohvaćat i preko imena ako nan se da

# Nađimo  sve događaje koji uključuju pojedino kažnjivo djelo
SELECT E.OpisDogadjaja, E.DatumVrijeme
FROM EvidencijaDogadaja E
JOIN Slucaj S ON E.SlucajID = S.Id
JOIN KaznjivaDjela_u_Slucaju KS ON S.Id = KS.SlucajID
WHERE KS.KaznjivoDjeloID = 1;

# Pronađi prosječnu vrijednost zapljene za pojedina kaznena djela
SELECT K.Naziv AS VrstaKaznenogDjela, AVG(Z.Vrijednost) AS ProsječnaVrijednostZapljene
FROM KaznjivaDjela_u_Slucaju KS
JOIN KaznjivaDjela K ON KS.KaznjivoDjeloID = K.ID
JOIN Zapljene Z ON KS.SlucajID = Z.SlucajID
GROUP BY K.Naziv;

# Pronađi sve odjele i broj zaposlenika na njima
SELECT O.Odjel_id, Odjeli.Naziv AS NazivOdjela, COUNT(O.Id) AS BrojZaposlenika
FROM Osoba O
JOIN Odjeli ON O.Odjel_id = Odjeli.Id
GROUP BY O.Odjel_id;

# Pronađi ukupnu vrijednost zapljena po odjelu i sortiraj ih po vrijednosti silazno
SELECT O.Odjel_id, SUM(Z.Vrijednost) AS UkupnaVrijednostZapljena
FROM Osoba O
JOIN Slucaj S ON O.Id = S.VoditeljID
JOIN Zapljene Z ON S.Id = Z.SlucajID
GROUP BY O.Odjel_id
ORDER BY UkupnaVrijednostZapljena DESC;
