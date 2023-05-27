-- Добавляем консолидированную информацию в нашу витрину (dm_rfm_segments)
INSERT INTO analysis.dm_rfm_segments (user_id, recency, frequency, monetary_value)
SELECT r.user_id,
       r.recency,
       f.frequency,
       m.monetary_value
FROM analysis.tmp_rfm_recency AS r
LEFT JOIN analysis.tmp_rfm_frequency AS f ON r.user_id = f.user_id
LEFT JOIN analysis.tmp_rfm_monetary_value AS m ON r.user_id = m.user_id;

-- Просматриваем первые 10 пользователей
SELECT *
FROM analysis.dm_rfm_segments
ORDER BY user_id
LIMIT 10;


