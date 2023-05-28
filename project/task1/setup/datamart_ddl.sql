-- Создаем витрину согласно задаче
CREATE TABLE analysis.dm_rfm_segments(
    user_id INT NOT NULL PRIMARY KEY,
    recency INT NOT NULL,
    frequency INT NOT NULL,
    monetary_value INT NOT NULL
);