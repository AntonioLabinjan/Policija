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
