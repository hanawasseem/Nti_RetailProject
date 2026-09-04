-- create schema retail_store;
-- use retail_store;

update product_data 
set product_id=trim(product_id);

update  product_data 
set category=trim(category);

update  product_data 
set color=trim(color);

update  product_data 
set size= trim(size);

update  product_data 
set season= trim(season);

update  product_data 
set supplier=trim(supplier);

update  product_data 
set cost_price=trim(cost_price);

update  product_data 
set list_price = trim(list_price);

SELECT *
FROM product_data
WHERE CONCAT(product_id, category, color, size, season, supplier, cost_price, list_price) IS NULL;


-- to identify the nulls
SELECT category, COUNT(*) FROM product_data GROUP BY category;  -- contains null values '???'
SELECT color,    COUNT(*) FROM product_data GROUP BY color;     -- contains null values ' '
SELECT size,     COUNT(*) FROM product_data GROUP BY size;
SELECT season,   COUNT(*) FROM product_data GROUP BY season;
SELECT supplier, COUNT(*) FROM product_data GROUP BY supplier;

-- select count(category) from product_data where category='???';

 /* SELECT *
FROM product_datastore_data
WHERE category = '???' OR color IS NULL; */

update  product_data 
set category='Unknown' where category ='???';

update product_data
set color='unknown' where color='';


 SELECT count(distinct product_id)
FROM product_data;

select * 
from product_data 
where cost_price > list_price;

select category ,supplier,count(*)
from product_data 
where cost_price > list_price 
 group by category,supplier;
 
ALTER TABLE product_data
ADD COLUMN profit_margin float ;

UPDATE product_data
SET profit_margin =list_price-cost_price ;
select * from product_data limit 500000;
SELECT COUNT(*) FROM product_data;