-- Создаем таблицу tmp_rfm_frequency в схеме analysis
CREATE TABLE analysis.tmp_rfm_frequency (
 user_id INT NOT NULL PRIMARY KEY,
 frequency INT NOT NULL CHECK(frequency >= 1 AND frequency <= 5)
);

-- Заполняем таблицу tmp_rfm_frequency
INSERT INTO tmp_rfm_frequency (user_id, frequency)
SELECT u.id AS user_id, 
       NTILE(5) OVER (ORDER BY COUNT(o.order_id) ASC) AS frequency 
FROM analysis.users AS u
LEFT JOIN analysis.orders AS o ON u.id = o.user_id
          AND o.status = (SELECT id FROM analysis.OrderStatuses WHERE key = 'Closed')
          AND EXTRACT (YEAR FROM o.order_ts) >= 2022
GROUP BY 1;