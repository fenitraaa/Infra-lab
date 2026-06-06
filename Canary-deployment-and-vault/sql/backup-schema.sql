--
-- PostgreSQL database dump
--

\restrict V3JFmkbSdRWJCJzuZZRQRAkBcp1UdB99pk4JMmssrtY950g6axUE1DOKpTq4ZOJ

-- Dumped from database version 18.4 (Ubuntu 18.4-1.pgdg24.04+1)
-- Dumped by pg_dump version 18.4 (Ubuntu 18.4-1.pgdg24.04+1)

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: client; Type: TABLE; Schema: public; Owner: fenitra
--

CREATE TABLE public.client (
    idcli character varying(10) NOT NULL,
    numtel character varying(20) NOT NULL,
    nom character varying(100) NOT NULL
);


ALTER TABLE public.client OWNER TO fenitra;

--
-- Name: flyway_schema_history; Type: TABLE; Schema: public; Owner: fenitra
--

CREATE TABLE public.flyway_schema_history (
    installed_rank integer NOT NULL,
    version character varying(50),
    description character varying(200) NOT NULL,
    type character varying(20) NOT NULL,
    script character varying(1000) NOT NULL,
    checksum integer,
    installed_by character varying(100) NOT NULL,
    installed_on timestamp without time zone DEFAULT now() NOT NULL,
    execution_time integer NOT NULL,
    success boolean NOT NULL
);


ALTER TABLE public.flyway_schema_history OWNER TO fenitra;

--
-- Name: place; Type: TABLE; Schema: public; Owner: fenitra
--

CREATE TABLE public.place (
    idvoit character varying(10) NOT NULL,
    place integer NOT NULL,
    occupation boolean DEFAULT false NOT NULL
);


ALTER TABLE public.place OWNER TO fenitra;

--
-- Name: reserver; Type: TABLE; Schema: public; Owner: fenitra
--

CREATE TABLE public.reserver (
    idreserv character varying(10) NOT NULL,
    idvoit character varying(10) NOT NULL,
    idcli character varying(10) NOT NULL,
    place integer NOT NULL,
    date_reserv timestamp without time zone NOT NULL,
    date_voyage timestamp without time zone NOT NULL,
    payment character varying(20) NOT NULL,
    montant_avance integer DEFAULT 0 NOT NULL,
    CONSTRAINT reserver_payment_check CHECK (((payment)::text = ANY ((ARRAY['SANS_AVANCE'::character varying, 'AVEC_AVANCE'::character varying, 'TOUT_PAYE'::character varying])::text[])))
);


ALTER TABLE public.reserver OWNER TO fenitra;

--
-- Name: reserver_idreserv_seq; Type: SEQUENCE; Schema: public; Owner: fenitra
--

CREATE SEQUENCE public.reserver_idreserv_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.reserver_idreserv_seq OWNER TO fenitra;

--
-- Name: reserver_idreserv_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: fenitra
--

ALTER SEQUENCE public.reserver_idreserv_seq OWNED BY public.reserver.idreserv;


--
-- Name: voiture; Type: TABLE; Schema: public; Owner: fenitra
--

CREATE TABLE public.voiture (
    frais integer,
    nbrplace integer,
    idvoit character varying(10) NOT NULL,
    design character varying(100) NOT NULL,
    type character varying(255) NOT NULL,
    CONSTRAINT voiture_type_check CHECK (((type)::text = ANY ((ARRAY['SIMPLE'::character varying, 'PREMIUM'::character varying, 'VIP'::character varying])::text[])))
);


ALTER TABLE public.voiture OWNER TO fenitra;

--
-- Name: reserver idreserv; Type: DEFAULT; Schema: public; Owner: fenitra
--

ALTER TABLE ONLY public.reserver ALTER COLUMN idreserv SET DEFAULT nextval('public.reserver_idreserv_seq'::regclass);


--
-- Name: client client_pkey; Type: CONSTRAINT; Schema: public; Owner: fenitra
--

ALTER TABLE ONLY public.client
    ADD CONSTRAINT client_pkey PRIMARY KEY (idcli);


--
-- Name: flyway_schema_history flyway_schema_history_pk; Type: CONSTRAINT; Schema: public; Owner: fenitra
--

ALTER TABLE ONLY public.flyway_schema_history
    ADD CONSTRAINT flyway_schema_history_pk PRIMARY KEY (installed_rank);


--
-- Name: place place_pkey; Type: CONSTRAINT; Schema: public; Owner: fenitra
--

ALTER TABLE ONLY public.place
    ADD CONSTRAINT place_pkey PRIMARY KEY (idvoit, place);


--
-- Name: reserver reserver_pkey; Type: CONSTRAINT; Schema: public; Owner: fenitra
--

ALTER TABLE ONLY public.reserver
    ADD CONSTRAINT reserver_pkey PRIMARY KEY (idreserv);


--
-- Name: voiture voiture_pkey; Type: CONSTRAINT; Schema: public; Owner: fenitra
--

ALTER TABLE ONLY public.voiture
    ADD CONSTRAINT voiture_pkey PRIMARY KEY (idvoit);


--
-- Name: flyway_schema_history_s_idx; Type: INDEX; Schema: public; Owner: fenitra
--

CREATE INDEX flyway_schema_history_s_idx ON public.flyway_schema_history USING btree (success);


--
-- Name: place place_idvoit_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fenitra
--

ALTER TABLE ONLY public.place
    ADD CONSTRAINT place_idvoit_fkey FOREIGN KEY (idvoit) REFERENCES public.voiture(idvoit);


--
-- Name: reserver reserver_idcli_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fenitra
--

ALTER TABLE ONLY public.reserver
    ADD CONSTRAINT reserver_idcli_fkey FOREIGN KEY (idcli) REFERENCES public.client(idcli);


--
-- Name: reserver reserver_idvoit_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fenitra
--

ALTER TABLE ONLY public.reserver
    ADD CONSTRAINT reserver_idvoit_fkey FOREIGN KEY (idvoit) REFERENCES public.voiture(idvoit);


--
-- PostgreSQL database dump complete
--

\unrestrict V3JFmkbSdRWJCJzuZZRQRAkBcp1UdB99pk4JMmssrtY950g6axUE1DOKpTq4ZOJ

