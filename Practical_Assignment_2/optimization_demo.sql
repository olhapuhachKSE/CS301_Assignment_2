-- PostgreSQL Optimization Demo
-- Use EXPLAIN or EXPLAIN ANALYZE before each query to compare execution plans.

-- ============================================================
-- 1. Non-optimized query
-- ============================================================

EXPLAIN ANALYZE
SELECT(

    SELECT STRING_AGG(result, ';')
    -- без string_agg видавало помилку що  підзапит повертає більше ніж один рядок, ШІ запронував вирішити так
    -- string_agg об'єднує кілька рядків в один рядок і записує черз крапку з комою
    FROM (
        SELECT
            CONCAT(c.name, ' ', c.surname, ': ', COUNT(o.order_id)) AS result
            -- contact об'єднує значення в один рядок
        FROM opt_orders AS o
        JOIN opt_clients AS c
            ON o.client_id = c.id
        JOIN opt_products AS p
            ON o.product_id = p.product_id
        GROUP BY
        	c.id,
        	c.name,
        	c.surname
        ORDER BY COUNT(o.order_id) DESC
        LIMIT 10
    ) AS sub1
) AS top_10_clients,
--цей запит буде повертати топ 10 клієнтів за кфлькфстю замовлень

(
    SELECT STRING_AGG(result, ';')
    FROM (
        SELECT
            CONCAT(c.name, ' ', c.surname, ': ', COUNT(o.order_id)) AS result
        FROM opt_orders AS o
        JOIN opt_clients AS c
            ON o.client_id = c.id
        JOIN opt_products AS p
            ON o.product_id = p.product_id
        WHERE c.name LIKE 'A%'
        GROUP BY
        	c.id,
        	c.name,
        	c.surname
        HAVING COUNT(o.order_id) > 1
        ORDER BY COUNT(o.order_id) DESC
    ) AS sub2
) AS clients_with_name_starts_A,
-- цуй запит повертає клфєнтів ім'я яких починається на а, і в них є замовдення

(
    SELECT STRING_AGG(result, ';')
    FROM (
        SELECT
            CONCAT('Order: ', o.order_id,', Client: ', c.name, ' ', c.surname,', Category: ', p.product_category ) AS result
            -- тут також допоміг ШІ щоб записати назва:  значення
        FROM opt_orders AS o
        JOIN opt_clients AS c
            ON o.client_id = c.id
        JOIN opt_products AS p
            ON o.product_id = p.product_id
        WHERE c.status = 'active' AND p.product_category = 'Category2'
        ORDER BY o.order_id
    ) AS sub3
) AS active_category2_orders;
-- цей запит повертає елфєнта з активним статусом і купленим продуктом з категорії 2


-- ============================================================
-- 2. Indexes for optimization
-- ============================================================



CREATE INDEX IF NOT EXISTS idx_opt_orders_client_id
    ON opt_orders(client_id);
-- зв'язок замовлення до ід клієнта постійно це використовуємо тому ставлю некластирезований індекс

CREATE INDEX IF NOT EXISTS idx_opt_orders_product_id
    ON opt_orders(product_id);

CREATE INDEX IF NOT EXISTS idx_opt_product_category
    ON opt_products(product_category);
    -- для фільтрації за категорією 2

CREATE INDEX IF NOT EXISTS idx_opt_clients_name
    ON opt_clients(name);
-- для фільтрації імен які починаються на і

CREATE INDEX IF NOT EXISTS idx_opt_clients_status
    ON opt_clients(status);
-- створила для оптимізації фільтрації за статусом кастомера




-- ============================================================
-- 3. Optimized query
-- ============================================================

SET enable_seqscan = OFF;
SET enable_indexscan = ON;

EXPLAIN ANALYZE
WITH filtered_orders AS (
    SELECT
        o.order_id,
        o.order_date,
        c.id AS client_id,
        c.name,
        c.surname,
        c.status,
        p.product_category
    FROM opt_orders AS o
    JOIN opt_products AS p
        ON o.product_id = p.product_id
    JOIN opt_clients AS c
        ON o.client_id = c.id
    WHERE status = 'active' AND product_category = 'Category2'
),
top_10_clients AS(
	SELECT STRING_AGG(name || ' ' || surname || ': ' || cnt, ';') AS result
	-- ШІ допоміг написати як записувати результати через string_agg
    FROM (
        SELECT
            client_id,
            name,
            surname,
            COUNT(order_id) AS cnt
        FROM filtered_orders
        GROUP BY client_id, name, surname
        ORDER BY cnt DESC
        LIMIT 10
    )),
clients_with_A AS(
	 SELECT STRING_AGG(name || ' ' || surname || ': ' || cnt, ';') AS result
    	FROM (
        	SELECT
            	client_id,
            	name,
            	surname,
            	COUNT(order_id) AS cnt
        	FROM filtered_orders
        	WHERE name LIKE 'A%'
        	GROUP BY client_id, name, surname
        	HAVING COUNT(order_id) > 1
    )),
active_category2_orders AS(
 SELECT STRING_AGG('Order: ' || order_id ||', Client: ' || name || ' ' || surname || ', Category: ' || product_category,';') AS result
    from filtered_orders
)
SELECT
    (SELECT result FROM top_10_clients) AS top_10_clients,
    (SELECT result FROM clients_with_A) AS clients_with_A,
    (SELECT result FROM active_category2_orders) AS active_category2_orders;
