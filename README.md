# 🛒 E-Commerce Sales Performance Analysis

## Project Overview
Project ini bertujuan untuk melakukan analisis performa penjualan E-Commerce menggunakan SQL. Fokus utamanya adalah membersihkan data mentah (*data cleaning*), menganalisis tren pendapatan bulanan, serta mengidentifikasi produk terlaris (*best-selling products*) baik secara global maupun per kategori.

Dalam project ini, saya menyelesaikan 5 studi kasus utama yang mensimulasikan permintaan tim bisnis sehari-hari.

## Tools & Techniques
* **Tools:** PostgreSQL
* **Key Techniques:** CTE (Common Table Expressions), Window Functions (`RANK`, `PARTITION BY`), Subqueries, Date Manipulation (`DATE_TRUNC`, `INTERVAL`), String Manipulation.

## Key Analysis & Insights

### 1. Data Cleaning & Product Standardization
Membersihkan data produk yang tidak standar untuk persiapan analisis.
* **Objective:** Membuat kode produk unik (`Product Code`), menstandarisasi lokasi pelanggan menjadi huruf kapital, dan memperbaiki format nama kategori.
* **Technique:** `CONCAT`, `LEFT/RIGHT`, `UPPER`, `REPLACE`.

### 2. Monthly Revenue Trend
Melacak performa pendapatan bersih (*Net Revenue*) dari waktu ke waktu.
* **Metric:** Menghitung total revenue setelah diskon.
* **Insight:** Mengelompokkan transaksi berdasarkan bulan untuk melihat tren kenaikan atau penurunan omzet.

### 3. High-Value Product Identification
Menyaring produk yang memiliki performa di atas rata-rata.
* **Technique:** Menggunakan **CTE** dan **Subquery** untuk membandingkan revenue tiap produk terhadap rata-rata revenue keseluruhan.
* **Business Value:** Membantu tim marketing fokus pada produk yang memberikan margin tinggi.

### 4. Product Ranking (Global vs. Category)
Siapa juara penjualan kita?
* **Global Rank:** 10 produk dengan kuantitas terjual terbanyak.
* **Category Rank:** 3 produk teratas di **setiap kategori**.
* **Code Highlight (Window Function):**
```sql
-- Ranking top 3 products per category
with sales_kategori as (
    select
        "Category",
        "ProductName",
        sum("QuantitySold") as total_sold
    from ecomm_data 
    group by "Category", "ProductName"
),
ranked_products as (
    select *,
        rank() over(
            partition by "Category"
            order by "total_sold" desc
        ) as ranking
    from sales_kategori
)
select * from ranked_products where "ranking" <= 3;
