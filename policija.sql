DROP DATABASE IF EXISTS Policija;
CREATE DATABASE Policija;
USE Policija;

# TABLICE
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

CREATE TABLE VrstaZgrade (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    OpisVrste VARCHAR(255) NOT NULL UNIQUE
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
CREATE TABLE Zgrada (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Adresa VARCHAR(255) NOT NULL,
    MjestoID INT,
    VrstaZgradeID INT,
    FOREIGN KEY (MjestoID) REFERENCES Mjesto(ID),
    FOREIGN KEY (VrstaZgradeID) REFERENCES VrstaZgrade(ID)
);

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




CREATE TABLE Vozilo (
    Id INT AUTO_INCREMENT PRIMARY KEY,
    Marka VARCHAR(255) NOT NULL,
    Model VARCHAR(255) NOT NULL,
    Registracija VARCHAR(20) NOT NULL UNIQUE,
    Godina_proizvodnje INT NOT NULL,
    Vlasnik_id INT,
    FOREIGN KEY (Vlasnik_id) REFERENCES Osoba(Id)
);


CREATE TABLE Predmet (
    Id INT AUTO_INCREMENT PRIMARY KEY,
    Naziv VARCHAR(255) NOT NULL,
    Id_Mjesto_Pronalaska INT,
    FOREIGN KEY (Id_Mjesto_Pronalaska) REFERENCES Mjesto(Id)
);

CREATE TABLE KaznjivaDjela (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Naziv VARCHAR(255) NOT NULL UNIQUE,
    Opis TEXT NOT NULL,
    Predviđena_kazna INT
);
CREATE TABLE Pas (
	Id INTEGER AUTO_INCREMENT PRIMARY KEY,
    Id_vlasnik INTEGER,
    Ime VARCHAR(255),
    Id_kaznjivo_djelo INTEGER, # dali je pas za drogu/ljude/oružje itd.
    FOREIGN KEY (Id_vlasnik) REFERENCES Osoba(Id),
    FOREIGN KEY (Id_kaznjivo_djelo) REFERENCES Kaznjivadjela(ID)
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
    Svjedok_id INT,
    FOREIGN KEY (IzvjestiteljID) REFERENCES Osoba(Id),
    FOREIGN KEY (VoditeljID) REFERENCES Osoba(Id),
    FOREIGN KEY (DokazID) REFERENCES Predmet(Id),
    FOREIGN KEY (PociniteljID) REFERENCES Osoba(Id),
    FOREIGN KEY (Pas_id) REFERENCES Pas(Id),
    FOREIGN KEY (Svjedok_id) REFERENCES Osoba(Id)
);
CREATE TABLE KaznjivaDjela_u_Slucaju (
	ID INT AUTO_INCREMENT PRIMARY KEY,
    SlucajID INT,
    KaznjivoDjeloID INT,
    FOREIGN KEY (SlucajID) REFERENCES Slucaj(ID),
    FOREIGN KEY (KaznjivoDjeloID) REFERENCES KaznjivaDjela(ID)
);





CREATE TABLE EvidencijaDogadaja (
    Id INT AUTO_INCREMENT PRIMARY KEY,
    SlucajID INT,
    OsumnjicenikID INT,
    OpisDogadjaja TEXT NOT NULL,
    DatumVrijeme DATETIME NOT NULL,
    MjestoId INT NOT NULL,
    FOREIGN KEY (SlucajID) REFERENCES Slucaj(Id),
    FOREIGN KEY (OsumnjicenikID) REFERENCES Osoba(Id),
    FOREIGN KEY (MjestoId) REFERENCES Mjesto(Id)
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
# Triger koji kreira stupac UkupnaVrijednostZapljena u tablici slučaj i ažurira ga nakon svake nove unesene zapljene u tom slučaju
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

# Triger koji premješta završene slučajeve iz tablice slučaj u tablicu arhiva
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

# Provjera da osoba nije nadređena sama sebi
DELIMITER //
CREATE TRIGGER ProvjeraHijerarhije
BEFORE INSERT ON Osoba
FOR EACH ROW
BEGIN
    IF NEW.Nadređeni_id IS NOT NULL AND NEW.Nadređeni_id = NEW.ID THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Nadređeni ne može biti ista osoba kao i podređeni.';
    END IF;
END;
//
DELIMITER ;

# Provjera da su datum početka i završetka slučaja različiti i da je datum završetka "veći" od datuma početka
DELIMITER //

CREATE TRIGGER ProvjeraDatumZavrsetka
BEFORE INSERT ON Slucaj
FOR EACH ROW
BEGIN
    IF NEW.Pocetak >= NEW.Zavrsetak THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Datum završetka slučaja mora biti veći od datuma početka.';
    END IF;
END;
//
DELIMITER ;

# UPITI
# Ispišimo sve voditelje slučajeva
SELECT O.Ime_Prezime, S.Naziv AS 'Naziv slučaja'
FROM Osoba O
JOIN Slucaj S ON O.ID = S.VoditeljID;

# Ispišimo slučajeve i evidencije za određenu osobu (osumnjičenika)
SELECT S.Naziv AS 'Naziv slučaja', ED.OpisDogadjaja, ED.DatumVrijeme, ED.MjestoID
FROM Slucaj S
JOIN EvidencijaDogadaja ED ON S.ID = ED.SlucajID
WHERE ED.OsumnjicenikID = (SELECT ID FROM Osoba WHERE Ime_Prezime = 'Ime Prezime');

# Ispišimo sve osobe koje su osumnjičene za određeno KD
SELECT DISTINCT O.Ime_Prezime
FROM Osoba O
JOIN EvidencijaDogadaja ED ON O.ID = ED.OsumnjicenikID
JOIN KaznjivaDjela_u_Slucaju KD ON ED.SlucajID = KD.SlucajID
JOIN KaznjivaDjela K ON KD.KaznjivoDjeloID = K.ID
WHERE K.Naziv = 'Naziv kaznenog djela';

# Pronađimo sve slučajeve koji sadrže KD i nisu riješeni
SELECT Slucaj.Naziv, KaznjivaDjela.Naziv AS KaznjivoDjelo
FROM Slucaj
INNER JOIN KaznjivaDjela_u_Slucaju ON Slucaj.ID = KaznjivaDjela_u_Slucaju.SlucajID
INNER JOIN KaznjivaDjela ON KaznjivaDjela_u_Slucaju.KaznjivoDjeloID = KaznjivaDjela.ID
WHERE Slucaj.Status = 'Aktivan';

# Izračunajmo iznos zapljene za svaki pojedini slučaj
SELECT Slucaj.Naziv, SUM(Zapljene.Vrijednost) AS UkupnaVrijednostZapljena
FROM Slucaj
LEFT JOIN Zapljene ON Slucaj.ID = Zapljene.SlucajID
GROUP BY Slucaj.ID;

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

# Pronađi osobu koja mora odslužiti najveću ukupnu zatvorsku kaznu
SELECT O.Id, O.Ime_Prezime, SUM(KD.Predviđena_kazna) AS Ukupna_kazna
FROM Osoba O
INNER JOIN Slucaj S ON O.Id = S.PociniteljID
INNER JOIN KaznjivaDjela_u_Slucaju KS ON S.Id = KS.SlucajID
INNER JOIN KaznjivaDjela KD ON KS.KaznjivoDjeloID = KD.ID
WHERE KD.Predviđena_kazna IS NOT NULL
GROUP BY O.Id, O.Ime_Prezime
ORDER BY Ukupna_kazna DESC
LIMIT 1;

# POGLEDI
# Pronađi sve policajce koji su vlasnici vozila koja su starija od 10 godina
CREATE VIEW PolicijskiSluzbeniciSaStarimVozilima AS
SELECT O.Id, O.Ime_Prezime, V.Marka, V.Model, V.Godina_proizvodnje
FROM Osoba O
JOIN Vozilo V ON O.Id = V.Vlasnik_id
WHERE O.Radno_mjesto_id = (SELECT Id FROM Radno_mjesto WHERE Vrsta = 'Policijski službenik')
AND YEAR(NOW()) - V.Godina_proizvodnje > 10;

# Napravi pogled koji će pronaći sve osobe koje su počinile kazneno djelo pljačke i pri tome su koristili pištolj (to dohvati pomoću tablice predmet) i nazovi pogled "Počinitelji oružane pljačke"
CREATE VIEW PočiniteljiOružanePljačke AS
SELECT O.Id, O.Ime_Prezime, K.Naziv AS 'KaznenoDjelo', P.Naziv AS 'Predmet'
FROM Osoba O
JOIN EvidencijaDogadaja ED ON O.Id = ED.OsumnjicenikID
JOIN KaznjivaDjela_u_Slucaju KS ON ED.SlucajID = KS.SlucajID
JOIN KaznjivaDjela K ON KS.KaznjivoDjeloID = K.ID
JOIN Predmet P ON ED.MjestoId = P.Id_Mjesto_Pronalaska
WHERE K.Naziv = 'Pljačka' AND P.Naziv = 'Pištolj';

#Napravi pogled koji će izlistati sva evidentirana kaznena djela i njihov postotak pojavljivanja u slučajevima
CREATE VIEW PostotakPojavljivanjaKaznenihDjela AS
SELECT
    KD.Naziv AS 'Kazneno_Djelo',
    COUNT(KS.SlucajID) AS 'Broj_Slucajeva',
    COUNT(KS.SlucajID) / (SELECT COUNT(*) FROM Slucaj) * 100 AS 'Postotak_Pojavljivanja'
FROM
    KaznjivaDjela KD
LEFT JOIN
    KaznjivaDjela_u_Slucaju KS
ON
    KD.ID = KS.KaznjivoDjeloID
GROUP BY
    KD.Naziv;

# Napravi pogled koji će izlistati sva evidentirana sredstva utvrđivanja istine i broj slučajeva u kojima je svako od njih korišteno
CREATE VIEW EvidentiranaSredstvaUtvrdivanjaIstine AS
SELECT Sredstvo_utvrdivanja_istine.Naziv AS 'SredstvoUtvrdivanjaIstine',
       COUNT(Sui_slucaj.Id_sui) AS 'BrojSlucajeva'
FROM Sredstvo_utvrdivanja_istine
LEFT JOIN Sui_slucaj ON Sredstvo_utvrdivanja_istine.Id = Sui_slucaj.Id_sui
GROUP BY Sredstvo_utvrdivanja_istine.Id;


# Napiši proceduru koja će svim zatvorenicima koji su još u zatvoru (datum odlaska iz zgrade zatvora im je NULL) dodati novi stupac sa brojem dana u zatvoru koji će dobiti tako da računa broj dana o dana dolaska u zgradu do današnjeg dana
DELIMITER //
CREATE PROCEDURE DodajBrojDanaUZatvoru()
BEGIN
    
    DECLARE done INT DEFAULT 0;
    DECLARE osoba_id INT;
    DECLARE datum_dolaska DATETIME;
    DECLARE danas DATETIME;
    
    DECLARE cur CURSOR FOR
    SELECT Id, Datum_dolaska_u_zgradu
    FROM Osoba
    WHERE Datum_odlaska_iz_zgrade IS NULL;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    
    OPEN cur;
    
    read_loop: LOOP
        FETCH cur INTO osoba_id, datum_dolaska;
        
        IF done = 1 THEN
            LEAVE read_loop;
        END IF;
        
       
        SET danas = NOW();
        SET @broj_dana_u_zatvoru = DATEDIFF(danas, datum_dolaska);
        
   
        UPDATE Osoba
        SET Broj_dana_u_zatvoru = @broj_dana_u_zatvoru
        WHERE Id = osoba_id;
    END LOOP;
    
    CLOSE cur;
    
END //
DELIMITER ;

# Napiši proceduru koja će omogućiti da pretražujemo slučajeve preko neke ključne riječi iz opisa
DELIMITER //
CREATE PROCEDURE PretraziSlucajevePoOpisu(IN kljucnaRijec TEXT)
BEGIN
    SELECT * FROM Slucaj WHERE Opis LIKE CONCAT('%', kljucnaRijec, '%');
END //
DELIMITER ;

# Napiši proceduru koja će kreirati novu privremenu tablicu u kojoj će se prikazati svi psi i broj slučajeva na kojima su radili. Zatim će dodati novi stupac tablici pas i u njega upisati "nagrađeni pas" kod svih pasa koji su radili na više od 15 slučajeva 
DELIMITER //
CREATE PROCEDURE Godisnje_nagrađivanje_pasa()
BEGIN
    -- Kreiraj privremenu tablicu
    CREATE TEMPORARY TABLE Temp_Psi (PasID INT, BrojSlucajeva INT);

    -- Izračunaj broj slučajeva za svakog psa
    INSERT INTO Temp_Psi (PasID, BrojSlucajeva)
    SELECT Pas_id, COUNT(*) AS BrojSlucajeva
    FROM Slucaj
    GROUP BY Pas_id;

    -- Dodaj novi stupac "Status" u tablicu "Pas" i označi "nagrađene pse"
    ALTER TABLE Pas ADD COLUMN Status VARCHAR(255);

    -- Postavi "nagrađeni pas" za pse koji su radili na više od 15 slučajeva
    UPDATE Pas
    SET Status = 'nagrađeni pas'
    WHERE Id IN (SELECT PasID FROM Temp_Psi WHERE BrojSlucajeva > 15);
    
    -- Obriši privremenu tablicu
    DROP TEMPORARY TABLE Temp_Psi;
END //
DELIMITER ;
