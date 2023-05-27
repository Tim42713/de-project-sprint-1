CREATE TABLE analysis.tmp_rfm_frequency (
 user_id INT NOT NULL PRIMARY KEY,
 frequency INT NOT NULL CHECK(frequency >= 1 AND frequency <= 5)
);

INSERT INTO tmp_rfm_frequency (user_id, frequency)
SELECT u.id AS user_id, 
       NTILE(5) OVER (ORDER BY COUNT(o.order_id) ASC) AS frequency 
FROM analysis.users AS u
LEFT JOIN analysis.orders AS o ON u.id = o.user_id
WHERE o.status = '4' 
      AND EXTRACT(year FROM o.order_ts) = '2022'
GROUP BY 1
ORDER BY frequency ASC;
