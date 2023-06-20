INSERT INTO
    public.customer(
        id,
        created_at,
        first_name,
        last_name,
        phone,
        email
    )
SELECT 
    s.id,  -- id

    timestamp '2010-01-10 20:00:00' + CONCAT(s.id::text, ' hours')::interval, -- created_at

    substring(md5(random()::text) from 0 for 16), -- first_name

    substring(md5(random()::text) from 0 for 16), -- last_name

    concat('+', floor(random() * pow(10, 11) + pow(10, 10))::text), -- phone

    concat(
        substring(md5(random()::text) from 0 for 16), 
        '@', 
        substring(md5(random()::text) from 0 for 8),
        '.',
        substring(md5(random()::text) from 0 for 4)
    ) -- email
FROM generate_series(1, 10000) AS s(id)
ORDER BY s.id;

INSERT INTO public.customer_visit (
    customer_id,
    created_at,
    visit_length,
    landing_page,
    exit_page,
    geo_tag,
    utm_source,
    utm_data
)
SELECT 
    floor(random() * 10000 + 1)::int, -- customer_id

    timestamp '2021-01-10 20:00:00' 
    + random() * (
        timestamp '2023-01-20 20:00:00' 
        - timestamp '2021-01-10 10:00:00'
    ), -- created_at
	
    floor(random() * 100 + 1)::int, -- visit_length

    concat(
        'https://',
        substring(md5(random()::text) from 0 for 8),
        '.',
        substring(md5(random()::text) from 0 for 3),
		'/',
        (
            SELECT string_agg(substring(md5(random()::text) from 0 for 8), '/')
            FROM generate_series(
                1,
                floor((random() + s.id / 10000) * 10 + 2)::int
            ) AS s2(id)
        )
    ), -- landing_page

    concat(
        'https://',
        substring(md5(random()::text) from 0 for 8),
        '.',
        substring(md5(random()::text) from 0 for 4),
		'/',
        (
            SELECT string_agg(substring(md5(random()::text) from 0 for 8), '/')
            FROM generate_series(
                1,
                floor((random() + s.id / 10000) * 10 + 2)::int
            ) AS s2(id)
        )
    ), -- exit_page

    CIRCLE( POINT( random() * 2 + 50 , random() * 2 + 50 ) , random() * 1000 ), -- geo_tag

    substring(md5(random()::text) from 0 for 2), -- utm_source

    jsonb_build_object(
      'error', (CASE WHEN random() > 0.2 THEN FALSE ELSE TRUE END),
      'data', substring(md5(random()::text) from 0 for 16)
    ) -- utm_data
FROM 
    generate_series(1, 10000) AS s(id)
ORDER BY s.id;
