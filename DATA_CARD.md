# Veri Kartı (Data Card) - Sağlık Öneri Motoru LLM Takip Sistemi

## 1. Veri Seti Genel Bilgileri
- **Domain (Alan):** Sağlık (Healthcare)
- **Sistem:** Öneri Motoru (Recommendation Engine)
- **Yapay Zeka Bileşeni:** LLM Çağrı Kayıtları ve Maliyet Takibi (LLM Call Logs & Cost Tracking)
- **Veri Seti Sahibi:** Kutay Berat
- **Tarih:** Kasım 2026

## 2. Amaç ve Kapsam
Bu veri seti, sağlık sektöründe hizmet veren bir kişiselleştirilmiş öneri motorunun arka planda kullandığı Büyük Dil Modellerinin (LLM) çağrı kayıtlarını, harcanan token miktarlarını ve oluşan maliyetleri izlemek ve analiz etmek amacıyla tasarlanmıştır.

## 3. Tablo Yapıları ve Veri Alanları

### A. `hastalar` Tablosu
Sisteme kayıtlı hastaların/kullanıcıların demografik ve temel sağlık durum bilgilerini tutar.
- `hasta_id` (INT, PK): Hasta benzersiz kimlik numarası.
- `ad_soyad` (VARCHAR): Hastanın adı ve soyadı.
- `yas` (INT): Hastanın yaşı.
- `cinsiyet` (VARCHAR): Cinsiyet bilgisi.
- `kronik_hastalik` (VARCHAR): Hastanın mevcut kronik rahatsızlıkları.

### B. `oneri_talepleri` Tablosu
Hastaların sistemden talep ettiği tavsiye ve şikayet başlıklarını içerir.
- `talep_id` (INT, PK): Talep benzersiz numarası.
- `hasta_id` (INT, FK): Talebi oluşturan hastanın ID'si.
- `sikayet_veya_hedef` (TEXT): Hastanın belirttiği semptom veya hedef.

### C. `llm_cagri_loglari` Tablosu
Yapay zeka modeline yapılan her bir API çağrısının teknik ve maliyet metriklerini saklar.
- `cagri_id` (INT, PK): Log kayıt numarası.
- `talep_id` (INT, FK): İlgili talebin ID'si.
- `kullanilan_model` (VARCHAR): Çağrılan LLM modeli (Örn: gpt-4o, claude-3-5-sonnet).
- `input_tokens` (INT): Girdi token sayısı.
- `output_tokens` (INT): Çıktı token sayısı.
- `sure_saniye` (DECIMAL): İsteğin yanıtlanma süresi (saniye).
- `maliyet_usd` (DECIMAL): Çağrının Amerikan Doları cinsinden maliyeti.

### D. `oneriler` Tablosu
LLM tarafından üretilen ve kullanıcıya sunulan son tavsiyeleri barındırır.
- `oneri_id` (INT, PK): Öneri benzersiz numarası.
- `talep_id` (INT, FK): İlgili talep ID'si.
- `cagri_id` (INT, FK): İlgili LLM çağrı ID'si.
- `oneri_metni` (TEXT): Üretilen sağlık tavsiyesi.
- `kategori` (VARCHAR): Tavsiye kategorisi (Beslenme, Egzersiz, Yaşam Tarzı).
