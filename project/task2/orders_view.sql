-- Запрос для корректной работы витрины после коррекции. 
WITH tab AS (SELECT order_id,
       MAX(dttm) AS dttm
FROM production.orderstatuslog
GROUP BY order_id
)
SELECT o.order_id,
       o.order_ts,
	   o.user_id,
	   o.bonus_payment,
	   o.payment,
	   o.cost,
	   o.bonus_grant,
	   os.status_id AS status
FROM production.orders AS o
INNER JOIN production.OrderStatusLog AS os ON o.order_id = os.order_id
INNER JOIN tab AS t ON os.order_id = t.order_id AND os.dttm = t.dttm