-- Создаем таблицу tmp_rfm_recency в схеме analysis
CREATE TABLE analysis.tmp_rfm_recency (
 user_id INT NOT NULL PRIMARY KEY,
 recency INT NOT NULL CHECK(recency >= 1 AND recency <= 5)
);

-- Заполняем таблицу tmp_rfm_recency
INSERT INTO analysis.tmp_rfm_recency(user_id, recency)
SELECT u.id AS user_id,
       NTILE(5) OVER (ORDER BY MAX(o.order_ts) NULLS FIRST) AS recency
FROM analysis.users AS u
LEFT JOIN analysis.orders AS o ON u.id = o.user_id
WHERE o.status = '4'
      AND EXTRACT (YEAR FROM o.order_ts) >= 2022
GROUP BY 1;
