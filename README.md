# Portofolio: E-Commerce Sales Performance SQL

## About Me
Perkenalkan saya Wildy Fahmi Rosyidi, seorang mahasiswa Statistik yang memiliki ketertarikan mendalam pada Data Analysis dan Data Science. Berpengalaman dalam pengolahan data menggunakan SQL, Python, dan R. 

## Project Overview
Project ini bertujuan untuk melakukan analisis performa penjualan E-Commerce menggunakan **SQL**. Fokus utamanya adalah membersihkan data mentah (*data cleaning*), menganalisis tren pendapatan bulanan, serta mengidentifikasi produk terlaris baik secara global maupun per kategori. Dan pada project ini, saya menyelesaikan 5 studi kasus utama yang mensimulasikan permintaan tim bisnis sehari-hari.

## Tools & Techniques
* **Tools:** DBeaver, SQL
* **Key Techniques:** CTE (Common Table Expressions), Window Functions (`RANK`, `PARTITION BY`), Subqueries, Date Manipulation (`DATE_TRUNC`, `INTERVAL`), String Manipulation.

## Project Detail
### Data
Data e-commerce (`ecomm_data`) yang saya gunakan merupakan data yang disediakan oleh mentor. Data ini berisikan detail dari customer dan barang yang dibeli oleh customer tersebut pada suatu toko.

### 1. String Cleaning & Product Label
Menampilkan `product_code` yang berisi gabungan dari 3 huruf pertama dari `ProductName` dan 2 huruf angka terakhir dari `ProductID` lalu dipisahkan dnegan `-`. Dan menampilkan lokasi dari customer yang di kapitalkan, serta mengganti penggunaan `&` menjadi `and` pada kolom kategori.
* **Technique:** `CONCAT`, `LEFT/RIGHT`, `UPPER`, `REPLACE`.
* **Insight:** Merapikan data sebelum digunakan untuk analisis
* **Code:**
```sql
select 
	concat(left("ProductName", 3), '-', right("ProductID"::TEXT, 2)) as product_code,
	upper("CustomerLocation") as standardized_location,
	replace("Category", '&', 'and') as cleaned_category
from ecomm_data;
```

### 2. Timestamp Analysis (Monthly Trend)
Melacak performa pendapatan bersih dari waktu ke waktu.
* **Technique:** `extract`, `date_trunc`
* **Insight:** Mengelompokkan transaksi berdasarkan bulan untuk melihat tren kenaikan atau penurunan omzet.
```sql
select
	sum("Price" * "QuantitySold" * (1 - ("Discount" / 100))) as total_net_revenue,
	count("ProductID") as total_transaksi,
	date_trunc('month', "PurchaseDate"::DATE) as period_month,
	extract(year from "PurchaseDate"::DATE) as year_purchase_date,
	extract(month from "PurchaseDate"::DATE) as month_purchase_date
from ecomm_data
group by period_month, year_purchase_date, month_purchase_date
order by period_month asc;
```

### 3. Time Filter dengan ADD/SUB Interval
Memfilter data sehingga hanya menampilkan data 7 hari terakhir
* **Technique:** `max`, `interval`, `order by`
* **Insight:** Melihat data seminggu terakhir
* **Code:**
```sql
select *,
	now() as current_system_time
from ecomm_data
where
	"PurchaseDate"::DATE > (
		select max("PurchaseDate"::DATE) - interval '7 days' from ecomm_data
	)
order by
	"PurchaseDate"::DATE;
```

### 4. Subquery & CTE
Menyaring produk yang memiliki performa di atas rata-rata.
* **Technique:** **CTE** & **SubQuery**
* **Business Value:** Membantu tim marketing fokus pada produk yang memiliki `net_revenue` diatas rata-rata.
* **Code:**
```sql
with tabel_revenue as (
	select *,
		("Price" * "QuantitySold" * (1 - ("Discount" / 100))) as net_revenue
	from ecomm_data
)
select 
	"ProductID",
	"ProductName",
	"net_revenue"
from tabel_revenue
where 
	net_revenue > (select avg(net_revenue) from tabel_revenue);
```

### 5. Product Ranking (Global & Category)
Ingin melihat top 3 produk dari tiap kategori 
* **Technique:** Menggunakan `limit` dan memisahkan data menjadi perkategori
* **Business Value:** Memudahkan tim bisnis melihat barang terbaik pada tiap kategori 
* **Code:**
```sql
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
select * from ranked_products
where "ranking" <= 3;
```
