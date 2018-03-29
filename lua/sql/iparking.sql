--
-- PostgreSQL database dump
--

-- Dumped from database version 10.0
-- Dumped by pg_dump version 10.0

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: cube; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS cube WITH SCHEMA public;


--
-- Name: EXTENSION cube; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION cube IS 'data type for multidimensional cubes';


--
-- Name: earthdistance; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS earthdistance WITH SCHEMA public;


--
-- Name: EXTENSION earthdistance; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION earthdistance IS 'calculate great-circle distances on the surface of the Earth';


SET search_path = public, pg_catalog;

--
-- Name: func_after_insert_appointment(); Type: FUNCTION; Schema: public; Owner: iparking
--

CREATE FUNCTION func_after_insert_appointment() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    cnt int;
BEGIN
        UPDATE  park_space set status=2 where space_id=NEW.space_id and lots_id=NEW.lots_id;
        RETURN NEW;
END;
$$;


ALTER FUNCTION public.func_after_insert_appointment() OWNER TO iparking;

--
-- Name: func_before_insert_data_up(); Type: FUNCTION; Schema: public; Owner: iparking
--

CREATE FUNCTION func_before_insert_data_up() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    cnt int;
    js jsonb := NEW.data_js;
BEGIN
    --更新车位状态
    IF js->>'error'!='NONE' or js->>'msg'!='PARKING_SPACE_STATUS' then
        return NEW;
    END IF;
    IF js->>'msg' = 'PARKING_SPACE_STATUS' THEN
        update park_space set status=js->>'status' where dev_eui=NEW.dev_eui;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.func_before_insert_data_up() OWNER TO iparking;

--
-- Name: hex_to_dec(text); Type: FUNCTION; Schema: public; Owner: iparking
--

CREATE FUNCTION hex_to_dec(in_hex text) RETURNS bigint
    LANGUAGE plpgsql IMMUTABLE STRICT
    AS $_$
 declare bl int := 8;
begin
  return   ('x' || $1)::bit varying::BIGINT;
end;
$_$;


ALTER FUNCTION public.hex_to_dec(in_hex text) OWNER TO iparking;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: appointment; Type: TABLE; Schema: public; Owner: iparking
--

CREATE TABLE appointment (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    begin_time timestamp without time zone DEFAULT (now())::timestamp without time zone NOT NULL,
    duration integer DEFAULT 600 NOT NULL,
    space_id integer NOT NULL
);


ALTER TABLE appointment OWNER TO iparking;

--
-- Name: appointment_id_seq; Type: SEQUENCE; Schema: public; Owner: iparking
--

CREATE SEQUENCE appointment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE appointment_id_seq OWNER TO iparking;

--
-- Name: appointment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: iparking
--

ALTER SEQUENCE appointment_id_seq OWNED BY appointment.id;


--
-- Name: billing; Type: TABLE; Schema: public; Owner: iparking
--

CREATE TABLE billing (
    id bigint NOT NULL,
    time_s timestamp without time zone DEFAULT (now())::timestamp without time zone NOT NULL,
    reason text,
    fee integer DEFAULT 0 NOT NULL
);


ALTER TABLE billing OWNER TO iparking;

--
-- Name: billing_id_seq; Type: SEQUENCE; Schema: public; Owner: iparking
--

CREATE SEQUENCE billing_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE billing_id_seq OWNER TO iparking;

--
-- Name: billing_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: iparking
--

ALTER SEQUENCE billing_id_seq OWNED BY billing.id;


--
-- Name: data_up; Type: TABLE; Schema: public; Owner: iparking
--

CREATE TABLE data_up (
    dev_eui bytea,
    time_s timestamp without time zone DEFAULT (now())::timestamp without time zone,
    raw bytea NOT NULL,
    data_js jsonb NOT NULL
);


ALTER TABLE data_up OWNER TO iparking;

--
-- Name: event; Type: TABLE; Schema: public; Owner: iparking
--

CREATE TABLE event (
    id integer NOT NULL,
    etype integer,
    time_s timestamp without time zone,
    degree integer,
    status integer
);


ALTER TABLE event OWNER TO iparking;

--
-- Name: event_id_seq; Type: SEQUENCE; Schema: public; Owner: iparking
--

CREATE SEQUENCE event_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE event_id_seq OWNER TO iparking;

--
-- Name: event_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: iparking
--

ALTER SEQUENCE event_id_seq OWNED BY event.id;


--
-- Name: park_incident; Type: TABLE; Schema: public; Owner: iparking
--

CREATE TABLE park_incident (
    id bigint NOT NULL,
    time_s timestamp without time zone DEFAULT (now())::timestamp without time zone NOT NULL,
    user_id integer NOT NULL,
    action text NOT NULL,
    space_id integer NOT NULL
);


ALTER TABLE park_incident OWNER TO iparking;

--
-- Name: park_incident_id_seq; Type: SEQUENCE; Schema: public; Owner: iparking
--

CREATE SEQUENCE park_incident_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE park_incident_id_seq OWNER TO iparking;

--
-- Name: park_incident_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: iparking
--

ALTER SEQUENCE park_incident_id_seq OWNED BY park_incident.id;


--
-- Name: park_lots; Type: TABLE; Schema: public; Owner: iparking
--

CREATE TABLE park_lots (
    lots_id integer NOT NULL,
    name text NOT NULL,
    city text NOT NULL,
    lat double precision NOT NULL,
    lon double precision NOT NULL
);


ALTER TABLE park_lots OWNER TO iparking;

--
-- Name: park_lots_id_seq; Type: SEQUENCE; Schema: public; Owner: iparking
--

CREATE SEQUENCE park_lots_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE park_lots_id_seq OWNER TO iparking;

--
-- Name: park_lots_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: iparking
--

ALTER SEQUENCE park_lots_id_seq OWNED BY park_lots.lots_id;


--
-- Name: park_space; Type: TABLE; Schema: public; Owner: iparking
--

CREATE TABLE park_space (
    space_id integer NOT NULL,
    dev_eui bytea,
    lots_id integer NOT NULL,
    des text DEFAULT ''::text NOT NULL,
    status text DEFAULT 'IDLE'::text NOT NULL,
    "position" point
);


ALTER TABLE park_space OWNER TO iparking;

--
-- Name: park_space_space_id_seq; Type: SEQUENCE; Schema: public; Owner: iparking
--

CREATE SEQUENCE park_space_space_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE park_space_space_id_seq OWNER TO iparking;

--
-- Name: park_space_space_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: iparking
--

ALTER SEQUENCE park_space_space_id_seq OWNED BY park_space.space_id;


--
-- Name: user_feedback; Type: TABLE; Schema: public; Owner: iparking
--

CREATE TABLE user_feedback (
    id integer NOT NULL,
    user_id integer,
    content text,
    degree integer,
    time_s timestamp without time zone
);


ALTER TABLE user_feedback OWNER TO iparking;

--
-- Name: user_feedback_id_seq; Type: SEQUENCE; Schema: public; Owner: iparking
--

CREATE SEQUENCE user_feedback_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE user_feedback_id_seq OWNER TO iparking;

--
-- Name: user_feedback_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: iparking
--

ALTER SEQUENCE user_feedback_id_seq OWNED BY user_feedback.id;


--
-- Name: user_info; Type: TABLE; Schema: public; Owner: iparking
--

CREATE TABLE user_info (
    user_id integer NOT NULL,
    mail text,
    password text NOT NULL,
    role_id integer DEFAULT 1 NOT NULL,
    open_id text
);


ALTER TABLE user_info OWNER TO iparking;

--
-- Name: user_info_id_seq; Type: SEQUENCE; Schema: public; Owner: iparking
--

CREATE SEQUENCE user_info_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE user_info_id_seq OWNER TO iparking;

--
-- Name: user_info_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: iparking
--

ALTER SEQUENCE user_info_id_seq OWNED BY user_info.user_id;


--
-- Name: appointment id; Type: DEFAULT; Schema: public; Owner: iparking
--

ALTER TABLE ONLY appointment ALTER COLUMN id SET DEFAULT nextval('appointment_id_seq'::regclass);


--
-- Name: billing id; Type: DEFAULT; Schema: public; Owner: iparking
--

ALTER TABLE ONLY billing ALTER COLUMN id SET DEFAULT nextval('billing_id_seq'::regclass);


--
-- Name: event id; Type: DEFAULT; Schema: public; Owner: iparking
--

ALTER TABLE ONLY event ALTER COLUMN id SET DEFAULT nextval('event_id_seq'::regclass);


--
-- Name: park_incident id; Type: DEFAULT; Schema: public; Owner: iparking
--

ALTER TABLE ONLY park_incident ALTER COLUMN id SET DEFAULT nextval('park_incident_id_seq'::regclass);


--
-- Name: park_lots lots_id; Type: DEFAULT; Schema: public; Owner: iparking
--

ALTER TABLE ONLY park_lots ALTER COLUMN lots_id SET DEFAULT nextval('park_lots_id_seq'::regclass);


--
-- Name: park_space space_id; Type: DEFAULT; Schema: public; Owner: iparking
--

ALTER TABLE ONLY park_space ALTER COLUMN space_id SET DEFAULT nextval('park_space_space_id_seq'::regclass);


--
-- Name: user_feedback id; Type: DEFAULT; Schema: public; Owner: iparking
--

ALTER TABLE ONLY user_feedback ALTER COLUMN id SET DEFAULT nextval('user_feedback_id_seq'::regclass);


--
-- Name: user_info user_id; Type: DEFAULT; Schema: public; Owner: iparking
--

ALTER TABLE ONLY user_info ALTER COLUMN user_id SET DEFAULT nextval('user_info_id_seq'::regclass);


--
-- Name: event event_pkey; Type: CONSTRAINT; Schema: public; Owner: iparking
--

ALTER TABLE ONLY event
    ADD CONSTRAINT event_pkey PRIMARY KEY (id);


--
-- Name: park_lots park_lots_pkey; Type: CONSTRAINT; Schema: public; Owner: iparking
--

ALTER TABLE ONLY park_lots
    ADD CONSTRAINT park_lots_pkey PRIMARY KEY (lots_id);


--
-- Name: park_space park_space_pkey; Type: CONSTRAINT; Schema: public; Owner: iparking
--

ALTER TABLE ONLY park_space
    ADD CONSTRAINT park_space_pkey PRIMARY KEY (space_id);


--
-- Name: user_feedback user_feedback_pkey; Type: CONSTRAINT; Schema: public; Owner: iparking
--

ALTER TABLE ONLY user_feedback
    ADD CONSTRAINT user_feedback_pkey PRIMARY KEY (id);


--
-- Name: user_info user_info_pkey; Type: CONSTRAINT; Schema: public; Owner: iparking
--

ALTER TABLE ONLY user_info
    ADD CONSTRAINT user_info_pkey PRIMARY KEY (user_id);


--
-- Name: park_lots_ll_to_earth_idx; Type: INDEX; Schema: public; Owner: iparking
--

CREATE INDEX park_lots_ll_to_earth_idx ON park_lots USING gist (ll_to_earth(lat, lon));


--
-- Name: appointment tgg_after_insert_appointment; Type: TRIGGER; Schema: public; Owner: iparking
--

CREATE TRIGGER tgg_after_insert_appointment AFTER INSERT ON appointment FOR EACH ROW EXECUTE PROCEDURE func_after_insert_appointment();


--
-- Name: data_up tgg_before_insert_data_up; Type: TRIGGER; Schema: public; Owner: iparking
--

CREATE TRIGGER tgg_before_insert_data_up AFTER INSERT ON data_up FOR EACH ROW EXECUTE PROCEDURE func_before_insert_data_up();


--
-- Name: park_incident fk_space_id; Type: FK CONSTRAINT; Schema: public; Owner: iparking
--

ALTER TABLE ONLY park_incident
    ADD CONSTRAINT fk_space_id FOREIGN KEY (space_id) REFERENCES park_space(space_id);


--
-- Name: appointment fk_space_id; Type: FK CONSTRAINT; Schema: public; Owner: iparking
--

ALTER TABLE ONLY appointment
    ADD CONSTRAINT fk_space_id FOREIGN KEY (space_id) REFERENCES park_space(space_id);


--
-- Name: park_space park_space_lots_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: iparking
--

ALTER TABLE ONLY park_space
    ADD CONSTRAINT park_space_lots_id_fkey FOREIGN KEY (lots_id) REFERENCES park_lots(lots_id);


--
-- PostgreSQL database dump complete
--

