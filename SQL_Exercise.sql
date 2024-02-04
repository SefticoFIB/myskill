/*
	EXERCISE SQL - SEFTICO FRIG INJEK .B
*/

---------------------------------------------------------------------------------------
--      1. MENEMUKAN BULAN YANG MEMILIKI TOTAL TRANSAKSI PALING BESAR PADA 2021      --
---------------------------------------------------------------------------------------
-- Source table: order_detail

select
	extract(month from order_date) as bulan,
	sum(after_discount) as total_highest_transaction_value
from
	order_detail od 
where 
	extract(year from order_date) = 2021
	and is_valid = 1
group by 1
order by 2 desc 
limit 1

---------------------------------------------------------------------------------------
--    2. MENEMUKAN KATEGORI YANG MEMILIKI TOTAL TRANSAKSI PALING BESAR PADA 2022     --
---------------------------------------------------------------------------------------
-- Source table: order_detail, sku_detail

select
	sd.category,
	sum(after_discount) as total_highest_transaction_value
from
	order_detail od 
	left join sku_detail sd on od.sku_id = sd.id
where 
	extract(year from od.order_date) = 2022
	and is_valid = 1
group by 1
order by 2 desc 
limit 1

---------------------------------------------------------------------------------------
--    3. MEMBANDINGKAN NILAI TRANSAKSI DARI MASING-MASING KATEGORI PADA TAHUN        --
--                                  2021 DENGAN 2022                                 --
--     MENAMPILKAN KATEGORI YANG MENGALAMI PENINGKATAN DAN PENURUNAN DARI TAHUN      --
--                                    2021 KE 2022                                   --        
---------------------------------------------------------------------------------------
-- Source table: order_detail, sku_detail

WITH transaksi_2021 AS (
    SELECT
        sd.category,
        SUM(od.after_discount) AS total_transaksi_2021
    FROM
        order_detail od
        LEFT JOIN sku_detail sd ON od.sku_id = sd.id
    WHERE
        EXTRACT(YEAR FROM od.order_date) = 2021
        AND od.is_valid = 1
    GROUP BY
        sd.category
),
transaksi_2022 AS (
    SELECT
        sd.category,
        SUM(od.after_discount) AS total_transaksi_2022
    FROM
        order_detail od
        LEFT JOIN sku_detail sd ON od.sku_id = sd.id
    WHERE
        EXTRACT(YEAR FROM od.order_date) = 2022
        AND od.is_valid = 1
    GROUP BY
        sd.category
)
SELECT
    t22.category,
    t22.total_transaksi_2022,
    t21.total_transaksi_2021,
    ROUND(CAST(t22.total_transaksi_2022 - t21.total_transaksi_2021 AS numeric), 0) AS growth,
    CASE
        WHEN t22.total_transaksi_2022 > t21.total_transaksi_2021 THEN 'Peningkatan'
        WHEN t22.total_transaksi_2022 < t21.total_transaksi_2021 THEN 'Penurunan'
        ELSE 'Tidak Berubah'
    END AS status
FROM
    transaksi_2022 t22
    LEFT JOIN transaksi_2021 t21 ON t22.category = t21.category
ORDER BY
    t22.category;

   
---------------------------------------------------------------------------------------
--     4. MENAMPILKAN TOP 5 METODE PEMBAYARAN YANG PALING POPULER SELAMA 2022        --       
---------------------------------------------------------------------------------------
-- Source table: order_detail, payment_detail

WITH popular_payment_methods AS (
    SELECT
        pd.payment_method,
        COUNT(DISTINCT od.id) AS total_unique_orders
    FROM
        order_detail od
        JOIN payment_detail pd ON od.payment_id = pd.id
    WHERE
        EXTRACT(YEAR FROM od.order_date) = 2022
        AND od.is_valid = 1
    GROUP BY
        pd.payment_method
)
SELECT
    payment_method,
    total_unique_orders
FROM
    popular_payment_methods
ORDER BY
    total_unique_orders DESC
LIMIT 5;

---------------------------------------------------------------------------------------
--               5. MENGURUTKAN 5 PRODUK BERDASARKAN NILAI TRANSAKSI                 --
--                      SAMSUNG, APPLE, SONY, HUAWEI, LENOVO                         --       
---------------------------------------------------------------------------------------
-- Source table: order_detail, sku_detail

WITH ProductSales AS (
    SELECT
        CASE
            WHEN LOWER(sd.sku_name) LIKE '%samsung%' THEN 'Samsung'
            WHEN LOWER(sd.sku_name) LIKE '%apple%' THEN 'Apple'
            WHEN LOWER(sd.sku_name) LIKE '%iphone%' THEN 'Apple'
            WHEN LOWER(sd.sku_name) LIKE '%macbook%' THEN 'Apple'
            WHEN LOWER(sd.sku_name) LIKE '%imac%' THEN 'Apple'
            WHEN LOWER(sd.sku_name) LIKE '%sony%' THEN 'Sony'
            WHEN LOWER(sd.sku_name) LIKE '%huawei%' THEN 'Huawei'
            WHEN LOWER(sd.sku_name) LIKE '%lenovo%' THEN 'Lenovo'
            ELSE sd.sku_name
        END AS product_category,
        ROUND(SUM(od.after_discount * od.qty_ordered)::numeric, 0) AS total_sales
    FROM
        order_detail od
    JOIN
        sku_detail sd ON od.sku_id = sd.id
    WHERE
        od.is_valid = 1
        AND sd.sku_name ILIKE ANY (ARRAY['%Samsung%', '%Apple%', '%Sony%', '%Huawei%', '%Lenovo%'])
    GROUP BY
        product_category
)

SELECT
    product_category,
    total_sales
FROM ProductSales
ORDER BY total_sales DESC;






