-- Создаем представления для используемых таблиц в схеме analysis
CREATE OR REPLACE VIEW analysis.users AS SELECT * FROM production.users;
CREATE OR REPLACE VIEW analysis.OrderItems AS SELECT * FROM production.OrderItems;
CREATE OR REPLACE VIEW analysis.OrderStatuses AS SELECT * FROM production.OrderStatuses;
CREATE OR REPLACE VIEW analysis.products AS SELECT * FROM production.products;
CREATE OR REPLACE VIEW analysis.orders AS SELECT * FROM production.orders;