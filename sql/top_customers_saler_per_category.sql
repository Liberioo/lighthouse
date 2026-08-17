-- avg ticket per customer
WITH customer_avg AS (
  SELECT customer_id, SUM(total)/COUNT(*) AS avg_ticket
  FROM lighthouse.orders o
  WHERE o.status = 'paid' OR o.status = 'confirmed'
  GROUP BY customer_id
),
customer_categories AS ( -- distinct category count per customer
  SELECT
    o.customer_id,
    COUNT(DISTINCT p.category_id) AS categories
  FROM lighthouse.orders o
  JOIN lighthouse.order_items oi ON oi.order_id = o.id
  JOIN lighthouse.product_variants pv ON pv.id = oi.product_variant_id
  JOIN lighthouse.products p ON pv.product_id = p.id
  WHERE o.status = 'paid' OR o.status = 'confirmed'
  GROUP BY o.customer_id
  HAVING COUNT(DISTINCT p.category_id) >= 13
),
top_customers AS ( -- top 10 customers with 13+ distinct categories ordered by desc avg ticket then asc customer id
  SELECT ca.customer_id, cc.categories, ca.avg_ticket
  FROM customer_avg ca JOIN customer_categories cc ON cc.customer_id = ca.customer_id
  ORDER BY ca.avg_ticket DESC, ca.customer_id ASC
  LIMIT 10
)
SELECT -- quantity of items purchased per category in the top 10 customers
  DISTINCT c.name as category,
  SUM(oi.quantity) as amount_sold
  FROM top_customers t
  JOIN lighthouse.orders o ON t.customer_id = o.customer_id
  JOIN lighthouse.order_items oi ON oi.order_id = o.id
  JOIN lighthouse.product_variants pv ON oi.product_variant_id = pv.id
  JOIN lighthouse.products p ON pv.product_id = p.id
  JOIN lighthouse.categories c ON p.category_id = c.id
  where o.status = 'paid' OR o.status = 'confirmed'
  GROUP BY category
  ORDER BY amount_sold DESC;