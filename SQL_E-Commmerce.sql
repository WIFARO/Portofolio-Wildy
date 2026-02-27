-- Studi Kasus 1 - String Cleaning & Product Label

select 
	concat(left("ProductName", 3), '-', right("ProductID"::TEXT, 2)) as product_code,
	upper("CustomerLocation") as standardized_location,
	replace("Category", '&', 'and') as cleaned_category
from ecomm_data;

-- Studi Kasus 2 - Timestamp Analysis (Monthly Trend)

select
	sum("Price" * "QuantitySold" * (1 - ("Discount" / 100))) as total_net_revenue,
	count("ProductID") as total_transaksi,
	date_trunc('month', "PurchaseDate"::DATE) as period_month,
	extract(year from "PurchaseDate"::DATE) as year_purchase_date,
	extract(month from "PurchaseDate"::DATE) as month_purchase_date
from ecomm_data
group by period_month, year_purchase_date, month_purchase_date
order by period_month asc;

-- Studi Kasus 3 - Time Filter dengan ADD/SUB Interval 

select *,
	now() as current_system_time
from ecomm_data
where
	"PurchaseDate"::DATE > (
		select max("PurchaseDate"::DATE) - interval '7 days' from ecomm_data
	)
order by
	"PurchaseDate"::DATE;

-- Studi Kasus 4 - Subquery & CTE: Di Atas Rata-rata

select 
	"ProductID",
	"ProductName",
	"Price"
from ecomm_data
where 
	"Price" > (select avg("Price") from ecomm_data)
order by 
	"Price" asc;

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

-- Studi Kasus 5 - Ranking: Global & Per Kategori

select 
	"ProductName",
	sum("QuantitySold") as total_sold,
	rank() over(order by sum("QuantitySold") desc) as global_rank
from ecomm_data
group by "ProductName" 
limit 10;

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
