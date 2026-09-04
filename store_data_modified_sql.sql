use retail_store;

select* from store_data;

update store_data
set store_size_m2 = null where store_name = 'Online' or store_name='online';

