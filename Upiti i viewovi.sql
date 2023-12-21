
# UPITI

 
-- Ispiši prosječan broj godina osoba koje su prijavile digitalno nasilje. 

SELECT AVG(YEAR(NOW())-YEAR(osoba.datum_rodenja)) AS prosjecan_broj_godina
FROM slucaj INNER JOIN osoba ON slucaj.id_izvjestitelj=osoba.id
WHERE slucaj.naziv LIKE '%digitalno nasilje%';

-- Prikaži osobu čiji je nestanak posljednji prijavljen

SELECT osoba.*
FROM osoba INNER JOIN slucaj ON osoba.id=slucaj.id_ostecenik
ORDER BY pocetak DESC
LIMIT 1;

-- Prikaži najčešću vrstu kažnjivog djela

SELECT kaznjiva_djela.*
FROM kaznjiva_djela INNER JOIN kaznjiva_djela_u_slucaju
GROUP BY kaznjiva_djela.id
ORDER BY COUNT(*)
LIMIT 1;


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

# OVO MOREMO UBACIT U POGLED
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
# Materijalizirani pogled (privremena tablica)
# Ako je uz osumnjičenika povezano vozilo, onda se stvara materijalizirani pogled koji prati sve osumnjičenike i njihova vozila
CREATE VIEW osumnjicenici_vozila AS
SELECT
	Osoba.id AS id_osobe,
	Osoba.ime_prezime,
	Osoba.datum_rodenja,
	Osoba.oib,
	Osoba.spol,
	Osoba.adresa,
	Osoba.telefon,
	Osoba.email,
	Vozilo.id AS id_vozila,
	Vozilo.marka,
	Vozilo.model,
	Vozilo.registracija,
	Vozilo.godina_proizvodnje
FROM Osoba
LEFT JOIN Vozilo ON Osoba.id = Vozilo.id_vlasnik
INNER JOIN Slucaj ON Osoba.id = Slucaj.id_pocinitelj;
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

-- Napravi pogled koji prikazuje broj kazni zboog brze vožnje u svakom gradu u proteklih mjesec dana. Zatim pomoću upita ispiši grad
-- u kojem je bilo najviše kazni zbog brze vožnje u proteklih mjesec dana.

CREATE VIEW brza_voznja_gradovi AS
SELECT mjesto.naziv, COUNT(*) AS broj_kazni_za_brzu_voznju
FROM mjesto INNER JOIN evidencija_dogadaja ON mjesto.id=evidencija_dogadaja.id_mjesto INNER JOIN slucaj ON evidencija_dogadaja.id_slucaj=slucaj.id
WHERE slucaj.naziv LIKE '%brza voznja%' AND evidencija_dogadaja.datum_vrijeme >= (NOW() - INTERVAL 1 MONTH)
GROUP BY mjesto.naziv;

SELECT *
FROM brza_voznja_gradovi
ORDER BY broj_kazni_za_brzu_voznju DESC
LIMIT 1; 

-- Napravi pogled koji prikazuje sve osobe koje su skrivile više od 2 prometne nesreće u posljednjih godinu dana. 
-- Zatim napravi upit koji će prikazati osobu koja je skrivila najviše prometnih nesreća u posljednjih godinu dana.

CREATE VIEW osoba_prometna_nesreca AS
SELECT osoba.*, COUNT(*) AS broj_prometnih_nesreca
FROM osoba INNER JOIN slucaj ON osoba.id=slucaj.id_pocinitelj INNER JOIN evidencija_dodagaja ON slucaj.id=evidencija_dogadaja.id_slucaj
WHERE evidencija_dogadaja.datum_vrijeme <= (NOW() - INTERVAL 1 YEAR) AND COUNT(*)>2 AND slucaj.naziv LIKE '%prometna nesreca%'
GROUP BY id_osoba;

SELECT *
FROM osoba_prometna_nesreca
ORDER BY broj_prometnih_nesreca DESC
LIMIT 1;
