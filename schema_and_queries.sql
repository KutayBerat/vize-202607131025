-- BLP 1005 Veritabanı Yönetim Sistemleri Vize Ödevi
-- Konu: Sağlık / Öneri Motoru / LLM Çağrı Kayıtları ve Maliyet Takibi

-- 1. TABLO OLUŞTURMA (DDL)

CREATE TABLE IF NOT EXISTS hastalar (
    hasta_id INT PRIMARY KEY AUTO_INCREMENT,
    ad_soyad VARCHAR(100) NOT NULL,
    yas INT NOT NULL,
    cinsiyet VARCHAR(10),
    kronik_hastalik VARCHAR(150),
    kayit_tarihi DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS oneri_talepleri (
    talep_id INT PRIMARY KEY AUTO_INCREMENT,
    hasta_id INT,
    sikayet_veya_hedef TEXT NOT NULL,
    talep_tarihi DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (hasta_id) REFERENCES hastalar(hasta_id)
);

CREATE TABLE IF NOT EXISTS llm_cagri_loglari (
    cagri_id INT PRIMARY KEY AUTO_INCREMENT,
    talep_id INT,
    kullanilan_model VARCHAR(50) NOT NULL,
    input_tokens INT NOT NULL,
    output_tokens INT NOT NULL,
    sure_saniye DECIMAL(5,2) NOT NULL,
    maliyet_usd DECIMAL(8,6) NOT NULL,
    cagri_zamani DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (talep_id) REFERENCES oneri_talepleri(talep_id)
);

CREATE TABLE IF NOT EXISTS oneriler (
    oneri_id INT PRIMARY KEY AUTO_INCREMENT,
    talep_id INT,
    cagri_id INT,
    oneri_metni TEXT NOT NULL,
    kategori VARCHAR(50) NOT NULL,
    olusturulma_tarihi DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (talep_id) REFERENCES oneri_talepleri(talep_id),
    FOREIGN KEY (cagri_id) REFERENCES llm_cagri_loglari(cagri_id)
);

-- 2. ÖRNEK VERİ GİRİŞİ (DML)

INSERT INTO hastalar (ad_soyad, yas, cinsiyet, kronik_hastalik) VALUES
('Ahmet Yılmaz', 45, 'Erkek', 'Tip 2 Diyabet'),
('Ayşe Kaya', 32, 'Kadın', 'Hipertansiyon'),
('Mehmet Demir', 60, 'Erkek', 'KOAH'),
('Fatma Çelik', 28, 'Kadın', 'Yok'),
('Can Öztürk', 50, 'Erkek', 'Kolesterol');

INSERT INTO oneri_talepleri (hasta_id, sikayet_veya_hedef) VALUES
(1, 'Kan şekerini dengelemek için haftalık beslenme tavsiyesi'),
(2, 'Tansiyonu yükseltmeyecek hafif egzersiz programı'),
(3, 'Nefes darlığını tetiklemeyecek günlük aktivite önerisi'),
(4, 'Genel bağışıklık güçlendirici beslenme listesi'),
(5, 'Kolesterol düşürücü diyet ve yürüyüş rutini');

INSERT INTO llm_cagri_loglari (talep_id, kullanilan_model, input_tokens, output_tokens, sure_saniye, maliyet_usd) VALUES
(1, 'gpt-4o', 450, 600, 2.45, 0.005250),
(2, 'gpt-4o-mini', 300, 250, 1.10, 0.000210),
(3, 'claude-3-5-sonnet', 520, 800, 3.20, 0.007560),
(4, 'gpt-4o-mini', 250, 300, 1.05, 0.000240),
(5, 'gpt-4o', 400, 550, 2.10, 0.004750);

INSERT INTO oneriler (talep_id, cagri_id, oneri_metni, kategori) VALUES
(1, 1, 'Düşük glisemik indeksli gıdalar tüketin. Akşam öğünlerinde karbonhidratı azaltın.', 'Beslenme'),
(2, 2, 'Haftada 4 gün 30 dakikalık tempolu yürüyüş yapın. Ağır ağırlık antrenmanlarından kaçının.', 'Egzersiz'),
(3, 3, 'Temiz havada kısa yürüyüşler yapın, tozlu ortamlardan kaçının.', 'Yaşam Tarzı'),
(4, 4, 'C vitamini yönünden zengin meyveler ve günlük 2.5 litre su tüketimine özen gösterin.', 'Beslenme'),
(5, 5, 'Zeytinyağlı yemekleri tercih edin, doymuş yağlardan uzak durun.', 'Beslenme');

-- 3. ÖDEVE ÖZEL SQL ANALİZ SORGULARI (50 Puanlık Kısım)

-- Soru 1: Model bazında toplam çağrı sayısı, toplam harcanan token ve toplam maliyet analizi
SELECT 
    kullanilan_model,
    COUNT(cagri_id) AS toplam_cagri,
    SUM(input_tokens + output_tokens) AS toplam_token,
    SUM(maliyet_usd) AS toplam_maliyet_usd
FROM llm_cagri_loglari
GROUP BY kullanilan_model
ORDER BY toplam_maliyet_usd DESC;

-- Soru 2: Hasta başına oluşturulan öneriler ve LLM maliyetlerinin dökümü
SELECT 
    h.ad_soyad,
    h.kronik_hastalik,
    ot.sikayet_veya_hedef,
    o.kategori AS oneri_kategorisi,
    l.kullanilan_model,
    l.maliyet_usd
FROM hastalar h
JOIN oneri_talepleri ot ON h.hasta_id = ot.hasta_id
JOIN oneriler o ON ot.talep_id = o.talep_id
JOIN llm_cagri_loglari l ON o.cagri_id = l.cagri_id;

-- Soru 3: Ortalama maliyeti en yüksek olan model ve yanıt süresi analizi
SELECT 
    kullanilan_model,
    AVG(sure_saniye) AS ortalama_sure_sn,
    AVG(maliyet_usd) AS ortalama_maliyet_usd
FROM llm_cagri_loglari
GROUP BY kullanilan_model;
