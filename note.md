# Superstore Satış və Mənfəət Təhlili (SQL Metodologiyası və Biznes Anlayışları)

## 1. Metodologiya və Quraşdırma
Bu layihədə Superstore pərakəndə satış məlumat dəsti yerli SQLite verilənlər bazasına (`sales.db`) yüklənmişdir. Layihənin əsas məqsədi bütün analitik aqreqasiya, sıralama, zaman seriyası və məntiqi qruplaşdırma əməliyyatlarını birbaşa SQL mühərrikində icra etməkdir. Python (Pandas və Seaborn/Matplotlib) yalnız SQL sorğularının nəticələrini işlətmək və visual qrafiklər çəkmək üçün istifadə edilmişdir.

---

## 2. Verilənlər Bazası DDL (`CREATE TABLE`)
`orders` cədvəlini düzgün məlumat tipləri ilə yaratmaq üçün istifadə olunan DDL kodu:

```sql
CREATE TABLE IF NOT EXISTS orders (
    "Row ID" INTEGER PRIMARY KEY,
    "Order ID" TEXT,
    "Order Date" TEXT,
    "Ship Date" TEXT,
    "Ship Mode" TEXT,
    "Customer ID" TEXT,
    "Customer Name" TEXT,
    "Segment" TEXT,
    "Country" TEXT,
    "City" TEXT,
    "State" TEXT,
    "Postal Code" TEXT,
    "Region" TEXT,
    "Product ID" TEXT,
    "Category" TEXT,
    "Sub-Category" TEXT,
    "Product Name" TEXT,
    "Sales" NUMERIC,
    "Quantity" INTEGER,
    "Discount" NUMERIC,
    "Profit" NUMERIC
);

1. Yüksək Endirimlər Şirkətin Mənfəətini Kəskin Zərərə Salır (Q7)
Tapıntı: Endirim tətbiq olunmayan (%0) sifarişlərdə ortalama mənfəət $66.90 təşkil edir. İndirim oranı %1–%20 arasında olduqda ortalama mənfəət $26.50-yə düşür. Lakin endirim %21-dən yuxarı qalxdıqda ciddi zərər yaranır: %21–%40 arası endirimlərdə ortalama -$77.86, %41-dən yuxarı endirimlərdə isə ortalama -$106.71 zərər formalaşır.

Tövsiyə: Endirim siyasətinə üst tavan (%20) qoyulmalı və %20-dən yuxarı endirimlər ləğv edilməlidir.

2. Mebel Alt-Kateqoriyaları Ciddi Zərər Mənbəyidir (Q6 və Q9)
Tapıntı: Alt-kateqoriyalar üzrə analiz göstərir ki, Tables (Stollar) ümumi -$17,725.48 və Bookcases (Kitab şkafları) ümumi -$3,472.56 zərər ilə şirkətin mənfəətini aşağı çəkən əsas məhsul qruplarıdır. Əksinə, Copiers (Fotokopi) $55,617.82 və Phones (Telefonlar) $44,515.73 mənfəət ilə liderlik edir.

Tövsiyə: Zərər edən Mebel (Furniture) alt-kateqoriyalarında maya dəyəri və endirim tavanı yenidən qiymətləndirilməlidir.

3. Satışlar 2015-ci İldən Sonra Güclü Böyümə Trendinə Girmişdir (Q8)
Tapıntı: 2014-cü ildə $484,247.50 olan ümumi satışlar 2015-ci ildə %-2.83 kiçilərək $470,532.51 olmuşdur. Lakin 2016-cı ildə %+29.47 artımla $609,205.60-a, 2017-ci ildə isə %+20.36 artımla $733,215.26-ya çatmışdır.

Tövsiyə: 2016-2017-ci illərdəki satış və marketinq strategiyası saxlanılmalı və növbəti illər üçün büdcə artırılmalıdır.

4. Çatdırılma Müddətləri Standartlara Uyğundur (Q4)
Tapıntı: Çatdırılma növlərinə görə ortalama kargolama müddəti: Same Day üçün 0.04 gün, First Class üçün 2.18 gün, Second Class üçün 3.24 gün və Standard Class üçün 5.01 gün təşkil edir.

Tövsiyə: Operativ loqistika uğurla çalışır; Standard Class çatdırılmasını 4 günə endirməklə müştəri məmnuniyyəti daha da artırıla bilər.