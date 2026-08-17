SELECT COUNT(*) FROM lighthouse.orders;

SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = 'lighthouse' AND table_name = 'orders';

SELECT MIN(created_at), MAX(created_at) FROM lighthouse.orders;

SELECT MIN(total), MAX(total), AVG(total) FROM lighthouse.orders;
