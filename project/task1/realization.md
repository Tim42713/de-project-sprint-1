# Витрина RFM

## 1.1. Выясните требования к целевой витрине.

Постановка задачи выглядит достаточно абстрактно - постройте витрину. Первым делом вам необходимо выяснить у заказчика детали. Запросите недостающую информацию у заказчика в чате.

Зафиксируйте вы ясненные требования. Составьте документацию готовящейся витрины на основе заданных вами вопросов, добавив все необходимые детали.

-----------

Задача: Подготовить витрину для для RFM-анализа. Для анализа нужно отобрать только успешно выполненные заказы, которые имеют статус closed;
Согласованное название витрины: dm_rfm_segments;
Глубина требуемых данных: с начала 2022 года;
Обновления: не требуются;
Хранение: в БД - de, схеме - analysis;
Сроки выполнения: нет условия.

Структура построенной витрины: 

user_id - идентификатор клиента;
recency (число от 1 до 5) - время с последнего заказа, где 1 означает, что клиент, либо совсем не делал заказов, либо давно и 5 — те, кто заказывал относительно недавно;
frequency (число от 1 до 5) - категоризация по кол-ву заказов, где 1 минимальное кол-во, а 5 наибольшее кол-во;
monetary_value (число от 1 до 5) - распределение по суммам трат клиентов, где 1 меньшее и 5 большее. 

## 1.2. Изучите структуру исходных данных.

Полключитесь к базе данных и изучите структуру таблиц.

Если появились вопросы по устройству источника, задайте их в чате.

Зафиксируйте, какие поля вы будете использовать для расчета витрины.

-----------

Доступны следующие 6 таблиц:

orders - в таблице предоставлены данные по заказам
orderitems - детализация заказов
orderstatuses - в данной таблице хранятся статусы заказов
orderstatuslog - суда записываются логи заказов 
products - таблица с информацией о продукции 
users - информация о клиентах 

Для построения витрины будем использовать таблицу - production.orders, где будет поле status будет фильтроваться по условию closed (4). Используемые поля: 
order_id - идентификатор заказа
order_ts - дата и время заказа
user_id - идентификатор клиента
cost - сумма оплаты 
status - статус заказа

Так же используется таблица - production.users:
id - идентификатор клиента 

## 1.3. Проанализируйте качество данных

Изучите качество входных данных. Опишите, насколько качественные данные хранятся в источнике. Так же укажите, какие инструменты обеспечения качества данных были использованы в таблицах в схеме production.

-----------

Пропущенные значения и дубликаты отсутствуют.(is null, distinct).

На данные установлены ограничения повышающие качество данных: 
таблица production.orders
order_id int4 NOT NULL - не может быть нулевых значений в айди заказа
order_ts timestamp NOT NULL, - для времени заказа уже установлен верный формат(timestamp) и ограничения нулевых значений 
"cost" numeric(19, 5) NOT NULL DEFAULT 0, - значения по дефолту не могут быть нулевыми
status int4 NOT NULL статус не может быть нулевым

Выделим отдельно установлена проверка на сумму коста (финального платежа) и ограничение по первичному ключу по столбцу order_id
CONSTRAINT orders_check CHECK ((cost = (payment + bonus_payment)))
CONSTRAINT orders_pkey PRIMARY KEY (order_id)

production.users: 
id int4 NOT NULL идентификатор не может быть нулевым для клиентов 
CONSTRAINT users_pkey PRIMARY KEY (id) установлены ограничения по первичному ключу 

## 1.4. Подготовьте витрину данных

Теперь, когда требования понятны, а исходные данные изучены, можно приступить к реализации.

### 1.4.1. Сделайте VIEW для таблиц из базы production.**

Вас просят при расчете витрины обращаться только к объектам из схемы analysis. Чтобы не дублировать данные (данные находятся в этой же базе), вы решаете сделать view. Таким образом, View будут находиться в схеме analysis и вычитывать данные из схемы production. 

Напишите SQL-запросы для создания пяти VIEW (по одному на каждую таблицу) и выполните их. Для проверки предоставьте код создания VIEW.

```SQL
CREATE VIEW analysis.users AS SELECT * FROM production.users;
CREATE VIEW analysis.OrderItems AS SELECT * FROM production.OrderItems;
CREATE VIEW analysis.OrderStatuses AS SELECT * FROM production.OrderStatuses;
CREATE VIEW analysis.products AS SELECT * FROM production.products;
CREATE VIEW analysis.orders AS SELECT * FROM production.orders;
```

### 1.4.2. Напишите DDL-запрос для создания витрины.**

Далее вам необходимо создать витрину. Напишите CREATE TABLE запрос и выполните его на предоставленной базе данных в схеме analysis.

```SQL
CREATE TABLE dm_rfm_segments(
    user_id INT NOT NULL PRIMARY KEY,
    recency INT NOT NULL,
    frequency INT NOT NULL,
    monetary_value INT NOT NULL
);
```

### 1.4.3. Напишите SQL запрос для заполнения витрины

Наконец, реализуйте расчет витрины на языке SQL и заполните таблицу, созданную в предыдущем пункте.

Для решения предоставьте код запроса.

```SQL
-- Поочередно заполняем таблицы для нашей витрины
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

CREATE TABLE analysis.tmp_rfm_recency (
 user_id INT NOT NULL PRIMARY KEY,
 recency INT NOT NULL CHECK(recency >= 1 AND recency <= 5)
);
INSERT INTO analysis.tmp_rfm_recency(user_id, recency)
SELECT u.id AS user_id,
       NTILE(5) OVER (ORDER BY MAX(o.order_ts) NULLS FIRST) AS recency
FROM analysis.users AS u
LEFT JOIN analysis.orders AS o ON u.id = o.user_id
WHERE o.status = '4'
      AND EXTRACT (YEAR FROM o.order_ts) >= 2022
GROUP BY 1;

-- Добавляем консолидированную информацию в нашу витрину (dm_rfm_segments)
INSERT INTO analysis.dm_rfm_segments (user_id, recency, frequency, monetary_value)
SELECT r.user_id,
       r.recency,
       f.frequency,
       m.monetary_value
FROM analysis.tmp_rfm_recency AS r
LEFT JOIN analysis.tmp_rfm_frequency AS f ON r.user_id = f.user_id
LEFT JOIN analysis.tmp_rfm_monetary_value AS m ON r.user_id = m.user_id;
```



