DROP TABLE IF EXISTS lighthouse.dim_date;

CREATE TABLE lighthouse.dim_date (
  date_id INTEGER PRIMARY KEY,          
  full_date DATE NOT NULL UNIQUE,
  day_of_week INTEGER NOT NULL, -- 0=Domingo ... 6=Sábado
  day_name TEXT NOT NULL,              
  day_of_month INTEGER NOT NULL,
  day_of_year INTEGER NOT NULL,
  month_number INTEGER NOT NULL,
  month_name TEXT NOT NULL,
  year INTEGER NOT NULL
);

INSERT INTO lighthouse.dim_date (
  date_id, full_date, day_of_week, day_name, day_of_month,
  day_of_year, month_number, month_name, year
)
SELECT
  TO_CHAR(d, 'YYYYMMDD')::INTEGER AS date_id,
  d AS full_date,
  EXTRACT(DOW FROM d)::INTEGER AS day_of_week,
  CASE EXTRACT(DOW FROM d)::INTEGER
    WHEN 0 THEN 'Domingo'
    WHEN 1 THEN 'Segunda-feira'
    WHEN 2 THEN 'Terça-feira'
    WHEN 3 THEN 'Quarta-feira'
    WHEN 4 THEN 'Quinta-feira'
    WHEN 5 THEN 'Sexta-feira'
    WHEN 6 THEN 'Sábado'
  END AS day_name,
  EXTRACT(DAY FROM d)::INTEGER AS day_of_month,
  EXTRACT(DOY FROM d)::INTEGER AS day_of_year,
  EXTRACT(MONTH FROM d)::INTEGER AS month_number,
  TO_CHAR(d, 'Month') AS month_name,
  EXTRACT(YEAR FROM d)::INTEGER AS year
FROM generate_series('2020-01-01'::DATE, '2026-12-31'::DATE, '1 day'::INTERVAL) AS d;

WITH daily_sales AS (
  SELECT
    dd.full_date,
    dd.day_of_week,
    dd.day_name,
    COALESCE(SUM(o.total), 0) AS total_sales
  FROM lighthouse.dim_date dd
  LEFT JOIN lighthouse.orders o 
    ON o.placed_at::DATE = dd.full_date AND o.channel = 'pos' AND o.status IN ('paid','confirmed')
  GROUP BY dd.full_date, dd.day_of_week, dd.day_name
  
)
SELECT
    day_of_week,
    day_name,
    AVG(total_sales) AS avg_sales,
    COUNT(*) AS days_counted
FROM daily_sales
GROUP BY day_of_week, day_name
ORDER BY avg_sales;