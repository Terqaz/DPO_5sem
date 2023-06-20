CREATE TYPE public.some_enum AS ENUM ('option1', 'option2');

CREATE TYPE public.some_type AS
(
	a integer,
	b character varying(32)
);

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE IF NOT EXISTS public.task2 (
    bigint_col bigint NOT NULL,
    smallint_col smallint NOT NULL,
    numeric_col numeric NOT NULL,
    real_col real NOT NULL,
    double_col double precision NOT NULL,
    boolean_col boolean NOT NULL,
    var_char_col character varying(32) COLLATE pg_catalog."default" NOT NULL,
    char_col character(32) COLLATE pg_catalog."default" NOT NULL,
    text_col text COLLATE pg_catalog."default" NOT NULL,
    date_col date NOT NULL,
    time_timezone_col time WITH time zone NOT NULL,
    time_col time without time zone NOT NULL,
    timestamp_timezone_col timestamp WITH time zone NOT NULL,
    timestamp_col timestamp without time zone NOT NULL,
    enum_col some_enum NOT NULL,
    money_col money NOT NULL,
    bytea_col bytea NOT NULL,
    int_array_col integer [] NOT NULL,
    point_col point NOT NULL,
    line_col line NOT NULL,
    json_col json NOT NULL,
    xml_col xml NOT NULL,
    uuid_col uuid NOT NULL DEFAULT uuid_generate_v4(),
    var_bit_col bit varying(32) NOT NULL,
    composite_col some_type NOT NULL
);