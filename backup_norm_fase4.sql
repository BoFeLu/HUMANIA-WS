--
-- PostgreSQL database dump
--

\restrict HLH8OajrfFBGUKkVuOaei11h7oaEMUgWMg3nAt0VBXOzazO8lv1hAC00cj6dAkj

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: norm; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA norm;


ALTER SCHEMA norm OWNER TO postgres;

--
-- Name: f_nodo_calculator_alpha(numeric, numeric); Type: FUNCTION; Schema: norm; Owner: uh_core
--

CREATE FUNCTION norm.f_nodo_calculator_alpha(base numeric, exponente numeric) RETURNS TABLE(resultado numeric, mensaje text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Validaci¢n de seguridad: evitar desbordamiento o bucles
    IF exponente > 1000 THEN
        RETURN QUERY SELECT 0::NUMERIC, 'ALERTA: Exponente demasiado alto. Riesgo de bloqueo.'::TEXT;
    ELSE
        RETURN QUERY SELECT (base ^ exponente)::NUMERIC, 'C lculo ejecutado exitosamente por CALCULATOR_ALPHA'::TEXT;
    END IF;
END;
$$;


ALTER FUNCTION norm.f_nodo_calculator_alpha(base numeric, exponente numeric) OWNER TO uh_core;

--
-- Name: fn_prevent_recursion(); Type: FUNCTION; Schema: norm; Owner: uh_core
--

CREATE FUNCTION norm.fn_prevent_recursion() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Bloqueo espec¡fico para el patr¢n de error de la L¡nea 7
    IF NEW.estatus_reparacion ILIKE '%RECURSIVE%' OR NEW.estatus_reparacion ILIKE '%L7%' THEN
        RAISE EXCEPTION 'ALERTA DE EMERGENCIA: Intento de recursividad detectado. Bloqueando transacci¢n.';
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION norm.fn_prevent_recursion() OWNER TO uh_core;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: constitucion; Type: TABLE; Schema: norm; Owner: postgres
--

CREATE TABLE norm.constitucion (
    id integer NOT NULL,
    seccion character varying(100) NOT NULL,
    contenido text NOT NULL,
    version integer DEFAULT 1,
    ts_carga timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE norm.constitucion OWNER TO postgres;

--
-- Name: constitucion_id_seq; Type: SEQUENCE; Schema: norm; Owner: postgres
--

CREATE SEQUENCE norm.constitucion_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE norm.constitucion_id_seq OWNER TO postgres;

--
-- Name: constitucion_id_seq; Type: SEQUENCE OWNED BY; Schema: norm; Owner: postgres
--

ALTER SEQUENCE norm.constitucion_id_seq OWNED BY norm.constitucion.id;


--
-- Name: integridad; Type: TABLE; Schema: norm; Owner: uh_core
--

CREATE TABLE norm.integridad (
    id_registro integer NOT NULL,
    timestamp_verificacion timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    estado_hash character varying(255) NOT NULL,
    estatus_reparacion text,
    version_core character varying(10) DEFAULT '2.0.1'::character varying
);


ALTER TABLE norm.integridad OWNER TO uh_core;

--
-- Name: integridad_id_registro_seq; Type: SEQUENCE; Schema: norm; Owner: uh_core
--

CREATE SEQUENCE norm.integridad_id_registro_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE norm.integridad_id_registro_seq OWNER TO uh_core;

--
-- Name: integridad_id_registro_seq; Type: SEQUENCE OWNED BY; Schema: norm; Owner: uh_core
--

ALTER SEQUENCE norm.integridad_id_registro_seq OWNED BY norm.integridad.id_registro;


--
-- Name: metadatos_archivos; Type: TABLE; Schema: norm; Owner: uh_core
--

CREATE TABLE norm.metadatos_archivos (
    id_archivo integer NOT NULL,
    nombre_archivo character varying(255) NOT NULL,
    ruta_local text NOT NULL,
    tamano_kb numeric DEFAULT 0,
    id_nodo_origen integer,
    CONSTRAINT chk_ruta_segura CHECK ((ruta_local ~~ 'C:\HUMANIA\%'::text))
);


ALTER TABLE norm.metadatos_archivos OWNER TO uh_core;

--
-- Name: metadatos_archivos_id_archivo_seq; Type: SEQUENCE; Schema: norm; Owner: uh_core
--

CREATE SEQUENCE norm.metadatos_archivos_id_archivo_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE norm.metadatos_archivos_id_archivo_seq OWNER TO uh_core;

--
-- Name: metadatos_archivos_id_archivo_seq; Type: SEQUENCE OWNED BY; Schema: norm; Owner: uh_core
--

ALTER SEQUENCE norm.metadatos_archivos_id_archivo_seq OWNED BY norm.metadatos_archivos.id_archivo;


--
-- Name: nodos_core; Type: TABLE; Schema: norm; Owner: uh_core
--

CREATE TABLE norm.nodos_core (
    id_nodo uuid DEFAULT gen_random_uuid() NOT NULL,
    nombre_modulo character varying(100),
    referencia_lanzador boolean DEFAULT true,
    logica_activa boolean DEFAULT true,
    CONSTRAINT chk_no_recursivity CHECK (((nombre_modulo)::text <> 'RECURSIVE_CALL_L7'::text))
);


ALTER TABLE norm.nodos_core OWNER TO uh_core;

--
-- Name: nodos_operativos; Type: TABLE; Schema: norm; Owner: uh_core
--

CREATE TABLE norm.nodos_operativos (
    id_nodo integer NOT NULL,
    nombre_nodo character varying(50) NOT NULL,
    descripcion text,
    estado_actividad boolean DEFAULT true,
    ultima_llamada timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    nivel_prioridad integer DEFAULT 1
);


ALTER TABLE norm.nodos_operativos OWNER TO uh_core;

--
-- Name: nodos_operativos_id_nodo_seq; Type: SEQUENCE; Schema: norm; Owner: uh_core
--

CREATE SEQUENCE norm.nodos_operativos_id_nodo_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE norm.nodos_operativos_id_nodo_seq OWNER TO uh_core;

--
-- Name: nodos_operativos_id_nodo_seq; Type: SEQUENCE OWNED BY; Schema: norm; Owner: uh_core
--

ALTER SEQUENCE norm.nodos_operativos_id_nodo_seq OWNED BY norm.nodos_operativos.id_nodo;


--
-- Name: v_estado_sistema; Type: VIEW; Schema: norm; Owner: uh_core
--

CREATE VIEW norm.v_estado_sistema AS
 SELECT
        CASE
            WHEN ((estado_hash)::text = 'ACK_N2_INTEGRITY_CONFIRMED'::text) THEN 'SISTEMA SEGURO [VERDE]'::text
            WHEN ((estado_hash)::text ~~ '%ERROR%'::text) THEN 'SISTEMA COMPROMETIDO [ROJO]'::text
            ELSE 'ESTADO INDETERMINADO [AMARILLO]'::text
        END AS indicador_visual,
    timestamp_verificacion AS ultima_sincronizacion,
    version_core AS nucleo_v
   FROM norm.integridad
  ORDER BY timestamp_verificacion DESC
 LIMIT 1;


ALTER VIEW norm.v_estado_sistema OWNER TO uh_core;

--
-- Name: constitucion id; Type: DEFAULT; Schema: norm; Owner: postgres
--

ALTER TABLE ONLY norm.constitucion ALTER COLUMN id SET DEFAULT nextval('norm.constitucion_id_seq'::regclass);


--
-- Name: integridad id_registro; Type: DEFAULT; Schema: norm; Owner: uh_core
--

ALTER TABLE ONLY norm.integridad ALTER COLUMN id_registro SET DEFAULT nextval('norm.integridad_id_registro_seq'::regclass);


--
-- Name: metadatos_archivos id_archivo; Type: DEFAULT; Schema: norm; Owner: uh_core
--

ALTER TABLE ONLY norm.metadatos_archivos ALTER COLUMN id_archivo SET DEFAULT nextval('norm.metadatos_archivos_id_archivo_seq'::regclass);


--
-- Name: nodos_operativos id_nodo; Type: DEFAULT; Schema: norm; Owner: uh_core
--

ALTER TABLE ONLY norm.nodos_operativos ALTER COLUMN id_nodo SET DEFAULT nextval('norm.nodos_operativos_id_nodo_seq'::regclass);


--
-- Data for Name: constitucion; Type: TABLE DATA; Schema: norm; Owner: postgres
--

COPY norm.constitucion (id, seccion, contenido, version, ts_carga) FROM stdin;
1	LEY_VITAL_11	LEY VITAL 11: PROTOCOLO DE TRAZABILIDAD EXHAUSTIVA. Todo avance, hallazgo o procedimiento debe quedar registrado en DB y archivos de estado. La amnesia tecnica se considera violacion de integridad.	1	2026-02-28 11:09:45.974088
2	LEY_VERIFICACION_TOTAL	LEY DE VERIFICACIÓN TOTAL: Ni el Humano ni la IA darán nada por supuesto. Antes de cualquier modificación, se realizará un escaneo de impacto, verificación de esquemas y comprobación de integridad. El desconocimiento del detalle infimo es la puerta al caos; la verificación es el único firewall.	1	2026-02-28 12:12:08.857638
\.


--
-- Data for Name: integridad; Type: TABLE DATA; Schema: norm; Owner: uh_core
--

COPY norm.integridad (id_registro, timestamp_verificacion, estado_hash, estatus_reparacion, version_core) FROM stdin;
1	2026-03-01 07:15:59.701504	ACK_N2_INTEGRITY_CONFIRMED	Limpieza profunda de tablas fantasma completada.	2.0.1
\.


--
-- Data for Name: metadatos_archivos; Type: TABLE DATA; Schema: norm; Owner: uh_core
--

COPY norm.metadatos_archivos (id_archivo, nombre_archivo, ruta_local, tamano_kb, id_nodo_origen) FROM stdin;
\.


--
-- Data for Name: nodos_core; Type: TABLE DATA; Schema: norm; Owner: uh_core
--

COPY norm.nodos_core (id_nodo, nombre_modulo, referencia_lanzador, logica_activa) FROM stdin;
\.


--
-- Data for Name: nodos_operativos; Type: TABLE DATA; Schema: norm; Owner: uh_core
--

COPY norm.nodos_operativos (id_nodo, nombre_nodo, descripcion, estado_actividad, ultima_llamada, nivel_prioridad) FROM stdin;
1	CALCULATOR_ALPHA	Procesamiento de operaciones matem ticas densas.	t	2026-03-01 07:20:03.063213	2
2	FILE_SYSTEM_OMEGA	Gesti¢n de lectura/escritura en disco local.	t	2026-03-01 07:20:03.063213	3
3	AUTOMATA_BETA	Ejecuci¢n de scripts de mantenimiento programado.	t	2026-03-01 07:20:03.063213	4
\.


--
-- Name: constitucion_id_seq; Type: SEQUENCE SET; Schema: norm; Owner: postgres
--

SELECT pg_catalog.setval('norm.constitucion_id_seq', 2, true);


--
-- Name: integridad_id_registro_seq; Type: SEQUENCE SET; Schema: norm; Owner: uh_core
--

SELECT pg_catalog.setval('norm.integridad_id_registro_seq', 2, true);


--
-- Name: metadatos_archivos_id_archivo_seq; Type: SEQUENCE SET; Schema: norm; Owner: uh_core
--

SELECT pg_catalog.setval('norm.metadatos_archivos_id_archivo_seq', 1, false);


--
-- Name: nodos_operativos_id_nodo_seq; Type: SEQUENCE SET; Schema: norm; Owner: uh_core
--

SELECT pg_catalog.setval('norm.nodos_operativos_id_nodo_seq', 3, true);


--
-- Name: constitucion constitucion_pkey; Type: CONSTRAINT; Schema: norm; Owner: postgres
--

ALTER TABLE ONLY norm.constitucion
    ADD CONSTRAINT constitucion_pkey PRIMARY KEY (id);


--
-- Name: integridad integridad_pkey; Type: CONSTRAINT; Schema: norm; Owner: uh_core
--

ALTER TABLE ONLY norm.integridad
    ADD CONSTRAINT integridad_pkey PRIMARY KEY (id_registro);


--
-- Name: metadatos_archivos metadatos_archivos_pkey; Type: CONSTRAINT; Schema: norm; Owner: uh_core
--

ALTER TABLE ONLY norm.metadatos_archivos
    ADD CONSTRAINT metadatos_archivos_pkey PRIMARY KEY (id_archivo);


--
-- Name: nodos_core nodos_core_pkey; Type: CONSTRAINT; Schema: norm; Owner: uh_core
--

ALTER TABLE ONLY norm.nodos_core
    ADD CONSTRAINT nodos_core_pkey PRIMARY KEY (id_nodo);


--
-- Name: nodos_operativos nodos_operativos_nombre_nodo_key; Type: CONSTRAINT; Schema: norm; Owner: uh_core
--

ALTER TABLE ONLY norm.nodos_operativos
    ADD CONSTRAINT nodos_operativos_nombre_nodo_key UNIQUE (nombre_nodo);


--
-- Name: nodos_operativos nodos_operativos_pkey; Type: CONSTRAINT; Schema: norm; Owner: uh_core
--

ALTER TABLE ONLY norm.nodos_operativos
    ADD CONSTRAINT nodos_operativos_pkey PRIMARY KEY (id_nodo);


--
-- Name: integridad trg_seguridad_n2; Type: TRIGGER; Schema: norm; Owner: uh_core
--

CREATE TRIGGER trg_seguridad_n2 BEFORE INSERT OR UPDATE ON norm.integridad FOR EACH ROW EXECUTE FUNCTION norm.fn_prevent_recursion();


--
-- Name: SCHEMA norm; Type: ACL; Schema: -; Owner: postgres
--

GRANT ALL ON SCHEMA norm TO uh_core;


--
-- Name: TABLE constitucion; Type: ACL; Schema: norm; Owner: postgres
--

GRANT ALL ON TABLE norm.constitucion TO uh_core;


--
-- Name: SEQUENCE constitucion_id_seq; Type: ACL; Schema: norm; Owner: postgres
--

GRANT ALL ON SEQUENCE norm.constitucion_id_seq TO uh_core;


--
-- PostgreSQL database dump complete
--

\unrestrict HLH8OajrfFBGUKkVuOaei11h7oaEMUgWMg3nAt0VBXOzazO8lv1hAC00cj6dAkj

