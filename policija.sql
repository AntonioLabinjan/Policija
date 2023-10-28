DROP DATABASE IF EXISTS Policija;
CREATE DATABASE Policija;
USE Policija;

# TABLICE
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
    Vrsta_zgrade VARCHAR(30),
    FOREIGN KEY (MjestoID) REFERENCES Mjesto(ID)
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

CREATE TABLE Osoba (
    Id INT AUTO_INCREMENT PRIMARY KEY,
    Ime_Prezime VARCHAR(255) NOT NULL,
    Datum_rodjenja DATE NOT NULL,
    Spol VARCHAR(10) NOT NULL,
    Adresa VARCHAR(255) NOT NULL,
    Fotografija BLOB,
    Telefon VARCHAR(20) NOT NULL,
    Email VARCHAR(255) NOT NULL UNIQUE
    );

CREATE TABLE Zaposlenik (
  Id INT AUTO_INCREMENT PRIMARY KEY,
  Datum_zaposlenja DATETIME NOT NULL,
  Datum_izlaska_iz_sluzbe DATETIME, # ovo može biti NULL ako nije izašao iz službe
  Nadređeni_id INT,
  Radno_mjesto_id INT,
  Odjel_id INT,
  Zgrada_id INT,
  Mjesto_id INT,
  Osoba_id INT,
  FOREIGN KEY (Nadređeni_id) REFERENCES Zaposlenik(Id), 
  FOREIGN KEY (Radno_mjesto_id) REFERENCES Radno_mjesto (Id),
  FOREIGN KEY (Odjel_id) REFERENCES Odjeli (Id),
  FOREIGN KEY (Zgrada_id) REFERENCES Zgrada (Id), # ovo je tipa zatvor di se nalazi/postaja di dela itd.
  FOREIGN KEY (Mjesto_id) REFERENCES Mjesto(Id),
  FOREIGN KEY (Osoba_id) REFERENCES Osoba(Id)
);
	
CREATE TABLE Vozilo (
    Id INT AUTO_INCREMENT PRIMARY KEY,
    Marka VARCHAR(255) NOT NULL,
    Model VARCHAR(255) NOT NULL,
    Registracija VARCHAR(20) UNIQUE,
    Godina_proizvodnje INT NOT NULL,
    Službeno_vozilo BOOLEAN, # je li službeno ili ne
    Vlasnik_id INT NOT NULL, # ovaj FK se odnosi na privatna/osobna vozila
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
    Id_trener INTEGER, # to je osoba zadužena za rad s psom
    Oznaka VARCHAR(255),
    Dob INTEGER,
    Status VARCHAR(255),
    Id_kaznjivo_djelo INTEGER,# dali je pas za drogu/ljude/oružje itd.
    FOREIGN KEY (Id_trener) REFERENCES Osoba(Id),
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
    Svjedok_id INT,
    FOREIGN KEY (IzvjestiteljID) REFERENCES Osoba(Id),
    FOREIGN KEY (VoditeljID) REFERENCES Zaposlenik(Id),
    FOREIGN KEY (DokazID) REFERENCES Predmet(Id),
    FOREIGN KEY (PociniteljID) REFERENCES Osoba(Id),
    FOREIGN KEY (Pas_id) REFERENCES Pas(Id),
    FOREIGN KEY (Svjedok_id) REFERENCES Osoba(Id)
);

CREATE TABLE EvidencijaDogadaja (
    Id INT AUTO_INCREMENT PRIMARY KEY,
    SlucajID INT,
    OpisDogadjaja TEXT NOT NULL,
    DatumVrijeme DATETIME NOT NULL,
    MjestoId INT NOT NULL,
    FOREIGN KEY (SlucajID) REFERENCES Slucaj(Id),
    FOREIGN KEY (MjestoId) REFERENCES Mjesto(Id)
);



CREATE TABLE KaznjivaDjela_u_Slucaju (
	ID INT AUTO_INCREMENT PRIMARY KEY,
    SlucajID INT,
    KaznjivoDjeloID INT,
    FOREIGN KEY (SlucajID) REFERENCES Slucaj(ID),
    FOREIGN KEY (KaznjivoDjeloID) REFERENCES KaznjivaDjela(ID)
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
    SlucajID INT,
    PredmetID INT,
    Vrijednost NUMERIC (5,2),
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
# Triger koji osigurava da pri unosu spola osobe možemo staviti samo muški ili ženski spol
DELIMITER //
CREATE TRIGGER ProvjeriIspravnostSpola
BEFORE INSERT ON Osoba
FOR EACH ROW
BEGIN
    DECLARE validanSpol BOOLEAN;

    SET NEW.Spol = LOWER(NEW.Spol);

    IF NEW.Spol IN ('muski', 'zenski', 'muški', 'ženski', 'm', 'ž', 'muški', 'ženski', 'muski', 'zenski') THEN
        SET validanSpol = TRUE;
    ELSE
        SET validanSpol = FALSE;
    END IF;

    IF NOT validanSpol THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Spol nije valjan. Ispravni formati su: muski, zenski, m, ž, muški, ženski.';
    END IF;
END;
//
DELIMITER ;

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
BEFORE INSERT ON Zaposlenik
FOR EACH ROW
BEGIN
    IF NEW.Nadređeni_id IS NOT NULL AND NEW.Nadređeni_id = NEW.Id THEN
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

# Napravi triger koji će, u slučaju da ažuriramo godine psa i one iznose 10 ili više, pas će biti automatski časno umirovljen
DELIMITER //
CREATE TRIGGER IzmjeniStatusPsa
BEFORE INSERT ON Pas
FOR EACH ROW
BEGIN
    IF NEW.dob >= 10 THEN
        SET NEW.status = 'Časno umirovljen';
    END IF;
END;
//
DELIMITER ;

# UPITI
# Ispišimo sve voditelje slučajeva i slučajeve koje vode
SELECT O.Ime_Prezime, S.Naziv AS 'Naziv slučaja'
FROM Zaposlenik Z
JOIN Osoba O ON Z.Osoba_id = O.Id
JOIN Slucaj S ON Z.Id = S.VoditeljID;


# Ispišimo slučajeve i evidencije za određenu osobu (osumnjičenika)
SELECT S.Naziv AS 'Naziv slučaja', ED.OpisDogadjaja, ED.DatumVrijeme, ED.MjestoId
FROM Slucaj S
JOIN EvidencijaDogadaja ED ON S.Id = ED.SlucajID
JOIN Osoba O ON O.Id = S.PociniteljID 
WHERE O.Ime_Prezime = 'Ime Prezime';

# Ispišimo sve osobe koje su osumnjičene za određeno KD
SELECT DISTINCT O.Ime_Prezime
FROM Osoba O
JOIN Slucaj S ON O.Id = S.PociniteljID
JOIN KaznjivaDjela_u_Slucaju KD ON S.Id = KD.SlucajID
JOIN KaznjivaDjela K ON KD.KaznjivoDjeloID = K.Id
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

# Nađimo sva kažnjiva djela koja su se dogodila ne nekom mjestu (mijenjamo id_mjesto_pronalaska) // OVO NE VALJA
SELECT K.Naziv, K.Opis
FROM KaznjivaDjela_u_Slucaju KS
JOIN KaznjivaDjela K ON KS.KaznjivoDjeloID = K.ID
JOIN EvidencijaDogadaja ED ON KS.SlucajID = ED.SlucajID
WHERE ED.MjestoId = 1; 

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
SELECT O.Naziv AS NazivOdjela, COUNT(Z.Id) AS BrojZaposlenika
FROM Zaposlenik Z
JOIN Odjeli O ON Z.Odjel_id = O.Id
GROUP BY O.id, O.Naziv;

# Pronađi ukupnu vrijednost zapljena po odjelu i sortiraj ih po vrijednosti silazno
SELECT Z.Odjel_id, SUM(ZP.Vrijednost) AS UkupnaVrijednostZapljena
FROM Slucaj S
JOIN Zapljene ZP ON S.Id = ZP.SlucajID
JOIN Zaposlenik Z ON S.VoditeljID = Z.Id
GROUP BY Z.Odjel_id
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
CREATE VIEW PolicajciSaStarimVozilima AS
SELECT O.Ime_Prezime AS Policajac, V.Marka, V.Model, V.Godina_proizvodnje
FROM Osoba O
JOIN Zaposlenik Z ON O.Id = Z.Osoba_id
JOIN Vozilo V ON O.Id = V.Vlasnik_id
WHERE Z.Radno_mjesto_id = (SELECT Id FROM Radno_mjesto WHERE Vrsta = 'Policajac')
AND V.Godina_proizvodnje <= YEAR(NOW()) - 10;

# Napravi pogled koji će pronaći sve osobe koje su počinile kazneno djelo pljačke i pri tome su koristili pištolj (to dohvati pomoću tablice predmet) i nazovi pogled "Počinitelji oružane pljačke"
CREATE VIEW PočiniteljiOružanePljačke AS
SELECT O.Ime_Prezime AS Počinitelj, K.Naziv AS KaznenoDjelo
FROM Osoba O
JOIN Slucaj S ON O.Id = S.PociniteljID
JOIN KaznjivaDjela_u_Slucaju KD ON S.Id = KD.SlucajID
JOIN KaznjivaDjela K ON KD.KaznjivoDjeloID = K.ID
JOIN Predmet P ON S.DokazID = P.Id
WHERE K.Naziv = 'Pljačka' AND P.Naziv LIKE '%pištolj%';


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


# Napravi pogled koji će izlistati sve slučajeve i sredstva utvrđivanja istine u njima, te izračunati trajanje svakog od slučajeva

CREATE VIEW SlucajeviSortiraniPoTrajanjuISredstva AS
SELECT S.*, 
       TIMESTAMPDIFF(DAY, S.Pocetak, S.Zavrsetak) AS Trajanje_u_danima, 
       GROUP_CONCAT(SUI.Naziv ORDER BY SUI.Naziv ASC SEPARATOR ', ') AS SredstvaUtvrdivanjaIstine
FROM Slucaj S
LEFT JOIN Sui_slucaj SUI_S ON S.ID = SUI_S.Id_slucaj
LEFT JOIN Sredstvo_utvrdivanja_istine SUI ON SUI_S.Id_sui = SUI.ID
GROUP BY S.ID
ORDER BY Trajanje_u_danima DESC;

# Napiši pogled koji će u jednu tablicu pohraniti sve izvještaje vezane uz pojedine slučajeve
CREATE VIEW IzvjestajiZaSlucajeve AS
SELECT S.Naziv AS Slucaj, I.Naslov AS NaslovIzvjestaja, I.Sadržaj AS SadržajIzvjestaja, O.Ime_Prezime AS AutorIzvjestaja
FROM Izvjestaji I
INNER JOIN Slucaj S ON I.SlucajID = S.ID
INNER JOIN Osoba O ON I.AutorID = O.Id;

# Napravi pogled koji će izlistati sve osobe i njihove odjele. Ukoliko osoba nije policajac te nema odjel (odjel je NULL), neka se uz tu osobu napiše "Osoba nije policijski službenik"
CREATE VIEW OsobeIOdjeli AS
SELECT O.Ime_Prezime AS ImeOsobe,
       CASE
           WHEN Z.Radno_mjesto_id IS NOT NULL THEN OD.Naziv
           ELSE 'Osoba nije policijski službenik'
       END AS NazivOdjela
FROM Osoba O
LEFT JOIN Zaposlenik Z ON O.Id = Z.Osoba_id
LEFT JOIN Odjeli OD ON Z.Odjel_id = OD.Id;


# Napravi pogled koji će ispisati sve voditelje slučajeva, ukupan broj slučajeva koje vode, ukupan broj rješenjih slučajeva, ukupan broj nerješenih slučajeva i postotak rješenosti
CREATE VIEW VoditeljiSlucajeviPregled AS
SELECT
    O.Ime_Prezime AS Voditelj,
    COUNT(S.ID) AS UkupanBrojSlucajeva,
    SUM(CASE WHEN S.Status = 'Završeno' THEN 1 ELSE 0 END) AS UkupanBrojRijesenihSlucajeva,
    SUM(CASE WHEN S.Status = 'Aktivan' THEN 1 ELSE 0 END) AS UkupanBrojNerijesenihSlucajeva,
    (SUM(CASE WHEN S.Status = 'Završeno' THEN 1 ELSE 0 END) / COUNT(S.ID)) * 100 AS PostotakRjesenosti
FROM
    Osoba O
LEFT JOIN
    Slucaj S ON O.ID = S.VoditeljID
GROUP BY
    Voditelj;

# Napravi view koji će prikazivati statistiku zapljena za svaku vrstu kaznenog djela (prosjek, minimum, maksimum  (za vrijednosti) i broj predmeta)
CREATE VIEW StatistikaZapljenaPoKaznenomDjelu AS
SELECT
    K.Naziv AS 'Vrsta_kaznenog_djela',
    AVG(Z.Vrijednost) AS 'Prosječna_vrijednost_zapljena',
    MAX(Z.Vrijednost) AS 'Najveća_vrijednost_zapljena',
    MIN(Z.Vrijednost) AS 'Najmanja_vrijednost_zapljena',
    COUNT(Z.ID) AS 'Broj_zapljenjenih_predmeta'
FROM Zapljene Z
JOIN Slucaj S ON Z.SlucajID = S.ID
JOIN KaznjivaDjela_u_Slucaju KDUS ON S.ID = KDUS.SlucajID
JOIN KaznjivaDjela K ON KDUS.KaznjivoDjeloID = K.ID
GROUP BY K.Naziv;


SELECT * From StatistikaZapljenaPoKaznenomDjelu;
DROP VIEW StatistikaZapljenaPoKaznenomDjelu;

# Napravi view koji će za svaki slučaj izračunati ukupnu zatvorsku kaznu, uz ograničenje da maksimalna zakonska zatvorska kazna u RH iznosi 50 godina. Ako ukupna kazna premaši 50, postaviti će se na 50 uz odgovarajuće upozorenje
CREATE VIEW UkupnaPredvidenaKaznaPoSlucaju AS
SELECT S.ID AS 'SlucajID',
       S.Naziv AS 'NazivSlucaja',
       CASE
           WHEN SUM(KD.Predviđena_kazna) > 50 THEN 50
           ELSE SUM(KD.Predviđena_kazna)
       END AS 'UkupnaPredvidenaKazna',
       CASE
           WHEN SUM(KD.Predviđena_kazna) > 50 THEN 'Maksimalna zakonska zatvorska kazna iznosi 50 godina'
           ELSE NULL
       END AS 'Napomena'
FROM Slucaj S
LEFT JOIN KaznjivaDjela_u_Slucaju KDUS ON S.ID = KDUS.SlucajID
LEFT JOIN KaznjivaDjela KD ON KDUS.KaznjivoDjeloID = KD.ID
GROUP BY S.ID, S.Naziv;


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
    
    CREATE TEMPORARY TABLE Temp_Psi (PasID INT, BrojSlucajeva INT);

    
    INSERT INTO Temp_Psi (PasID, BrojSlucajeva)
    SELECT Pas_id, COUNT(*) AS BrojSlucajeva
    FROM Slucaj
    GROUP BY Pas_id;

    
    ALTER TABLE Pas ADD COLUMN Status VARCHAR(255);

    
    UPDATE Pas
    SET Status = 'nagrađeni pas'
    WHERE Id IN (SELECT PasID FROM Temp_Psi WHERE BrojSlucajeva > 15);
    
    
    DROP TEMPORARY TABLE Temp_Psi;
END //
DELIMITER ;

# Napiši proceduru koja će generirati izvještaje o slučajevima u zadnjih 20 dana (ovaj broj se može prilagođavati)
DELIMITER //
CREATE PROCEDURE GenerirajIzvjestajeOSlučajevima()
BEGIN
    DECLARE DatumPocetka DATE;
    DECLARE DatumZavrsetka DATE;
    
    -- Postavimo početni i završni datum za analizu (npr. 20 dana, ali moremo izmjenit)
    SET DatumPocetka = CURDATE() - INTERVAL 20 DAY;
    SET DatumZavrsetka = CURDATE();
    
    CREATE TEMPORARY TABLE TempIzvjestaji (
        SlucajID INT,
        NazivSlucaja VARCHAR(255),
        Pocetak DATE,
        Zavrsetak DATE,
        Status VARCHAR(50)
    );

    
    INSERT INTO TempIzvjestaji (SlucajID, NazivSlucaja, Pocetak, Zavrsetak, Status)
    SELECT S.ID, S.Naziv, S.Pocetak, S.Zavrsetak, S.Status
    FROM Slucaj S
    WHERE S.Pocetak BETWEEN DatumPocetka AND DatumZavrsetka;
    
    
    SELECT * FROM TempIzvjestaji;
    
    
    DROP TEMPORARY TABLE TempIzvjestaji;
END;
//
DELIMITER ;

# Napiši proceduru koja će za određenu osobu kreirati potvrdu o nekažnjavanju. To će napraviti samo u slučaju da osoba stvarno nije evidentirana niti u jednom slučaju kao počinitelj. Ukoliko je osoba kažnjavana i za to ćemo dobiti odgovarajuću obavijest. Također,ako uspješno izdamo potvrdu, neka se prikaže i datum izdavanja
DELIMITER //

CREATE PROCEDURE ProvjeriNekažnjavanje(IN osoba_id INT)
BEGIN
    DECLARE počinitelj_count INT;
    DECLARE osoba_ime_prezime VARCHAR(255);
    DECLARE obavijest VARCHAR(255);
    DECLARE izdavanje_datum DATETIME;

    SET izdavanje_datum = NOW();

    SELECT Ime_Prezime INTO osoba_ime_prezime FROM Osoba WHERE Id = osoba_id;

    SELECT COUNT(*) INTO počinitelj_count
    FROM Slucaj
    WHERE PociniteljID = osoba_id;

    IF počinitelj_count > 0 THEN
        SET obavijest = 'Osoba je kažnjavana';
        SELECT obavijest AS Poruka;
    ELSE
        INSERT INTO Izvjestaji (Naslov, Sadržaj, AutorID, SlucajID)
        VALUES ('Potvrda o nekažnjavanju', CONCAT('Osoba ', osoba_ime_prezime, ' nije kažnjavana. Izdana ', DATE_FORMAT(izdavanje_datum, '%d-%m-%Y %H:%i:%s')), osoba_id, NULL);
        SELECT CONCAT('Potvrda za ', osoba_ime_prezime) AS Poruka;
    END IF;
END //

DELIMITER ;

# Napiši proceduru koja će omogućiti da za određenu osobu izmjenimo kontakt informacije (email i/ili broj telefona)
DELIMITER //

CREATE PROCEDURE IzmjeniKontaktInformacije(
    IN osoba_id INT,
    IN novi_email VARCHAR(255),
    IN novi_telefon VARCHAR(20)
)
BEGIN
    -- Provjeri postoji li osoba s navedenim ID-jem
    DECLARE br_osoba INT;
    SELECT COUNT(*) INTO br_osoba FROM Osoba WHERE Id = osoba_id;
    
    IF br_osoba > 0 THEN
        UPDATE Osoba
        SET Email = novi_email, Telefon = novi_telefon
        WHERE Id = osoba_id;
        
        SELECT 'Kontakt informacije su uspješno izmijenjene' AS Poruka;
    ELSE
        SELECT 'Osoba s navedenim ID-jem ne postoji' AS Poruka;
    END IF;
END //

DELIMITER ;

# Napiši proceduru koja će za određeni slučaj izlistati sve događaje koji su se u njemu dogodili i poredati ih kronološki
DELIMITER //

CREATE PROCEDURE Izlistaj_dogadjaje(IN slucajID INT)
BEGIN
    SELECT ed.Id, ed.OpisDogadjaja, ed.DatumVrijeme
    FROM EvidencijaDogadaja AS ed
    WHERE ed.SlucajID = slucajID
    ORDER BY ed.DatumVrijeme;
END //

DELIMITER ;

# FUNKCIJE
# Napiši funkciju koja kao argument prima naziv kaznenog djela i vraća naziv KD, predviđenu kaznu i broj pojavljivanja KD u slučajevima
DELIMITER //
CREATE FUNCTION KDInfo(naziv_kaznenog_djela VARCHAR(255)) RETURNS TEXT
DETERMINISTIC
BEGIN
    DECLARE predvidena_kazna INT;
    DECLARE broj_pojavljivanja INT;
    
    SELECT Predviđena_kazna INTO predvidena_kazna
    FROM KaznjivaDjela
    WHERE Naziv = naziv_kaznenog_djela;

    SELECT COUNT(*) INTO broj_pojavljivanja
    FROM KaznjivaDjela_u_Slucaju
    WHERE KaznjivoDjeloID = (SELECT ID FROM KaznjivaDjela WHERE Naziv = naziv_kaznenog_djela);

    RETURN CONCAT('Kazneno djelo: ', naziv_kaznenog_djela, '\nPredviđena kazna: ', predvidena_kazna, '\nBroj pojavljivanja: ', broj_pojavljivanja);
END;
//
DELIMITER ;

SELECT KDInfo('NazivKaznenogDjela');

# Napiši funkciju koja će vratiti informacije o osobi prema broju telefona
DELIMITER //
CREATE FUNCTION InformacijeOOsobiPoTelefonu(broj_telefona VARCHAR(20)) RETURNS TEXT
DETERMINISTIC
BEGIN
    DECLARE osoba_info TEXT;

    SELECT CONCAT('Ime i prezime: ', Ime_Prezime, '\nDatum rođenja: ', Datum_rodjenja, '\nAdresa: ', Adresa, '\nEmail: ', Email)
    INTO osoba_info
    FROM Osoba
    WHERE Telefon = broj_telefona;

    IF osoba_info IS NOT NULL THEN
        RETURN osoba_info;
    ELSE
        RETURN 'Osoba s navedenim brojem telefona nije pronađena.';
    END IF;
END;
//
DELIMITER ;

# Napravi funkciju koja će za argument uzimati naziv grada i onda će izbrojati sve slučajeve u tom gradu. Također će izbrojiti sve slučajeve generalno i sve gradove generalno. Zatim će izračunati prosječan broj slučajeva po gradu. Na samom kraju će usporediti broj slučajeva u gradu koji smo uzeli za argument s prosječnim brojem slučajeva i vratit će "Ispodprosječna stopa" ako je manji od prosjeka; "U skladu s prosjekom" ako je isti kao prosjek ili "Iznadprosječna stopa" ako je veći od prosjeka. Prosjek računamo tako da podijelimo ukupan broj slučajeva s ukupnim brojem gradova
 
DELIMITER //
CREATE FUNCTION StopaKriminaliteta(grad VARCHAR(255))
RETURNS VARCHAR(50)
DETERMINISTIC
BEGIN
    DECLARE broj_slucajeva_u_gradu INT;
    DECLARE ukupan_broj_slucajeva INT;
    DECLARE ukupan_broj_gradova INT;
    DECLARE prosjecna_stopa_kriminaliteta DECIMAL(10, 2);

    SELECT COUNT(*) INTO broj_slucajeva_u_gradu
    FROM Slucaj
    WHERE MjestoId = (SELECT Id FROM Mjesto WHERE Naziv = grad);

    SELECT COUNT(*) INTO ukupan_broj_slucajeva
    FROM Slucaj;

    SELECT COUNT(DISTINCT MjestoId) INTO ukupan_broj_gradova
    FROM Slucaj;

    IF ukupan_broj_gradova > 0 THEN
        SET prosjecna_stopa_kriminaliteta = ukupan_broj_slucajeva / ukupan_broj_gradova;
    ELSE
        SET prosjecna_stopa_kriminaliteta = 0;
    END IF;

    IF broj_slucajeva_u_gradu < prosjecna_stopa_kriminaliteta THEN
        RETURN 'Ispodprosječna stopa';
    ELSEIF broj_slucajeva_u_gradu = prosjecna_stopa_kriminaliteta THEN
        RETURN 'U skladu s prosjekom';
    ELSE
        RETURN 'Iznadprosječna stopa';
    END IF;
END;
//
DELIMITER ;

# NAPIŠI SQL FUNKCIJU KOJA ĆE SLUŽITI ZA UNAPRIJEĐENJE POLICIJSKIH SLUŽBENIKA. Za argument će primati id osobe koju unaprijeđujemo i id novog radnog mjesta na koje je unaprijeđujemo. Taj će novi radno_mjesto_id zamjeniti stari. Također će provjeravati je li slučajno novi radno_mjesto_id jednak radno_mjesto_id-ju osobe koja je nadređena osobi koju unaprijeđujemo. Ako jest, postavit ćemo nadređeni_id na NULL zato što nam ne može biti nadređena osoba ista po činu
DELIMITER //
CREATE FUNCTION UnaprijediPolicijskogSluzbenika(osoba_id INT, novo_radno_mjesto_id INT)
RETURNS VARCHAR(255)
DETERMINISTIC
BEGIN
    DECLARE stari_radno_mjesto_id INT;
    DECLARE stari_nadredeni_id INT;

    SELECT Radno_mjesto_id, Nadređeni_id INTO stari_radno_mjesto_id, stari_nadredeni_id
    FROM Zaposlenik
    WHERE Osoba_id = osoba_id;

    IF novo_radno_mjesto_id = stari_radno_mjesto_id THEN
        UPDATE Zaposlenik
        SET Nadređeni_id = NULL
        WHERE Osoba_id = osoba_id;
        RETURN 'Unaprijeđeni službenik nema istog nadređenog.';
    ELSE
        UPDATE Zaposlenik
        SET Radno_mjesto_id = novo_radno_mjesto_id
        WHERE Osoba_id = osoba_id;
        RETURN 'Službenik uspješno unaprijeđen.';
    END IF;
END;
//
DELIMITER ;

# Napiši funkciju koja će za određeni predmet vratiti slučaj u kojem je taj predmet dokaz i osobu koja je u tom slučaju osumnjičena
DELIMITER //

CREATE FUNCTION DohvatiSlucajIOsobu(predmet_id INT)
RETURNS VARCHAR(512)
BEGIN
    DECLARE slucaj_naziv VARCHAR(255);
    DECLARE osoba_ime_prezime VARCHAR(255);
    DECLARE rezultat VARCHAR(512);
    
    -- Dohvati naziv slučaja
    SELECT Slucaj.Naziv INTO slucaj_naziv
    FROM Slucaj
    WHERE Slucaj.DokazID = predmet_id;
    
    -- Dohvati ime i prezime osobe povezane s predmetom
    SELECT Osoba.Ime_Prezime INTO osoba_ime_prezime
    FROM Osoba
    INNER JOIN Slucaj ON Osoba.Id = Slucaj.PociniteljID
    WHERE Slucaj.DokazID = predmet_id;
    
    
    SET rezultat = CONCAT('Odabrani je predmet dokaz u slučaju: ', slucaj_naziv, ', gdje je osumnjičena osoba: ', osoba_ime_prezime);
    
    RETURN rezultat;
END //

DELIMITER ;


/* KILLCOUNT:
    18 tables
    6 triggers
    11 queries
    10 views
    4 functions
    4 procedures
*/
