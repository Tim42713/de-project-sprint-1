CREATE TABLE analysis.tmp_rfm_monetary_value (
 user_id INT NOT NULL PRIMARY KEY,
 monetary_value INT NOT NULL CHECK(monetary_value >= 1 AND monetary_value <= 5)
);

INSERT INTO tmp_rfm_monetary_value (user_id, monetary_value)
SELECT u.id AS user_id,
       NTILE(5) OVER (ORDER BY SUM(o.cost) ASC) AS monetary_value
FROM analysis.users AS u
LEFT JOIN analysis.orders AS o ON u.id = o.user_id
WHERE o.status = '4' 
      AND extract(year FROM o.order_ts) = '2022'
GROUP BY 1
ORDER BY monetary_value ASC;