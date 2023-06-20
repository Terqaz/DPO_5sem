-- 3.1.1 Статус заказа | Среднее время пребывания заказа в этом статусе

-- Получаем интервалы времени в которых находились заказы в определенном статусе
WITH order_status_interval AS (
    -- Интервалы времени при первом изменении статуса заказов
    SELECT
        OH.old_value :: int AS status_id,
        OH.created_at - O.created_at AS interval
    FROM
        order_history AS OH
        INNER JOIN "order" O ON O.id = OH.order_id
        AND OH.old_value :: int = 1
        AND OH.field_name = 'status_id'
        
    UNION

    -- Интервалы времени при последующих изменениях статуса заказов
    SELECT
        OH.new_value :: int AS status_id,
        OH2.created_at - OH.created_at AS interval
    FROM
        order_history AS OH
        INNER JOIN order_history AS OH2 ON OH.order_id = OH2.order_id
        AND OH.new_value = OH2.old_value
        AND OH.field_name = 'status_id'
        AND OH2.field_name = 'status_id'
    WHERE
        OH.new_value :: int != 1

    UNION

    -- Интервалы времени невыполненных заказов
    SELECT
        O.status_id AS status_id,
        CURRENT_TIMESTAMP(0) - OH.created_at AS interval
    FROM
        "order" AS O
        INNER JOIN order_history AS OH ON O.id = OH.order_id
        AND OH.field_name = 'status_id'
        AND O.status_id = OH.new_value::int
    WHERE
        O.status_id != 7
)
SELECT
    S.name,
    avg(OSI.interval) AS avg_time
FROM
    order_status_interval AS OSI
    RIGHT JOIN "status" AS S ON S.id = OSI.status_id
GROUP BY
    S.id,
    S.name
ORDER BY
    S.id;

-- 3.2.1 ID клиента | Дата последнего визита
SELECT
    CV.customer_id AS customer_id,
    max(CV.created_at) AS last_visit
FROM
    customer_visit AS CV
GROUP BY customer_id
ORDER BY last_visit DESC;

-- 3.2.2 ID клиента | Среднее количество просмотров страниц за визит
WITH customer_visit_pages_count AS (
    -- Количества посещенных сотрудниками страниц за визиты
    SELECT
        CV.customer_id AS customer_id,
        CVP.visit_id AS visit_id,
        count(CVP.id) AS pages_count
    FROM
        customer_visit_page AS CVP
        INNER JOIN customer_visit AS CV ON CV.id = CVP.visit_id
    GROUP BY
        customer_id,
        visit_id
)
SELECT
    customer_id,
    round(avg(pages_count), 2) AS avg_pages_per_visit
FROM
    customer_visit_pages_count
GROUP BY
    customer_id;

-- 3.2.3 ID клиента | Адреса страниц с визитами дольше среднего времени визита этого клиента
WITH customer_avg_time_on_pages AS (
    -- Среднее время посещения страниц сотрудниками за каждый визит
    SELECT
        CV.customer_id AS customer_id,
        CVP.visit_id AS visit_id,
        avg(CVP.time_on_page) AS avg_time_on_page
    FROM
        customer_visit_page AS CVP
        INNER JOIN customer_visit AS CV ON CV.id = CVP.visit_id
    GROUP BY
        customer_id,
        visit_id
)
SELECT
    CATP.customer_id AS customer_id,
    CVP.page AS PAGE
FROM
    customer_avg_time_on_pages AS CATP
    INNER JOIN customer_visit_page AS CVP ON CVP.visit_id = CATP.visit_id
    AND CVP.time_on_page > CATP.avg_time_on_page
ORDER BY
    customer_id;

-- 3.3.1 ID клиента | Среднее время между заказами
WITH order_creating_dates AS (
    -- Даты создания сотрудниками текущего и предыдущего заказов
    SELECT
        O.customer_id AS customer_id,
        O.created_at AS created_at,
        lag(created_at) over (
            PARTITION by O.customer_id
            ORDER BY O.created_at
        ) AS prev_created_at
    FROM
        "order" AS O
)
SELECT
    OCD.customer_id AS customer_id,
    avg(OCD.created_at - OCD.prev_created_at) AS orders_avg_time_between
FROM
    order_creating_dates AS OCD
GROUP BY
    customer_id
ORDER BY 
	orders_avg_time_between DESC

-- 3.3.2 ID клиента | Количество визитов | Количество заказов
WITH customer_visits_count AS (
    -- Количества визитов сотрудников
    SELECT
        C.id AS customer_id,
        count(CV.id) AS visits_count
    FROM
        customer AS C
        LEFT JOIN customer_visit AS CV ON CV.customer_id = C.id
    GROUP BY
        C.id
),
customer_orders_count AS (
    -- Количества заказов сотрудников
    SELECT
        C.id AS customer_id,
        count(O.id) AS orders_count
    FROM
        customer AS C
        LEFT JOIN "order" AS O ON O.customer_id = C.id
    GROUP BY
        C.id
)
SELECT
    CVC.customer_id AS customer_id,
    CVC.visits_count AS visits_count,
    COC.orders_count AS orders_count
FROM
    customer_visits_count AS CVC
    INNER JOIN customer_orders_count AS COC ON COC.customer_id = CVC.customer_id
ORDER BY
    customer_id;

-- 3.3.3 Источник трафика | Количество визитов с этим источником | Количество созданных заказов | Количество оплаченных заказов | Количество выполненных заказов
WITH utm_source_visits_count AS (
    -- Количества переходов с каждого источника трафика
    SELECT
        CV.utm_source AS utm_source,
        count(CV.id) AS utm_source_count
    FROM
        customer_visit AS CV
    GROUP BY
        utm_source
),
order_statuses_count AS (
    -- Количества созданных, оплаченных и выполненных заказов для каждого источника трафика
    SELECT
        O.utm_source AS utm_source,
        count(O.id) FILTER (
            WHERE
                S.name = 'Создан'
        ) AS created_orders_count,
        count(O.id) FILTER (
            WHERE
                O.is_paid = TRUE
        ) AS paid_orders_count,
        count(O.id) FILTER (
            WHERE
                S.name = 'Выполнен'
        ) AS completed_orders_count
    FROM
        "order" AS O
        INNER JOIN "status" AS S ON O.status_id = S.id
    GROUP BY
        utm_source
)
SELECT
    UVC.utm_source AS utm_source,
    UVC.utm_source_count AS utm_source_count,
    OSC.created_orders_count AS created_orders_count,
    OSC.paid_orders_count AS paid_orders_count,
    OSC.completed_orders_count AS completed_orders_count
FROM
    utm_source_visits_count AS UVC
    INNER JOIN order_statuses_count AS OSC ON OSC.utm_source = UVC.utm_source
ORDER BY
    UVC.utm_source;

-- 3.3.4 ID менеджера | Среднее время выполнения заказов | Доля отмененных заказов | Сумма выполненных заказов | Средняя стоимость заказа
WITH order_manager_dates AS (
    -- Даты привязки менеджеров к заказам, где менеджеры не менялись
    SELECT
        O.id AS order_id,
        O.manager_id AS manager_id,
        O.created_at AS start_date,
        CURRENT_TIMESTAMP(0) AS end_date
    FROM
        "order" AS O
        WHERE O.id NOT IN (
            SELECT OH.order_id FROM order_history AS OH
            WHERE OH.field_name = 'manager_id'
        )

    UNION

    -- Даты привязки менеджеров к заказам, где менеджеры менялись
    SELECT
        OH.order_id AS order_id,
        OH.new_value :: int AS manager_id,
        OH.created_at AS start_date,
        OH2.created_at AS end_date
    FROM
        order_history AS OH
        INNER JOIN order_history AS OH2 ON OH2.order_id = OH.order_id
        AND OH.field_name = 'manager_id'
        AND OH2.field_name = 'manager_id'
        AND OH2.old_value = OH.new_value

    UNION

    -- Даты привязки последних менеджеров к заказам
    SELECT
        O.id AS order_id,
        O.manager_id AS manager_id,
        OH.created_at AS start_date,
        CURRENT_TIMESTAMP(0) AS end_date
    FROM
        "order" AS O
        INNER JOIN order_history AS OH ON OH.order_id = O.id
        AND OH.field_name = 'manager_id'
        AND O.manager_id = OH.new_value :: int
),
order_status_dates AS (
    -- Даты изменений статусов заказов
    SELECT
        O.id AS order_id,
        OLD_S.name AS old_status,
        OH.created_at AS old_status_date,
        NEW_S.name AS new_status,
        OH2.created_at AS new_status_date
    FROM
        "order" AS O
        INNER JOIN order_history AS OH ON O.id = OH.order_id
        AND OH.field_name = 'status_id'
        INNER JOIN order_history AS OH2 ON O.id = OH2.order_id
        AND OH2.field_name = 'status_id'
        AND OH.new_value = OH2.old_value
        RIGHT JOIN "status" AS OLD_S ON OLD_S.id = OH2.old_value::int
		RIGHT JOIN "status" AS NEW_S ON NEW_S.id = OH2.new_value::int
)
SELECT
    OMD.manager_id AS manager_id,
	
    avg(OSD.new_status_date - OSD.old_status_date) FILTER (
        WHERE OSD.new_status = 'Выполнен'
    ) AS completed_orders_avg_time,
	
	(
		(count(OSD.order_id) FILTER (WHERE OSD.new_status = 'Отменен'))::float
		/
		count(OSD.order_id)::float
	) AS canceled_orders_part,
	
	sum(O.total_sum) FILTER (
		WHERE OSD.new_status = 'Выполнен'
	) AS completed_orders_total_sum,
	
	avg(O.total_sum) AS orders_total_sum
FROM
    order_manager_dates AS OMD
    INNER JOIN order_status_dates AS OSD ON OSD.order_id = OMD.order_id
	AND OMD.start_date <= OSD.new_status_date AND OSD.new_status_date <= OMD.end_date
	LEFT JOIN "order" AS O ON O.id = OMD.order_id
GROUP BY OMD.manager_id
ORDER BY OMD.manager_id

-- 3.3.4 ID менеджера | Рейтинг менеджера
-- Рейтинг считается как (Доля выполненных менеджером заказов - доля выполненных заказов в среднем) + (Среднее время выполнения заказов менеджером - Среднее время выполнения заказов итого) - (Процент отмененных менеджером заказов - Процент отмененных заказов всего)
WITH order_manager_dates AS (
    -- Даты привязки менеджеров к заказам, где менеджеры не менялись
    SELECT
        O.id AS order_id,
        O.manager_id AS manager_id,
        O.created_at AS start_date,
        CURRENT_TIMESTAMP(0) AS end_date
    FROM
        "order" AS O
        WHERE O.id NOT IN (
            SELECT OH.order_id FROM order_history AS OH
            WHERE OH.field_name = 'manager_id'
        )

    UNION

    -- Даты привязки менеджеров к заказам, где менеджеры менялись
    SELECT
        OH.order_id AS order_id,
        OH.new_value :: int AS manager_id,
        OH.created_at AS start_date,
        OH2.created_at AS end_date
    FROM
        order_history AS OH
        INNER JOIN order_history AS OH2 ON OH2.order_id = OH.order_id
        AND OH.field_name = 'manager_id'
        AND OH2.field_name = 'manager_id'
        AND OH2.old_value = OH.new_value

    UNION

    -- Даты привязки последних менеджеров к заказам
    SELECT
        O.id AS order_id,
        O.manager_id AS manager_id,
        OH.created_at AS start_date,
        CURRENT_TIMESTAMP(0) AS end_date
    FROM
        "order" AS O
        INNER JOIN order_history AS OH ON OH.order_id = O.id
        AND OH.field_name = 'manager_id'
        AND O.manager_id = OH.new_value :: int
),
order_status_dates AS (
    -- Даты изменений статусов заказов
    SELECT
        O.id AS order_id,
        OLD_S.name AS old_status,
        OH.created_at AS old_status_date,
        NEW_S.name AS new_status,
        OH2.created_at AS new_status_date
    FROM
        "order" AS O
        INNER JOIN order_history AS OH ON O.id = OH.order_id
        AND OH.field_name = 'status_id'
        INNER JOIN order_history AS OH2 ON O.id = OH2.order_id
        AND OH2.field_name = 'status_id'
        AND OH.new_value = OH2.old_value
        RIGHT JOIN "status" AS OLD_S ON OLD_S.id = OH2.old_value::int
		RIGHT JOIN "status" AS NEW_S ON NEW_S.id = OH2.new_value::int
),
completed_orders_part AS (
    -- Часть выполненных заказов от всех заказов
	SELECT 
	(
		(count(O.id) FILTER (WHERE O.status_id IN (SELECT id FROM "status" WHERE name = 'Выполнен')))::float
		/
		count(O.id)::float
	) AS value
	FROM "order" AS O
),
completed_orders_avg_time AS (
    -- Время среднего выполнения заказов
	SELECT avg(OSD.new_status_date - OSD.old_status_date) AS value
	FROM order_status_dates AS OSD
	WHERE OSD.new_status = 'Выполнен'
),
canceled_orders_percent AS (
    -- Процент отмененных заказов от всех заказов
	SELECT 
		((
			(count(OSD.order_id) FILTER (WHERE OSD.new_status = 'Отменен'))::float
			/
			count(OSD.order_id)::float
		) * 100) AS value
	FROM order_status_dates AS OSD
)
SELECT
    OMD.manager_id AS manager_id,
	(
		-- (Доля выполненных менеджером заказов - доля выполненных заказов в среднем) 
		(
			(count(OSD.order_id) FILTER (WHERE OSD.new_status = 'Выполнен'))::float
			/
			count(OSD.order_id)::float
		)
		- (SELECT value FROM completed_orders_part)
		
		-- + (Среднее время выполнения заказов менеджером - Среднее время выполнения заказов итого)
		+ extract(hours 
			FROM avg(OSD.new_status_date - OSD.old_status_date) FILTER (
        		WHERE OSD.new_status = 'Выполнен'
    		)
		  )
		- extract(hours 
			FROM (SELECT value FROM completed_orders_avg_time)
		)
		
		-- - (Процент отмененных менеджером заказов - Процент отмененных заказов всего)
		- (
			(
				(count(OSD.order_id) FILTER (WHERE OSD.new_status = 'Отменен'))::float
				/
				count(OSD.order_id)::float
			) * 100
		)
		+ (SELECT value FROM canceled_orders_percent)
	) AS raiting
FROM
    order_manager_dates AS OMD
    INNER JOIN order_status_dates AS OSD ON OSD.order_id = OMD.order_id
	AND OMD.start_date <= OSD.new_status_date AND OSD.new_status_date <= OMD.end_date
	LEFT JOIN "order" AS O ON O.id = OMD.order_id
GROUP BY OMD.manager_id
ORDER BY OMD.manager_id
