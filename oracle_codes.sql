
--Tablolar

--1
CREATE TABLE Ogrenciler (
    OgrenciNo VARCHAR2(30) PRIMARY KEY,
    Ad VARCHAR2(50) not null,
    Soyad VARCHAR2(50) not null,
    DogumTarihi DATE not null,
    Cinsiyet VARCHAR2(10) not null,
    IletisimNumarasi VARCHAR2(20) not null,
    Eposta VARCHAR2(100) not null,
    Adres VARCHAR2(255) not null
);

insert into ogrenciler values(
'213301032','Ali','Keskin',to_date('2002-12-12','yyyy-mm-dd'),'Erkek','05467896783','AlKesk@gmail.com','KaraKýþla Mah. ,Serçe Sok. ,Kat 1 Daire 10, Kocaeli/Derince');
commit;

insert into ogrenciler values(
'213301033','Ayþe','Duman',to_date('2002-7-10','yyyy-mm-dd'),'Kýz','05338900875','AyþeDum@gmail.com','Melek Mah. ,Karga Sok. ,Kat 3 Daire 5, Sakarya/Arifiye');
commit;

insert into ogrenciler values(
'203301054','Zillet','Kara',to_date('2001-3-22','yyyy-mm-dd'),'Kýz','05552903815','ZillKar@gmail.com','Mavi Mah. ,Papatya Sok. ,Kat 1 Daire 7, Sakarya/Serdivan');
commit;


--2
CREATE TABLE OgretimGorevlileri(
    OgretimGorevlisiID NUMBER PRIMARY KEY,
    Ad VARCHAR2(50) not null,
    Soyad VARCHAR2(50) not null,
    IletisimNumarasi VARCHAR2(20) not null,
    Eposta VARCHAR2(100) not null
);

insert into ogretimgorevlileri values(1,'Kemal','Parlak','05898769080','ParlakKem@gmail.com');
commit;
insert into ogretimgorevlileri values(2,'Cemil','Razý','05795763041','CemRaz@gmail.com');
commit;


--3
CREATE TABLE Dersler (												
    DersID NUMBER PRIMARY KEY,
    OgretimGorevlisiID NUMBER not null,
    DersAdi VARCHAR2(100) not null,
    DersAciklamasi VARCHAR2(255) not null,
    KrediSaatleri NUMBER not null,
    CONSTRAINT fk_key_ders_hoca FOREIGN KEY(OgretimGorevlisiID) REFERENCES OgretimGorevlileri(OgretimGorevlisiID)
);

insert into dersler values(1,2,'Veri Tabaný Programlama','Oracle üzerinden veri tabaný programlama iþlemleri',4);
commit;
insert into dersler values(2,2,'Veri Madenciliði','Makine öðrenimi algoritmalarýyla çekilen verinin yorumlanmasý','4');
commit;
insert into dersler values(3,1,'Programlama Dili','C# .Net eðitimi','3');

--4
CREATE TABLE Kayitlar (
    KayitID NUMBER PRIMARY KEY,
    OgrenciNo VARCHAR2(30) NOT NULL,
    DersID NUMBER not null,
    KayitTarihi DATE not null,
    Notu VARCHAR2(2) not null,
    CONSTRAINT fk_key1 FOREIGN KEY (OgrenciNo) REFERENCES Ogrenciler(OgrenciNo),
    CONSTRAINT fk_key2 FOREIGN KEY (DersID) REFERENCES Dersler(DersID)
);

insert into kayitlar values(1,'213301032',1,to_date('2021-9-12','yyyy-mm-dd'),'A');
commit;

insert into kayitlar values(2,'213301033',1,to_date('2021-9-12','yyyy-mm-dd'),'B');
commit;

insert into kayitlar values(3,'203301054',2,to_date('2021-9-12','yyyy-mm-dd'),'C');
commit;

insert into kayitlar values(5,'213301032',2,to_date('2021-9-12','yyyy-mm-dd'),'B');
commit;

insert into kayitlar values(7,'213301032',3,to_date('2021-9-12','yyyy-mm-dd'),'D');
commit;


--5
CREATE TABLE Siniflar (
    SinifID NUMBER PRIMARY KEY,
    OgretimGorevlisiID NUMBER NOT NULL,
    OgrenciNo varchar2(30) NOT NULL,
    OdaNumarasi VARCHAR2(20) NOT NULL ,
    Kapasite NUMBER,
    CONSTRAINT fk_key4 FOREIGN KEY(OgretimGorevlisiID) REFERENCES OgretimGorevlileri(OgretimGorevlisiID),
    CONSTRAINT fk_key5 FOREIGN KEY(OgrenciNo) REFERENCES Ogrenciler(OgrenciNo)
);

insert into siniflar values(1,1,'213301032','210',100);
insert into siniflar values(2,2,'213301033','210',200);
insert into siniflar values(3,1,'203301054','222',100);


--Sorgular

--Sorgu 1
SELECT o.ad as OgrenciAdi,d.dersadi as DersAdi,k.kayittarihi as KayitTarihi,d.kredisaatleri as k_saatleri FROM ogrenciler o 
    JOIN kayýtlar k 
        ON o.ogrencino = k.ogrencino
            JOIN dersler d ON k.dersid = d.dersid
                WHERE o.OgrenciNo = '213301032';
                

--Sorgu 2
SELECT og.ad, k.ogrencino,k.notu,s.sinifid FROM siniflar s
    JOIN ogretimgorevlileri og
        ON og.ogretimgorevlisiid = s.ogretimgorevlisiid
            JOIN kayitlar k ON k.ogrencino = s.ogrencino 
                WHERE k.dersid = 
                    (SELECT dersid FROM Dersler WHERE dersadi = 'Veri Madenciliði');
                    
                    
--Triggerlar

--Trigger 1
CREATE OR REPLACE TRIGGER ogretimgorevlisi_silme_engelleme
BEFORE DELETE ON OgretimGorevlileri
FOR EACH ROW
DECLARE
    engelle EXCEPTION;
    PRAGMA EXCEPTION_INIT(engelle, -20002);
    sayac NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO sayac
    FROM Siniflar
    WHERE OgretimGorevlisiID = :OLD.OgretimGorevlisiID;

    IF sayac <> 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Bu öðretmen alt sýnýflarda eðitim verdiði için silinememektedir.');
    ELSE
        dbms_output.put_line('Ogretmen silme iþlemi baþarýlý!!');
    END IF;
END;

--Trigger 1 çalýþtýrma kodu
delete ogretimgorevlileri where ogretimgorevlisiid = 1;

--Trigger 2
CREATE OR REPLACE TRIGGER Ogrenci_Harf_Notu_Kontrol
BEFORE INSERT OR UPDATE ON Kayitlar
FOR EACH ROW
DECLARE
    yanlis_not EXCEPTION;
    PRAGMA EXCEPTION_INIT(yanlis_not, -20001);
BEGIN
    IF NOT (:NEW.Notu IN ('A', 'B', 'C', 'D', 'F')) THEN
        raise_application_error(-20001, 'Geçersiz not girdiniz!'); 
    ELSE
        dbms_output.put_line('Not baþarýyla girildi!');
    END IF;
END;

--Trigger 2 çalýþtýrma kodu
update kayitlar
set notu = 'G' where ogrencino = '213301032'; 


--Prosedürler

--Prosedür 1
CREATE SEQUENCE SEQ_KAYIT_ID
    INCREMENT BY 1
    START WITH 4
    MINVALUE 4
    MAXVALUE 100
    CYCLE
    CACHE 2;


CREATE OR REPLACE PROCEDURE pr_ogrenci_ve_kayit_yerlestirme(
    p_OgrenciNo IN VARCHAR2,
    p_Ad IN VARCHAR2,
    p_Soyad IN VARCHAR2,
    p_DogumTarihi IN DATE,
    p_Cinsiyet IN VARCHAR2,
    p_IletisimNumarasi IN VARCHAR2,
    p_Eposta IN VARCHAR2,
    p_Adres IN VARCHAR2,
    p_DersID IN NUMBER,
    p_Notu IN VARCHAR2,
    p_KayitTarihi IN DATE
)
AS
BEGIN
   
    INSERT INTO Ogrenciler(OgrenciNo, Ad, Soyad, DogumTarihi, Cinsiyet, IletisimNumarasi, Eposta, Adres)
    VALUES (p_OgrenciNo, p_Ad, p_Soyad, p_DogumTarihi, p_Cinsiyet, p_IletisimNumarasi, p_Eposta, p_Adres);

    INSERT INTO Kayitlar(KayitID, OgrenciNo, DersID, Notu, KayitTarihi)
    VALUES (SEQ_KAYIT_ID.NEXTVAL, p_OgrenciNo, p_DersID, p_Notu, p_KayitTarihi);
    
    COMMIT;
END pr_ogrenci_ve_kayit_yerlestirme;

--Prosedür 1'i aktifleþtiren kod
BEGIN
pr_ogrenci_ve_kayit_yerlestirme('213301045','Zeliha','Büyük',to_date('2002-12-12','yyyy-mm-dd'),'Kýz','05678908875','Zel@gmail.com','Adres Yok',2,'C',to_date('2022-03-05','yyyy-mm-dd'));
END;


--Prosedür 2
CREATE OR REPLACE PROCEDURE pr_dersi_gecip_gecmeme_durumu(
   pr_ogr_no IN VARCHAR2, pr_ogr_ders_id IN NUMBER)
AS
CURSOR crs is SELECT notu
    FROM kayitlar 
        WHERE ogrencino = pr_ogr_no and dersid = pr_ogr_ders_id;
ogr_notu VARCHAR2(2);
BEGIN
    OPEN crs;
    FETCH crs into ogr_notu;
        CASE
            WHEN ogr_notu <> 'F' THEN 
                dbms_output.put_line(pr_ogr_no||' Numaralý öðrenci dersten geçmiþtir.');
            WHEN crs%notfound THEN
                dbms_output.put_line(pr_ogr_no||' Böyle bir öðrenci bulunamamýþtýr.');
            ELSE
                dbms_output.put_line(pr_ogr_no||' Numaralý öðrenci dersten kalmýþtýr.');
         END CASE;
    CLOSE crs;
END;

--Prosedür 2'yi aktifleþtiren kod
update kayitlar 
set notu = 'F' WHERE kayitlar.ogrencino = '213301032' and dersid = 1;

BEGIN

pr_dersi_gecip_gecmeme_durumu('213301032',1);

END;


--Fonksiyonlar
    
--Fonksiyon 1
create or replace Type OgrenciBilgiTut as object
(
    OgrenciNo VARCHAR2(30),
    Ad VARCHAR2(50),
    Soyad VARCHAR2(50) ,
    DogumTarihi DATE ,
    Cinsiyet VARCHAR2(10) ,
    IletisimNumarasi VARCHAR2(20) ,
    Eposta VARCHAR2(100) ,
    Adres VARCHAR2(255) 
);

CREATE OR REPLACE Type BilgiTut as table of OgrenciBilgiTut;


CREATE OR REPLACE FUNCTION f_ogrenci_bilgisi_getir(
    p_OgrenciNo IN VARCHAR2
)
RETURN BilgiTut
IS
sonuc BilgiTut := new BilgiTut();
BEGIN
    FOR s IN (SELECT * FROM OGRENCILER WHERE ogrencino = p_OgrenciNo) LOOP
        sonuc.extend;
        sonuc(sonuc.COUNT) := new OgrenciBilgiTut(s.ogrencino,s.ad,s.soyad,s.dogumtarihi,s.cinsiyet,s.iletisimnumarasi,s.eposta,s.adres);
    END LOOP;
    RETURN sonuc;
END f_ogrenci_bilgisi_getir;

--Fonksiyon 1 çaðýrma
select * from table(f_ogrenci_bilgisi_getir('213301032'));


--Fonksiyon 2
CREATE OR REPLACE FUNCTION f_ogrencinin_aldigi_total_kredi(
    p_OgrenciNo IN VARCHAR2
)
RETURN NUMBER
AS
    CURSOR c IS SELECT * FROM Kayitlar K
    JOIN Dersler D ON K.DersID = D.DersID
    WHERE K.OgrenciNo = p_OgrenciNo;
    
    TYPE COUNTER IS TABLE OF c%ROWTYPE INDEX BY BINARY_INTEGER;
    row_list COUNTER;
    ogrenci_satiri c%ROWTYPE;
    
    TYPE kredi_saatleri IS TABLE OF NUMBER;
    saatler kredi_saatleri := kredi_saatleri();
    total_kredi_saati NUMBER := 0;
    sayac NUMBER := 0;
BEGIN
    OPEN c;
    FETCH c BULK COLLECT INTO row_list;
    saatler.extend(row_list.COUNT);
    FOR i IN row_list.first..row_list.last LOOP
        sayac := sayac + 1;
        saatler(sayac) := row_list(i).KrediSaatleri;
    END LOOP;
    CLOSE c;
    
    FOR i IN saatler.first..saatler.last LOOP
        total_kredi_saati := total_kredi_saati + saatler(i);
    END LOOP;  
    
    RETURN total_kredi_saati;
END f_ogrencinin_aldigi_total_kredi;


--Fonksiyon 2'yi çaðýrma
DECLARE
a number;
BEGIN
a:= f_ogrencinin_aldigi_total_kredi('213301032');
DBMS_OUTPUT.PUT_LINE('Girilen numaralý öðrencinin kredi toplamý: ' || a);
END;


--Exception
DECLARE
    maks_ogrenci NUMBER := 100;
    ogrenci_sayisi NUMBER;
    mevcut_asildi EXCEPTION;
BEGIN
    SELECT COUNT(*) INTO ogrenci_sayisi FROM ogrenciler; 
    IF ogrenci_sayisi > maks_ogrenci THEN
        RAISE mevcut_asildi;
    ELSE
        dbms_output.put_line('Öðrenci sayýsý:' || ogrenci_sayisi);
    END IF;
    EXCEPTION
        WHEN mevcut_asildi THEN
            dbms_output.put_line('Sýnýf mevcudu aþýldý!!');
END;
                                              
                                      
--Job
BEGIN
  DBMS_SCHEDULER.create_job (
    job_name        => 'Ogrenci_Dersler_JOB',
    job_type        => 'PLSQL_BLOCK',
    job_action      => 'BEGIN
                          FOR r IN (SELECT o.OgrenciNo,k.notu, o.Ad, o.Soyad, d.DersAdi
                                      FROM Ogrenciler o
                                      JOIN Kayitlar k ON o.OgrenciNo = k.OgrenciNo
                                      JOIN Dersler d ON k.DersID = d.DersID)
                          LOOP
                            DBMS_OUTPUT.PUT_LINE(''OgrenciNo: '' || r.OgrenciNo || '', Ad: '' || r.Ad ||
                                               '', Soyad: '' || r.Soyad || '', Notu:'' || r.notu || '', Ders: '' || r.DersAdi);
                          END LOOP;
                       END;',
    start_date      => SYSTIMESTAMP,                        
    repeat_interval => 'FREQ=MINUTELY; INTERVAL=1',       
    enabled         => TRUE                               
  );

  DBMS_OUTPUT.PUT_LINE('Job baþarýyla yaratýldý.');
END;

--Job'ýn aktif olup olmadýðýný görme
select *
from all_scheduler_job_run_details
where job_name = 'OGRENCI_DERSLER_JOB';

--Log tablosunu temizleme
exec dbms_scheduler.purge_log();


