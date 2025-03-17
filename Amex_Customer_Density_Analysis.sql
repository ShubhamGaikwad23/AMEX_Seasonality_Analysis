CREATE TABLE transaction_records (
    transaction_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    transaction_amount DECIMAL(10, 2) NOT NULL,
    transaction_date DATETIME NOT NULL,
    store_id INT NOT NULL
);

INSERT INTO transaction_records (transaction_id, customer_id, transaction_amount, transaction_date, store_id) VALUES
(1, 3, 189.00, '2024-01-21 00:00:00', 4),
(2, 7, 495.00, '2024-01-29 00:00:00', 1),
(3, 11, 207.00, '2024-02-17 00:00:00', 5),
(4, 11, 483.00, '2024-01-08 00:00:00', 5),
(5, 8, 290.00, '2024-02-14 00:00:00', 2),
(6, 5, 209.00, '2024-01-09 00:00:00', 5),
(7, 4, 465.00, '2024-02-17 00:00:00', 2),
(8, 8, 194.00, '2024-02-05 00:00:00', 1),
(9, 8, 465.00, '2024-01-15 00:00:00', 4),
(10, 3, 70.00, '2024-01-18 00:00:00', 4),
(11, 6, 383.00, '2024-02-06 00:00:00', 4),
(12, 5, 74.00, '2024-02-20 00:00:00', 5),
(13, 2, 263.00, '2024-02-10 00:00:00', 1),
(14, 8, 339.00, '2024-01-05 00:00:00', 5),
(15, 12, 150.00, '2024-01-03 00:00:00', 5),
(16, 14, 326.00, '2024-01-07 00:00:00', 1),
(17, 6, 154.00, '2024-02-24 00:00:00', 1),
(18, 2, 40.00, '2024-02-12 00:00:00', 1),
(19, 12, 348.00, '2024-01-05 00:00:00', 1),
(20, 5, 186.00, '2024-02-24 00:00:00', 4),
(21, 1, 293.00, '2024-01-30 00:00:00', 3),
(22, 12, 407.00, '2024-01-19 00:00:00', 3),
(23, 10, 108.00, '2024-01-27 00:00:00', 1),
(24, 6, 335.00, '2024-02-14 00:00:00', 3),
(25, 13, 33.00, '2024-02-04 00:00:00', 3),
(26, 12, 261.00, '2024-01-11 00:00:00', 1),
(27, 9, 284.00, '2024-02-06 00:00:00', 3),
(28, 1, 365.00, '2024-01-15 00:00:00', 5),
(29, 11, 72.00, '2024-02-01 00:00:00', 2),
(30, 11, 405.00, '2024-02-18 00:00:00', 2);


CREATE TABLE stores (
    store_id INT PRIMARY KEY,
    store_location VARCHAR(50) NOT NULL,
    store_open_date DATETIME NOT NULL,
    area_name VARCHAR(50) NOT NULL,
    area_size INT NOT NULL
);

INSERT INTO stores (store_id, store_location, store_open_date, area_name, area_size) VALUES
(1, 'City Center', '2018-09-11 00:00:00', 'Area A', 121),
(2, 'Suburbs', '2019-08-10 00:00:00', 'Area B', 238),
(3, 'Downtown', '2012-05-11 00:00:00', 'Area C', 70),
(4, 'Industrial Area', '2013-07-19 00:00:00', 'Area D', 152),
(5, 'Mall', '2013-02-05 00:00:00', 'Area E', 171);

--Problem Statement: Identify the top 3 areas with the highest customer density.

--Customer density = (total number of unique customers in the area / area size).

SELECT * FROM transaction_records;
SELECT * FROM stores;


--Approach 1: 
WITH AreaDensity AS (
    SELECT 
        s.area_name,
        COUNT(DISTINCT t.customer_id) * 1.0 / SUM(s.area_size) AS customer_density
    FROM 
        transaction_records t
    JOIN 
        stores s ON t.store_id = s.store_id
    GROUP BY 
        s.area_name
)
SELECT TOP 3 
    area_name, 
    customer_density
FROM 
    AreaDensity
ORDER BY 
    customer_density DESC;


--Appraoch 2: (In case of different area size for same area)
WITH x AS (
SELECT area_name,COUNT(DISTINCT(customer_id))/area_size AS customer_density
FROM stores s 
JOIN transaction_records t 
ON s.store_id=t.store_id
GROUP BY area_name,area_size),
y AS (
SELECT area_name,customer_density,
DENSE_RANK() OVER(ORDER BY customer_density DESC) AS rnk 
FROM x)
SELECT area_name,customer_density
FROM y 
WHERE rnk<=3;
-----------------------------------------------------------------------------------
# Here is the solution using Pandas
# Import your libraries
import pandas as pd

# Start writing code
df1=pd.merge(transaction_records,stores,on='store_id')
df2=df1.groupby(['area_name','area_size']).agg({'customer_id':'nunique'}).reset_index().rename(columns={'customer_id':'customer_count'})
df2['customer_density']=df2['customer_count']/df2['area_size']
df2['rank']=df2['customer_density'].rank(method='dense',ascending=False)
df2[df2['rank']<=3][['area_name','customer_density']].sort_values(by='customer_density',ascending=False)
