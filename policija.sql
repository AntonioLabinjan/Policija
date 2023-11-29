# ovo je dobro jeeeeej :)
DROP DATABASE IF EXISTS Policija;
CREATE DATABASE Policija;
USE Policija;

# TABLICE
CREATE TABLE Podrucje_uprave (
    id INT AUTO_INCREMENT PRIMARY KEY,
    naziv VARCHAR(255) NOT NULL UNIQUE
);
CREATE TABLE Mjesto (
    id INT AUTO_INCREMENT PRIMARY KEY,
    naziv VARCHAR(255) NOT NULL,
    id_podrucje_uprave INT,
    FOREIGN KEY (Id_Podrucje_Uprave) REFERENCES Podrucje_uprave(Id)
);

CREATE TABLE Zgrada (
    id INT AUTO_INCREMENT PRIMARY KEY,
    adresa VARCHAR(255) NOT NULL,
    id_mjesto INT,
    vrsta_zgrade VARCHAR(30),
    FOREIGN KEY (id_mjesto) REFERENCES Mjesto(ID)
);

CREATE TABLE  Radno_mjesto(
    id INT AUTO_INCREMENT PRIMARY KEY,
    vrsta VARCHAR(255) NOT NULL,
    dodatne_informacije TEXT
);

CREATE TABLE Odjeli (
    id INT AUTO_INCREMENT PRIMARY KEY,
    naziv VARCHAR(255) NOT NULL UNIQUE,
    opis TEXT
);

CREATE TABLE Osoba (
    id INT AUTO_INCREMENT PRIMARY KEY,
    ime_prezime VARCHAR(255) NOT NULL,
    datum_rodenja DATE NOT NULL,
    oib CHAR(11) NOT NULL UNIQUE,
    spol VARCHAR(10) NOT NULL,
    adresa VARCHAR(255) NOT NULL,
    telefon VARCHAR(20) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE
    );

CREATE TABLE Zaposlenik (
  id INT AUTO_INCREMENT PRIMARY KEY,
  datum_zaposlenja DATE NOT NULL,
  datum_izlaska_iz_sluzbe DATE, # ovo može biti NULL ako nije izašao iz službe
  id_nadređeni INT,
  id_radno_mjesto INT,
  id_odjel INT,
  id_zgrada INT,
  id_osoba INT,
  FOREIGN KEY (id_nadređeni) REFERENCES Zaposlenik(id), 
  FOREIGN KEY (id_radno_mjesto) REFERENCES Radno_mjesto(id),
  FOREIGN KEY (id_odjel) REFERENCES Odjeli(id),
  FOREIGN KEY (id_zgrada) REFERENCES Zgrada(id), # ovo je tipa zatvor di se nalazi/postaja di dela itd.
  FOREIGN KEY (id_osoba) REFERENCES Osoba(id)
);
	
CREATE TABLE Vozilo (
    id INT AUTO_INCREMENT PRIMARY KEY,
    marka VARCHAR(255) NOT NULL,
    model VARCHAR(255) NOT NULL,
    registracija VARCHAR(20) UNIQUE,
    godina_proizvodnje INT NOT NULL,
    sluzbeno_vozilo BOOLEAN, # je li službeno ili ne
    id_vlasnik INT NOT NULL, # ovaj FK se odnosi na privatna/osobna vozila
    FOREIGN KEY (id_vlasnik) REFERENCES Osoba(id)
);


CREATE TABLE Predmet (
    id INT AUTO_INCREMENT PRIMARY KEY,
    naziv VARCHAR(255) NOT NULL,
    id_mjesto_pronalaska INT,
    FOREIGN KEY (id_mjesto_pronalaska) REFERENCES Mjesto(id)
);

CREATE TABLE Kaznjiva_djela (
    id INT AUTO_INCREMENT PRIMARY KEY,
    naziv VARCHAR(255) NOT NULL UNIQUE,
    opis TEXT NOT NULL,
    predvidena_kazna INT,#zatvorska
    predvidena_novcana_kazna DECIMAL(10,2)
    
);

CREATE TABLE Pas (
    id INTEGER AUTO_INCREMENT PRIMARY KEY,
    id_trener INTEGER, # to je osoba zadužena za rad s psom
    oznaka VARCHAR(255) UNIQUE, # pretpostavljan da je ovo unikatno za svakega psa; ima mi logike 
    dob INTEGER NOT NULL,
    status VARCHAR(255),
    id_kaznjivo_djelo INTEGER,# dali je pas za drogu/ljude/oružje itd.
    FOREIGN KEY (id_trener) REFERENCES Zaposlenik(id),
    FOREIGN KEY (id_kaznjivo_djelo) REFERENCES Kaznjiva_djela(id)
    );

CREATE TABLE Slucaj (
    id INT AUTO_INCREMENT PRIMARY KEY,
    naziv VARCHAR(255) NOT NULL,
    opis TEXT,
    pocetak DATETIME NOT NULL,
    zavrsetak DATETIME NOT NULL,
    status VARCHAR(20),
    id_pocinitelj INT,
    id_izvjestitelj INT,
    id_voditelj INT,
    id_dokaz INT,
    ukupna_vrijednost_zapljena INT,
    id_pas INT,
    id_svjedok INT,
id_ostecenik INT,
    FOREIGN KEY (id_pocinitelj) REFERENCES Osoba(id),
    FOREIGN KEY (id_izvjestitelj) REFERENCES Osoba(id),
    FOREIGN KEY (id_voditelj) REFERENCES Zaposlenik(id),
    FOREIGN KEY (id_dokaz) REFERENCES Predmet(id),
    FOREIGN KEY (id_pas) REFERENCES Pas(id),
    FOREIGN KEY (id_svjedok) REFERENCES Osoba(id),
FOREIGN KEY (id_ostecenik) REFERENCES Osoba(id)
);

CREATE TABLE Evidencija_dogadaja (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_slucaj INT,
    opis_dogadaja TEXT NOT NULL,
    datum_vrijeme DATETIME NOT NULL,
    id_mjesto INT NOT NULL,
    FOREIGN KEY (id_slucaj) REFERENCES Slucaj(id),
    FOREIGN KEY (id_mjesto) REFERENCES Mjesto(id)
);



CREATE TABLE Kaznjiva_djela_u_slucaju (
	id INT AUTO_INCREMENT PRIMARY KEY,
    id_slucaj INT,
    id_kaznjivo_djelo INT,
    FOREIGN KEY (id_slucaj) REFERENCES Slucaj(id),
    FOREIGN KEY (id_kaznjivo_djelo) REFERENCES Kaznjiva_djela(id)
);




CREATE TABLE Izvjestaji (
    id INT AUTO_INCREMENT PRIMARY KEY,
    naslov VARCHAR(255) NOT NULL,
    sadrzaj TEXT NOT NULL,
    id_autor INT NOT NULL,
    id_slucaj INT NOT NULL,
    FOREIGN KEY (id_autor) REFERENCES Zaposlenik(id),
    FOREIGN KEY (id_slucaj) REFERENCES Slucaj(id)
);

CREATE TABLE Zapljene (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_slucaj INT NOT NULL,
    id_predmet INT NOT NULL,
    vrijednost NUMERIC (10,2),
    FOREIGN KEY (id_slucaj) REFERENCES Slucaj(id),
    FOREIGN KEY (id_predmet) REFERENCES Predmet(id)
);

CREATE TABLE Sredstvo_utvrdivanja_istine ( # ovo je tipa poligraf, alkotest i sl.
	id INT AUTO_INCREMENT PRIMARY KEY,
    naziv VARCHAR(100) NOT NULL
);

CREATE TABLE Sui_slucaj (
	id INT AUTO_INCREMENT PRIMARY KEY,
    id_sui INT,
    id_slucaj INT,
    FOREIGN KEY (id_sui) REFERENCES Sredstvo_utvrdivanja_istine(id),
    FOREIGN KEY (id_slucaj) REFERENCES Slucaj(id)
);

# KORISNICI (autentifikacija/autorizacija)
-- Kreiranje admin korisnika
CREATE USER 'admin'@'localhost' IDENTIFIED BY 'admin_password';
GRANT ALL PRIVILEGES ON *.* TO 'admin'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
-- prikaz ovlasti
SHOW GRANTS FOR 'admin'@'localhost';
-- oduzimanje ovlasti
REVOKE ALL PRIVILEGES ON *.* FROM 'admin'@'localhost';
FLUSH PRIVILEGES;
-- brisanje korisnika
DROP USER 'admin'@'localhost';


-- Kreiranje HR korisnika
CREATE USER 'hr'@'localhost' IDENTIFIED BY 'hr_password';
GRANT SELECT, INSERT, UPDATE, DELETE ON Policija.Radno_mjesto TO 'hr'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON Policija.Odjeli TO 'hr'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON Policija.Zaposlenik TO 'hr'@'localhost';
FLUSH PRIVILEGES;
-- prikaz ovlasti
SHOW GRANTS FOR 'hr'@'localhost';
-- oduzimanje ovlasti
REVOKE ALL PRIVILEGES ON *.* FROM 'hr'@'localhost';
FLUSH PRIVILEGES;
-- brisanje korisnika
DROP USER 'hr'@'localhost';

# Napravi korisnika za običnu fizičku osobu koja nije djelatnik policije i ima pristup samo osnovnijim, neklasificiranim tablicama
CREATE USER 'fizicka_osoba'@'localhost' IDENTIFIED BY 'fizicka_osoba_password';
GRANT SELECT ON Policija.Podrucje_uprave TO 'fizicka_osoba'@'localhost';
GRANT SELECT ON Policija.Mjesto TO 'fizicka_osoba'@'localhost';
GRANT SELECT ON Policija.Zgrada TO 'fizicka_osoba'@'localhost';
GRANT SELECT ON Policija.Radno_mjesto TO 'fizicka_osoba'@'localhost';
GRANT SELECT ON Policija.Odjeli TO 'fizicka_osoba'@'localhost';
GRANT SELECT (ime_prezime, datum_rodenja, spol, adresa, telefon, email) ON Policija.Osoba TO 'fizicka_osoba'@'localhost';
GRANT SELECT ON Policija.Kaznjiva_djela TO 'fizicka_osoba'@'localhost';
GRANT SELECT ON Policija.Sredstvo_utvrdivanja_istine TO 'fizicka_osoba'@'localhost';
FLUSH PRIVILEGES;

SHOW GRANTS FOR 'fizicka_osoba'@'localhost';
REVOKE ALL PRIVILEGES ON *.* FROM 'fizicka_osoba'@'localhost';
FLUSH PRIVILEGES;
-- brisanje korisnika
DROP USER 'fizicka_osoba'@'localhost';

# Napravi korisnika 'detektiv' (ne znan dali je to egzaktan naziv; forši da pitamo Denisa) koji će biti zadužen za prikupljanje dokaza na slučajevima, predmete, sredstva_utvrđivanja_istine i sastavljanje izvještaja
CREATE USER 'detektiv'@'localhost' IDENTIFIED BY 'detektiv_password';
GRANT SELECT, INSERT, UPDATE, DELETE ON Policija.Predmet TO 'detektiv'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON Policija.Slucaj TO 'detektiv'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON Policija.Sui TO 'detektiv'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON Policija.Sui_slucaj TO 'detektiv'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON Policija.Izvjestaji TO 'detektiv'@'localhost';
FLUSH PRIVILEGES;

# TRIGERI
# Iako postoji opcija kaskadnog brisanja u SQL-u, ovdje ćemo u nekim slučajevima pomoću trigera htijeti zabraniti brisanje, pošto je važno da neki podaci ostanu zabilježeni. U iznimnim slučajevima možemo ostavljati obavijest da je neka vrijednost obrisana iz baze. Također, u većini slučajeva nam opcija kaskadnog brisanja nikako ne bi odgovarala, zato što je u radu policije važna kontinuirana evidencija
# Napiši triger koji će a) ako u području uprave više od 5 mjesta, zabraniti brisanje uz obavijest: "Područje uprave s više od 5 mjesta ne smije biti obrisano" b) ako u području uprave ima manje od 5 mjesta, dopustiti da se područje uprave obriše, ali će se onda u mjestima koja referenciraju to područje uprave, pojaviti obavijest "Prvotno područje uprave je obrisano, povežite mjesto s novim područjem"
DELIMITER //
CREATE TRIGGER bd_podrucje_uprave
BEFORE DELETE ON Podrucje_uprave
FOR EACH ROW
BEGIN
    DECLARE count_mjesta INT;
    SELECT COUNT(*) INTO count_mjesta FROM Mjesto WHERE id_podrucje_uprave = OLD.id;
    
    IF count_mjesta > 5 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Područje uprave s više od 5 mjesta ne smije biti obrisano.';
    ELSE
        UPDATE Mjesto
        SET id_podrucje_uprave = NULL
        WHERE id_podrucje_uprave = OLD.id;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Prvotno područje uprave je obrisano, povežite mjesto s novim područjem.';
    END IF;
END;
//
DELIMITER ;

# Napiši triger koji će a) spriječiti brisanje osobe ako je ona zaposlenik koji je još u službi (datum izlaska iz službe nije null) uz obavijest:
# "osoba koju pokušavate obrisati je zaposlenik, prvo ju obrišite iz tablice zaposlenika)" b) obrisati osobu i iz tablice zaposlenika i iz tablice osoba, 
# ukoliko datum_izlaska_iz_službe ima neku vrijednost što ukazuje da osoba više nije zaposlena
DELIMITER //
CREATE TRIGGER bd_osoba
BEFORE DELETE ON Osoba
FOR EACH ROW
BEGIN
    DECLARE is_zaposlenik BOOLEAN;
    SET is_zaposlenik = EXISTS (SELECT 1 FROM Zaposlenik WHERE id_osoba = OLD.id AND datum_izlaska_iz_sluzbe IS NULL);

    IF is_zaposlenik = TRUE THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Osoba koju pokušavate obrisati je zaposlenik, prvo ju obrišite iz tablice Zaposlenik.';
    ELSE
        IF EXISTS (SELECT 1 FROM Zaposlenik WHERE id_osoba = OLD.id) THEN
            DELETE FROM Zaposlenik WHERE id_osoba = OLD.id;
        END IF;
    END IF;
END;
//
DELIMITER ;


# Napiši triger koji će, u slučaju da se kažnjivo djelo obriše iz baze, postaviti id_kaznjivo_djelo kod psa na NULL, ukoliko je on prije bio zadužen za upravo to KD koje smo obrisali
DELIMITER //
CREATE TRIGGER ad_pas
AFTER DELETE ON Kaznjiva_djela
FOR EACH ROW
BEGIN
    UPDATE Pas
    SET id_kaznjivo_djelo = NULL
    WHERE id_kaznjivo_djelo = OLD.id;
END;
//
DELIMITER ;

# Napiši triger koji će zabraniti da iz tablice obrišemo predmete koji služe kao dokazi u aktivnim slučajevima (status im nije završeno, te se ne nalaza u arhivi) uz obavijest "Ne možete obrisati dokaze za aktivan slučaj"
DELIMITER //
CREATE TRIGGER bd_dokaz
BEFORE DELETE ON Predmet
FOR EACH ROW
BEGIN
    DECLARE aktivan INT;
    SELECT COUNT(*) INTO aktivan FROM Slucaj WHERE id_dokaz = OLD.id AND status != 'Završeno';
    
    IF aktivan > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ne možete obrisati dokaze za aktivni slučaj.';
    END IF;
END;
//
DELIMITER ;

# Napiši triger koji će zabraniti da iz tablice obrišemo osobe koje su evidentirani kao počinitelji u aktivnim slučajevima
DELIMITER //
CREATE TRIGGER bd_osoba_2
BEFORE DELETE ON Osoba
FOR EACH ROW
BEGIN
    DECLARE je_pocinitelj INT;
    SELECT COUNT(*) INTO je_pocinitelj FROM Slucaj WHERE id_pocinitelj = OLD.id AND status != 'Završeno';
    
    IF je_pocinitelj > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ne možete obrisati osobu koja je evidentirana kao počinitelj.';
    END IF;
END;
//
DELIMITER ;

# Napiši triger koji će zabraniti brisanje bilo kojeg izvještaja kreiranog za slučajeve koji nisu završeni (završetak je NULL), ili im je završetak "noviji" od 10 godina (ne smijemo brisati izvještaje za aktivne slučajeve, i za slučajeve koji su završili pred manje od 10 godina)
DELIMITER //
CREATE TRIGGER bd_izvjestaj
BEFORE DELETE ON Izvjestaji
FOR EACH ROW
BEGIN
    DECLARE slucaj_zavrsen DATETIME;
    SELECT zavrsetak INTO slucaj_zavrsen FROM Slucaj WHERE id = OLD.id_slucaj;
    
    IF slucaj_zavrsen IS NULL OR slucaj_zavrsen > DATE_SUB(NOW(), INTERVAL 10 YEAR) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ne možete obrisati izvještaj za aktivan slučaj ili za slučaj koji je završio unutar posljednjih 10 godina.';
    END IF;
END;
//
DELIMITER ;

# Triger koji osigurava da pri unosu spola osobe možemo staviti samo muški ili ženski spol
DELIMITER //
CREATE TRIGGER bi_osoba
BEFORE INSERT ON Osoba
FOR EACH ROW
BEGIN
    DECLARE validan_spol BOOLEAN;

    SET NEW.Spol = LOWER(NEW.Spol);

    IF NEW.Spol IN ('muski', 'zenski', 'muški', 'ženski', 'm', 'ž', 'muški', 'ženski', 'muski', 'zenski') THEN
        SET validan_spol = TRUE;
    ELSE
        SET validan_spol = FALSE;
    END IF;

    IF NOT validan_spol THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Spol nije valjan. Ispravni formati su: muski, zenski, m, ž, muški, ženski.';
    END IF;
END;
//
DELIMITER ;

# Triger koji kreira stupac Ukupna_vrijednost_zapljena u tablici slučaj i ažurira ga nakon svake nove unesene zapljene u tom slučaju
DELIMITER //
CREATE TRIGGER ai_zapljena
AFTER INSERT ON Zapljene
FOR EACH ROW
BEGIN
    DECLARE ukupno DECIMAL(10, 2);
    
    SELECT SUM(P.Vrijednost) INTO ukupno
    FROM Predmet P
    WHERE P.ID = NEW.id_predmet;

    UPDATE Slucaj
    SET Ukupna_vrijednost_zapljena = ukupno
    WHERE ID = NEW.id_slucaj;
END;
//
DELIMITER ;

# Triger koji premješta završene slučajeve iz tablice slučaj u tablicu arhiva
DELIMITER //
CREATE TRIGGER au_slucaj_arhiva
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
CREATE TRIGGER bi_zaposlenik
BEFORE INSERT ON Zaposlenik
FOR EACH ROW
BEGIN
    IF NEW.id_nadređeni IS NOT NULL AND NEW.id_nadređeni = NEW.Id THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Nadređeni ne može biti ista osoba kao i podređeni.';
    END IF;
END;
//
DELIMITER ;

# Provjera da su datum početka i završetka slučaja različiti i da je datum završetka "veći" od datuma početka
DELIMITER //

CREATE TRIGGER bi_slucaj
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

CREATE TRIGGER bu_pas
BEFORE UPDATE ON Pas
FOR EACH ROW
BEGIN
    IF NEW.dob >= 10 AND OLD.dob <> NEW.dob THEN
        SET NEW.status = 'Časno umirovljen';
    END IF;
END;
//
DELIMITER ;

# Napravi triger koji će, u slučaju da je pas časno umirovljen koristeći triger (ili ručno), onemogućiti da ga koristimo u novim slučajevima
DELIMITER //
CREATE TRIGGER bi_slucaj_pas
BEFORE INSERT ON Slucaj
FOR EACH ROW
BEGIN
    DECLARE Pas_Status VARCHAR(255);
    SELECT Status INTO Pas_Status FROM Pas WHERE Id = NEW.id_pas;
    
    IF Pas_Status = 'Časno umirovljen' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Pas kojeg pokušavate koristiti na slučaju je umirovljen, odaberite drugog.';
    END IF;
END;
//
DELIMITER ;

# Napiši triger koji će, u slučaju da je osoba mlađa od 18 godina (godina današnjeg datuma - godina rođenja daju broj manji od 18), pri dodavanju te osobe u slučaj dodati poseban stupac s napomenom: Počinitelj je maloljetan - slučaj nije otvoren za javnost
ALTER TABLE Slucaj
ADD COLUMN Napomena VARCHAR(255);

DELIMITER //

CREATE TRIGGER bi_slucaj_maloljetni_pocinitelj
BEFORE INSERT ON Slucaj
FOR EACH ROW
BEGIN
    DECLARE datum_rodjenja DATE;
    DECLARE godina_danas INT;
    DECLARE godina_rodjenja INT;
    
    SELECT Osoba.Datum_rodjenja INTO datum_rodjenja
    FROM Osoba
    WHERE Osoba.Id = NEW.id_pocinitelj;
    
    SET godina_danas = YEAR(NOW());
    
    SET godina_rodjenja = YEAR(datum_rodjenja);
    
    IF (godina_danas - godina_rodjenja) < 18 THEN
        SET NEW.Napomena = 'Počinitelj je maloljetan - slučaj nije otvoren za javnost';
    ELSE
        SET NEW.Napomena = 'Počinitelj je punoljetan - javnost smije prisustvovati slučaju';
    END IF;
END //

DELIMITER ;

# Napravi triger koji će onemogućiti da maloljetnik bude vlasnik vozila
DELIMITER //
CREATE TRIGGER bi_vozilo_punoljetnost
BEFORE INSERT ON Vozilo FOR EACH ROW
BEGIN
    DECLARE vlasnik_godine INT;
    SELECT TIMESTAMPDIFF(YEAR, (SELECT Datum_rodjenja FROM Osoba WHERE Id = NEW.id_vlasnik), CURDATE()) INTO vlasnik_godine;

    IF vlasnik_godine < 18 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Vlasnik vozila je maloljetan i ne može posjedovati vozilo!';
    END IF;
END;
//
DELIMITER ;


# Napravi triger koji će u slučaju da postavljamo status slučaja na završeno, postaviti datum završetka na današnji ako mi eksplicitno ne navedemo neki drugi datum, ali će dozvoliti da ga izmjenimo ako želimo
DELIMITER //

CREATE TRIGGER bu_slucaj
BEFORE UPDATE ON Slucaj
FOR EACH ROW
BEGIN
    IF NEW.Status = 'Riješen' AND OLD.Status != 'Riješen' AND NEW.Zavrsetak IS NULL THEN
        SET NEW.Zavrsetak = CURRENT_DATE();
    END IF;
END;
//
DELIMITER ;



# UPITI
# Ispišimo sve voditelje slučajeva i slučajeve koje vode
SELECT O.Ime_Prezime, S.Naziv AS 'Naziv slučaja'
FROM Zaposlenik Z
JOIN Osoba O ON Z.id_osoba = O.Id
JOIN Slucaj S ON Z.Id = S.id_voditelj;


# Ispišimo slučajeve i evidencije za određenu osobu (osumnjičenika)
SELECT S.Naziv AS 'Naziv slučaja', ED.opis_dogadaja, ED.datum_vrijeme, ED.id_mjesto
FROM Slucaj S
JOIN Evidencija_dogadaja ED ON S.Id = ED.id_slucaj
JOIN Osoba O ON O.Id = S.id_pocinitelj
WHERE O.Ime_Prezime = 'Ime Prezime';

# Ispišimo sve osobe koje su osumnjičene za određeno KD
SELECT DISTINCT O.Ime_Prezime
FROM Osoba O
JOIN Slucaj S ON O.Id = S.id_pocinitelj
JOIN Kaznjiva_djela_u_slucaju	KD ON S.Id = KD.id_slucaj
JOIN Kaznjiva_djela	K ON KD.id_kaznjivo_djelo = K.id
WHERE K.Naziv = 'Naziv kaznenog djela';

# Pronađimo sve slučajeve koji sadrže KD i nisu riješeni
SELECT Slucaj.Naziv, Kaznjiva_djela.Naziv AS KaznjivoDjelo
FROM Slucaj
INNER JOIN Kaznjiva_djela_u_slucaju	ON Slucaj.ID = Kaznjiva_djela_u_slucaju.id_slucaj
INNER JOIN Kaznjiva_djela ON 
Kaznjiva_djela_u_slucaju.id_kaznjivo_djelo= Kaznjiva_djela.id
WHERE Slucaj.Status = 'Aktivan';

# Izračunajmo iznos zapljene za svaki pojedini slučaj
SELECT Slucaj.Naziv, SUM(Zapljene.Vrijednost) AS UkupnaVrijednostZapljena
FROM Slucaj
LEFT JOIN Zapljene ON Slucaj.ID = Zapljene.id_slucaj
GROUP BY Slucaj.ID;

# Nađimo sva kažnjiva djela koja su se dogodila ne nekom mjestu (mijenjamo id_mjesto_pronalaska)
SELECT K.Naziv, K.Opis
FROM Kaznjiva_Djela_u_Slucaju KS
JOIN Kaznjiva_Djela K ON KS.id_kaznjivo_djelo= K.ID
JOIN Evidencija_Dogadaja ED ON KS.id_slucaj= ED.id_slucaj
WHERE ED.id_mjesto=1;

# Nađimo  sve događaje koji uključuju pojedino kažnjivo djelo
SELECT E.Opis_Dogadaja, E.Datum_Vrijeme
FROM Evidencija_Dogadaja E
JOIN Slucaj S ON E.id_slucaj = S.Id
JOIN Kaznjiva_Djela_u_Slucaju KS ON S.Id = KS.id_slucaj
WHERE KS.id_kaznjivo_djelo = 1; # ovo moremo izmjenit

# Pronađi prosječnu vrijednost zapljene za pojedina kaznena djela
SELECT K.Naziv AS VrstaKaznenogDjela, AVG(Z.Vrijednost) AS ProsječnaVrijednostZapljene
FROM Kaznjiva_Djela_u_Slucaju KS
JOIN Kaznjiva_Djela K ON KS.id_kaznjivo_djelo= K.ID
JOIN Zapljene Z ON KS.id_slucaj	= Z.id_slucaj
GROUP BY K.Naziv;

# Pronađi sve odjele i broj zaposlenika na njima
SELECT O.Naziv AS NazivOdjela, COUNT(Z.Id) AS BrojZaposlenika
FROM Zaposlenik Z
JOIN Odjeli O ON Z.id_odjel	 = O.Id
GROUP BY O.id, O.Naziv;

# Pronađi ukupnu vrijednost zapljena po odjelu i sortiraj ih po vrijednosti silazno
SELECT Z.id_odjel, SUM(ZP.Vrijednost) AS UkupnaVrijednostZapljena
FROM Slucaj S
JOIN Zapljene ZP ON S.Id = ZP.id_slucaj
JOIN Zaposlenik Z ON S.id_voditelj= Z.Id
GROUP BY Z.id_odjel
ORDER BY UkupnaVrijednostZapljena DESC;



# Pronađi osobu koja mora odslužiti najveću ukupnu zatvorsku kaznu
SELECT O.Id, O.Ime_Prezime, SUM(KD.Predvidena_kazna) AS Ukupna_kazna
FROM Osoba O
INNER JOIN Slucaj S ON O.Id = S.id_pocinitelj
INNER JOIN Kaznjiva_Djela_u_Slucaju KS ON S.Id = KS.id_slucaj
INNER JOIN Kaznjiva_Djela KD ON KS.id_kaznjivo_djelo= KD.ID
WHERE KD.Predvidena_kazna IS NOT NULL
GROUP BY O.Id, O.Ime_Prezime
ORDER BY Ukupna_kazna DESC
LIMIT 1;

# Pronađi policijskog službenika koji je vodio najviše slučajeva
SELECT
    z.Id AS Zaposlenik_Id,
    o.Ime_Prezime AS Ime_Prezime,
    COUNT(s.Id) AS Broj_Slucajeva
FROM Zaposlenik z
JOIN Osoba o ON z.id_osoba= o.Id
LEFT JOIN Slucaj s ON s.id_voditelj = z.Id
GROUP BY z.Id, o.Ime_Prezime
HAVING COUNT(s.Id) = (
    SELECT MAX(Broj_Slucajeva)
    FROM (
        SELECT COUNT(Id) AS Broj_Slucajeva
        FROM Slucaj
        GROUP BY id_voditelj
    ) AS Max_voditelj
);

# Ispiši sva mjesta gdje nema evidentiranih kaznjivih djela u slučajevima(ili uopće nema slučajeva)
SELECT M.Id, M.Naziv
FROM Mjesto M
LEFT JOIN Evidencija_dogadaja ED ON M.Id = ED.id_mjesto
LEFT JOIN Slucaj S ON ED.id_slucaj= S.Id
LEFT JOIN Kaznjiva_Djela_u_Slucaju KDS ON S.Id = KDS.id_slucaj
WHERE KDS.id_slucaj IS NULL OR KDS.id_kaznjivo_djelo IS NULL
GROUP BY M.Id, M.Naziv;


# POGLEDI
# Pronađi sve policajce koji su vlasnici vozila koja su starija od 10 godina
CREATE VIEW PolicajciSaStarimVozilima AS
SELECT O.Ime_Prezime AS Policajac, V.Marka, V.Model, V.Godina_proizvodnje
FROM Osoba O
JOIN Zaposlenik Z ON O.Id = Z.id_osoba
JOIN Vozilo V ON O.Id = V.id_vlasnik
WHERE Z.id_radno_mjesto= (SELECT Id FROM Radno_mjesto WHERE Vrsta = 'Policajac')
AND V.Godina_proizvodnje <= YEAR(NOW()) - 10;

# Napravi pogled koji će pronaći sve osobe koje su počinile kazneno djelo pljačke i pri tome su koristili pištolj (to dohvati pomoću tablice predmet) i nazovi pogled "Počinitelji oružane pljačke"
CREATE VIEW PočiniteljiOružanePljačke AS
SELECT O.Ime_Prezime AS Počinitelj, K.Naziv AS KaznenoDjelo
FROM Osoba O
JOIN Slucaj S ON O.Id = S.id_pocinitelj
JOIN Kaznjiva_Djela_u_Slucaju KD ON S.Id = KD.id_slucaj
JOIN Kaznjiva_Djela K ON KD.id_kaznjivo_djelo	= K.ID
JOIN Predmet P ON S.id_dokaz= P.Id
WHERE K.Naziv = 'Pljačka' AND P.Naziv LIKE '%pištolj%';


#Napravi pogled koji će izlistati sva evidentirana kaznena djela i njihov postotak pojavljivanja u slučajevima
CREATE VIEW PostotakPojavljivanjaKaznenihDjela AS
SELECT
    KD.Naziv AS 'Kazneno_Djelo',
    COUNT(KS.id_slucaj) AS 'Broj_Slucajeva',
    COUNT(KS.id_slucaj) / (SELECT COUNT(*) FROM Slucaj) * 100 AS 'Postotak_Pojavljivanja'
FROM
    Kaznjiva_Djela KD
LEFT JOIN
    Kaznjiva_Djela_u_Slucaju KS
ON
    KD.ID = KS.id_kaznjivo_djelo
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
SELECT S.Naziv AS Slucaj, I.Naslov AS NaslovIzvjestaja, I.Sadrzaj AS SadržajIzvjestaja, O.Ime_Prezime AS AutorIzvjestaja
FROM Izvjestaji I
INNER JOIN Slucaj S ON I.id_slucaj	 = S.ID
INNER JOIN Osoba O ON I.id_autor	= O.Id;

# Napravi pogled koji će izlistati sve osobe i njihove odjele. Ukoliko osoba nije policajac te nema odjel (odjel je NULL), neka se uz tu osobu napiše "Osoba nije policijski službenik"
CREATE VIEW OsobeIOdjeli AS
SELECT O.Ime_Prezime AS ImeOsobe,
       CASE
           WHEN Z.id_radno_mjesto
           IS NOT NULL THEN OD.Naziv
           ELSE 'Osoba nije policijski službenik'
       END AS NazivOdjela
FROM Osoba O
LEFT JOIN Zaposlenik Z ON O.Id = Z.id_osoba
LEFT JOIN Odjeli OD ON Z.id_odjel= OD.Id;


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
    Slucaj S ON O.ID = S.id_voditelj
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
JOIN Slucaj S ON Z.id_slucaj	 = S.ID
JOIN Kaznjiva_Djela_u_Slucaju KDUS ON S.ID = KDUS.id_slucaj
JOIN Kaznjiva_Djela K ON KDUS.id_kaznjivo_djelo = K.id
GROUP BY K.Naziv;


SELECT * From StatistikaZapljenaPoKaznenomDjelu;
DROP VIEW StatistikaZapljenaPoKaznenomDjelu;

# Napravi view koji će za svaki slučaj izračunati ukupnu zatvorsku kaznu, uz ograničenje da maksimalna zakonska zatvorska kazna u RH iznosi 50 godina. Ako ukupna kazna premaši 50, postaviti će se na 50 uz odgovarajuće upozorenje
CREATE VIEW UkupnaPredvidenaKaznaPoSlucaju AS
SELECT S.ID AS 'SlucajID',
       S.Naziv AS 'NazivSlucaja',
       CASE
           WHEN SUM(KD.Predvidena_kazna) > 50 THEN 50
           ELSE SUM(KD.Predvidena_kazna)
       END AS 'UkupnaPredvidenaKazna',
       CASE
           WHEN SUM(KD.Predvidena_kazna) > 50 THEN 'Maksimalna zakonska zatvorska kazna iznosi 50 godina'
           ELSE NULL
       END AS 'Napomena'
FROM Slucaj S
LEFT JOIN Kaznjiva_Djela_u_Slucaju KDUS ON S.ID = KDUS.id_slucaj
LEFT JOIN Kaznjiva_Djela KD ON KDUS.id_kaznjivo_djelo		= KD.ID
GROUP BY S.ID, S.Naziv;

# Napiši view koji će za sve policijske službenike dohvatiti njihovu dob i godine staža (ukoliko je još aktivan, oduzimat ćemo od trenutne godine godinu zaposlenja, a ako je umirovljen, oduzimat će od godine umirovljenja godinu zaposlenja)
# Onda dodat još stupac koji prati dali je umirovljen ili aktivan
CREATE VIEW Pogled_Policijskih_Sluzbenika AS
SELECT
    o.Id AS Zaposlenik_Id,
    o.Ime_Prezime AS Ime_Prezime,
    o.Datum_rodenja AS Datum_rodenja,
    DATEDIFF(CURRENT_DATE, z.Datum_zaposlenja) AS Godine_Staza,
    CASE
        WHEN z.Datum_izlaska_iz_sluzbe IS NOT NULL AND z.Datum_izlaska_iz_sluzbe <= CURRENT_DATE THEN 'Da'
        ELSE 'Ne'
    END AS Umirovljen
FROM Osoba o
INNER JOIN Zaposlenik z ON o.Id = z.id_osoba;

# Napravi pogled koji će izlistati sve pse i broj slučajeva na kojima je svaki od njih radio. U poseban stupac dodaj broj riješenih slučajeva od onih na kojima su radili. Zatim izračunaj postotak rješenosti slučajeva za svakog psa i to dodaj u novi stupac
CREATE VIEW Pregled_Pasa AS
SELECT
    P.Id AS PasID,
    P.Oznaka AS OznakaPsa,
    O.Ime_Prezime AS Vlasnik,
    COUNT(S.Id) AS BrojSlucajeva,
    SUM(CASE WHEN S.Status = 'Završeno' THEN 1 ELSE 0 END) AS BrojRijesenih,
    (SUM(CASE WHEN S.Status = 'Završeno' THEN 1 ELSE 0 END) / COUNT(S.Id) * 100) AS PostotakRjesenosti
FROM
    Pas AS P
LEFT JOIN Slucaj AS S ON P.Id = S.id_pas
LEFT JOIN Osoba AS O ON P.Id_trener = O.Id
GROUP BY
    P.Id;

# Nadogradi prethodni view tako da pronalazi najefikasnijeg psa, s najvećim postotkom rješenosti
CREATE VIEW NajefikasnijiPas AS
SELECT
    PasID,
    OznakaPsa,
    Vlasnik,
    BrojSlucajeva,
    BrojRijesenih,
    PostotakRjesenosti
FROM
    Pregled_Pasa
WHERE
    PostotakRjesenosti = (SELECT MAX(PostotakRjesenosti) FROM Pregled_Pasa);


# PROCEDURE
# Napiši proceduru za unos novog područja uprave
DELIMITER //

CREATE PROCEDURE Dodaj_Novo_Podrucje_Uprave(IN p_naziv VARCHAR(255))
BEGIN
    INSERT INTO Podrucje_uprave (naziv) VALUES (p_naziv);
END //

DELIMITER ;

# Napiši proceduru za unos novog mjesta
DELIMITER //

CREATE PROCEDURE Dodaj_Novo_Mjesto(
    IN p_naziv VARCHAR(255),
    IN p_id_podrucje_uprave INT
)
BEGIN
    INSERT INTO Mjesto (naziv, id_podrucje_uprave) VALUES (p_naziv, p_id_podrucje_uprave);
END //

DELIMITER ;

# Napiši proceduru za unos nove zgrade
DELIMITER //

CREATE PROCEDURE Dodaj_Novu_Zgradu(
    IN p_adresa VARCHAR(255),
    IN p_vrsta_zgrade VARCHAR(30),
    IN p_id_mjesto INT
)
BEGIN
    INSERT INTO Zgrada (adresa, vrsta_zgrade, id_mjesto) VALUES (p_adresa, p_vrsta_zgrade, p_id_mjesto);
END //

DELIMITER ;

# Napiši proceduru za unos novog radnog mjesta
DELIMITER //

CREATE PROCEDURE Dodaj_Novo_Radno_Mjesto(
    IN p_vrsta VARCHAR(255),
    IN p_dodatne_informacije TEXT
)
BEGIN
    INSERT INTO Radno_mjesto (vrsta, dodatne_informacije) VALUES (p_vrsta, p_dodatne_informacije);
END //

DELIMITER ;

# Napiši proceduru za unos novog odjela
DELIMITER //

CREATE PROCEDURE Dodaj_Novi_Odjel(
    IN p_naziv VARCHAR(255),
    IN p_opis TEXT
)
BEGIN
    INSERT INTO Odjeli (naziv, opis) VALUES (p_naziv, p_opis);
END //

DELIMITER ;

# Napiši proceduru za unos nove osobe
DELIMITER //

CREATE PROCEDURE Dodaj_Novu_Osobu(
    IN p_ime_prezime VARCHAR(255),
    IN p_datum_rodenja DATE,
    IN p_oib CHAR(11),
    IN p_spol VARCHAR(10),
    IN p_adresa VARCHAR(255),
    IN p_fotografija BLOB,
    IN p_telefon VARCHAR(20),
    IN p_email VARCHAR(255)
)
BEGIN
    INSERT INTO Osoba (ime_prezime, datum_rodenja, oib, spol, adresa, fotografija, telefon, email)
    VALUES (p_ime_prezime, p_datum_rodenja, p_oib, p_spol, p_adresa, p_fotografija, p_telefon, p_email);
END //

DELIMITER ;

# Procedura za unos novog zaposlenika
DELIMITER //

CREATE PROCEDURE Dodaj_Novog_Zaposlenika(
    IN p_datum_zaposlenja DATETIME,
    IN p_id_nadređeni INT,
    IN p_id_radno_mjesto INT,
    IN p_id_odjel INT,
    IN p_id_zgrada INT,
    IN p_id_mjesto INT,
    IN p_id_osoba INT
)
BEGIN
    INSERT INTO Zaposlenik (datum_zaposlenja, id_nadređeni, id_radno_mjesto, id_odjel, id_zgrada, id_mjesto, id_osoba)
    VALUES (p_datum_zaposlenja, p_id_nadređeni, p_id_radno_mjesto, p_id_odjel, p_id_zgrada, p_id_mjesto, p_id_osoba);
END //

DELIMITER ;

# Procedura za unos novog vozila
DELIMITER //

CREATE PROCEDURE Dodaj_Novo_Vozilo(
    IN p_marka VARCHAR(255),
    IN p_model VARCHAR(255),
    IN p_registracija VARCHAR(20),
    IN p_godina_proizvodnje INT,
    IN p_tip_vozila INT, -- 1 za službeno, 0 za privatno
    IN p_id_vlasnik INT
)
BEGIN
    DECLARE v_vlasnik VARCHAR(255);
    
    IF p_tip_vozila = 1 THEN
        SET v_vlasnik = 'Ministarstvo unutarnjih poslova';
    ELSE
        -- Ako nije službeno vozilo, koristimo predani ID vlasnika
        SELECT ime_prezime INTO v_vlasnik FROM Osoba WHERE id = p_id_vlasnik;
    END IF;
    
    INSERT INTO Vozilo (marka, model, registracija, godina_proizvodnje, sluzbeno_vozilo, id_vlasnik)
    VALUES (p_marka, p_model, p_registracija, p_godina_proizvodnje, p_tip_vozila, v_vlasnik);
END //

DELIMITER ;

# Napiši proceduru za dodavanje novog predmeta
DELIMITER //

CREATE PROCEDURE Dodaj_Novi_Predmet(
    IN p_naziv VARCHAR(255),
    IN p_id_mjesto_pronalaska INT
)
BEGIN
    -- Unos novog predmeta
    INSERT INTO Predmet (naziv, id_mjesto_pronalaska)
    VALUES (p_naziv, p_id_mjesto_pronalaska);
END //

DELIMITER ;

# Napiši proceduru za dodavanje novog kaznjivog djela u bazu
DELIMITER //

CREATE PROCEDURE Dodaj_Novo_Kaznjivo_Djelo(
    IN p_naziv VARCHAR(255),
    IN p_opis TEXT,
    IN p_predvidena_kazna INT
)
BEGIN
    -- Unos novog kaznjivog djela
    INSERT INTO Kaznjiva_djela (naziv, opis, predvidena_kazna)
    VALUES (p_naziv, p_opis, p_predvidena_kazna);
END //

DELIMITER ;

# Napiši proceduru za dodavanje novog psa
DELIMITER //

CREATE PROCEDURE Dodaj_Novog_Psa(
    IN p_id_trener INTEGER,
    IN p_oznaka VARCHAR(255),
    IN p_dob INTEGER,
    IN p_status VARCHAR(255),
    IN p_id_kaznjivo_djelo INTEGER
)
BEGIN
    -- Unos novog psa
    INSERT INTO Pas (id_trener, oznaka, dob, status, id_kaznjivo_djelo)
    VALUES (p_id_trener, p_oznaka, p_dob, p_status, p_id_kaznjivo_djelo);
END //

DELIMITER ;

# Napiši proceduru za dodavanje novog slučaja, ali neka se ukupna vrijednost zapljena i dalje računa automatski preko trigera
DELIMITER //

CREATE PROCEDURE Dodaj_Novi_Slucaj(
    IN p_naziv VARCHAR(255),
    IN p_opis TEXT,
    IN p_pocetak DATETIME,
    IN p_zavrsetak DATETIME,
    IN p_status VARCHAR(20),
    IN p_id_pocinitelj INT,
    IN p_id_izvjestitelj INT,
    IN p_id_voditelj INT,
    IN p_id_dokaz INT,
    IN p_id_pas INT,
    IN p_id_svjedok INT
)
BEGIN
    -- Unos novog slučaja
    INSERT INTO Slucaj (naziv, opis, pocetak, zavrsetak, status, id_pocinitelj, id_izvjestitelj, id_voditelj, id_dokaz, id_pas, id_svjedok)
    VALUES (p_naziv, p_opis, p_pocetak, p_zavrsetak, p_status, p_id_pocinitelj, p_id_izvjestitelj, p_id_voditelj, p_id_dokaz, p_id_pas, p_id_svjedok);
END //

DELIMITER ;

# Napravi proceduru koja će dodati novi događaj
DELIMITER //

CREATE PROCEDURE Dodaj_događaj_u_evidenciju(
    IN p_slucaj_id INT,
    IN p_opis_dogadaja TEXT,
    IN p_datum_vrijeme DATETIME,
    IN p_mjesto_id INT
)
BEGIN
    INSERT INTO Evidencija_dogadaja (id_slucaj, opis_dogadaja, datum_vrijeme, id_mjesto)
    VALUES (p_slucaj_id, p_opis_dogadaja, p_datum_vrijeme, p_mjesto_id);
END //

DELIMITER ;

# Napiši proceduru koja će dodavati kažnjiva djela u slučaju
DELIMITER //

CREATE PROCEDURE Dodaj_Kaznjivo_Djelo_U_Slucaju(
    IN p_slucaj_id INT,
    IN p_kaznjivo_djelo_id INT
)
BEGIN
    INSERT INTO Kaznjiva_djela_u_slucaju (id_slucaj, id_kaznjivo_djelo)
    VALUES (p_slucaj_id, p_kaznjivo_djelo_id);
END //

DELIMITER ;


DELIMITER //

# Napiši proceduru za dodavanje izvještaja
CREATE PROCEDURE Dodaj_Izvjestaj(
    IN p_naslov VARCHAR(255),
    IN p_sadrzaj TEXT,
    IN p_autor_id INT,
    IN p_slucaj_id INT
)
BEGIN
    INSERT INTO Izvjestaji (naslov, sadrzaj, id_autor, id_slucaj)
    VALUES (p_naslov, p_sadrzaj, p_autor_id, p_slucaj_id);
END //

DELIMITER ;

# Napiši proceduru za dodavanje zapljena
DELIMITER //

CREATE PROCEDURE Dodaj_Zapljene(
    IN p_opis TEXT,
    IN p_slucaj_id INT,
    IN p_predmet_id INT,
    IN p_vrijednost NUMERIC(5,2)
)
BEGIN
    INSERT INTO Zapljene (opis, id_slucaj, id_predmet, Vrijednost)
    VALUES (p_opis, p_slucaj_id, p_predmet_id, p_vrijednost);
END //

DELIMITER ;


# Napiši proceduru za dodavanje sredstva utvrđivanja istine
DELIMITER //

CREATE PROCEDURE Dodaj_Sredstvo_Utvrđivanja_Istine(
    IN p_naziv VARCHAR(100)
)
BEGIN
    INSERT INTO Sredstvo_utvrdivanja_istine (naziv)
    VALUES (p_naziv);
END //

DELIMITER ;

# Napiši proceduru za dodavanje SUI slučaj
DELIMITER //

CREATE PROCEDURE Dodaj_Sui_Slucaj(
    IN p_id_sui INT,
    IN p_id_slucaj INT
)
BEGIN
    INSERT INTO Sui_slucaj (id_sui, id_slucaj)
    VALUES (p_id_sui, p_id_slucaj);
END //

DELIMITER ;

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
    
    CREATE TEMPORARY TABLE Temp_Psi (id_pas	INT, BrojSlucajeva INT);

    
    INSERT INTO Temp_Psi (id_pas, BrojSlucajeva)
    SELECT id_pas, COUNT(*) AS BrojSlucajeva
    FROM Slucaj
    GROUP BY id_pas;

    
    ALTER TABLE Pas ADD COLUMN Status VARCHAR(255);

    
    UPDATE Pas
    SET Status = 'nagrađeni pas'
    WHERE Id IN (SELECT	id_pas  FROM Temp_Psi WHERE BrojSlucajeva > 15);
    
    
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
    WHERE id_pocinitelj	= osoba_id;

    IF počinitelj_count > 0 THEN
        SET obavijest = 'Osoba je kažnjavana';
        SELECT obavijest AS Poruka;
    ELSE
        INSERT INTO Izvjestaji (Naslov, Sadržaj, id_autor, id_slucaj)
        VALUES ('Potvrda o nekažnjavanju', CONCAT('Osoba ', osoba_ime_prezime, ' nije kažnjavana. Izdana ', DATE_FORMAT(izdavanje_datum, '%d-%m-%Y %H:%i:%s')), osoba_id, NULL);
        SELECT CONCAT('Potvrda za ', osoba_ime_prezime) AS Poruka;
    END IF;
END //

DELIMITER ;

# Napiši proceduru koja će omogućiti da za određenu osobu izmjenimo kontakt informacije (email i/ili broj telefona)
DELIMITER //

CREATE PROCEDURE IzmjeniKontaktInformacije(
    IN id_osoba INT,
    IN novi_email VARCHAR(255),
    IN novi_telefon VARCHAR(20)
)
BEGIN
    DECLARE br_osoba INT;
    SELECT COUNT(*) INTO br_osoba FROM Osoba WHERE Id = id_osoba;
    
    IF br_osoba > 0 THEN
        UPDATE Osoba
        SET Email = novi_email, Telefon = novi_telefon
        WHERE Id = id_osoba;
        
        SELECT 'Kontakt informacije su uspješno izmijenjene' AS Poruka;
    ELSE
        SELECT 'Osoba s navedenim ID-jem ne postoji' AS Poruka;
    END IF;
END //

DELIMITER ;

# Napiši proceduru koja će za određeni slučaj izlistati sve događaje koji su se u njemu dogodili i poredati ih kronološki
DELIMITER //

CREATE PROCEDURE Izlistaj_dogadjaje(IN id_slucaj INT)
BEGIN
    SELECT ed.Id, ed.opis_dogadaja,ed.datum_vrijeme
    FROM Evidencija_dogadaja	AS ed
    WHERE ed.id_slucaj = id_slucaj
    ORDER BY ed.Datum_Vrijeme;
END //

DELIMITER ;
CALL Izlistaj_dogadjaje(10);
# Napiši PROCEDURU KOJA ZA ARGUMENT PRIMA OZNAKU PSA, A VRAĆA ID, IME i PREZIME VLASNIKA i BROJ SLUČAJEVA U KOJIMA JE PAS SUDJELOVAO
DELIMITER //
CREATE PROCEDURE Info_pas(IN Oznaka VARCHAR(255))
BEGIN
    SELECT
        O.Id AS Vlasnik_id,
        O.Ime_Prezime AS Trener,
        COUNT(S.Id) AS BrojSlucajeva
    FROM
        Pas AS P
    INNER JOIN Slucaj AS S ON P.Id = S.id_pas
    INNER JOIN Osoba AS O ON P.Id_trener = O.Id
    WHERE
        P.Oznaka = Oznaka
    GROUP BY
        P.Id;
END
//
DELIMITER ;

# Napiši proceduru koja će za određeno KD moći smanjiti ili povećati predviđenu kaznu tako što će za argument primiti naziv KD i broj godina za koji želimo izmjeniti kaznu
# Ako želimo smanjiti kaznu, za argument ćemo prosljediti negativan broj
DELIMITER //
CREATE PROCEDURE izmjeni_kaznu(IN naziv_djela VARCHAR(255), IN iznos INT)
BEGIN
    DECLARE kazna INT;
    
    SELECT predvidena_kazna INTO kazna
    FROM Kaznjiva_djela
    WHERE naziv = naziv_djela;
    
    IF kazna IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Traženo KD ne postoji u bazi';
    END IF;
    
    SET kazna = kazna + iznos;
    
    UPDATE Kaznjiva_djela
    SET predvidena_kazna = kazna
    WHERE naziv = naziv_djela;
END //
DELIMITER ;

#Napiši proceduru koja će dohvaćati slučajeve koji sadrže određeno kazneno djelo i sortirati ih po vrijednosti zapljene silazno
DELIMITER //
CREATE PROCEDURE Dohvati_Slucajeve_Po_Kaznenom_Djelu_Sortirano(kaznenoDjeloNaziv VARCHAR(255))
BEGIN
    DECLARE slucaj_id INT;
    DECLARE slucaj_naziv VARCHAR(255);
    DECLARE zapljena_vrijednost NUMERIC (5,2);

    DECLARE slucajevi_Cursor CURSOR FOR
        SELECT Slucaj.id, Slucaj.naziv, Zapljene.Vrijednost
        FROM Slucaj
        JOIN Kaznjiva_djela_u_slucaju ON Slucaj.id = Kaznjiva_djela_u_slucaju.id_slucaj
        JOIN Kaznjiva_djela ON Kaznjiva_djela_u_slucaju.id_kaznjivo_djelo = Kaznjiva_djela.id
        LEFT JOIN Zapljene ON Slucaj.id = Zapljene.id_slucaj
        WHERE Kaznjiva_djela.naziv = kaznenoDjeloNaziv
        ORDER BY Zapljene.Vrijednost DESC;

    OPEN slucajevi_Cursor;

    slucaj_loop: LOOP
        FETCH slucajevi_Cursor INTO slucaj_id, slucaj_naziv, zapljena_vrijednost;
        IF slucaj_id IS NULL THEN
            LEAVE slucaj_loop;
        END IF;
        -- Ovdje možeš raditi s podacima
        SELECT slucaj_naziv, zapljena_vrijednost;
    END LOOP;

    CLOSE slucajevi_Cursor;
END //
DELIMITER ;
CALL Dohvati_Slucajeve_Po_Kaznenom_Djelu_Sortirano('Ubojstvo');

# Napiši proceduru koja će ispisati sve zaposlenike, imena i prezimena, adrese i brojeve telefona u jednom redu za svakog zaposlenika
DROP PROCEDURE IF EXISTS IspisiInformacijeZaposlenika;
DELIMITER //

CREATE PROCEDURE IspisiInformacijeZaposlenika()
BEGIN

    DECLARE zaposlenik_id INT;
    DECLARE zaposlenik_ime_prezime VARCHAR(255);
    DECLARE zaposlenik_adresa VARCHAR(255);
    DECLARE zaposlenik_telefon VARCHAR(20);


    DECLARE zaposleniciCursor CURSOR FOR
        SELECT Zaposlenik.id, Osoba.ime_prezime, Osoba.adresa, Osoba.telefon
        FROM Zaposlenik
        JOIN Osoba ON Zaposlenik.id_osoba = Osoba.id;


    DECLARE CONTINUE HANDLER FOR NOT FOUND
    BEGIN

        SELECT 'Nema dostupnih informacija o zaposlenicima.' AS Info;
    END;

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN

        SELECT 'Došlo je do greške u izvršavanju SQL upita.' AS Info;
    END;


    OPEN zaposleniciCursor;

    zaposlenik_loop: LOOP

        FETCH zaposleniciCursor INTO zaposlenik_id, zaposlenik_ime_prezime, zaposlenik_adresa, zaposlenik_telefon;


        IF zaposlenik_id IS NULL THEN
            LEAVE zaposlenik_loop;
        END IF;


        SELECT CONCAT('Zaposlenik: ', zaposlenik_ime_prezime, ', Adresa: ', zaposlenik_adresa, ', Telefon: ', zaposlenik_telefon) AS Info;
    END LOOP;


    CLOSE zaposleniciCursor;
END //

DELIMITER ;



CALL IspisiInformacijeZaposlenika;
# Napiši proceduru koja će ispisati sve slučajeve i za svaki slučaj ispisati voditelja i ukupan iznos zapljena. Ako nema pronađenih slučajeva, neka nas obavijesti o tome
DROP PROCEDURE IspisiPodatkeOSlucajevimaIZapljenama;
DELIMITER //

CREATE PROCEDURE IspisiPodatkeOSlucajevimaIZapljenama()
BEGIN
    -- Kreirajte tablicu za privremene rezultate
    CREATE TEMPORARY TABLE IF NOT EXISTS TempRezultati (
        id INT,
        voditeljImePrezime VARCHAR(255),
        ukupanIznosZapljena NUMERIC(10, 2)
    );

    -- Ubacite podatke o slučajevima, voditeljima i ukupnom iznosu zapljena u tablicu za privremene rezultate
    INSERT INTO TempRezultati (id, voditeljImePrezime, ukupanIznosZapljena)
    SELECT
        Slucaj.id,
        Osoba.ime_prezime AS voditeljImePrezime,
        COALESCE(SUM(Zapljene.Vrijednost), 0) AS ukupanIznosZapljena # sumiraj sve zapljene koje nisu NULL (za to služi COALESCE)
    FROM Slucaj
    JOIN Zaposlenik ON Slucaj.id_voditelj = Zaposlenik.id
    JOIN Osoba ON Zaposlenik.id_osoba = Osoba.id
    LEFT JOIN Zapljene ON Slucaj.id = Zapljene.id_slucaj
    GROUP BY Slucaj.id, Osoba.ime_prezime;

    -- Ispisivanje informacija o slučaju
    SELECT * FROM TempRezultati;

    -- Ispis obavijesti ako nema pronađenih redaka
    IF (SELECT COUNT(*) FROM TempRezultati) = 0 THEN
        SELECT 'Nema podataka o slučajevima i zapljenama.' AS Napomena;
    END IF;

    -- Obrišite tablicu za privremene rezultate
    DROP TEMPORARY TABLE IF EXISTS TempRezultati;

END //

DELIMITER ;


CALL IspisiPodatkeOSlucajevimaIZapljenama;
# FUNKCIJE + upiti za funkcije
# Napiši funkciju koja kao argument prima naziv kaznenog djela i vraća naziv KD, predviđenu kaznu i broj pojavljivanja KD u slučajevima
DELIMITER //
CREATE FUNCTION KDInfo(naziv_kaznenog_djela VARCHAR(255)) RETURNS TEXT
DETERMINISTIC
BEGIN
    DECLARE predvidena_kazna INT;
    DECLARE broj_pojavljivanja INT;
    
    SELECT predvidena_kazna INTO predvidena_kazna
    FROM Kaznjiva_djela
    WHERE Naziv = naziv_kaznenog_djela;

    SELECT COUNT(*) INTO broj_pojavljivanja
    FROM Kaznjiva_Djela_u_Slucaju
    WHERE id_kaznjivo_djelo= (SELECT ID FROM Kaznjiva_djela	WHERE Naziv = naziv_kaznenog_djela);

    RETURN CONCAT('Kazneno djelo: ', naziv_kaznenog_djela, '\nPredviđena kazna: ', predvidena_kazna, '\nBroj pojavljivanja: ', broj_pojavljivanja);
END;
//
DELIMITER ;

SELECT KDInfo('NazivKaznenogDjela');

# Napiši upit koji će koristeći ovu funkciju izlistati sva kaznena djela koja su se dogodila u 2023. godini (ili nekoj drugoj) i njihov broj pojavljivanja
SELECT
    KDInfo(KD.Naziv) AS KaznenoDjeloInfo,
    COUNT(KS.id_kaznjivo_djelo) AS BrojPojavljivanja
FROM Kaznjiva_Djela_u_Slucaju KS
INNER JOIN Kaznjiva_djela KD ON KS.id_kaznjivo_djelo = KD.ID
INNER JOIN Slucaj S ON KS.id_slucaj = S.ID
WHERE YEAR(S.Pocetak) = 2023
GROUP BY KD.Naziv;


# Napiši funkciju koja će vratiti informacije o osobi prema broju telefona
DELIMITER //
CREATE FUNCTION InformacijeOOsobiPoTelefonu(broj_telefona VARCHAR(20)) RETURNS TEXT
DETERMINISTIC
BEGIN
    DECLARE osoba_info TEXT;

    SELECT CONCAT('Ime i prezime: ', Ime_Prezime, '\nDatum rođenja: ', Datum_rodenja, '\nAdresa: ', Adresa, '\nEmail: ', Email)
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

# Napiši upit koji će izlistati sve brojeve telefona i informacije o tim osobama, ali samo ako te osobe nisu policijski službenici
SELECT
    Telefon,
    InformacijeOOsobiPoTelefonu(Telefon) AS OsobaInfo
FROM Osoba
WHERE Osoba.id NOT IN(SELECT id_osoba FROM Zaposlenik);


# NAPIŠI SQL FUNKCIJU KOJA ĆE SLUŽITI ZA UNAPRIJEĐENJE POLICIJSKIH SLUŽBENIKA. Za argument će primati id osobe koju unaprijeđujemo i id novog radnog mjesta na koje je unaprijeđujemo. Taj će novi radno_mjesto_id zamjeniti stari. Također će provjeravati je li slučajno novi radno_mjesto_id jednak radno_mjesto_id-ju osobe koja je nadređena osobi koju unaprijeđujemo. Ako jest, postavit ćemo nadređeni_id na NULL zato što nam ne može biti nadređena osoba ista po činu
SET SQL_safe_updates = 0;
# SELECT UnaprijediPolicijskogSluzbenika(4, 6);
DELIMITER //
CREATE FUNCTION UnaprijediPolicijskogSluzbenika(id_osoba	INT, novo_radno_mjesto_id INT)
RETURNS VARCHAR(255)
DETERMINISTIC
BEGIN
    DECLARE stari_radno_mjesto_id INT;
    DECLARE stari_nadredeni_id INT;

    SELECT id_radno_mjesto, id_nadređeni	INTO stari_radno_mjesto_id, stari_nadredeni_id
    FROM Zaposlenik
    WHERE 
    id_osoba = id_osoba;
    IF novo_radno_mjesto_id = stari_radno_mjesto_id THEN
        UPDATE Zaposlenik
        SET id_nadređeni
        = NULL
        WHERE id_osoba = id_osoba;
        RETURN 'Unaprijeđeni službenik nema istog nadređenog.';
    ELSE
        UPDATE Zaposlenik
        SET id_radno_mjesto
        = novo_radno_mjesto_id
        WHERE id_osoba = id_osoba;
        RETURN 'Službenik uspješno unaprijeđen.';
    END IF;
END;
//
DELIMITER ;
DROP FUNCTION UnaprijediPolicijskogSluzbenika;
# Napiši funkciju koja će za određeni predmet vratiti slučaj u kojem je taj predmet dokaz i osobu koja je u tom slučaju osumnjičena
DELIMITER //

CREATE FUNCTION DohvatiSlucajIOsobu(id_predmet	INT)
RETURNS VARCHAR(512)
DETERMINISTIC
BEGIN
    DECLARE slucaj_naziv VARCHAR(255);
    DECLARE osoba_ime_prezime VARCHAR(255);
    DECLARE rezultat VARCHAR(512);
    
    
    SELECT Slucaj.Naziv INTO slucaj_naziv
    FROM Slucaj
    WHERE Slucaj.id_dokaz= predmet_id;
    
    
    SELECT Osoba.Ime_Prezime INTO osoba_ime_prezime
    FROM Osoba
    INNER JOIN Slucaj ON Osoba.Id = Slucaj.id_pocinitelj
    WHERE Slucaj.id_dokaz
    = predmet_id;
    
    
    SET rezultat = CONCAT('Odabrani je predmet dokaz u slučaju: ', slucaj_naziv, ', gdje je osumnjičena osoba: ', osoba_ime_prezime);
    
    RETURN rezultat;
END //

DELIMITER ;
# Napiši upit koji izdvaja informacije o određenom predmetu, uključujući naziv predmeta, naziv povezanog slučaja i ime i prezime osumnjičenika u tom slučaju, koristeći funkciju DohvatiSlucajIOsobu za dobijanje dodatnih detalja za taj predmet.
SELECT
    Predmet.ID AS PredmetID,
    Predmet.Naziv AS NazivPredmeta,
    Slucaj.Naziv AS NazivSlucaja,
    Osoba.Ime_Prezime AS ImePrezimeOsumnjicenika,
    DohvatiSlucajIOsobu(Predmet.ID) AS InformacijeOPredmetu
FROM Predmet
INNER JOIN Slucaj ON Predmet.ID = Slucaj.id_dokaz
INNER JOIN Osoba ON Slucaj.id_pocinitelj = Osoba.ID
WHERE Predmet.ID = 5;


# Napravi funkciju koja će za argument primati sredstvo utvrđivanja istine, zatim će prebrojiti u koliko je slučajeva to sredstvo korišteno, prebrojit će koliko je slučajeva od tog broja riješeno, te će na temelju ta 2 podatka izračunati postotak rješenosti slučajeva gdje se odabrano sredstvo koristi
DELIMITER //

CREATE FUNCTION IzracunajPostotakRjesenosti (
    sredstvo_id INT
) RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE ukupno INT;
    DECLARE koristeno INT;
    DECLARE postotak DECIMAL(5,2);
    
    
    SELECT COUNT(*) INTO ukupno FROM Sui_slucaj WHERE Id_sui = sredstvo_id;
    
    
    SELECT COUNT(*) INTO koristeno FROM Sui_slucaj s
    INNER JOIN Slucaj c ON s.Id_slucaj = c.Id
    WHERE s.Id_sui = sredstvo_id AND c.Status = 'Riješen';
    
    
    IF ukupno IS NOT NULL AND ukupno > 0 THEN
        SET postotak = (koristeno / ukupno) * 100;
    ELSE
        SET postotak = 0.00;
    END IF;
    
    RETURN postotak;
END //

DELIMITER ;

# Koristeći gornju funkciju prikaži sredstva koja imaju rješenost veću od 50% (riješeno je više od 50% slučajeva koja koriste to sredstvo)
SELECT
    Sredstvo_utvrdivanja_istine.ID AS id_sredstvo,
    Sredstvo_utvrdivanja_istine.Naziv AS Naziv_Sredstva,
    IzracunajPostotakRjesenosti(Sredstvo_utvrdivanja_istine.ID) AS postotak
FROM Sredstvo_utvrdivanja_istine
WHERE IzracunajPostotakRjesenosti(Sredstvo_utvrdivanja_istine.ID) > 50.00;

# Napiši funkciju koja će za argument primati registarske tablice vozila, a vraćat će informaciju je li se to vozilo pojavilo u nekom od slučajeva, tako što će provjeriti je li se id_osoba koji referencira vlasnika pojavio u nekom slučaju kao pocinitelj_id. Ako se pojavilo, vraćat će "Vozilo se pojavljivalo u slučajevima", a ako se nije pojavilo, vraćat će "Vozilo se nije pojavljivalo u slučajevima". Također, vratit će i broj koliko se puta vozilo pojavilo
DELIMITER //
CREATE FUNCTION Provjera_vozila(Registracija VARCHAR(20)) RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
    DECLARE result VARCHAR(100);
    DECLARE count INT;

    SELECT COUNT(*)
    INTO count
    FROM Slucaj
    WHERE id_pocinitelj
    IN (SELECT id_vlasnik
    FROM Vozilo WHERE Registracija = Registracija);

    IF count > 0 THEN
        SET result = CONCAT('Vozilo se pojavljivalo u slučajevima (', count, ' puta)');
    ELSE
        SET result = 'Vozilo se nije pojavljivalo u slučajevima';
    END IF;

    RETURN result;
END //
DELIMITER ;

# Koristeći funkciju prikažite vozila koja se pojavljuju iznad prosjeka (u iznadprosječnom broju)
CREATE TEMPORARY TABLE Prosjek_Pojavljivanja AS
SELECT AVG(count) AS Prosjek
FROM (
    SELECT COUNT(*) AS count
    FROM Slucaj
    INNER JOIN Vozilo ON Slucaj.id_pocinitelj = Vozilo.id_vlasnik
    GROUP BY Vozilo.Registracija
) AS Podupit1;

SELECT V.Registracija, Provjera_vozila(V.Registracija) AS StatusVozila
FROM Vozilo V
INNER JOIN (
    SELECT Vozilo.Registracija, COUNT(*) AS count
    FROM Slucaj
    INNER JOIN Vozilo ON Slucaj.id_pocinitelj = Vozilo.id_vlasnik
    GROUP BY Vozilo.Registracija
) AS Podupit2 ON V.Registracija = Podupit2.Registracija
WHERE Podupit2.count > (SELECT Prosjek FROM Prosjek_Pojavljivanja);




# Funkcija koja za argument prima id podrucja uprave i vraća broj mjesta u tom području te naziv svih mjesta u 1 stringu
DELIMITER //
CREATE FUNCTION Podaci_O_Podrucju(id_podrucje INT) RETURNS TEXT
DETERMINISTIC
BEGIN
    DECLARE broj_mjesta INT;
    DECLARE mjesta TEXT;
    
    SELECT COUNT(*) INTO broj_mjesta
    FROM Mjesto
    WHERE id_podrucje_uprave = id_podrucje;
    
    SELECT GROUP_CONCAT(naziv SEPARATOR ';') INTO mjesta
    FROM Mjesto
    WHERE id_podrucje_uprave = id_podrucje;
    
    RETURN CONCAT('Područje: ', (SELECT naziv FROM Podrucje_uprave WHERE id = id_podrucje), 
                  ', Broj mjesta: ', broj_mjesta, ', Mjesta: ', mjesta);
END //
DELIMITER ;

DELIMITER //

CREATE FUNCTION Broj_Kaznjivih_Djela_U_Slucaju(id_slucaj INT) RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE broj_kaznjivih_djela INT;

    SELECT COUNT(*) INTO broj_kaznjivih_djela
    FROM Kaznjiva_djela_u_slucaju
    WHERE id_slucaj = id_slucaj;

    RETURN broj_kaznjivih_djela;
END;

//
DELIMITER ;

SELECT Broj_Kaznjivih_Djela_U_Slucaju(5);

# Koristeći gornju funkciju napiši upit koji će naći slučaj s najviše kažnjivih djela
SELECT
    S.ID AS id_slucaj,
    S.Naziv AS Naziv_Slucaja,
    MAX(Broj_Kaznjivih_Djela_U_Slucaju(S.ID)) AS Broj_Kaznjivih_Djela
FROM Slucaj S
GROUP BY id_slucaj, Naziv_Slucaja;


# Funkcija koje će za argument primati status slučajeva i vratiti će broj slučajeva sa tim statusom
DELIMITER //
CREATE FUNCTION broj_slucajeva_po_statusu(status VARCHAR(20)) RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE broj_slucajeva INT;

    IF status IS NULL THEN
        SET broj_slucajeva = 0;
    ELSE
        SELECT COUNT(*) INTO broj_slucajeva
        FROM Slucaj
        WHERE Status = status;
    END IF;

    RETURN broj_slucajeva;
END;

//
DELIMITER ;

# Koristeći gornju funkciju napravi upit koji će dohvatiti sve statuse koji vrijede za više od 5 slučajeva (ili neki drugi broj)
SELECT 
    Status,
    COUNT(*) AS broj_slucajeva
FROM
    Slucaj
GROUP BY
    Status
HAVING
    broj_slucajeva_po_statusu(Status) > 5; -- Prilagodimo broj prema potrebi

# Funkcija koja za argument prima id_slucaj i računa njegovo trajanje; ako je završen, onda trajanje od početka do završetka, a ako nije, onda trajanje od početka do poziva funkcije
DELIMITER //
CREATE FUNCTION Informacije_o_slucaju(id_slucaj INT) RETURNS TEXT
DETERMINISTIC
BEGIN
    DECLARE status_slucaja VARCHAR(20);
    DECLARE trajanje_slucaja INT;

    SELECT 
        Status,
        CASE
            WHEN Zavrsetak IS NULL THEN DATEDIFF(NOW(), Pocetak)
            ELSE DATEDIFF(Zavrsetak, Pocetak)
        END AS trajanje
    INTO
        status_slucaja, trajanje_slucaja
    FROM 
        Slucaj
    WHERE 
        id = id_slucaj;

    RETURN CONCAT('Status slučaja: ', status_slucaja, '\nTrajanje slučaja: ', trajanje_slucaja, ' dana');
END;
//
DELIMITER ;


# IDEJA; ZA INSERTANJE KORISTIMO TRANSAKCIJE U KOJIMA POZIVAMO PROCEDURE ZA INSERT U POJEDINE TABLICE

/* KILLCOUNT:
    18 tables
    16 triggers
    20 queries
    13 views
    10 functions
    30 procedures
*/

# Ovo je samo neko testiranje, niš bitno
/*CALL Dodaj_Novo_Kaznjivo_Djelo('Kaznivo Djelo 1', 'Opis prvog kaznenog djela', 1000);
CALL Dodaj_Novo_Kaznjivo_Djelo('Kaznivo Djelo 2', 'Opis drugog kaznenog djela', 1500);
CALL Dodaj_Novo_Kaznjivo_Djelo('Kaznivo Djelo 3', 'Opis trećeg kaznenog djela', 800);

SELECT * FROM kaznjiva_djela;
SET SQL_SAFE_UPDATES = 0;

DELETE FROM kaznjiva_djela;
*/

# Autentifikacija i autorizacija; nekako dodat neke osnove
