-- bigint_col
SELECT bigint_col FROM task2
WHERE bigint_col > 0;

-- smallint_col
SELECT smallint_col FROM task2
WHERE smallint_col < 30000;

-- numeric_col
SELECT numeric_col FROM task2
WHERE numeric_col < 23535232.2;

-- real_col
SELECT real_col FROM task2
WHERE real_col > -2354.2565;

-- double_col
SELECT double_col FROM task2
WHERE double_col < 2387.83274184;

-- boolean_col
SELECT boolean_col FROM task2
WHERE boolean_col = true;

-- var_char_col
SELECT var_char_col FROM task2
WHERE var_char_col LIKE '%t%';

-- char_col
SELECT char_col FROM task2
WHERE char_col LIKE '%0123456789%';

-- text_col
SELECT text_col FROM task2
WHERE text_col LIKE 'The%';

-- date_col
SELECT date_col FROM task2
WHERE extract(year from date_col) > 2000;

-- time_timezone_col
SELECT time_timezone_col FROM task2
WHERE extract(hour from time_timezone_col) > 1;

-- time_col
SELECT time_col FROM task2
WHERE extract(minute from time_col) < 10;

-- timestamp_timezone_col
SELECT timestamp_timezone_col FROM task2
WHERE extract(timezone_hour from timestamp_timezone_col) < 2;

-- timestamp_col
SELECT timestamp_col FROM task2
WHERE extract(second from timestamp_col) < 15;

-- enum_col
SELECT enum_col FROM task2
WHERE enum_col = 'option1';

-- money_col
SELECT money_col FROM task2
WHERE money_col::numeric::float > 10.1;

-- bytea_col
SELECT bytea_col FROM task2
WHERE bytea_col = '\x123456';

-- int_array_col
SELECT int_array_col FROM task2
WHERE 1234 = ANY (int_array_col);

-- point_col
SELECT point_col FROM task2
WHERE point_col >> point '(0, 145.622)';

-- line_col
SELECT line_col FROM task2
WHERE (point '(10, 4000)' <-> line_col) < 10000.0;

-- json_col
SELECT json_col FROM task2
WHERE json_array_length(json_col #> '{b,c}') < 3;

-- xml_col
SELECT xml_col FROM task2
WHERE xpath_exists('/foo/foo2/text()', xml_col);

-- uuid_col
SELECT uuid_col FROM task2
WHERE uuid_col = '15b1074a-cb2b-4c9f-9dcb-3be7f496970a';

-- var_bit_col
SELECT var_bit_col FROM task2
WHERE octet_length(var_bit_col) > 1;

-- composite_col
SELECT (composite_col).a FROM task2
WHERE (composite_col).b = 'abcd2352';
