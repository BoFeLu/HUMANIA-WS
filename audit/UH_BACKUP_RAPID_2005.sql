--
-- PostgreSQL database dump
--

\restrict fs4ULlDdGYq8lIYmBRwczgdXSKa57L8c95Qgt4Mkr0vEsmflippikhFpPYFn5xz

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
-- Name: execution; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA execution;


ALTER SCHEMA execution OWNER TO postgres;

--
-- Name: kb; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA kb;


ALTER SCHEMA kb OWNER TO postgres;

--
-- Name: leyes; Type: SCHEMA; Schema: -; Owner: uh_core
--

CREATE SCHEMA leyes;


ALTER SCHEMA leyes OWNER TO uh_core;

--
-- Name: norm; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA norm;


ALTER SCHEMA norm OWNER TO postgres;

--
-- Name: notary; Type: SCHEMA; Schema: -; Owner: uh_core
--

CREATE SCHEMA notary;


ALTER SCHEMA notary OWNER TO uh_core;

--
-- Name: soporte; Type: SCHEMA; Schema: -; Owner: uh_core
--

CREATE SCHEMA soporte;


ALTER SCHEMA soporte OWNER TO uh_core;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: ledger_event_type; Type: TYPE; Schema: notary; Owner: uh_core
--

CREATE TYPE notary.ledger_event_type AS ENUM (
    'INTENT',
    'DISPATCHED',
    'RESULT',
    'POSTCHECK_FAIL',
    'ABORTED',
    'SECURITY_EVENT'
);


ALTER TYPE notary.ledger_event_type OWNER TO uh_core;

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
-- Name: fn_mantenimiento_logs(); Type: FUNCTION; Schema: norm; Owner: uh_core
--

CREATE FUNCTION norm.fn_mantenimiento_logs() RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM norm.integridad
    WHERE id_registro NOT IN (
        SELECT id_registro 
        FROM norm.integridad 
        ORDER BY id_registro DESC 
        LIMIT 100
    );
END;
$$;


ALTER FUNCTION norm.fn_mantenimiento_logs() OWNER TO uh_core;

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

--
-- Name: block_update_delete(); Type: FUNCTION; Schema: notary; Owner: uh_core
--

CREATE FUNCTION notary.block_update_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  RAISE EXCEPTION 'UltraHumania Notary Ledger is append-only: % is forbidden', TG_OP;
END;
$$;


ALTER FUNCTION notary.block_update_delete() OWNER TO uh_core;

--
-- Name: enforce_result_has_intent(); Type: FUNCTION; Schema: notary; Owner: postgres
--

CREATE FUNCTION notary.enforce_result_has_intent() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ BEGIN IF NEW.event_type = 'RESULT' THEN IF NOT EXISTS (SELECT 1 FROM notary.ledger_events i WHERE i.event_type = 'INTENT' AND i.correlation_id = NEW.correlation_id) THEN RAISE EXCEPTION 'RESULT without INTENT for correlation_id=%', NEW.correlation_id; END IF; END IF; RETURN NEW; END; $$;


ALTER FUNCTION notary.enforce_result_has_intent() OWNER TO postgres;

--
-- Name: buscar_en_uh(text); Type: FUNCTION; Schema: public; Owner: uh_core
--

CREATE FUNCTION public.buscar_en_uh(termino_busqueda text) RETURNS TABLE(fuente text, nombre_o_error text, detalle_o_solucion text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    -- Convertimos todo a ::TEXT para que la uni¢n sea perfecta
    SELECT 'LEY'::TEXT, titulo::TEXT, descripcion::TEXT FROM leyes.constitucion 
    WHERE titulo ILIKE '%' || termino_busqueda || '%' OR descripcion ILIKE '%' || termino_busqueda || '%'
    UNION ALL
    SELECT 'SOPORTE'::TEXT, error_detectado::TEXT, solucion_aplicada::TEXT FROM soporte.bitacora_errores 
    WHERE error_detectado ILIKE '%' || termino_busqueda || '%' OR solucion_aplicada ILIKE '%' || termino_busqueda || '%';
END;
$$;


ALTER FUNCTION public.buscar_en_uh(termino_busqueda text) OWNER TO uh_core;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: session_logs; Type: TABLE; Schema: execution; Owner: postgres
--

CREATE TABLE execution.session_logs (
    id integer NOT NULL,
    comando text,
    resultado text,
    ts timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE execution.session_logs OWNER TO postgres;

--
-- Name: session_logs_id_seq; Type: SEQUENCE; Schema: execution; Owner: postgres
--

CREATE SEQUENCE execution.session_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE execution.session_logs_id_seq OWNER TO postgres;

--
-- Name: session_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: execution; Owner: postgres
--

ALTER SEQUENCE execution.session_logs_id_seq OWNED BY execution.session_logs.id;


--
-- Name: problems; Type: TABLE; Schema: kb; Owner: postgres
--

CREATE TABLE kb.problems (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    title text NOT NULL,
    description text NOT NULL,
    severity text,
    environment text,
    tags text[],
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT problems_severity_check CHECK ((severity = ANY (ARRAY['low'::text, 'medium'::text, 'high'::text, 'critical'::text])))
);


ALTER TABLE kb.problems OWNER TO postgres;

--
-- Name: solutions; Type: TABLE; Schema: kb; Owner: postgres
--

CREATE TABLE kb.solutions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    problem_id uuid NOT NULL,
    description text NOT NULL,
    steps jsonb,
    validated boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    evidence_hash text
);


ALTER TABLE kb.solutions OWNER TO postgres;

--
-- Name: soporte_tecnico; Type: TABLE; Schema: kb; Owner: postgres
--

CREATE TABLE kb.soporte_tecnico (
    conversation_id text NOT NULL,
    customer_issue text,
    tech_response text,
    resolution_time text,
    issue_category text,
    issue_status text
);


ALTER TABLE kb.soporte_tecnico OWNER TO postgres;

--
-- Name: constitucion; Type: TABLE; Schema: leyes; Owner: uh_core
--

CREATE TABLE leyes.constitucion (
    id_ley integer NOT NULL,
    titulo character varying(100) NOT NULL,
    descripcion text NOT NULL,
    categoria character varying(50),
    fecha_emision timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    jerarquia character varying(20) DEFAULT 'ESENCIAL'::character varying,
    fuente_origen character varying(100) DEFAULT 'UH_PROPIO'::character varying,
    tipo_norma character varying(50) DEFAULT 'TECNICA'::character varying
);


ALTER TABLE leyes.constitucion OWNER TO uh_core;

--
-- Name: constitucion_id_ley_seq; Type: SEQUENCE; Schema: leyes; Owner: uh_core
--

CREATE SEQUENCE leyes.constitucion_id_ley_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE leyes.constitucion_id_ley_seq OWNER TO uh_core;

--
-- Name: constitucion_id_ley_seq; Type: SEQUENCE OWNED BY; Schema: leyes; Owner: uh_core
--

ALTER SEQUENCE leyes.constitucion_id_ley_seq OWNED BY leyes.constitucion.id_ley;


--
-- Name: mapa_rutas; Type: TABLE; Schema: leyes; Owner: uh_core
--

CREATE TABLE leyes.mapa_rutas (
    id integer NOT NULL,
    ruta text,
    estado text DEFAULT 'DETECTADA'::text
);


ALTER TABLE leyes.mapa_rutas OWNER TO uh_core;

--
-- Name: mapa_rutas_id_seq; Type: SEQUENCE; Schema: leyes; Owner: uh_core
--

CREATE SEQUENCE leyes.mapa_rutas_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE leyes.mapa_rutas_id_seq OWNER TO uh_core;

--
-- Name: mapa_rutas_id_seq; Type: SEQUENCE OWNED BY; Schema: leyes; Owner: uh_core
--

ALTER SEQUENCE leyes.mapa_rutas_id_seq OWNED BY leyes.mapa_rutas.id;


--
-- Name: principios_valores; Type: TABLE; Schema: leyes; Owner: uh_core
--

CREATE TABLE leyes.principios_valores (
    id_valor integer NOT NULL,
    nombre character varying(100) NOT NULL,
    nivel character varying(20),
    descripcion text,
    aplicacion_practica text
);


ALTER TABLE leyes.principios_valores OWNER TO uh_core;

--
-- Name: principios_valores_id_valor_seq; Type: SEQUENCE; Schema: leyes; Owner: uh_core
--

CREATE SEQUENCE leyes.principios_valores_id_valor_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE leyes.principios_valores_id_valor_seq OWNER TO uh_core;

--
-- Name: principios_valores_id_valor_seq; Type: SEQUENCE OWNED BY; Schema: leyes; Owner: uh_core
--

ALTER SEQUENCE leyes.principios_valores_id_valor_seq OWNED BY leyes.principios_valores.id_valor;


--
-- Name: protocolos_respuesta; Type: TABLE; Schema: leyes; Owner: uh_core
--

CREATE TABLE leyes.protocolos_respuesta (
    id_protocolo integer NOT NULL,
    nombre_protocolo character varying(255) NOT NULL,
    descripcion text,
    pasos_ejecucion jsonb,
    fecha_creacion timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE leyes.protocolos_respuesta OWNER TO uh_core;

--
-- Name: protocolos_respuesta_id_protocolo_seq; Type: SEQUENCE; Schema: leyes; Owner: uh_core
--

CREATE SEQUENCE leyes.protocolos_respuesta_id_protocolo_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE leyes.protocolos_respuesta_id_protocolo_seq OWNER TO uh_core;

--
-- Name: protocolos_respuesta_id_protocolo_seq; Type: SEQUENCE OWNED BY; Schema: leyes; Owner: uh_core
--

ALTER SEQUENCE leyes.protocolos_respuesta_id_protocolo_seq OWNED BY leyes.protocolos_respuesta.id_protocolo;


--
-- Name: v_recordatorio_ley_vital; Type: VIEW; Schema: leyes; Owner: uh_core
--

CREATE VIEW leyes.v_recordatorio_ley_vital AS
 SELECT 'ATENCIàN: Se aplica LEY_VITAL_MAXIMO_ORDEN. Comandos completos y precisos obligatorios.'::text AS estatus
   FROM leyes.constitucion
  WHERE ((titulo)::text = 'LEY_VITAL_MAXIMO_ORDEN'::text);


ALTER VIEW leyes.v_recordatorio_ley_vital OWNER TO uh_core;

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
-- Name: v_alertas_sistema; Type: VIEW; Schema: norm; Owner: uh_core
--

CREATE VIEW norm.v_alertas_sistema AS
 SELECT nombre_archivo,
    tamano_kb,
    ruta_local,
        CASE
            WHEN (tamano_kb > (102400)::numeric) THEN 'CRÖTICO: EXCESO DE PESO'::text
            WHEN (tamano_kb > (51200)::numeric) THEN 'ADVERTENCIA: ARCHIVO PESADO'::text
            ELSE 'NORMAL'::text
        END AS estado_alerta
   FROM norm.metadatos_archivos;


ALTER VIEW norm.v_alertas_sistema OWNER TO uh_core;

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
-- Name: ledger_events; Type: TABLE; Schema: notary; Owner: uh_core
--

CREATE TABLE notary.ledger_events (
    event_id uuid DEFAULT gen_random_uuid() NOT NULL,
    seq bigint NOT NULL,
    prev_hash_sha256 character(64) NOT NULL,
    event_hash_sha256 character(64) NOT NULL,
    correlation_id uuid NOT NULL,
    event_type notary.ledger_event_type NOT NULL,
    action_id character varying(120) NOT NULL,
    action_version character varying(32) NOT NULL,
    policy_hash_sha256 character(64) NOT NULL,
    event_envelope_hash_sha256 character(64) NOT NULL,
    candidate_plan_hash_sha256 character(64),
    action_request jsonb NOT NULL,
    action_result jsonb,
    evidence_manifest jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_hash_hex_envelope CHECK ((event_envelope_hash_sha256 ~ '^[0-9a-f]{64}$'::text)),
    CONSTRAINT chk_hash_hex_event CHECK ((event_hash_sha256 ~ '^[0-9a-f]{64}$'::text)),
    CONSTRAINT chk_hash_hex_policy CHECK ((policy_hash_sha256 ~ '^[0-9a-f]{64}$'::text)),
    CONSTRAINT chk_hash_hex_prev CHECK ((prev_hash_sha256 ~ '^[0-9a-f]{64}$'::text))
);


ALTER TABLE notary.ledger_events OWNER TO uh_core;

--
-- Name: ledger_events_seq_seq; Type: SEQUENCE; Schema: notary; Owner: uh_core
--

CREATE SEQUENCE notary.ledger_events_seq_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE notary.ledger_events_seq_seq OWNER TO uh_core;

--
-- Name: ledger_events_seq_seq; Type: SEQUENCE OWNED BY; Schema: notary; Owner: uh_core
--

ALTER SEQUENCE notary.ledger_events_seq_seq OWNED BY notary.ledger_events.seq;


--
-- Name: ledger_genesis; Type: TABLE; Schema: notary; Owner: uh_core
--

CREATE TABLE notary.ledger_genesis (
    id smallint DEFAULT 1 NOT NULL,
    genesis_hash_sha256 character(64) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_genesis_hash_hex CHECK ((genesis_hash_sha256 ~ '^[0-9a-f]{64}$'::text))
);


ALTER TABLE notary.ledger_genesis OWNER TO uh_core;

--
-- Name: v_orphan_results; Type: VIEW; Schema: notary; Owner: postgres
--

CREATE VIEW notary.v_orphan_results AS
 SELECT seq,
    correlation_id,
    action_id,
    created_at
   FROM notary.ledger_events r
  WHERE ((event_type = 'RESULT'::notary.ledger_event_type) AND (NOT (EXISTS ( SELECT 1
           FROM notary.ledger_events i
          WHERE ((i.event_type = 'INTENT'::notary.ledger_event_type) AND (i.correlation_id = r.correlation_id) AND (i.seq < r.seq))))));


ALTER VIEW notary.v_orphan_results OWNER TO postgres;

--
-- Name: bitacora_errores; Type: TABLE; Schema: soporte; Owner: uh_core
--

CREATE TABLE soporte.bitacora_errores (
    id_error integer NOT NULL,
    error_detectado text NOT NULL,
    contexto_psql text,
    solucion_aplicada text NOT NULL,
    estado_resolucion character varying(20) DEFAULT 'RESUELTO'::character varying,
    fecha_incidente timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    hallazgo_clave text,
    tecnica_aplicada character varying(100),
    iteracion integer DEFAULT 1
);


ALTER TABLE soporte.bitacora_errores OWNER TO uh_core;

--
-- Name: v_dashboard_conocimiento; Type: VIEW; Schema: public; Owner: uh_core
--

CREATE VIEW public.v_dashboard_conocimiento AS
 SELECT ( SELECT count(*) AS count
           FROM leyes.constitucion) AS total_leyes,
    ( SELECT count(*) AS count
           FROM soporte.bitacora_errores) AS errores_resueltos,
    'SISTEMA CEREBRAL ACTIVO'::text AS estado;


ALTER VIEW public.v_dashboard_conocimiento OWNER TO uh_core;

--
-- Name: v_deontologia_ia; Type: VIEW; Schema: public; Owner: uh_core
--

CREATE VIEW public.v_deontologia_ia AS
 SELECT titulo AS ley_vital,
    descripcion AS mandato_ia
   FROM leyes.constitucion
  WHERE ((titulo)::text = 'LEY_VITAL_MAXIMO_ORDEN'::text);


ALTER VIEW public.v_deontologia_ia OWNER TO uh_core;

--
-- Name: v_mapa_conocimiento; Type: VIEW; Schema: public; Owner: uh_core
--

CREATE VIEW public.v_mapa_conocimiento AS
 SELECT c.categoria,
    c.titulo AS concepto,
    COALESCE(s.error_detectado, 'SISTEMA ESTABLE'::text) AS riesgo_asociado,
    COALESCE(s.estado_resolucion, 'N/A'::character varying) AS estado_riesgo
   FROM (leyes.constitucion c
     LEFT JOIN soporte.bitacora_errores s ON ((s.contexto_psql ~~* (('%'::text || (c.titulo)::text) || '%'::text))));


ALTER VIEW public.v_mapa_conocimiento OWNER TO uh_core;

--
-- Name: bitacora_errores_id_error_seq; Type: SEQUENCE; Schema: soporte; Owner: uh_core
--

CREATE SEQUENCE soporte.bitacora_errores_id_error_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE soporte.bitacora_errores_id_error_seq OWNER TO uh_core;

--
-- Name: bitacora_errores_id_error_seq; Type: SEQUENCE OWNED BY; Schema: soporte; Owner: uh_core
--

ALTER SEQUENCE soporte.bitacora_errores_id_error_seq OWNED BY soporte.bitacora_errores.id_error;


--
-- Name: session_logs id; Type: DEFAULT; Schema: execution; Owner: postgres
--

ALTER TABLE ONLY execution.session_logs ALTER COLUMN id SET DEFAULT nextval('execution.session_logs_id_seq'::regclass);


--
-- Name: constitucion id_ley; Type: DEFAULT; Schema: leyes; Owner: uh_core
--

ALTER TABLE ONLY leyes.constitucion ALTER COLUMN id_ley SET DEFAULT nextval('leyes.constitucion_id_ley_seq'::regclass);


--
-- Name: mapa_rutas id; Type: DEFAULT; Schema: leyes; Owner: uh_core
--

ALTER TABLE ONLY leyes.mapa_rutas ALTER COLUMN id SET DEFAULT nextval('leyes.mapa_rutas_id_seq'::regclass);


--
-- Name: principios_valores id_valor; Type: DEFAULT; Schema: leyes; Owner: uh_core
--

ALTER TABLE ONLY leyes.principios_valores ALTER COLUMN id_valor SET DEFAULT nextval('leyes.principios_valores_id_valor_seq'::regclass);


--
-- Name: protocolos_respuesta id_protocolo; Type: DEFAULT; Schema: leyes; Owner: uh_core
--

ALTER TABLE ONLY leyes.protocolos_respuesta ALTER COLUMN id_protocolo SET DEFAULT nextval('leyes.protocolos_respuesta_id_protocolo_seq'::regclass);


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
-- Name: ledger_events seq; Type: DEFAULT; Schema: notary; Owner: uh_core
--

ALTER TABLE ONLY notary.ledger_events ALTER COLUMN seq SET DEFAULT nextval('notary.ledger_events_seq_seq'::regclass);


--
-- Name: bitacora_errores id_error; Type: DEFAULT; Schema: soporte; Owner: uh_core
--

ALTER TABLE ONLY soporte.bitacora_errores ALTER COLUMN id_error SET DEFAULT nextval('soporte.bitacora_errores_id_error_seq'::regclass);


--
-- Data for Name: session_logs; Type: TABLE DATA; Schema: execution; Owner: postgres
--

COPY execution.session_logs (id, comando, resultado, ts) FROM stdin;
1	AUDIT_VOLUME_STATS	Auditoría Total Iniciada. Detectados 4443 archivos. Dominio: .md y .txt. Cerebro: 66 scripts .ps1.	2026-02-28 11:24:51.782154
2	CODE_ANALYSIS_BLOCK_1	Código analizado: Sentinel usa SHA256 encadenado. Startup requiere LM Studio (Port 1234). Localizados secretos de notificación.	2026-02-28 11:32:45.398243
3	CRITICAL_ALERT_IMPL	Implementado script de Alerta Roja. Iniciada inspección del Manifiesto y Watchdog. Preparando actualización de hashes.	2026-02-28 11:34:10.723022
4	MANIFEST_UPGRADE_5.0	Sincronización Watchdog-Sentinel completada. Manifiesto 5.0-ULTRA generado. Sistema blindado contra falsos positivos.	2026-02-28 11:37:33.608069
5	SENTINEL_REFACTOR	Refactorización de Sentinel: Corregido error silencioso. Añadida detección de archivos faltantes y try/catch global.	2026-02-28 11:51:06.481827
6	INFRA_STABILIZATION	Implementado LogRotate industrial. Sistema elevado a Manifiesto 6.0-GOLD. Limpieza de cebos completada.	2026-02-28 11:52:48.048445
\.


--
-- Data for Name: problems; Type: TABLE DATA; Schema: kb; Owner: postgres
--

COPY kb.problems (id, title, description, severity, environment, tags, created_at, updated_at) FROM stdin;
3db37f90-06a6-43a1-b14a-b2dd64fc473c	SCHEMA_MISMATCH_N2: Desalineacion de Metadatos	Fallo por suposicion de columnas. Se requiere auditoria previa.	\N	\N	\N	2026-03-02 19:26:04.191345+01	2026-03-02 19:26:04.191345+01
7676f523-121a-4184-b36f-fafe59e15e80	DESALINEACION_ESQUEMA_FIX	Fallo por suposicion de columnas. Corregido con auditoria.	\N	\N	\N	2026-03-02 19:27:31.610648+01	2026-03-02 19:27:31.610648+01
bc650abf-6f8a-42a0-ab72-c6b3a73a31b0	DESALINEACION_ESQUEMA_FIX	Fallo por suposicion de columnas. Corregido con auditoria.	\N	\N	\N	2026-03-02 19:27:39.806767+01	2026-03-02 19:27:39.806767+01
4a93dfc1-2518-453a-ae51-5f9b846b4fbb	DEBUG_UUID_CAPTURE_FAIL	Fallo en la captura de UUID desde terminal PS. El output sucio impidio la vinculacion.	\N	\N	\N	2026-03-02 19:28:19.596754+01	2026-03-02 19:28:19.596754+01
6730676e-0fe6-42c7-ba6c-3532d41f359e	INFRA_PERSISTENCE_READY	Despliegue exitoso del Guardian-RS y estabilizacion de la persistencia del nucleo.	\N	\N	\N	2026-03-02 19:47:48.304162+01	2026-03-02 19:47:48.304162+01
ae3a2406-ddea-468f-9eac-e1a78696d6d3	MILESTONE_V1_STABLE	Consolidacion total de la infraestructura: Rust Guardian + DB v17 + Dashboard.	\N	\N	\N	2026-03-02 20:05:35.196496+01	2026-03-02 20:05:35.196496+01
\.


--
-- Data for Name: solutions; Type: TABLE DATA; Schema: kb; Owner: postgres
--

COPY kb.solutions (id, problem_id, description, steps, validated, created_at, updated_at, evidence_hash) FROM stdin;
da309341-f57a-43be-81fe-ea3b3b882da0	4a93dfc1-2518-453a-ae51-5f9b846b4fbb	Uso de CTE (WITH) para vinculacion interna en el motor SQL.	{"1": "Eliminar variables intermedias", "2": "Usar sentencia WITH", "3": "Validar integridad atomica"}	t	2026-03-02 19:28:19.596754+01	2026-03-02 19:28:19.596754+01	\N
392300ec-dba0-4541-91bd-7f09ba265f47	6730676e-0fe6-42c7-ba6c-3532d41f359e	Sustitucion de WinSW por binario nativo en Rust con watchdog de 30s.	{"1": "Compilacion Release", "2": "Despliegue en BIN", "3": "Activacion de Guardian-RS"}	t	2026-03-02 19:47:48.304162+01	2026-03-02 19:47:48.304162+01	\N
f2837e31-8975-4f82-a183-4f89220650de	ae3a2406-ddea-468f-9eac-e1a78696d6d3	Sistema blindado con exito bajo supervision de ASIR.	{"1": "Compilacion Rust OK", "2": "Snapshot SQL verificado", "3": "Dashboard Operativo"}	t	2026-03-02 20:05:35.196496+01	2026-03-02 20:05:35.196496+01	\N
\.


--
-- Data for Name: soporte_tecnico; Type: TABLE DATA; Schema: kb; Owner: postgres
--

COPY kb.soporte_tecnico (conversation_id, customer_issue, tech_response, resolution_time, issue_category, issue_status) FROM stdin;
\.


--
-- Data for Name: constitucion; Type: TABLE DATA; Schema: leyes; Owner: uh_core
--

COPY leyes.constitucion (id_ley, titulo, descripcion, categoria, fecha_emision, jerarquia, fuente_origen, tipo_norma) FROM stdin;
1	LEY_EVIDENCIA_OUTPUT	Toda operaci¢n debe dejar evidencia: output y exitcode.	TECNICA	2026-03-02 08:08:01.313453	ESENCIAL	UH_PROPIO	TECNICA
2	WATCHDOG_N2_STANDBY	El Watchdog (winsw.exe) supervisa el Runner UH_GUARD_RUN.	INFRAESTRUCTURA	2026-03-02 08:08:01.313453	ESENCIAL	UH_PROPIO	TECNICA
3	DEF_RUNNER	UH_GUARD_RUN: Script PowerShell n£cleo que orquesta la ejecuci¢n y el estado.	DICCIONARIO	2026-03-02 08:19:53.383588	ESENCIAL	UH_PROPIO	TECNICA
4	DEF_WATCHDOG	UH_WATCHDOG: Servicio basado en winsw.exe que asegura la persistencia del Runner.	DICCIONARIO	2026-03-02 08:19:53.383588	ESENCIAL	UH_PROPIO	TECNICA
5	DEF_VERIFIERS	Scripts en la carpeta /verifiers que validan leyes antes de permitir cambios.	DICCIONARIO	2026-03-02 08:19:53.383588	ESENCIAL	UH_PROPIO	TECNICA
6	DEF_ARTEFACTS	Archivos en /state, /logs y /guard que persisten la memoria del sistema.	DICCIONARIO	2026-03-02 08:19:53.383588	ESENCIAL	UH_PROPIO	TECNICA
7	PROC_UPDATE_RUNNER	1. Detener Watchdog. 2. Actualizar .ps1. 3. Validar Hash. 4. Iniciar Watchdog.	PROCEDIMIENTO	2026-03-02 08:19:53.388219	ESENCIAL	UH_PROPIO	TECNICA
8	PROC_LOG_ROTATION	El modo "roll" de winsw debe configurarse para evitar saturaci¢n de disco.	PROCEDIMIENTO	2026-03-02 08:19:53.388219	ESENCIAL	UH_PROPIO	TECNICA
9	METODO_IPA	Investigar, Pulir, Aplicar: Ciclo de mejora continua para cada m¢dulo de UH.	METODOLOGIA	2026-03-02 10:01:52.935969	ESENCIAL	UH_PROPIO	TECNICA
10	ESTANDAR_BOM_FORCE	Uso obligatorio de Byte Order Mark para evitar errores de lectura en el Runner.	TECNICA	2026-03-02 10:01:52.935969	ESENCIAL	UH_PROPIO	TECNICA
11	FILTRO_NO_SPEC	Prohibida la especulaci¢n t‚cnica; cada comando debe basarse en un hallazgo previo.	ETICA_IA	2026-03-02 10:01:52.935969	ESENCIAL	UH_PROPIO	TECNICA
12	LEY_VITAL_HEURISTICA	El progreso se basa en el ciclo: Estudio -> Experimentaci¢n Controlada -> An lisis -> Pulido.	METODOLOGIA	2026-03-02 10:14:27.772	VITAL	UH_PROPIO	FILOSOFIA_SISTEMA
13	STD_IEEE_830	Especificaci¢n de requisitos de software: Correcto, Inequ¡voco, Completo, Consistente.	ESTANDAR	2026-03-02 10:14:52.107612	ESENCIAL	IEEE	TECNICA
14	STD_NASA_POWER_OF_10	Reglas cr¡ticas para c¢digo de alta fiabilidad: Sin recursividad, l¡mites fijos en bucles.	SEGURIDAD	2026-03-02 10:14:52.107612	VITAL	NASA	TECNICA
15	PRINCIPIO_SOLID	Cinco principios de dise¤o orientado a objetos para sistemas mantenibles y escalables.	ARQUITECTURA	2026-03-02 10:14:52.107612	ESENCIAL	INDUSTRIA	TECNICA
16	LEY_VITAL_MAXIMO_ORDEN	SISTEMA EN LEVEL_4: PERSISTENCIA TOTAL, INTEGRIDAD DE BITS VERIFICADA Y GOBERNANZA AUTàNOMA ALCANZADA.	OPERATIVIDAD	2026-03-02 10:35:02.555131	VITAL	ALBERTO_CORE	DEONTOLOGIA_IA
17	Evidence-Gated	Solo 1 comando/accion por turno. No avanzar sin output.	METODOLOGIA	2026-03-02 19:18:12.835552	ESENCIAL	ULTRAHUMANIA_AI	TECNICA
18	BOM-Invariant	Scripts .ps1 deben ser UTF-8 con BOM obligatoriamente.	TECNICA	2026-03-02 19:18:12.916308	CRITICA	ULTRAHUMANIA_AI	TECNICA
19	Stop-Rule	El asistente debe detenerse ante fallos y pedir salida.	PROTOCOLOS	2026-03-02 19:18:12.999476	ESENCIAL	ULTRAHUMANIA_AI	TECNICA
\.


--
-- Data for Name: mapa_rutas; Type: TABLE DATA; Schema: leyes; Owner: uh_core
--

COPY leyes.mapa_rutas (id, ruta, estado) FROM stdin;
1	C:\\\\ULTRAHUMANIA	DETECTADA
2	C:\\\\HUMANIA_TEST_ROOT	DETECTADA
3	C:\\\\Users\\\\Alber2Pruebas\\\\Desktop\\\\ULTRAH	DETECTADA
4	C:\\\\Users\\\\Alber2Pruebas\\\\Desktop\\\\TRANSHUMANIA	DETECTADA
5	C:\\\\HUMANIA_BACKUP_GOLD	DETECTADA
\.


--
-- Data for Name: principios_valores; Type: TABLE DATA; Schema: leyes; Owner: uh_core
--

COPY leyes.principios_valores (id_valor, nombre, nivel, descripcion, aplicacion_practica) FROM stdin;
1	INTEGRIDAD_CONTEXTUAL	VITAL	La IA no debe alucinar ni perder el hilo de la investigaci¢n previa.	Uso obligatorio de archivos .state
2	EVIDENCIA_EMPIRICA	VITAL	Ninguna soluci¢n se da por buena sin un exitcode exitoso comprobado.	Captura de output en cada comando
\.


--
-- Data for Name: protocolos_respuesta; Type: TABLE DATA; Schema: leyes; Owner: uh_core
--

COPY leyes.protocolos_respuesta (id_protocolo, nombre_protocolo, descripcion, pasos_ejecucion, fecha_creacion) FROM stdin;
1	REPARACION_ENCODING	Protocolo para detectar y re-inyectar BOM UTF8 en scripts corruptos.	\N	2026-03-02 17:48:27.853994
2	RECUPERACION_SYSTEM_0	Protocolo de re-inicializacion de servicios bajo cuenta SYSTEM tras fallos de session.	\N	2026-03-02 17:48:27.853994
3	SINCRONIZACION_ODS	Protocolo de exportacion de hallazgos de bitacora a archivos de intercambio CSV.	\N	2026-03-02 17:48:27.853994
4	GESTION_LOG_ROTATE	Protocolo de rotacion y limpieza de logs para mantenimiento de disco.	\N	2026-03-02 17:48:27.853994
\.


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
3	2026-03-01 22:52:56.551739	ACK_N2_FINAL_CONSOLIDATION	Protocolo N2 Completo. Daemon de vigilancia y limpieza activado.	2.0.1
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
-- Data for Name: ledger_events; Type: TABLE DATA; Schema: notary; Owner: uh_core
--

COPY notary.ledger_events (event_id, seq, prev_hash_sha256, event_hash_sha256, correlation_id, event_type, action_id, action_version, policy_hash_sha256, event_envelope_hash_sha256, candidate_plan_hash_sha256, action_request, action_result, evidence_manifest, created_at) FROM stdin;
a7fbf56e-fe8c-42ef-87b5-ac6a9acf4c14	1	0000000000000000000000000000000000000000000000000000000000000000	aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa	574a0ea8-384b-49bf-9c0e-06a0915be8d9	INTENT	system.metrics.read	0.1.2	bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb	cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc	dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd	{"test": true}	\N	\N	2026-02-20 18:35:53.917565+01
a10c2437-72b6-4047-b8f2-957c4271877c	2	aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa	eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee	574a0ea8-384b-49bf-9c0e-06a0915be8d9	ABORTED	system.metrics.read	0.1.2	bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb	cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc	dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd	{"test": true}	{"reason": "TEST_RECORD_INVALID_HASHES", "sealed": true}	[]	2026-02-20 18:40:09.909608+01
a1f6c51d-58f3-46b0-8f74-d65761b0b58c	3	eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee	e3dc70f8e6b1e66704db9616228e8143a40aa5522206ac2dda97b7829a89ed35	325e0af6-2f95-4920-9c23-53e95ab2641f	INTENT	system.metrics.read	0.1.2	1111111111111111111111111111111111111111111111111111111111111111	2222222222222222222222222222222222222222222222222222222222222222	3333333333333333333333333333333333333333333333333333333333333333	{"labels": {}, "source": "prometheus", "timeout_ms": 1000, "metric_name": "up"}	\N	\N	2026-02-20 19:31:09.627736+01
3b4a886b-5549-4511-9a6e-8f7056543ec3	7	e3dc70f8e6b1e66704db9616228e8143a40aa5522206ac2dda97b7829a89ed35	c998958469eeef5bf5f872c5c80491b377b1f1949515770677b75828dbb2e1c3	e1ef5332-d928-4b58-84a5-fedcf088ffdf	INTENT	system.metrics.read	0.1.2	f12013c034553465af716bc1612e4993526d7a624cb3d235968ee2650d025c1e	2222222222222222222222222222222222222222222222222222222222222222	3333333333333333333333333333333333333333333333333333333333333333	{"labels": {}, "source": "prometheus", "timeout_ms": 1000, "metric_name": "up"}	\N	\N	2026-02-20 19:52:41.676182+01
74e6583c-2730-43af-825f-ed3b3a54a729	8	c998958469eeef5bf5f872c5c80491b377b1f1949515770677b75828dbb2e1c3	a36e4bf605970ab565d8766ed54d47429d25bdfdbb80aeb61882d259a04ef770	b35ffe2c-0573-4c6b-b9c4-67d708b83cc6	INTENT	system.metrics.read	0.1.2	f12013c034553465af716bc1612e4993526d7a624cb3d235968ee2650d025c1e	d63b5a7fbaf939ff9a7eece7bc2b5d7ab106ada53e2f1c26bc6fda9a461fcac5	3333333333333333333333333333333333333333333333333333333333333333	{"labels": {}, "source": "prometheus", "timeout_ms": 1000, "metric_name": "up"}	\N	\N	2026-02-20 20:02:28.04539+01
a917aa3a-d83b-40dd-a85b-c0c83e8f2aa6	9	a36e4bf605970ab565d8766ed54d47429d25bdfdbb80aeb61882d259a04ef770	80fa14e5c972633e5377c8b2c430b9e332102c2cfb3d07b2f523babe19ef3c34	50a0831a-8513-4e21-b243-014063380e52	INTENT	system.metrics.read	0.1.2	f12013c034553465af716bc1612e4993526d7a624cb3d235968ee2650d025c1e	d63b5a7fbaf939ff9a7eece7bc2b5d7ab106ada53e2f1c26bc6fda9a461fcac5	9b7c1e83fab56ade94d7d76e4b2d56a9ec4711daf20d38966efc85349015ae36	{"labels": {}, "source": "prometheus", "timeout_ms": 1000, "metric_name": "up"}	\N	\N	2026-02-20 20:04:40.31437+01
22b50f29-7617-412f-bc45-1f2f0eaff1ea	10	80fa14e5c972633e5377c8b2c430b9e332102c2cfb3d07b2f523babe19ef3c34	cbf294cd17d4b251f56d958e57658563db3d6e63c733e62f568bbd7cd1efd6bd	50a0831a-8513-4e21-b243-014063380e52	RESULT	system.metrics.read	0.1.2	f12013c034553465af716bc1612e4993526d7a624cb3d235968ee2650d025c1e	d63b5a7fbaf939ff9a7eece7bc2b5d7ab106ada53e2f1c26bc6fda9a461fcac5	9b7c1e83fab56ade94d7d76e4b2d56a9ec4711daf20d38966efc85349015ae36	{"labels": {}, "source": "prometheus", "timeout_ms": 1000, "metric_name": "up"}	{"v": 1, "result": {"sample": "up{job=\\"prometheus\\"} 1", "http_status": 200, "payload_format": "prometheus_text_0.0.4"}, "end_utc": "2026-02-20T19:05:31Z", "exit_code": 0, "start_utc": "2026-02-20T19:05:30Z", "correlation_id": "50a0831a-8513-4e21-b243-014063380e52"}	[{"id": "raw_http_response", "path": "C:\\\\ULTRAHUMANIA\\\\vault\\\\evidence\\\\raw_http_response.txt", "bytes": 0, "sha256": "0000000000000000000000000000000000000000000000000000000000000000"}]	2026-02-20 20:09:38.64505+01
17794690-d019-4738-a107-f0b627b00bfc	11	cbf294cd17d4b251f56d958e57658563db3d6e63c733e62f568bbd7cd1efd6bd	638e8bd35fe843fe13310242a34cd74c1943521554a4d125b4daf8cf0f270b1c	50a0831a-8513-4e21-b243-014063380e52	RESULT	system.metrics.read	0.1.2	f12013c034553465af716bc1612e4993526d7a624cb3d235968ee2650d025c1e	d63b5a7fbaf939ff9a7eece7bc2b5d7ab106ada53e2f1c26bc6fda9a461fcac5	9b7c1e83fab56ade94d7d76e4b2d56a9ec4711daf20d38966efc85349015ae36	{"labels": {}, "source": "prometheus", "timeout_ms": 1000, "metric_name": "up"}	{"v": 1, "result": {"sample": "up{job=\\"prometheus\\"} 1", "http_status": 200, "payload_format": "prometheus_text_0.0.4"}, "end_utc": "2026-02-20T19:05:31Z", "exit_code": 0, "start_utc": "2026-02-20T19:05:30Z", "correlation_id": "50a0831a-8513-4e21-b243-014063380e52"}	{"id": "raw_http_response", "path": "C:\\\\ULTRAHUMANIA\\\\vault\\\\evidence\\\\raw_http_response.txt", "bytes": 84, "sha256": "44cb38fd72637dd8f4b86093a1707789c3ad5951534bb2d42a3eec059294ceac"}	2026-02-20 20:14:58.984577+01
1b6f56b8-54b5-403a-8e63-8c33c5e4b821	12	638e8bd35fe843fe13310242a34cd74c1943521554a4d125b4daf8cf0f270b1c	05948bb89f0c8739f834187e67803d05846c42c565b7588dacb0779351151239	50a0831a-8513-4e21-b243-014063380e52	RESULT	system.metrics.read	0.1.2	f12013c034553465af716bc1612e4993526d7a624cb3d235968ee2650d025c1e	d63b5a7fbaf939ff9a7eece7bc2b5d7ab106ada53e2f1c26bc6fda9a461fcac5	9b7c1e83fab56ade94d7d76e4b2d56a9ec4711daf20d38966efc85349015ae36	{"labels": {}, "source": "prometheus", "timeout_ms": 1000, "metric_name": "up"}	{"v": 1, "result": {"sample": "up{job=\\"prometheus\\"} 1", "http_status": 200, "payload_format": "prometheus_text_0.0.4"}, "end_utc": "2026-02-20T19:05:31Z", "exit_code": 0, "start_utc": "2026-02-20T19:05:30Z", "correlation_id": "50a0831a-8513-4e21-b243-014063380e52"}	[{"id": "raw_http_response", "path": "C:\\\\ULTRAHUMANIA\\\\vault\\\\evidence\\\\raw_http_response.txt", "bytes": 84, "sha256": "44cb38fd72637dd8f4b86093a1707789c3ad5951534bb2d42a3eec059294ceac"}]	2026-02-20 20:23:09.065856+01
1c6605e9-38b7-4770-b24e-99c1fcd5f75f	13	05948bb89f0c8739f834187e67803d05846c42c565b7588dacb0779351151239	af36152fd14ce872e6ca221d888923f8c80e8cc8f8d9c2cedbe00c263486c0d4	c0d83357-8940-44b7-a361-135bbd38cf54	INTENT	constitution.superlaw.sealed	0.1.2	f12013c034553465af716bc1612e4993526d7a624cb3d235968ee2650d025c1e	b56ff6da66c7d7e602761548b19fdcc190031511b938b24eb1d66e3f4ed3bdb4	a5e5f52fb7a3e0134137c38e000deed974bf310d613e4e912bbba43d29634d45	{"law_path": "C:\\\\ULTRAHUMANIA\\\\docs\\\\constitution\\\\SUPERLEY_ARQUITECTURA_ULTRAHUMANIA_v1.md", "seal_path": "C:\\\\ULTRAHUMANIA\\\\docs\\\\constitution\\\\SUPERLAW_SEAL.json", "law_sha256": "a5e5f52fb7a3e0134137c38e000deed974bf310d613e4e912bbba43d29634d45", "law_version": "1.0", "seal_sha256": "b56ff6da66c7d7e602761548b19fdcc190031511b938b24eb1d66e3f4ed3bdb4", "verification_method": "Get-FileHash(superlaw).Hash.ToLower() == SUPERLAW_SEAL.law_sha256.ToLower()", "verification_result": true}	\N	\N	2026-02-20 21:41:29.845095+01
753979be-4a47-43bd-b1b0-605b3e7805e0	14	af36152fd14ce872e6ca221d888923f8c80e8cc8f8d9c2cedbe00c263486c0d4	f4c2f88ec42a89c716b8bf979f401ce98432a379539c673d20ca27da24da57d6	1c6605e9-38b7-4770-b24e-99c1fcd5f75f	RESULT	constitution.superlaw.sealed	0.1.2	f12013c034553465af716bc1612e4993526d7a624cb3d235968ee2650d025c1e	b56ff6da66c7d7e602761548b19fdcc190031511b938b24eb1d66e3f4ed3bdb4	a5e5f52fb7a3e0134137c38e000deed974bf310d613e4e912bbba43d29634d45	{"law_path": "C:\\\\ULTRAHUMANIA\\\\docs\\\\constitution\\\\SUPERLEY_ARQUITECTURA_ULTRAHUMANIA_v1.md", "seal_path": "C:\\\\ULTRAHUMANIA\\\\docs\\\\constitution\\\\SUPERLAW_SEAL.json", "law_sha256": "a5e5f52fb7a3e0134137c38e000deed974bf310d613e4e912bbba43d29634d45", "law_version": "1.0", "seal_sha256": "b56ff6da66c7d7e602761548b19fdcc190031511b938b24eb1d66e3f4ed3bdb4", "verification_method": "Get-FileHash(superlaw).Hash.ToLower() == SUPERLAW_SEAL.law_sha256.ToLower()", "verification_result": true}	{"v": 1, "result": {"status": "sealed", "message": "SUPERLEY sealed and verified (real_hash == sealed_hash)."}, "end_utc": "2026-02-20T20:30:00Z", "exit_code": 0, "correlation_id": "1c6605e9-38b7-4770-b24e-99c1fcd5f75f"}	[{"id": "superlaw", "path": "C:\\\\ULTRAHUMANIA\\\\docs\\\\constitution\\\\SUPERLEY_ARQUITECTURA_ULTRAHUMANIA_v1.md", "type": "file", "sha256": "a5e5f52fb7a3e0134137c38e000deed974bf310d613e4e912bbba43d29634d45"}, {"id": "superlaw_seal", "path": "C:\\\\ULTRAHUMANIA\\\\docs\\\\constitution\\\\SUPERLAW_SEAL.json", "type": "file", "sha256": "b56ff6da66c7d7e602761548b19fdcc190031511b938b24eb1d66e3f4ed3bdb4"}]	2026-02-20 21:56:02.079549+01
d12ca9be-fa22-46b0-88e7-09e64352df83	15	f4c2f88ec42a89c716b8bf979f401ce98432a379539c673d20ca27da24da57d6	faba95d907b444e537e90bb937b5251775bb950daefe911d4a2cf6a9929b4bc6	c0d83357-8940-44b7-a361-135bbd38cf54	RESULT	constitution.superlaw.sealed	0.1.2	f12013c034553465af716bc1612e4993526d7a624cb3d235968ee2650d025c1e	b56ff6da66c7d7e602761548b19fdcc190031511b938b24eb1d66e3f4ed3bdb4	a5e5f52fb7a3e0134137c38e000deed974bf310d613e4e912bbba43d29634d45	{"law_path": "C:\\\\ULTRAHUMANIA\\\\docs\\\\constitution\\\\SUPERLEY_ARQUITECTURA_ULTRAHUMANIA_v1.md", "seal_path": "C:\\\\ULTRAHUMANIA\\\\docs\\\\constitution\\\\SUPERLAW_SEAL.json", "law_sha256": "a5e5f52fb7a3e0134137c38e000deed974bf310d613e4e912bbba43d29634d45", "law_version": "1.0", "seal_sha256": "b56ff6da66c7d7e602761548b19fdcc190031511b938b24eb1d66e3f4ed3bdb4", "verification_method": "Get-FileHash(superlaw).Hash.ToLower() == SUPERLAW_SEAL.law_sha256.ToLower()", "verification_result": true}	{"v": 1, "result": {"status": "sealed", "message": "SUPERLEY sealed and verified (correct correlation)."}, "end_utc": "2026-02-20T21:45:00Z", "exit_code": 0, "correlation_id": "c0d83357-8940-44b7-a361-135bbd38cf54"}	[{"id": "superlaw", "path": "C:\\\\ULTRAHUMANIA\\\\docs\\\\constitution\\\\SUPERLEY_ARQUITECTURA_ULTRAHUMANIA_v1.md", "type": "file", "sha256": "a5e5f52fb7a3e0134137c38e000deed974bf310d613e4e912bbba43d29634d45"}, {"id": "superlaw_seal", "path": "C:\\\\ULTRAHUMANIA\\\\docs\\\\constitution\\\\SUPERLAW_SEAL.json", "type": "file", "sha256": "b56ff6da66c7d7e602761548b19fdcc190031511b938b24eb1d66e3f4ed3bdb4"}]	2026-02-20 21:59:07.00437+01
\.


--
-- Data for Name: ledger_genesis; Type: TABLE DATA; Schema: notary; Owner: uh_core
--

COPY notary.ledger_genesis (id, genesis_hash_sha256, created_at) FROM stdin;
1	0000000000000000000000000000000000000000000000000000000000000000	2026-02-20 18:32:02.515072+01
\.


--
-- Data for Name: bitacora_errores; Type: TABLE DATA; Schema: soporte; Owner: uh_core
--

COPY soporte.bitacora_errores (id_error, error_detectado, contexto_psql, solucion_aplicada, estado_resolucion, fecha_incidente, hallazgo_clave, tecnica_aplicada, iteracion) FROM stdin;
1	Error de sintaxis CLS	Consola psql	Recordar que CLS es de Windows; en psql se usa \\! cls o Ctrl+L.	RESUELTO	2026-03-02 08:08:03.120435	\N	\N	1
2	Interferencia de Antivirus/EDR	Vectores Externos	Configurar exclusiones para C:\\HUMANIA y winsw.exe.	PREVENTIVO	2026-03-02 08:16:20.412255	\N	\N	1
3	Race Conditions (Actualizaci¢n)	Watchdog Update	Implementar Hash-check en cada inicio del binario.	PREVENTIVO	2026-03-02 08:16:20.412255	\N	\N	1
4	Desfase de Credenciales	Cuentas de Servicio	Configurar alertas de expiraci¢n de cuenta de servicio.	PENDIENTE	2026-03-02 08:16:20.412255	\N	\N	1
5	Dependencia de PowerShell	Arquitectura Windows	Asegurar ExecutionPolicy Bypass en el servicio.	MITIGADO	2026-03-02 08:19:55.452288	\N	\N	1
6	Sincronizaci¢n de Contexto	Chat-to-System	Uso obligatorio de archivos .state para evitar alucinaciones de la IA.	EN_PROGRESO	2026-03-02 08:19:55.452288	\N	\N	1
7	Fallo de persistencia de contexto	Sesiones entre chats	Creaci¢n de archivos .state y .json (last_success.json) para memoria externa.	RESUELTO	2026-03-02 09:16:29.631465	\N	\N	1
8	Inconsistencia en la estructura de consultas	Funci¢n buscar_en_uh	Casting expl¡cito a ::TEXT en todas las columnas del UNION ALL.	RESUELTO	2026-03-02 09:16:29.631465	\N	\N	1
9	Error de codificaci¢n (Mojibake)	Salida de comandos PowerShell	Configuraci¢n forzada de salida en UTF-8 con BOM.	RESUELTO	2026-03-02 09:16:29.631465	\N	\N	1
10	P‚rdida de integridad estructural	Actualizaci¢n de esquemas	Implementaci¢n de disparadores (triggers) de integridad en el esquema norm.	RESUELTO	2026-03-02 09:16:29.631465	\N	\N	1
11	Acceso Denegado Invisible (EFS)	C:\\HUMANIA bajo SYSTEM	Migraci¢n forzada de artefactos a rutas no cifradas y validaci¢n mediante UH_DIAG_FASTCHECK.	PULIDO	2026-03-02 10:01:19.550492	EFS es una capa criptogr fica que no responde a ACLs est ndar.	Arquitectura BIN/DATA	1
12	System.Object[] op_Subtraction	\N	Validar [int] para ¡ndices de arrays en manipulaciones de archivos grandes.	RESUELTO	2026-03-02 10:01:54.458065	\N	Casting de Tipos Fuerza	1
13	Persistencia de Contexto LLM	\N	Generaci¢n de INDEX_MASTER.md sincronizado con la base de datos.	RESUELTO	2026-03-02 10:01:54.458065	\N	Snapshotting de Artefactos	1
14	Incompatibilidad de Encoding Byte en PS7	C:\\ULTRAHUMANIA\\guard	Actualizaci¢n de scripts de auditor¡a y re-guardado de .ps1 con encoding utf8boms.	PULIDO	2026-03-02 10:44:50.688981	PowerShell Core requiere -AsByteStream en lugar de -Encoding Byte para validaci¢n de BOM.	Correcci¢n de Sintaxis Multi-versi¢n	1
15	System.Object[] op_Subtraction	UH_GUARD_RUN.ps1 / PS7	Forzar el tipo de dato [int] antes de la operaci¢n de resta en ¡ndices.	RESUELTO	2026-03-02 10:45:54.437079	Los arrays en PS7 devuelven objetos gen‚ricos que no soportan operadores aritm‚ticos directamente.	Casting Expl¡cito [int]	1
16	Bloqueo Invisible EFS	C:\\HUMANIA (SYSTEM)	Mover artefactos fuera de carpetas con atributos de cifrado de usuario.	PULIDO	2026-03-02 10:45:54.437079	Archivos cifrados con EFS por cuentas de usuario son inaccesibles para SYSTEM sin el certificado.	Migraci¢n BIN/DATA	1
17	Fallo de Verificador BOM	Procedimientos de Auditor¡a	Actualizar scripts de auditor¡a para usar -AsByteStream o clases .NET.	RESUELTO	2026-03-02 10:45:54.437079	Sintaxis -Encoding Byte no es compatible con PowerShell Core.	Refactorizaci¢n AsByteStream	1
18	P‚rdida de Contexto entre Sesiones	Interfaz IA-Humano	Implementaci¢n de carga obligatoria de INDEX_MASTER.md al iniciar turno.	ESTABLE	2026-03-02 10:45:54.437079	La memoria del chat es vol til; el sistema debe leer artefactos f¡sicos al inicio.	Protocolo ACK_INIT	1
19	Conflicto de Rutas HUMANIA/ULTRAHUMANIA	Estructura de Directorios	Mover todo el contenido vivo a C:\\ULTRAHUMANIA y archivar C:\\HUMANIA.	PULIDO	2026-03-02 10:45:54.437079	La coexistencia de dos ra¡ces genera dispersi¢n de backups y scripts.	Unificaci¢n Estructural	1
20	Colision con Variable Reservada $error	PowerShell / Auditoria Lupa	Sustitucion de $error por $dbEntry en todos los scripts de auditoria.	PULIDO	2026-03-02 11:03:29.674465	La variable $error es una constante de solo lectura en PowerShell; intentar usarla en foreach causa WriteError.	Renombrado de Variable de Iteracion	1
21	Dependencia de Sesion de Usuario	Infraestructura de Servicios	Registro de UH_GUARD_RUN.ps1 como servicio de Windows con politicas de autorrecuperacion.	PULIDO	2026-03-02 11:18:20.280847	Los scripts manuales mueren al cerrar la terminal o la sesion de Windows.	Arquitectura de Servicio de Sistema (Automatico)	1
22	Fallo de binding CIM en Register-ScheduledTask	PowerShell 5.1/7.x Infrastructure	Registro de tarea Watchdog mediante comando nativo de Windows para asegurar persistencia.	PULIDO	2026-03-02 11:37:51.995494	Incompatibilidad de tipos MSFT_TaskAction en la sesion actual.	Sustitucion de Cmdlet por binario nativo schtasks.exe	1
23	Incompatibilidad de Verificaci¢n de Bits (PS5 vs PS7)	Auditoria de Integridad / BOM Check	Estandarizaci¢n de verificadores para interoperabilidad de motores PowerShell.	PULIDO	2026-03-02 11:43:18.160251	El par metro -Encoding Byte fall¢ en el motor actual, impidiendo la validaci¢n autom tica.	Sustituci¢n por [System.IO.File]::ReadAllBytes y validaci¢n de Heartbeat manual.	1
24	Desviaci¢n de Rutas Externas	File System	Inclusi¢n de rutas en la Matriz de Integridad.	PULIDO	2026-03-02 18:21:33.335413	Existencia de mara¤a de carpetas (TRANSHUMANIA, GOLD) fuera del n£cleo.	Mapeo de Rutas en leyes.mapa_rutas	1
25	Inconsistencia de Eventos de Energ¡a	PowerShell / Win32	Monitorizaci¢n activa en memoria (Job 66).	PULIDO	2026-03-02 18:21:33.335413	Fallo de binding en ScriptBlock para el monitor de suspensi¢n.	Uso de Register-ObjectEvent directo	1
26	Falta de Blindaje de Binarios	Arquitectura de Software	Planificaci¢n de migraci¢n de m¢dulos cr¡ticos a binarios compilados.	EN_PROGRESO	2026-03-02 18:21:33.335413	Dependencia excesiva de scripts interpretados (.ps1).	Propuesta de N£cleo de Hierro (Rust)	1
\.


--
-- Name: session_logs_id_seq; Type: SEQUENCE SET; Schema: execution; Owner: postgres
--

SELECT pg_catalog.setval('execution.session_logs_id_seq', 6, true);


--
-- Name: constitucion_id_ley_seq; Type: SEQUENCE SET; Schema: leyes; Owner: uh_core
--

SELECT pg_catalog.setval('leyes.constitucion_id_ley_seq', 19, true);


--
-- Name: mapa_rutas_id_seq; Type: SEQUENCE SET; Schema: leyes; Owner: uh_core
--

SELECT pg_catalog.setval('leyes.mapa_rutas_id_seq', 5, true);


--
-- Name: principios_valores_id_valor_seq; Type: SEQUENCE SET; Schema: leyes; Owner: uh_core
--

SELECT pg_catalog.setval('leyes.principios_valores_id_valor_seq', 2, true);


--
-- Name: protocolos_respuesta_id_protocolo_seq; Type: SEQUENCE SET; Schema: leyes; Owner: uh_core
--

SELECT pg_catalog.setval('leyes.protocolos_respuesta_id_protocolo_seq', 4, true);


--
-- Name: constitucion_id_seq; Type: SEQUENCE SET; Schema: norm; Owner: postgres
--

SELECT pg_catalog.setval('norm.constitucion_id_seq', 2, true);


--
-- Name: integridad_id_registro_seq; Type: SEQUENCE SET; Schema: norm; Owner: uh_core
--

SELECT pg_catalog.setval('norm.integridad_id_registro_seq', 3, true);


--
-- Name: metadatos_archivos_id_archivo_seq; Type: SEQUENCE SET; Schema: norm; Owner: uh_core
--

SELECT pg_catalog.setval('norm.metadatos_archivos_id_archivo_seq', 1, false);


--
-- Name: nodos_operativos_id_nodo_seq; Type: SEQUENCE SET; Schema: norm; Owner: uh_core
--

SELECT pg_catalog.setval('norm.nodos_operativos_id_nodo_seq', 3, true);


--
-- Name: ledger_events_seq_seq; Type: SEQUENCE SET; Schema: notary; Owner: uh_core
--

SELECT pg_catalog.setval('notary.ledger_events_seq_seq', 15, true);


--
-- Name: bitacora_errores_id_error_seq; Type: SEQUENCE SET; Schema: soporte; Owner: uh_core
--

SELECT pg_catalog.setval('soporte.bitacora_errores_id_error_seq', 26, true);


--
-- Name: session_logs session_logs_pkey; Type: CONSTRAINT; Schema: execution; Owner: postgres
--

ALTER TABLE ONLY execution.session_logs
    ADD CONSTRAINT session_logs_pkey PRIMARY KEY (id);


--
-- Name: problems problems_pkey; Type: CONSTRAINT; Schema: kb; Owner: postgres
--

ALTER TABLE ONLY kb.problems
    ADD CONSTRAINT problems_pkey PRIMARY KEY (id);


--
-- Name: solutions solutions_pkey; Type: CONSTRAINT; Schema: kb; Owner: postgres
--

ALTER TABLE ONLY kb.solutions
    ADD CONSTRAINT solutions_pkey PRIMARY KEY (id);


--
-- Name: soporte_tecnico soporte_tecnico_pkey; Type: CONSTRAINT; Schema: kb; Owner: postgres
--

ALTER TABLE ONLY kb.soporte_tecnico
    ADD CONSTRAINT soporte_tecnico_pkey PRIMARY KEY (conversation_id);


--
-- Name: constitucion constitucion_pkey; Type: CONSTRAINT; Schema: leyes; Owner: uh_core
--

ALTER TABLE ONLY leyes.constitucion
    ADD CONSTRAINT constitucion_pkey PRIMARY KEY (id_ley);


--
-- Name: mapa_rutas mapa_rutas_pkey; Type: CONSTRAINT; Schema: leyes; Owner: uh_core
--

ALTER TABLE ONLY leyes.mapa_rutas
    ADD CONSTRAINT mapa_rutas_pkey PRIMARY KEY (id);


--
-- Name: mapa_rutas mapa_rutas_ruta_key; Type: CONSTRAINT; Schema: leyes; Owner: uh_core
--

ALTER TABLE ONLY leyes.mapa_rutas
    ADD CONSTRAINT mapa_rutas_ruta_key UNIQUE (ruta);


--
-- Name: principios_valores principios_valores_pkey; Type: CONSTRAINT; Schema: leyes; Owner: uh_core
--

ALTER TABLE ONLY leyes.principios_valores
    ADD CONSTRAINT principios_valores_pkey PRIMARY KEY (id_valor);


--
-- Name: protocolos_respuesta protocolos_respuesta_nombre_protocolo_key; Type: CONSTRAINT; Schema: leyes; Owner: uh_core
--

ALTER TABLE ONLY leyes.protocolos_respuesta
    ADD CONSTRAINT protocolos_respuesta_nombre_protocolo_key UNIQUE (nombre_protocolo);


--
-- Name: protocolos_respuesta protocolos_respuesta_pkey; Type: CONSTRAINT; Schema: leyes; Owner: uh_core
--

ALTER TABLE ONLY leyes.protocolos_respuesta
    ADD CONSTRAINT protocolos_respuesta_pkey PRIMARY KEY (id_protocolo);


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
-- Name: ledger_events chk_evidence_manifest_is_array; Type: CHECK CONSTRAINT; Schema: notary; Owner: uh_core
--

ALTER TABLE notary.ledger_events
    ADD CONSTRAINT chk_evidence_manifest_is_array CHECK (((evidence_manifest IS NULL) OR (jsonb_typeof(evidence_manifest) = 'array'::text))) NOT VALID;


--
-- Name: ledger_events ledger_events_pkey; Type: CONSTRAINT; Schema: notary; Owner: uh_core
--

ALTER TABLE ONLY notary.ledger_events
    ADD CONSTRAINT ledger_events_pkey PRIMARY KEY (event_id);


--
-- Name: ledger_events ledger_events_seq_key; Type: CONSTRAINT; Schema: notary; Owner: uh_core
--

ALTER TABLE ONLY notary.ledger_events
    ADD CONSTRAINT ledger_events_seq_key UNIQUE (seq);


--
-- Name: ledger_genesis ledger_genesis_pkey; Type: CONSTRAINT; Schema: notary; Owner: uh_core
--

ALTER TABLE ONLY notary.ledger_genesis
    ADD CONSTRAINT ledger_genesis_pkey PRIMARY KEY (id);


--
-- Name: bitacora_errores bitacora_errores_pkey; Type: CONSTRAINT; Schema: soporte; Owner: uh_core
--

ALTER TABLE ONLY soporte.bitacora_errores
    ADD CONSTRAINT bitacora_errores_pkey PRIMARY KEY (id_error);


--
-- Name: idx_kb_problems_severity; Type: INDEX; Schema: kb; Owner: postgres
--

CREATE INDEX idx_kb_problems_severity ON kb.problems USING btree (severity);


--
-- Name: idx_kb_problems_tags; Type: INDEX; Schema: kb; Owner: postgres
--

CREATE INDEX idx_kb_problems_tags ON kb.problems USING gin (tags);


--
-- Name: idx_kb_solutions_problem_id; Type: INDEX; Schema: kb; Owner: postgres
--

CREATE INDEX idx_kb_solutions_problem_id ON kb.solutions USING btree (problem_id);


--
-- Name: idx_kb_solutions_validated; Type: INDEX; Schema: kb; Owner: postgres
--

CREATE INDEX idx_kb_solutions_validated ON kb.solutions USING btree (validated);


--
-- Name: idx_ledger_action; Type: INDEX; Schema: notary; Owner: uh_core
--

CREATE INDEX idx_ledger_action ON notary.ledger_events USING btree (action_id);


--
-- Name: idx_ledger_corr; Type: INDEX; Schema: notary; Owner: uh_core
--

CREATE INDEX idx_ledger_corr ON notary.ledger_events USING btree (correlation_id);


--
-- Name: idx_ledger_created; Type: INDEX; Schema: notary; Owner: uh_core
--

CREATE INDEX idx_ledger_created ON notary.ledger_events USING btree (created_at);


--
-- Name: idx_ledger_type; Type: INDEX; Schema: notary; Owner: uh_core
--

CREATE INDEX idx_ledger_type ON notary.ledger_events USING btree (event_type);


--
-- Name: integridad trg_seguridad_n2; Type: TRIGGER; Schema: norm; Owner: uh_core
--

CREATE TRIGGER trg_seguridad_n2 BEFORE INSERT OR UPDATE ON norm.integridad FOR EACH ROW EXECUTE FUNCTION norm.fn_prevent_recursion();


--
-- Name: ledger_events trg_block_update_delete; Type: TRIGGER; Schema: notary; Owner: uh_core
--

CREATE TRIGGER trg_block_update_delete BEFORE DELETE OR UPDATE ON notary.ledger_events FOR EACH ROW EXECUTE FUNCTION notary.block_update_delete();


--
-- Name: ledger_events trg_enforce_result_has_intent; Type: TRIGGER; Schema: notary; Owner: uh_core
--

CREATE TRIGGER trg_enforce_result_has_intent BEFORE INSERT ON notary.ledger_events FOR EACH ROW EXECUTE FUNCTION notary.enforce_result_has_intent();


--
-- Name: solutions solutions_problem_id_fkey; Type: FK CONSTRAINT; Schema: kb; Owner: postgres
--

ALTER TABLE ONLY kb.solutions
    ADD CONSTRAINT solutions_problem_id_fkey FOREIGN KEY (problem_id) REFERENCES kb.problems(id) ON DELETE CASCADE;


--
-- Name: SCHEMA execution; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA execution TO uh_core;


--
-- Name: SCHEMA kb; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA kb TO uh_core;


--
-- Name: SCHEMA norm; Type: ACL; Schema: -; Owner: postgres
--

GRANT ALL ON SCHEMA norm TO uh_core;


--
-- Name: TABLE session_logs; Type: ACL; Schema: execution; Owner: postgres
--

GRANT ALL ON TABLE execution.session_logs TO uh_core;


--
-- Name: SEQUENCE session_logs_id_seq; Type: ACL; Schema: execution; Owner: postgres
--

GRANT ALL ON SEQUENCE execution.session_logs_id_seq TO uh_core;


--
-- Name: TABLE problems; Type: ACL; Schema: kb; Owner: postgres
--

GRANT ALL ON TABLE kb.problems TO uh_core;


--
-- Name: TABLE solutions; Type: ACL; Schema: kb; Owner: postgres
--

GRANT ALL ON TABLE kb.solutions TO uh_core;


--
-- Name: TABLE soporte_tecnico; Type: ACL; Schema: kb; Owner: postgres
--

GRANT ALL ON TABLE kb.soporte_tecnico TO uh_core;


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

\unrestrict fs4ULlDdGYq8lIYmBRwczgdXSKa57L8c95Qgt4Mkr0vEsmflippikhFpPYFn5xz

