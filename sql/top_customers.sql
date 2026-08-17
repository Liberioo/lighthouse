WITH customer_avg AS ( -- avg ticket per customer
  SELECT customer_id, SUM(total)/COUNT(*) AS avg_ticket
  FROM lighthouse.orders o
  WHERE o.status = 'paid' OR o.status = 'confirmed'
  GROUP BY customer_id
),
customer_categories AS ( -- distinct categories per customer
  SELECT 
    o.customer_id,
    COUNT(DISTINCT p.category_id) AS categories
  FROM lighthouse.orders o
  JOIN lighthouse.order_items oi ON oi.order_id = o.id
  JOIN lighthouse.product_variants pv ON pv.id = oi.product_variant_id
  JOIN lighthouse.products p ON pv.product_id = p.id
  WHERE o.status = 'paid' OR o.status = 'confirmed'
  GROUP BY o.customer_id
)
SELECT -- top 10 customers with 13+ distinct categories and orderer by descending avg ticket then ascending customer id
    ca.customer_id,
    cc.categories,
    ca.avg_ticket
FROM customer_avg ca
JOIN customer_categories cc ON cc.customer_id = ca.customer_id
WHERE cc.categories >= 13
ORDER BY ca.avg_ticket DESC, ca.customer_id ASC
LIMIT 10;