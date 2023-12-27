--
-- PostgreSQL database dump
--

-- Dumped from database version 16.0 (Debian 16.0-1.pgdg120+1)
-- Dumped by pg_dump version 16.0 (Debian 16.0-1.pgdg120+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: accept_pack_trigger_function(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.accept_pack_trigger_function() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
v_staff_id INTEGER;
BEGIN
SELECT "warehouseStaff" INTO v_staff_id
    FROM pack
    WHERE "warehouseStaff" = NEW."warehouseStaff";
  INSERT INTO log (detail, time)
  VALUES (
'Yeni kargo eklendi. Görevli ID: ' || v_staff_id,
    CURRENT_TIMESTAMP
  );
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.accept_pack_trigger_function() OWNER TO postgres;

--
-- Name: calculate_total_cost(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.calculate_total_cost() RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
    total_cost NUMERIC := 0;
BEGIN
    SELECT SUM(cost) INTO total_cost
    FROM receipt;

    RETURN total_cost;
END;
$$;


ALTER FUNCTION public.calculate_total_cost() OWNER TO postgres;

--
-- Name: create_receipt(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.create_receipt(pack_id_param integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    pack_cost MONEY;
    pack_payment_type INTEGER;
BEGIN
    SELECT cost, "paymentType" INTO pack_cost, pack_payment_type
    FROM pack
    WHERE id = pack_id_param;


    INSERT INTO receipt (pack, cost, "paymentType", time)
    VALUES (pack_id_param, pack_cost, pack_payment_type, CURRENT_TIMESTAMP);
END;
$$;


ALTER FUNCTION public.create_receipt(pack_id_param integer) OWNER TO postgres;

--
-- Name: delete_pack_trigger_function(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.delete_pack_trigger_function() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
v_staff_id INTEGER;
BEGIN
SELECT "warehouseStaff" INTO v_staff_id
    FROM pack
    WHERE "warehouseStaff" = OLD."warehouseStaff";
  INSERT INTO log (detail, time)
  VALUES (
'Kargo silindi. Görevli ID: ' || v_staff_id,
    CURRENT_TIMESTAMP
  );
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.delete_pack_trigger_function() OWNER TO postgres;

--
-- Name: score_changed_trigger_function(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.score_changed_trigger_function() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE 
    score_new INTEGER;
BEGIN
    IF OLD.score = 0 THEN
        SELECT score INTO score_new FROM courier WHERE NEW.courier = courier.id;
        score_new := score_new + NEW.score;
        UPDATE courier SET score = score_new WHERE id = NEW.courier;
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.score_changed_trigger_function() OWNER TO postgres;

--
-- Name: update_entered_pack_and_score(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_entered_pack_and_score() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE "warehouseStaff"
    SET "enteredPack" = "enteredPack" + 1
    WHERE id = NEW."warehouseStaff";

    UPDATE "warehouseStaff"
    SET score = score + (NEW.mass * 1.3)
    WHERE id = NEW."warehouseStaff";

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_entered_pack_and_score() OWNER TO postgres;

--
-- Name: update_pack_cost(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_pack_cost(id integer, mass integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    index INTEGER;
	costNew INTEGER;
BEGIN
    index := id;
    IF mass <= 10 THEN
        costNew = mass * 2.5;
    ELSIF mass > 10 AND mass <= 50 THEN
         costNew = mass * 2.75;
    ELSIF mass > 50 AND mass <= 100 THEN
         costNew = mass * 3.10;
    ELSE
         costNew = mass * 3.5;
    END IF;
	
	UPDATE pack SET cost = costNew WHERE pack.id = index;
END;
$$;


ALTER FUNCTION public.update_pack_cost(id integer, mass integer) OWNER TO postgres;

--
-- Name: update_pack_status_courier(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_pack_status_courier(kargo_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    current_time TIMESTAMP := CURRENT_TIMESTAMP;
BEGIN
    UPDATE pack
    SET status = 4, courier = 0
    WHERE id = kargo_id;

    INSERT INTO log (detail, time)
    VALUES ('Kargo depoya döndü. Kargo ID: ' || kargo_id, CURRENT_TIMESTAMP);
END;
$$;


ALTER FUNCTION public.update_pack_status_courier(kargo_id integer) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: address; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.address (
    id integer NOT NULL,
    city integer,
    district integer,
    detail character varying,
    area integer NOT NULL,
    person integer
);


ALTER TABLE public.address OWNER TO postgres;

--
-- Name: address_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.address_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.address_id_seq OWNER TO postgres;

--
-- Name: address_id_seq1; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.address_id_seq1
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.address_id_seq1 OWNER TO postgres;

--
-- Name: address_id_seq1; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.address_id_seq1 OWNED BY public.address.id;


--
-- Name: area; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.area (
    id integer NOT NULL,
    city integer NOT NULL,
    district integer NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE public.area OWNER TO postgres;

--
-- Name: area_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.area_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.area_id_seq OWNER TO postgres;

--
-- Name: area_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.area_id_seq OWNED BY public.area.id;


--
-- Name: city; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.city (
    id integer NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE public.city OWNER TO postgres;

--
-- Name: city_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.city_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.city_id_seq OWNER TO postgres;

--
-- Name: city_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.city_id_seq OWNED BY public.city.id;


--
-- Name: courier; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.courier (
    id integer NOT NULL,
    score double precision,
    "deliveredPack" integer
);


ALTER TABLE public.courier OWNER TO postgres;

--
-- Name: customer; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customer (
    id integer NOT NULL,
    priority integer NOT NULL
);


ALTER TABLE public.customer OWNER TO postgres;

--
-- Name: district; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.district (
    id integer NOT NULL,
    name character varying NOT NULL,
    city integer
);


ALTER TABLE public.district OWNER TO postgres;

--
-- Name: district_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.district_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.district_id_seq OWNER TO postgres;

--
-- Name: district_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.district_id_seq OWNED BY public.district.id;


--
-- Name: log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.log (
    id integer NOT NULL,
    detail character varying NOT NULL,
    "time" timestamp without time zone NOT NULL
);


ALTER TABLE public.log OWNER TO postgres;

--
-- Name: log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.log_id_seq OWNER TO postgres;

--
-- Name: log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.log_id_seq OWNED BY public.log.id;


--
-- Name: pack; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pack (
    id integer NOT NULL,
    address integer,
    customer integer NOT NULL,
    "warehouseStaff" integer NOT NULL,
    courier integer,
    cost money NOT NULL,
    "paymentType" integer NOT NULL,
    status integer NOT NULL,
    receipt integer,
    mass double precision,
    score integer
);


ALTER TABLE public.pack OWNER TO postgres;

--
-- Name: pack_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pack_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pack_id_seq OWNER TO postgres;

--
-- Name: pack_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pack_id_seq OWNED BY public.pack.id;


--
-- Name: paymentType; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."paymentType" (
    id integer NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE public."paymentType" OWNER TO postgres;

--
-- Name: paymentType_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."paymentType_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."paymentType_id_seq" OWNER TO postgres;

--
-- Name: paymentType_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."paymentType_id_seq" OWNED BY public."paymentType".id;


--
-- Name: person; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.person (
    id integer NOT NULL,
    surname character varying NOT NULL,
    tckn integer NOT NULL,
    phone integer,
    address smallint,
    role integer,
    name character varying
);


ALTER TABLE public.person OWNER TO postgres;

--
-- Name: person_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.person_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.person_id_seq OWNER TO postgres;

--
-- Name: person_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.person_id_seq OWNED BY public.person.id;


--
-- Name: receipt; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.receipt (
    id integer NOT NULL,
    cost money NOT NULL,
    "paymentType" integer NOT NULL,
    "time" timestamp without time zone NOT NULL,
    pack integer
);


ALTER TABLE public.receipt OWNER TO postgres;

--
-- Name: receipt_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.receipt_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.receipt_id_seq OWNER TO postgres;

--
-- Name: receipt_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.receipt_id_seq OWNED BY public.receipt.id;


--
-- Name: role; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.role (
    id integer NOT NULL,
    name character varying
);


ALTER TABLE public.role OWNER TO postgres;

--
-- Name: role_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.role_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.role_id_seq OWNER TO postgres;

--
-- Name: role_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.role_id_seq OWNED BY public.role.id;


--
-- Name: status; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.status (
    id integer NOT NULL,
    name character varying
);


ALTER TABLE public.status OWNER TO postgres;

--
-- Name: status_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.status_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.status_id_seq OWNER TO postgres;

--
-- Name: status_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.status_id_seq OWNED BY public.status.id;


--
-- Name: warehouse; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.warehouse (
    id integer NOT NULL,
    address integer NOT NULL
);


ALTER TABLE public.warehouse OWNER TO postgres;

--
-- Name: wareHouse_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."wareHouse_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."wareHouse_id_seq" OWNER TO postgres;

--
-- Name: wareHouse_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."wareHouse_id_seq" OWNED BY public.warehouse.id;


--
-- Name: warehouseStaff; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."warehouseStaff" (
    id integer NOT NULL,
    score double precision,
    "enteredPack" integer,
    warehouse integer
);


ALTER TABLE public."warehouseStaff" OWNER TO postgres;

--
-- Name: address id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.address ALTER COLUMN id SET DEFAULT nextval('public.address_id_seq1'::regclass);


--
-- Name: area id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.area ALTER COLUMN id SET DEFAULT nextval('public.area_id_seq'::regclass);


--
-- Name: city id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.city ALTER COLUMN id SET DEFAULT nextval('public.city_id_seq'::regclass);


--
-- Name: district id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.district ALTER COLUMN id SET DEFAULT nextval('public.district_id_seq'::regclass);


--
-- Name: log id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.log ALTER COLUMN id SET DEFAULT nextval('public.log_id_seq'::regclass);


--
-- Name: pack id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pack ALTER COLUMN id SET DEFAULT nextval('public.pack_id_seq'::regclass);


--
-- Name: paymentType id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."paymentType" ALTER COLUMN id SET DEFAULT nextval('public."paymentType_id_seq"'::regclass);


--
-- Name: person id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.person ALTER COLUMN id SET DEFAULT nextval('public.person_id_seq'::regclass);


--
-- Name: receipt id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.receipt ALTER COLUMN id SET DEFAULT nextval('public.receipt_id_seq'::regclass);


--
-- Name: role id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role ALTER COLUMN id SET DEFAULT nextval('public.role_id_seq'::regclass);


--
-- Name: status id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.status ALTER COLUMN id SET DEFAULT nextval('public.status_id_seq'::regclass);


--
-- Name: warehouse id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.warehouse ALTER COLUMN id SET DEFAULT nextval('public."wareHouse_id_seq"'::regclass);


--
-- Data for Name: address; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.address (id, city, district, detail, area, person) FROM stdin;
2	55	102	gül sk	72	\N
3	52	97	yildiz sk	78	\N
4	55	102	mert sk	71	\N
5	55	102	yildiz sk	77	\N
6	52	103	okul sk	80	94
0	0	0	0	0	\N
7	52	98	havuz sk	81	95
8	52	103	ada sk	82	96
9	53	104	anit sk	83	96
10	57	105	petek sk	84	97
11	56	100	cicek sk	85	98
12	52	103	404 sk	86	105
13	53	106	500 sk	87	106
14	59	107	gul sk	88	97
15	60	108	yildiz sk	89	107
16	61	109	404 sk	90	107
\.


--
-- Data for Name: area; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.area (id, city, district, name) FROM stdin;
71	55	102	arabacialani
72	52	97	inonu
77	55	102	kemalpasa
78	52	97	cinar
79	52	97	yildiztepe
80	52	103	gunesli
0	0	0	0
81	52	98	soganli
82	52	103	evren
83	53	104	yildiz
84	57	105	evren
85	56	100	bayrampasa
86	52	103	inonu
87	53	106	yildiz
88	59	107	cumhuriyet
89	60	108	mert
90	61	109	cem sk
\.


--
-- Data for Name: city; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.city (id, name) FROM stdin;
52	istanbul
53	ankara
54	izmir
55	sakarya
56	bayburt
0	0
57	samsun
58	karaman
59	isparta
60	balikesir
61	bitlis
\.


--
-- Data for Name: courier; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.courier (id, score, "deliveredPack") FROM stdin;
93	355	34
100	25	1
\.


--
-- Data for Name: customer; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.customer (id, priority) FROM stdin;
94	1
95	3
96	2
97	5
98	1
99	1
105	2
106	1
107	1
\.


--
-- Data for Name: district; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.district (id, name, city) FROM stdin;
97	bağcılar	52
98	bahcelievler	52
99	esenler	52
100	demirozu	56
101	karsiyaka	54
102	serdivan	55
103	bagcilar	52
0	0	0
104	kazan	53
105	carsamba	57
106	kecioren	53
107	bahcelievler	59
108	bayrampasa	60
109	minare	61
\.


--
-- Data for Name: log; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.log (id, detail, "time") FROM stdin;
31	Yeni kargo eklendi. Görevli ID: 91	2023-12-23 12:23:46.604835
32	Yeni kargo eklendi. Görevli ID: 91	2023-12-23 14:17:35.210374
33	Kargo silindi. Görevli ID: 91	2023-12-23 14:19:36.473861
34	Yeni kargo eklendi. Görevli ID: 91	2023-12-23 15:18:51.143127
35	Yeni kargo eklendi. Görevli ID: 91	2023-12-23 15:22:26.22889
36	Kargo depoya döndü. Kargo ID: 54	2023-12-23 15:23:37.714944
37	Yeni kargo eklendi. Görevli ID: 91	2023-12-24 23:19:14.03354
38	Yeni kargo eklendi. Görevli ID: 91	2023-12-24 23:20:54.909862
39	Yeni kargo eklendi. Görevli ID: 91	2023-12-24 23:22:30.6386
40	Yeni kargo eklendi. Görevli ID: 91	2023-12-25 20:26:55.515773
41	Yeni kargo eklendi. Görevli ID: 91	2023-12-25 20:38:27.689767
42	Kargo silindi. Görevli ID: 91	2023-12-25 22:24:31.363902
43	Yeni kargo eklendi. Görevli ID: 91	2023-12-26 05:59:51.096651
\.


--
-- Data for Name: pack; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pack (id, address, customer, "warehouseStaff", courier, cost, "paymentType", status, receipt, mass, score) FROM stdin;
51	8	96	91	93	$94.00	3	1	0	34	250
53	10	97	91	93	$52.00	2	1	0	19	99999
54	11	98	91	0	$39.00	1	4	0	14	0
55	12	105	91	0	$33.00	1	4	0	12	0
56	12	106	91	0	$30.00	1	4	0	11	0
57	13	106	91	93	$110.00	1	1	0	40	10
58	14	97	91	100	$33.00	3	1	0	12	25
60	16	107	91	93	$39.00	2	3	0	14	0
\.


--
-- Data for Name: paymentType; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."paymentType" (id, name) FROM stdin;
1	cash
2	debit
3	paid
0	0
\.


--
-- Data for Name: person; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.person (id, surname, tckn, phone, address, role, name) FROM stdin;
91	tayfur	1111	5555555	\N	4	hasan
92	yılmaz	1112	5555555	\N	4	mert
93	kaya	2222	5555555	\N	2	ali
94	usta	3232	5555555	0	3	melih
95	ucuran	5367	55555	0	3	ismail
96	kurt	6264	5555	0	3	veli
97	kara	4545	555555	0	3	süleyman
98	sert	7777	555555	0	3	mehmet
99	kerem	1234	555555	0	3	hasan
100	polat	9999	555555	0	2	ramazan
102	yildiz	7898	55555	0	4	bekir
104	gul	4456	55555	0	4	mert
105	dilli	3454	555555	0	3	ilayda
106	tayfur	2222	55555	0	3	engin
107	yildiz	9999	55555	0	3	melih
\.


--
-- Data for Name: receipt; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.receipt (id, cost, "paymentType", "time", pack) FROM stdin;
0	$0.00	0	2023-12-23 15:23:07	\N
5	$94.00	3	2023-12-23 13:09:13.147417	51
6	$94.00	3	2023-12-23 15:17:10.612268	51
8	$52.00	2	2023-12-23 15:19:37.658799	53
9	$94.00	3	2023-12-23 15:20:51.442137	51
10	$52.00	2	2023-12-23 15:21:26.420484	53
11	$110.00	1	2023-12-24 23:25:28.602886	57
12	$33.00	3	2023-12-25 20:43:16.700985	58
\.


--
-- Data for Name: role; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.role (id, name) FROM stdin;
2	courier
3	customer
4	warehouseStaff
\.


--
-- Data for Name: status; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.status (id, name) FROM stdin;
1	delivered
2	canceled
3	on road
4	accepted
\.


--
-- Data for Name: warehouse; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.warehouse (id, address) FROM stdin;
2	2
3	4
\.


--
-- Data for Name: warehouseStaff; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."warehouseStaff" (id, score, "enteredPack", warehouse) FROM stdin;
92	643	22	3
102	0	0	2
104	0	0	3
91	516	371	2
\.


--
-- Name: address_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.address_id_seq', 1, false);


--
-- Name: address_id_seq1; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.address_id_seq1', 16, true);


--
-- Name: area_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.area_id_seq', 90, true);


--
-- Name: city_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.city_id_seq', 61, true);


--
-- Name: district_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.district_id_seq', 109, true);


--
-- Name: log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.log_id_seq', 43, true);


--
-- Name: pack_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pack_id_seq', 60, true);


--
-- Name: paymentType_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."paymentType_id_seq"', 3, true);


--
-- Name: person_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.person_id_seq', 107, true);


--
-- Name: receipt_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.receipt_id_seq', 12, true);


--
-- Name: role_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.role_id_seq', 4, true);


--
-- Name: status_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.status_id_seq', 4, true);


--
-- Name: wareHouse_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."wareHouse_id_seq"', 3, true);


--
-- Name: address address_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.address
    ADD CONSTRAINT address_pk PRIMARY KEY (id);


--
-- Name: area area_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.area
    ADD CONSTRAINT area_pk PRIMARY KEY (id);


--
-- Name: city city_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.city
    ADD CONSTRAINT city_pk PRIMARY KEY (id);


--
-- Name: courier courier_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.courier
    ADD CONSTRAINT courier_pk PRIMARY KEY (id);


--
-- Name: customer customer_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer
    ADD CONSTRAINT customer_pk PRIMARY KEY (id);


--
-- Name: district district_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.district
    ADD CONSTRAINT district_pk PRIMARY KEY (id);


--
-- Name: log log_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.log
    ADD CONSTRAINT log_pk PRIMARY KEY (id);


--
-- Name: pack pack_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pack
    ADD CONSTRAINT pack_pk PRIMARY KEY (id);


--
-- Name: paymentType paymentType_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."paymentType"
    ADD CONSTRAINT "paymentType_pk" PRIMARY KEY (id);


--
-- Name: person person_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.person
    ADD CONSTRAINT person_pk UNIQUE (id);


--
-- Name: person person_pk2; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.person
    ADD CONSTRAINT person_pk2 PRIMARY KEY (id);


--
-- Name: receipt receipt_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.receipt
    ADD CONSTRAINT receipt_pk PRIMARY KEY (id);


--
-- Name: role role_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role
    ADD CONSTRAINT role_pk PRIMARY KEY (id);


--
-- Name: status status_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.status
    ADD CONSTRAINT status_pk PRIMARY KEY (id);


--
-- Name: warehouse wareHouse_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.warehouse
    ADD CONSTRAINT "wareHouse_pk" PRIMARY KEY (id);


--
-- Name: warehouseStaff warehouseStaff_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."warehouseStaff"
    ADD CONSTRAINT "warehouseStaff_pk" PRIMARY KEY (id);


--
-- Name: pack accept_pack_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER accept_pack_trigger AFTER INSERT ON public.pack FOR EACH ROW EXECUTE FUNCTION public.accept_pack_trigger_function();


--
-- Name: pack delete_pack_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER delete_pack_trigger AFTER DELETE ON public.pack FOR EACH ROW EXECUTE FUNCTION public.delete_pack_trigger_function();


--
-- Name: pack score_changed_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER score_changed_trigger AFTER UPDATE OF score ON public.pack FOR EACH ROW WHEN ((old.score IS DISTINCT FROM new.score)) EXECUTE FUNCTION public.score_changed_trigger_function();


--
-- Name: pack update_entered_pack_and_score_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_entered_pack_and_score_trigger AFTER INSERT ON public.pack FOR EACH ROW EXECUTE FUNCTION public.update_entered_pack_and_score();


--
-- Name: address address_area_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.address
    ADD CONSTRAINT address_area_id_fk FOREIGN KEY (area) REFERENCES public.area(id);


--
-- Name: address address_city_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.address
    ADD CONSTRAINT address_city_id_fk FOREIGN KEY (city) REFERENCES public.city(id);


--
-- Name: address address_district_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.address
    ADD CONSTRAINT address_district_id_fk FOREIGN KEY (district) REFERENCES public.district(id);


--
-- Name: address address_person_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.address
    ADD CONSTRAINT address_person_id_fk FOREIGN KEY (person) REFERENCES public.person(id);


--
-- Name: area area_city_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.area
    ADD CONSTRAINT area_city_id_fk FOREIGN KEY (city) REFERENCES public.city(id);


--
-- Name: area area_district_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.area
    ADD CONSTRAINT area_district_id_fk FOREIGN KEY (district) REFERENCES public.district(id);


--
-- Name: district district_city_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.district
    ADD CONSTRAINT district_city_id_fk FOREIGN KEY (city) REFERENCES public.city(id);


--
-- Name: pack pack_customer_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pack
    ADD CONSTRAINT pack_customer_id_fk FOREIGN KEY (customer) REFERENCES public.customer(id);


--
-- Name: pack pack_paymentType_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pack
    ADD CONSTRAINT "pack_paymentType_id_fk" FOREIGN KEY ("paymentType") REFERENCES public."paymentType"(id);


--
-- Name: pack pack_receipt_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pack
    ADD CONSTRAINT pack_receipt_id_fk FOREIGN KEY (receipt) REFERENCES public.receipt(id);


--
-- Name: pack pack_status_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pack
    ADD CONSTRAINT pack_status_id_fk FOREIGN KEY (status) REFERENCES public.status(id);


--
-- Name: pack pack_warehouseStaff_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pack
    ADD CONSTRAINT "pack_warehouseStaff_id_fk" FOREIGN KEY ("warehouseStaff") REFERENCES public."warehouseStaff"(id);


--
-- Name: courier peopleCourier; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.courier
    ADD CONSTRAINT "peopleCourier" FOREIGN KEY (id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: customer peopleCustomer; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer
    ADD CONSTRAINT "peopleCustomer" FOREIGN KEY (id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: person person_role_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.person
    ADD CONSTRAINT person_role_id_fk FOREIGN KEY (role) REFERENCES public.role(id);


--
-- Name: receipt receipt_pack_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.receipt
    ADD CONSTRAINT receipt_pack_id_fk FOREIGN KEY (pack) REFERENCES public.pack(id);


--
-- Name: receipt receipt_paymentType_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.receipt
    ADD CONSTRAINT "receipt_paymentType_id_fk" FOREIGN KEY ("paymentType") REFERENCES public."paymentType"(id);


--
-- Name: warehouseStaff warehouseStaff_warehouse_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."warehouseStaff"
    ADD CONSTRAINT "warehouseStaff_warehouse_id_fk" FOREIGN KEY (warehouse) REFERENCES public.warehouse(id);


--
-- PostgreSQL database dump complete
--

