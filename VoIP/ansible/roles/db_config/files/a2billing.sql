--
-- PostgreSQL database dump
--

\restrict YqB7rbSlCi1SIrdrzc5eI6v1cyk0SObhA31wvDcGTD0f5mGXJzSh8RZfnAeJO3K

-- Dumped from database version 15.19 (Debian 15.19-0+deb12u1)
-- Dumped by pg_dump version 15.19 (Debian 15.19-0+deb12u1)

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
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

-- *not* creating schema, since initdb creates it


--
-- Name: cc_card_serial_set(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.cc_card_serial_set() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    UPDATE cc_card_seria SET value=value+1 WHERE id=NEW.id_seria;
    SELECT value INTO NEW.serial FROM cc_card_seria WHERE id=NEW.id_seria;
    RETURN NEW;
  END
$$;


--
-- Name: cc_card_serial_update(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.cc_card_serial_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    IF NEW.id_seria IS NOT NULL AND NEW.id_seria = OLD.id_seria THEN
      RETURN NEW;
    END IF;
    UPDATE cc_card_seria SET value=value+1 WHERE id=NEW.id_seria;
    SELECT value INTO NEW.serial FROM cc_card_seria WHERE id=NEW.id_seria;
    RETURN NEW;
  END
$$;


--
-- Name: cc_ratecard_validate_regex(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.cc_ratecard_validate_regex() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
  BEGIN
    IF SUBSTRING(new.dialprefix,1,1) != '_' THEN
      RETURN new;
    END IF;
    PERFORM '0' ~* REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE('^' || new.dialprefix || '$', 'X', '[0-9]', 'g'), 'Z', '[1-9]', 'g'), 'N', '[2-9]', 'g'), E'\\.', E'\\.+', 'g'), '_', '', 'g');
    RETURN new;
  END
$_$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: cc_agent; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_agent (
    id bigint NOT NULL,
    datecreation timestamp without time zone DEFAULT now(),
    active boolean DEFAULT false NOT NULL,
    login character varying(20) NOT NULL,
    passwd character varying(40),
    location text,
    language character varying(5) DEFAULT 'en'::text,
    id_tariffgroup integer,
    options integer DEFAULT 0 NOT NULL,
    credit numeric(15,5) DEFAULT 0 NOT NULL,
    currency character varying(3) DEFAULT 'USD'::character varying NOT NULL,
    locale character varying(10) DEFAULT 'C'::character varying,
    commission numeric(10,4) DEFAULT 0 NOT NULL,
    vat numeric(10,4) DEFAULT 0 NOT NULL,
    banner text,
    perms integer,
    lastname character varying(50),
    firstname character varying(50),
    address character varying(100),
    city character varying(40),
    state character varying(40),
    country character varying(40),
    zipcode character varying(20),
    phone character varying(20),
    email character varying(70),
    fax character varying(20),
    company character varying(50)
);


--
-- Name: cc_agent_commission; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_agent_commission (
    id bigint NOT NULL,
    id_payment bigint,
    id_card bigint NOT NULL,
    date timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    amount numeric(15,5) NOT NULL,
    paid_status smallint DEFAULT '0'::smallint NOT NULL,
    description text,
    id_agent integer NOT NULL
);


--
-- Name: cc_agent_commission_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_agent_commission_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_agent_commission_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_agent_commission_id_seq OWNED BY public.cc_agent_commission.id;


--
-- Name: cc_agent_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_agent_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_agent_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_agent_id_seq OWNED BY public.cc_agent.id;


--
-- Name: cc_agent_signup; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_agent_signup (
    id bigint NOT NULL,
    id_agent integer NOT NULL,
    code character varying(30) NOT NULL,
    id_tariffgroup integer NOT NULL,
    id_group integer NOT NULL
);


--
-- Name: cc_agent_signup_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_agent_signup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_agent_signup_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_agent_signup_id_seq OWNED BY public.cc_agent_signup.id;


--
-- Name: cc_agent_tariffgroup; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_agent_tariffgroup (
    id_agent bigint NOT NULL,
    id_tariffgroup integer NOT NULL
);


--
-- Name: cc_alarm; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_alarm (
    id bigint NOT NULL,
    name text NOT NULL,
    periode integer DEFAULT 1 NOT NULL,
    type integer DEFAULT 1 NOT NULL,
    maxvalue numeric NOT NULL,
    minvalue numeric DEFAULT '-1'::integer NOT NULL,
    id_trunk integer,
    status integer DEFAULT 0 NOT NULL,
    numberofrun integer DEFAULT 0 NOT NULL,
    numberofalarm integer DEFAULT 0 NOT NULL,
    datecreate timestamp without time zone DEFAULT now(),
    datelastrun timestamp without time zone DEFAULT now(),
    emailreport text
);


--
-- Name: cc_alarm_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_alarm_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_alarm_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_alarm_id_seq OWNED BY public.cc_alarm.id;


--
-- Name: cc_alarm_report; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_alarm_report (
    id bigint NOT NULL,
    cc_alarm_id bigint NOT NULL,
    calculatedvalue numeric NOT NULL,
    daterun timestamp without time zone DEFAULT now()
);


--
-- Name: cc_alarm_report_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_alarm_report_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_alarm_report_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_alarm_report_id_seq OWNED BY public.cc_alarm_report.id;


--
-- Name: cc_autorefill_report; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_autorefill_report (
    id bigint NOT NULL,
    daterun timestamp(0) without time zone DEFAULT now(),
    totalcardperform integer,
    totalcredit double precision
);


--
-- Name: cc_autorefill_report_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_autorefill_report_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_autorefill_report_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_autorefill_report_id_seq OWNED BY public.cc_autorefill_report.id;


--
-- Name: cc_backup; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_backup (
    id bigint NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    path character varying(255) DEFAULT ''::character varying NOT NULL,
    creationdate timestamp without time zone DEFAULT now()
);


--
-- Name: cc_backup_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_backup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_backup_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_backup_id_seq OWNED BY public.cc_backup.id;


--
-- Name: cc_billing_customer; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_billing_customer (
    id bigint NOT NULL,
    id_card bigint NOT NULL,
    date timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    id_invoice bigint NOT NULL
);


--
-- Name: cc_billing_customer_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_billing_customer_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_billing_customer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_billing_customer_id_seq OWNED BY public.cc_billing_customer.id;


--
-- Name: cc_call; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_call (
    id bigint NOT NULL,
    card_id bigint NOT NULL,
    sessionid text NOT NULL,
    uniqueid text NOT NULL,
    nasipaddress text,
    starttime timestamp without time zone,
    stoptime timestamp without time zone,
    sessiontime integer,
    calledstation text,
    destination integer DEFAULT 0,
    terminatecauseid smallint DEFAULT 1,
    sessionbill double precision,
    id_tariffgroup integer,
    id_tariffplan integer,
    id_ratecard integer,
    id_trunk integer,
    sipiax integer DEFAULT 0,
    src text,
    id_did integer,
    buycost numeric(15,5) DEFAULT 0,
    id_card_package_offer integer DEFAULT 0,
    real_sessiontime integer,
    dnid character varying(40),
    a2b_custom1 character varying(255),
    a2b_custom2 character varying(255)
);


--
-- Name: cc_call_archive; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_call_archive (
    id bigint NOT NULL,
    card_id bigint NOT NULL,
    sessionid text NOT NULL,
    uniqueid text NOT NULL,
    nasipaddress text,
    starttime timestamp without time zone,
    stoptime timestamp without time zone,
    sessiontime integer,
    calledstation text,
    destination integer DEFAULT 0,
    terminatecauseid smallint DEFAULT 1,
    sessionbill double precision,
    id_tariffgroup integer,
    id_tariffplan integer,
    id_ratecard integer,
    id_trunk integer,
    sipiax integer DEFAULT 0,
    src text,
    id_did integer,
    buycost numeric(15,5) DEFAULT 0,
    id_card_package_offer integer DEFAULT 0,
    real_sessiontime integer,
    dnid character varying(40)
);


--
-- Name: cc_call_archive_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_call_archive_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_call_archive_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_call_archive_id_seq OWNED BY public.cc_call_archive.id;


--
-- Name: cc_call_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_call_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_call_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_call_id_seq OWNED BY public.cc_call.id;


--
-- Name: cc_callback_spool; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_callback_spool (
    id bigint NOT NULL,
    uniqueid text,
    entry_time timestamp without time zone DEFAULT now(),
    status text,
    server_ip text,
    num_attempt integer DEFAULT 0 NOT NULL,
    last_attempt_time timestamp without time zone,
    manager_result text,
    agi_result text,
    callback_time timestamp without time zone,
    channel text,
    exten text,
    context text,
    priority text,
    application text,
    data text,
    timeout text,
    callerid text,
    variable character varying(300),
    account text,
    async text,
    actionid text,
    id_server integer,
    id_server_group integer
);


--
-- Name: cc_callback_spool_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_callback_spool_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_callback_spool_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_callback_spool_id_seq OWNED BY public.cc_callback_spool.id;


--
-- Name: cc_callerid; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_callerid (
    id bigint NOT NULL,
    cid text NOT NULL,
    id_cc_card bigint NOT NULL,
    activated boolean DEFAULT true NOT NULL
);


--
-- Name: cc_callerid_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_callerid_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_callerid_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_callerid_id_seq OWNED BY public.cc_callerid.id;


--
-- Name: cc_campaign; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_campaign (
    id bigint NOT NULL,
    name character varying(50) NOT NULL,
    creationdate timestamp without time zone DEFAULT now(),
    startingdate timestamp without time zone DEFAULT now(),
    expirationdate timestamp without time zone,
    description text,
    id_card bigint DEFAULT '0'::bigint NOT NULL,
    secondusedreal integer DEFAULT 0,
    nb_callmade integer DEFAULT 0,
    status integer DEFAULT 1 NOT NULL,
    frequency integer DEFAULT 20 NOT NULL,
    forward_number character varying(50),
    daily_start_time time without time zone DEFAULT '10:00:00'::time without time zone NOT NULL,
    daily_stop_time time without time zone DEFAULT '18:00:00'::time without time zone NOT NULL,
    monday smallint DEFAULT '1'::smallint NOT NULL,
    tuesday smallint DEFAULT '1'::smallint NOT NULL,
    wednesday smallint DEFAULT '1'::smallint NOT NULL,
    thursday smallint DEFAULT '1'::smallint NOT NULL,
    friday smallint DEFAULT '1'::smallint NOT NULL,
    saturday smallint DEFAULT '0'::smallint NOT NULL,
    sunday smallint DEFAULT '0'::smallint NOT NULL,
    id_cid_group integer NOT NULL,
    id_campaign_config integer NOT NULL,
    callerid character varying(60) NOT NULL
);


--
-- Name: cc_campaign_config; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_campaign_config (
    id integer NOT NULL,
    name character varying(40) NOT NULL,
    flatrate numeric(15,5) DEFAULT 0 NOT NULL,
    context character varying(40) NOT NULL,
    description text
);


--
-- Name: cc_campaign_config_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_campaign_config_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_campaign_config_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_campaign_config_id_seq OWNED BY public.cc_campaign_config.id;


--
-- Name: cc_campaign_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_campaign_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_campaign_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_campaign_id_seq OWNED BY public.cc_campaign.id;


--
-- Name: cc_campaign_phonebook; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_campaign_phonebook (
    id_campaign integer NOT NULL,
    id_phonebook integer NOT NULL
);


--
-- Name: cc_campaign_phonestatus; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_campaign_phonestatus (
    id_phonenumber bigint NOT NULL,
    id_campaign integer NOT NULL,
    id_callback character varying(40) NOT NULL,
    status integer DEFAULT 0 NOT NULL,
    lastuse timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: cc_campaignconf_cardgroup; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_campaignconf_cardgroup (
    id_campaign_config integer NOT NULL,
    id_card_group integer NOT NULL
);


--
-- Name: cc_card; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_card (
    id bigint NOT NULL,
    creationdate timestamp without time zone DEFAULT now(),
    firstusedate timestamp without time zone,
    expirationdate timestamp without time zone,
    enableexpire integer DEFAULT 0,
    expiredays integer DEFAULT 0,
    username text NOT NULL,
    useralias text NOT NULL,
    uipass text,
    credit numeric(12,4) NOT NULL,
    tariff integer DEFAULT 0,
    id_didgroup integer DEFAULT 0,
    activated boolean DEFAULT false NOT NULL,
    lastname text,
    firstname text,
    address text,
    city text,
    state text,
    country text,
    zipcode text,
    phone text,
    email text,
    fax text,
    inuse integer DEFAULT 0,
    simultaccess integer DEFAULT 0,
    currency character varying(3) DEFAULT 'USD'::character varying,
    lastuse date DEFAULT now(),
    nbused integer DEFAULT 0,
    typepaid integer DEFAULT 0,
    creditlimit integer DEFAULT 0,
    voipcall integer DEFAULT 0,
    sip_buddy integer DEFAULT 0,
    iax_buddy integer DEFAULT 0,
    language text DEFAULT 'en'::text,
    redial text,
    runservice integer DEFAULT 0,
    nbservice integer DEFAULT 0,
    id_campaign integer DEFAULT 0,
    num_trials_done integer DEFAULT 0,
    vat numeric(6,3) DEFAULT 0,
    servicelastrun timestamp without time zone,
    initialbalance numeric(12,4) DEFAULT 0 NOT NULL,
    invoiceday integer DEFAULT 1,
    autorefill integer DEFAULT 0,
    loginkey text,
    mac_addr character varying(17) DEFAULT '00-00-00-00-00-00'::character varying NOT NULL,
    id_timezone integer DEFAULT 0,
    status integer DEFAULT 1 NOT NULL,
    tag character varying(50),
    voicemail_permitted integer DEFAULT 0 NOT NULL,
    voicemail_activated integer DEFAULT 0 NOT NULL,
    last_notification timestamp without time zone,
    email_notification character varying(70),
    notify_email smallint DEFAULT 0 NOT NULL,
    credit_notification integer DEFAULT '-1'::integer NOT NULL,
    id_group integer DEFAULT 1 NOT NULL,
    company_name character varying(50),
    company_website character varying(60),
    vat_rn character varying(40) DEFAULT NULL::character varying,
    traffic bigint DEFAULT 0,
    traffic_target text,
    discount numeric(5,2) DEFAULT '0'::numeric NOT NULL,
    restriction smallint DEFAULT '0'::smallint NOT NULL,
    id_seria integer,
    serial bigint,
    block smallint DEFAULT 0 NOT NULL,
    lock_pin character varying(20) DEFAULT '0'::character varying
);


--
-- Name: cc_card_archive; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_card_archive (
    id bigint NOT NULL,
    creationdate timestamp without time zone,
    firstusedate timestamp without time zone,
    expirationdate timestamp without time zone,
    enableexpire integer DEFAULT 0,
    expiredays integer DEFAULT 0,
    username text NOT NULL,
    useralias text NOT NULL,
    uipass text,
    credit numeric(12,4) NOT NULL,
    tariff integer DEFAULT 0,
    id_didgroup integer DEFAULT 0,
    activated boolean DEFAULT false NOT NULL,
    lastname text,
    firstname text,
    address text,
    city text,
    state text,
    country text,
    zipcode text,
    phone text,
    email text,
    fax text,
    inuse integer DEFAULT 0,
    simultaccess integer DEFAULT 0,
    currency character varying(3) DEFAULT 'USD'::character varying,
    lastuse date DEFAULT now(),
    nbused integer DEFAULT 0,
    typepaid integer DEFAULT 0,
    creditlimit integer DEFAULT 0,
    voipcall integer DEFAULT 0,
    sip_buddy integer DEFAULT 0,
    iax_buddy integer DEFAULT 0,
    language text DEFAULT 'en'::text,
    redial text,
    runservice integer DEFAULT 0,
    nbservice integer DEFAULT 0,
    id_campaign integer DEFAULT 0,
    num_trials_done integer DEFAULT 0,
    vat numeric(6,3) DEFAULT 0,
    servicelastrun timestamp without time zone,
    initialbalance numeric(12,4) DEFAULT 0 NOT NULL,
    invoiceday integer DEFAULT 1,
    autorefill integer DEFAULT 0,
    loginkey text,
    mac_addr character varying(17) DEFAULT '00-00-00-00-00-00'::character varying NOT NULL,
    id_timezone integer DEFAULT 0,
    status integer DEFAULT 1 NOT NULL,
    tag character varying(50),
    voicemail_permitted integer DEFAULT 0 NOT NULL,
    voicemail_activated integer DEFAULT 0 NOT NULL,
    last_notification timestamp without time zone,
    email_notification character varying(70),
    notify_email smallint DEFAULT 0 NOT NULL,
    credit_notification integer DEFAULT '-1'::integer NOT NULL,
    id_group integer DEFAULT 1 NOT NULL,
    company_name character varying(50),
    company_website character varying(60),
    vat_rn character varying(40) DEFAULT NULL::character varying,
    traffic bigint DEFAULT 0,
    traffic_target text,
    discount numeric(5,2) DEFAULT '0'::numeric NOT NULL,
    restriction smallint DEFAULT '0'::smallint NOT NULL,
    id_seria integer,
    serial bigint
);


--
-- Name: cc_card_archive_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_card_archive_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_card_archive_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_card_archive_id_seq OWNED BY public.cc_card_archive.id;


--
-- Name: cc_card_group; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_card_group (
    id integer NOT NULL,
    name character varying(30) NOT NULL,
    description text,
    users_perms integer DEFAULT 0 NOT NULL,
    id_agent integer,
    flatrate numeric(15,5) DEFAULT 0 NOT NULL,
    campaign_context character varying(40)
);


--
-- Name: cc_card_group_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_card_group_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_card_group_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_card_group_id_seq OWNED BY public.cc_card_group.id;


--
-- Name: cc_card_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_card_history (
    id bigint NOT NULL,
    id_cc_card bigint,
    datecreated timestamp without time zone DEFAULT now(),
    description text
);


--
-- Name: cc_card_history_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_card_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_card_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_card_history_id_seq OWNED BY public.cc_card_history.id;


--
-- Name: cc_card_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_card_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_card_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_card_id_seq OWNED BY public.cc_card.id;


--
-- Name: cc_card_package_offer; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_card_package_offer (
    id bigint NOT NULL,
    id_cc_card bigint NOT NULL,
    id_cc_package_offer bigint NOT NULL,
    date_consumption timestamp without time zone DEFAULT now(),
    used_secondes bigint NOT NULL
);


--
-- Name: cc_card_package_offer_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_card_package_offer_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_card_package_offer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_card_package_offer_id_seq OWNED BY public.cc_card_package_offer.id;


--
-- Name: cc_card_seria; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_card_seria (
    id integer NOT NULL,
    name character(30) NOT NULL,
    description text,
    value bigint DEFAULT 0 NOT NULL
);


--
-- Name: cc_card_seria_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_card_seria_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_card_seria_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_card_seria_id_seq OWNED BY public.cc_card_seria.id;


--
-- Name: cc_card_subscription; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_card_subscription (
    id bigint NOT NULL,
    id_cc_card bigint DEFAULT 0 NOT NULL,
    id_subscription_fee integer DEFAULT 0 NOT NULL,
    startdate timestamp without time zone DEFAULT now(),
    stopdate timestamp without time zone,
    product_id character varying(100) DEFAULT NULL::character varying,
    product_name character varying(100) DEFAULT NULL::character varying
);


--
-- Name: cc_card_subscription_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_card_subscription_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_card_subscription_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_card_subscription_id_seq OWNED BY public.cc_card_subscription.id;


--
-- Name: cc_cardgroup_service; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_cardgroup_service (
    id_card_group integer NOT NULL,
    id_service integer NOT NULL
);


--
-- Name: cc_charge; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_charge (
    id bigint NOT NULL,
    id_cc_card bigint NOT NULL,
    iduser integer DEFAULT 0 NOT NULL,
    creationdate timestamp without time zone DEFAULT now(),
    amount numeric(12,4) NOT NULL,
    currency character varying(3) DEFAULT 'USD'::character varying,
    chargetype integer DEFAULT 0,
    description text,
    id_cc_did bigint DEFAULT 0,
    id_cc_card_subscription bigint,
    cover_from date,
    cover_to date,
    charged_status smallint DEFAULT '0'::smallint NOT NULL,
    invoiced_status smallint DEFAULT '0'::smallint NOT NULL
);


--
-- Name: cc_charge_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_charge_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_charge_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_charge_id_seq OWNED BY public.cc_charge.id;


--
-- Name: cc_config; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_config (
    id integer NOT NULL,
    config_title character varying(100) NOT NULL,
    config_key character varying(100) NOT NULL,
    config_value text NOT NULL,
    config_description text NOT NULL,
    config_valuetype integer DEFAULT 0 NOT NULL,
    config_listvalues text,
    config_group_title character varying(64) NOT NULL
);


--
-- Name: cc_config_group; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_config_group (
    id integer NOT NULL,
    group_title character varying(64) NOT NULL,
    group_description character varying(255) NOT NULL
);


--
-- Name: cc_config_group_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_config_group_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_config_group_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_config_group_id_seq OWNED BY public.cc_config_group.id;


--
-- Name: cc_config_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_config_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_config_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_config_id_seq OWNED BY public.cc_config.id;


--
-- Name: cc_configuration; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_configuration (
    configuration_id bigint NOT NULL,
    configuration_title character varying(64) NOT NULL,
    configuration_key character varying(64) NOT NULL,
    configuration_value character varying(255) NOT NULL,
    configuration_description character varying(255) NOT NULL,
    configuration_type integer DEFAULT 0 NOT NULL,
    use_function character varying(255),
    set_function character varying(255)
);


--
-- Name: cc_configuration_configuration_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_configuration_configuration_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_configuration_configuration_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_configuration_configuration_id_seq OWNED BY public.cc_configuration.configuration_id;


--
-- Name: cc_country; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_country (
    id integer NOT NULL,
    countrycode text NOT NULL,
    countryprefix text DEFAULT '0'::text NOT NULL,
    countryname text NOT NULL
);


--
-- Name: cc_country_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_country_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_country_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_country_id_seq OWNED BY public.cc_country.id;


--
-- Name: cc_currencies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_currencies (
    id integer NOT NULL,
    currency character(3) DEFAULT ''::bpchar NOT NULL,
    name character varying(30) DEFAULT ''::character varying NOT NULL,
    value numeric(12,5) DEFAULT 0.00000 NOT NULL,
    lastupdate timestamp without time zone DEFAULT now(),
    basecurrency character(3) DEFAULT 'USD'::bpchar NOT NULL
);


--
-- Name: cc_currencies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_currencies_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_currencies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_currencies_id_seq OWNED BY public.cc_currencies.id;


--
-- Name: cc_did; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_did (
    id bigint NOT NULL,
    id_cc_didgroup bigint NOT NULL,
    id_cc_country integer NOT NULL,
    activated integer DEFAULT 1 NOT NULL,
    reserved integer DEFAULT 0,
    iduser bigint DEFAULT 0 NOT NULL,
    did text NOT NULL,
    creationdate timestamp without time zone DEFAULT now(),
    startingdate timestamp without time zone DEFAULT now(),
    expirationdate timestamp without time zone,
    description text,
    secondusedreal integer DEFAULT 0,
    billingtype integer DEFAULT 0,
    fixrate numeric(12,4) NOT NULL
);


--
-- Name: cc_did_destination; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_did_destination (
    id bigint NOT NULL,
    destination text NOT NULL,
    priority integer DEFAULT 0 NOT NULL,
    id_cc_card bigint NOT NULL,
    id_cc_did bigint NOT NULL,
    creationdate timestamp without time zone DEFAULT now(),
    activated integer DEFAULT 1 NOT NULL,
    secondusedreal integer DEFAULT 0,
    voip_call integer DEFAULT 0
);


--
-- Name: cc_did_destination_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_did_destination_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_did_destination_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_did_destination_id_seq OWNED BY public.cc_did_destination.id;


--
-- Name: cc_did_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_did_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_did_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_did_id_seq OWNED BY public.cc_did.id;


--
-- Name: cc_did_use; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_did_use (
    id bigint NOT NULL,
    id_cc_card bigint,
    id_did bigint NOT NULL,
    reservationdate timestamp without time zone DEFAULT now() NOT NULL,
    releasedate timestamp without time zone,
    activated integer DEFAULT 0,
    month_payed integer DEFAULT 0,
    reminded smallint DEFAULT '0'::smallint NOT NULL
);


--
-- Name: cc_did_use_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_did_use_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_did_use_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_did_use_id_seq OWNED BY public.cc_did_use.id;


--
-- Name: cc_didgroup; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_didgroup (
    id bigint NOT NULL,
    iduser integer DEFAULT 0 NOT NULL,
    creationdate timestamp without time zone DEFAULT now(),
    didgroupname text NOT NULL
);


--
-- Name: cc_didgroup_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_didgroup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_didgroup_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_didgroup_id_seq OWNED BY public.cc_didgroup.id;


--
-- Name: cc_ecommerce_product; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_ecommerce_product (
    id bigint NOT NULL,
    product_name text NOT NULL,
    creationdate timestamp without time zone DEFAULT now(),
    description text,
    expirationdate timestamp without time zone,
    enableexpire integer DEFAULT 0,
    expiredays integer DEFAULT 0,
    credit numeric(12,4) NOT NULL,
    tariff integer DEFAULT 0,
    id_didgroup integer DEFAULT 0,
    mailtype character varying(50) DEFAULT ''::character varying NOT NULL,
    activated boolean DEFAULT false NOT NULL,
    simultaccess integer DEFAULT 0,
    currency character varying(3) DEFAULT 'USD'::character varying,
    typepaid integer DEFAULT 0,
    creditlimit integer DEFAULT 0,
    language text DEFAULT 'en'::text,
    runservice integer DEFAULT 0,
    sip_friend integer DEFAULT 0,
    iax_friend integer DEFAULT 0
);


--
-- Name: cc_ecommerce_product_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_ecommerce_product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_ecommerce_product_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_ecommerce_product_id_seq OWNED BY public.cc_ecommerce_product.id;


--
-- Name: cc_epayment_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_epayment_log (
    id bigint NOT NULL,
    cardid bigint DEFAULT 0 NOT NULL,
    amount character varying(50) DEFAULT 0 NOT NULL,
    vat double precision DEFAULT 0 NOT NULL,
    paymentmethod character varying(255) NOT NULL,
    cc_owner character varying(255) NOT NULL,
    cc_number character varying(255) NOT NULL,
    cc_expires character varying(255) NOT NULL,
    creationdate timestamp(0) without time zone DEFAULT now(),
    status integer DEFAULT 0 NOT NULL,
    cvv character varying(4),
    credit_card_type character varying(20),
    currency character varying(4),
    transaction_detail text,
    item_type character varying(30),
    item_id bigint
);


--
-- Name: cc_epayment_log_agent; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_epayment_log_agent (
    id bigint NOT NULL,
    agent_id bigint DEFAULT '0'::bigint NOT NULL,
    amount character varying(50) DEFAULT '0'::numeric NOT NULL,
    vat double precision DEFAULT '0'::double precision NOT NULL,
    paymentmethod character(50) NOT NULL,
    cc_owner character varying(64) DEFAULT NULL::character varying,
    cc_number character varying(32) DEFAULT NULL::character varying,
    cc_expires character varying(7) DEFAULT NULL::character varying,
    creationdate timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    status integer DEFAULT 0 NOT NULL,
    cvv character varying(4) DEFAULT NULL::character varying,
    credit_card_type character varying(20) DEFAULT NULL::character varying,
    currency character varying(4) DEFAULT NULL::character varying,
    transaction_detail text
);


--
-- Name: cc_epayment_log_agent_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_epayment_log_agent_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_epayment_log_agent_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_epayment_log_agent_id_seq OWNED BY public.cc_epayment_log_agent.id;


--
-- Name: cc_epayment_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_epayment_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_epayment_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_epayment_log_id_seq OWNED BY public.cc_epayment_log.id;


--
-- Name: cc_iax_buddies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_iax_buddies (
    id integer NOT NULL,
    id_cc_card integer DEFAULT 0 NOT NULL,
    name character varying(80) DEFAULT ''::character varying NOT NULL,
    type character varying(6) DEFAULT 'friend'::character varying NOT NULL,
    username character varying(80) DEFAULT ''::character varying NOT NULL,
    accountcode character varying(20),
    regexten character varying(20),
    callerid character varying(80),
    amaflags character varying(7),
    secret character varying(80),
    md5secret character varying(80),
    nat character varying(3) DEFAULT 'yes'::character varying NOT NULL,
    dtmfmode character varying(7) DEFAULT 'RFC2833'::character varying NOT NULL,
    disallow character varying(100) DEFAULT 'all'::character varying,
    allow character varying(100) DEFAULT 'gsm,ulaw,alaw'::character varying,
    host character varying(31) DEFAULT ''::character varying NOT NULL,
    qualify character varying(7) DEFAULT 'yes'::character varying NOT NULL,
    canreinvite character varying(20) DEFAULT 'yes'::character varying,
    callgroup character varying(10),
    context character varying(80),
    defaultip character varying(15),
    fromuser character varying(80),
    fromdomain character varying(80),
    insecure character varying(20),
    language character varying(2),
    mailbox character varying(50),
    permit character varying(95),
    deny character varying(95),
    mask character varying(95),
    pickupgroup character varying(10),
    port character varying(5) DEFAULT ''::character varying NOT NULL,
    restrictcid character varying(1),
    rtptimeout character varying(3),
    rtpholdtimeout character varying(3),
    musiconhold character varying(100),
    regseconds integer DEFAULT 0 NOT NULL,
    ipaddr character varying(15) DEFAULT ''::character varying NOT NULL,
    cancallforward character varying(3) DEFAULT 'yes'::character varying,
    trunk character varying(3) DEFAULT 'no'::character varying
);


--
-- Name: cc_iax_buddies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_iax_buddies_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_iax_buddies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_iax_buddies_id_seq OWNED BY public.cc_iax_buddies.id;


--
-- Name: cc_invoice; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_invoice (
    id bigint NOT NULL,
    reference character varying(30),
    id_card bigint NOT NULL,
    date timestamp without time zone DEFAULT now() NOT NULL,
    paid_status smallint DEFAULT '0'::smallint NOT NULL,
    status smallint DEFAULT '0'::smallint NOT NULL,
    title character varying(50) NOT NULL,
    description text NOT NULL
);


--
-- Name: cc_invoice_conf; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_invoice_conf (
    id integer NOT NULL,
    key_val character varying(50) NOT NULL,
    value character varying(50) NOT NULL
);


--
-- Name: cc_invoice_conf_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_invoice_conf_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_invoice_conf_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_invoice_conf_id_seq OWNED BY public.cc_invoice_conf.id;


--
-- Name: cc_invoice_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_invoice_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_invoice_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_invoice_id_seq OWNED BY public.cc_invoice.id;


--
-- Name: cc_invoice_item; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_invoice_item (
    id bigint NOT NULL,
    id_invoice bigint NOT NULL,
    date timestamp without time zone DEFAULT now() NOT NULL,
    price numeric(15,5) DEFAULT '0'::numeric NOT NULL,
    vat numeric(4,2) DEFAULT '0'::numeric NOT NULL,
    description text NOT NULL,
    id_ext bigint,
    type_ext character varying(10)
);


--
-- Name: cc_invoice_item_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_invoice_item_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_invoice_item_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_invoice_item_id_seq OWNED BY public.cc_invoice_item.id;


--
-- Name: cc_invoice_payment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_invoice_payment (
    id_invoice bigint NOT NULL,
    id_payment bigint NOT NULL
);


--
-- Name: cc_iso639; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_iso639 (
    code text NOT NULL,
    name text NOT NULL,
    lname text,
    charset text DEFAULT 'ISO-8859-1'::text NOT NULL
);


--
-- Name: cc_logpayment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_logpayment (
    id bigint NOT NULL,
    date timestamp(0) without time zone DEFAULT now() NOT NULL,
    payment numeric(15,5) NOT NULL,
    card_id bigint NOT NULL,
    id_logrefill bigint,
    description text,
    added_refill smallint DEFAULT 0 NOT NULL,
    payment_type smallint DEFAULT 0 NOT NULL,
    added_commission smallint DEFAULT 0 NOT NULL
);


--
-- Name: cc_logpayment_agent; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_logpayment_agent (
    id bigint NOT NULL,
    date timestamp without time zone DEFAULT now() NOT NULL,
    payment numeric(15,5) NOT NULL,
    agent_id bigint NOT NULL,
    id_logrefill bigint,
    description text,
    added_refill smallint DEFAULT '0'::smallint NOT NULL,
    payment_type smallint DEFAULT '0'::smallint NOT NULL,
    added_commission smallint DEFAULT '0'::smallint NOT NULL
);


--
-- Name: cc_logpayment_agent_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_logpayment_agent_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_logpayment_agent_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_logpayment_agent_id_seq OWNED BY public.cc_logpayment_agent.id;


--
-- Name: cc_logpayment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_logpayment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_logpayment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_logpayment_id_seq OWNED BY public.cc_logpayment.id;


--
-- Name: cc_logrefill; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_logrefill (
    id bigint NOT NULL,
    date timestamp(0) without time zone DEFAULT now() NOT NULL,
    credit numeric(15,5) NOT NULL,
    card_id bigint NOT NULL,
    description text,
    refill_type smallint DEFAULT 0 NOT NULL,
    added_invoice smallint DEFAULT '0'::smallint NOT NULL
);


--
-- Name: cc_logrefill_agent; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_logrefill_agent (
    id bigint NOT NULL,
    date timestamp without time zone DEFAULT now() NOT NULL,
    credit numeric(15,5) NOT NULL,
    agent_id bigint NOT NULL,
    description text,
    refill_type smallint DEFAULT '0'::smallint NOT NULL
);


--
-- Name: cc_logrefill_agent_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_logrefill_agent_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_logrefill_agent_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_logrefill_agent_id_seq OWNED BY public.cc_logrefill_agent.id;


--
-- Name: cc_logrefill_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_logrefill_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_logrefill_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_logrefill_id_seq OWNED BY public.cc_logrefill.id;


--
-- Name: cc_notification; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_notification (
    id bigint NOT NULL,
    key_value character varying(40),
    date timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    priority smallint DEFAULT '0'::smallint NOT NULL,
    from_type smallint NOT NULL,
    from_id bigint DEFAULT '0'::bigint
);


--
-- Name: cc_notification_admin; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_notification_admin (
    id_notification bigint NOT NULL,
    id_admin integer NOT NULL,
    viewed smallint DEFAULT '0'::smallint NOT NULL
);


--
-- Name: cc_notification_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_notification_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_notification_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_notification_id_seq OWNED BY public.cc_notification.id;


--
-- Name: cc_outbound_cid_group; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_outbound_cid_group (
    id bigint NOT NULL,
    creationdate timestamp(0) without time zone DEFAULT now(),
    group_name text NOT NULL
);


--
-- Name: cc_outbound_cid_group_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_outbound_cid_group_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_outbound_cid_group_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_outbound_cid_group_id_seq OWNED BY public.cc_outbound_cid_group.id;


--
-- Name: cc_outbound_cid_list; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_outbound_cid_list (
    id bigint NOT NULL,
    outbound_cid_group bigint NOT NULL,
    cid text NOT NULL,
    activated integer DEFAULT 0 NOT NULL,
    creationdate timestamp(0) without time zone DEFAULT now()
);


--
-- Name: cc_outbound_cid_list_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_outbound_cid_list_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_outbound_cid_list_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_outbound_cid_list_id_seq OWNED BY public.cc_outbound_cid_list.id;


--
-- Name: cc_package_group; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_package_group (
    id integer NOT NULL,
    name character varying(30) NOT NULL,
    description text
);


--
-- Name: cc_package_group_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_package_group_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_package_group_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_package_group_id_seq OWNED BY public.cc_package_group.id;


--
-- Name: cc_package_offer; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_package_offer (
    id bigint NOT NULL,
    creationdate timestamp without time zone DEFAULT now(),
    label text NOT NULL,
    packagetype integer NOT NULL,
    billingtype integer NOT NULL,
    startday integer NOT NULL,
    freetimetocall integer NOT NULL
);


--
-- Name: cc_package_offer_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_package_offer_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_package_offer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_package_offer_id_seq OWNED BY public.cc_package_offer.id;


--
-- Name: cc_package_rate; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_package_rate (
    package_id integer NOT NULL,
    rate_id integer NOT NULL
);


--
-- Name: cc_packgroup_package; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_packgroup_package (
    packagegroup_id integer NOT NULL,
    package_id integer NOT NULL
);


--
-- Name: cc_payment_methods; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_payment_methods (
    id bigint NOT NULL,
    payment_method text NOT NULL,
    payment_filename text NOT NULL
);


--
-- Name: cc_payment_methods_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_payment_methods_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_payment_methods_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_payment_methods_id_seq OWNED BY public.cc_payment_methods.id;


--
-- Name: cc_payments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_payments (
    id bigint NOT NULL,
    customers_id bigint DEFAULT '0'::bigint NOT NULL,
    customers_name text NOT NULL,
    customers_email_address text NOT NULL,
    item_name text NOT NULL,
    item_id text NOT NULL,
    item_quantity integer DEFAULT 0 NOT NULL,
    payment_method character varying(32) NOT NULL,
    cc_type character varying(20),
    cc_owner character varying(64),
    cc_number character varying(32),
    cc_expires character varying(6),
    orders_status integer NOT NULL,
    orders_amount numeric(14,6),
    last_modified timestamp without time zone,
    date_purchased timestamp without time zone,
    orders_date_finished timestamp without time zone,
    currency character varying(3),
    currency_value numeric(14,6)
);


--
-- Name: cc_payments_agent; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_payments_agent (
    id bigint NOT NULL,
    agent_id bigint NOT NULL,
    agent_name character varying(200) NOT NULL,
    agent_email_address character varying(96) NOT NULL,
    item_name character varying(127) DEFAULT NULL::character varying,
    item_id character varying(127) DEFAULT NULL::character varying,
    item_quantity integer DEFAULT 0 NOT NULL,
    payment_method character varying(32) NOT NULL,
    cc_type character varying(20) DEFAULT NULL::character varying,
    cc_owner character varying(64) DEFAULT NULL::character varying,
    cc_number character varying(32) DEFAULT NULL::character varying,
    cc_expires character varying(4) DEFAULT NULL::character varying,
    orders_status integer NOT NULL,
    orders_amount numeric(14,6) DEFAULT NULL::numeric,
    last_modified timestamp without time zone,
    date_purchased timestamp without time zone,
    orders_date_finished timestamp without time zone,
    currency character(3) DEFAULT NULL::bpchar,
    currency_value numeric(14,6) DEFAULT NULL::numeric
);


--
-- Name: cc_payments_agent_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_payments_agent_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_payments_agent_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_payments_agent_id_seq OWNED BY public.cc_payments_agent.id;


--
-- Name: cc_payments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_payments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_payments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_payments_id_seq OWNED BY public.cc_payments.id;


--
-- Name: cc_payments_status; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_payments_status (
    id bigint NOT NULL,
    status_id integer NOT NULL,
    status_name character varying(200) NOT NULL
);


--
-- Name: cc_payments_status_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_payments_status_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_payments_status_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_payments_status_id_seq OWNED BY public.cc_payments_status.id;


--
-- Name: cc_paypal; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_paypal (
    id bigint NOT NULL,
    payer_id character varying(60) DEFAULT NULL::character varying,
    payment_date character varying(50) DEFAULT NULL::character varying,
    txn_id character varying(50) DEFAULT NULL::character varying,
    first_name character varying(50) DEFAULT NULL::character varying,
    last_name character varying(50) DEFAULT NULL::character varying,
    payer_email character varying(75) DEFAULT NULL::character varying,
    payer_status character varying(50) DEFAULT NULL::character varying,
    payment_type character varying(50) DEFAULT NULL::character varying,
    memo text,
    item_name character varying(127) DEFAULT NULL::character varying,
    item_number character varying(127) DEFAULT NULL::character varying,
    quantity bigint DEFAULT '0'::bigint NOT NULL,
    mc_gross numeric(9,2) DEFAULT NULL::numeric,
    mc_fee numeric(9,2) DEFAULT NULL::numeric,
    tax numeric(9,2) DEFAULT NULL::numeric,
    mc_currency character varying(3) DEFAULT NULL::character varying,
    address_name character varying(255) DEFAULT ''::character varying NOT NULL,
    address_street character varying(255) DEFAULT ''::character varying NOT NULL,
    address_city character varying(255) DEFAULT ''::character varying NOT NULL,
    address_state character varying(255) DEFAULT ''::character varying NOT NULL,
    address_zip character varying(255) DEFAULT ''::character varying NOT NULL,
    address_country character varying(255) DEFAULT ''::character varying NOT NULL,
    address_status character varying(255) DEFAULT ''::character varying NOT NULL,
    payer_business_name character varying(255) DEFAULT ''::character varying NOT NULL,
    payment_status character varying(255) DEFAULT ''::character varying NOT NULL,
    pending_reason character varying(255) DEFAULT ''::character varying NOT NULL,
    reason_code character varying(255) DEFAULT ''::character varying NOT NULL,
    txn_type character varying(255) DEFAULT ''::character varying NOT NULL
);


--
-- Name: cc_paypal_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_paypal_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_paypal_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_paypal_id_seq OWNED BY public.cc_paypal.id;


--
-- Name: cc_phonebook; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_phonebook (
    id integer NOT NULL,
    name character varying(30) NOT NULL,
    description text,
    id_card bigint NOT NULL
);


--
-- Name: cc_phonebook_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_phonebook_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_phonebook_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_phonebook_id_seq OWNED BY public.cc_phonebook.id;


--
-- Name: cc_phonenumber; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_phonenumber (
    id bigint NOT NULL,
    id_phonebook integer NOT NULL,
    number character varying(30) NOT NULL,
    name character varying(40),
    creationdate timestamp without time zone DEFAULT now() NOT NULL,
    status smallint DEFAULT '1'::smallint NOT NULL,
    info text,
    amount integer DEFAULT 0 NOT NULL
);


--
-- Name: cc_phonenumber_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_phonenumber_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_phonenumber_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_phonenumber_id_seq OWNED BY public.cc_phonenumber.id;


--
-- Name: cc_prefix; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_prefix (
    prefix bigint NOT NULL,
    destination character varying(60) NOT NULL
);


--
-- Name: cc_prefix_prefix_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_prefix_prefix_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_prefix_prefix_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_prefix_prefix_seq OWNED BY public.cc_prefix.prefix;


--
-- Name: cc_provider; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_provider (
    id bigint NOT NULL,
    provider_name text NOT NULL,
    creationdate timestamp without time zone DEFAULT now(),
    description text
);


--
-- Name: cc_provider_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_provider_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_provider_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_provider_id_seq OWNED BY public.cc_provider.id;


--
-- Name: cc_ratecard; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_ratecard (
    id integer NOT NULL,
    idtariffplan integer DEFAULT 0 NOT NULL,
    dialprefix text NOT NULL,
    destination integer DEFAULT 0,
    buyrate numeric(15,5) DEFAULT 0 NOT NULL,
    buyrateinitblock integer DEFAULT 0 NOT NULL,
    buyrateincrement integer DEFAULT 0 NOT NULL,
    rateinitial numeric(15,5) DEFAULT 0 NOT NULL,
    initblock integer DEFAULT 0 NOT NULL,
    billingblock integer DEFAULT 0 NOT NULL,
    connectcharge numeric(15,5) DEFAULT 0 NOT NULL,
    disconnectcharge numeric(15,5) DEFAULT 0 NOT NULL,
    stepchargea numeric(15,5) DEFAULT 0 NOT NULL,
    chargea numeric(15,5) DEFAULT 0 NOT NULL,
    timechargea integer DEFAULT 0 NOT NULL,
    billingblocka integer DEFAULT 0 NOT NULL,
    stepchargeb numeric(15,5) DEFAULT 0 NOT NULL,
    chargeb numeric(15,5) DEFAULT 0 NOT NULL,
    timechargeb integer DEFAULT 0 NOT NULL,
    billingblockb integer DEFAULT 0 NOT NULL,
    stepchargec numeric(15,5) DEFAULT 0 NOT NULL,
    chargec numeric(15,5) DEFAULT 0 NOT NULL,
    timechargec integer DEFAULT 0 NOT NULL,
    billingblockc integer DEFAULT 0 NOT NULL,
    startdate timestamp(0) without time zone DEFAULT now(),
    stopdate timestamp(0) without time zone,
    starttime integer DEFAULT 0 NOT NULL,
    endtime integer DEFAULT 10079 NOT NULL,
    id_trunk integer DEFAULT '-1'::integer,
    musiconhold character varying(100),
    id_outbound_cidgroup integer DEFAULT '-1'::integer NOT NULL,
    rounding_calltime integer DEFAULT 0 NOT NULL,
    rounding_threshold integer DEFAULT 0 NOT NULL,
    additional_block_charge numeric(15,5) DEFAULT 0 NOT NULL,
    additional_block_charge_time integer DEFAULT 0 NOT NULL,
    tag character varying(50),
    is_merged integer DEFAULT 0,
    additional_grace integer DEFAULT 0 NOT NULL,
    minimal_cost numeric(15,5) DEFAULT 0 NOT NULL,
    announce_time_correction numeric(5,3) DEFAULT 1.0 NOT NULL,
    disconnectcharge_after integer DEFAULT 0 NOT NULL
);


--
-- Name: cc_ratecard_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_ratecard_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_ratecard_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_ratecard_id_seq OWNED BY public.cc_ratecard.id;


--
-- Name: cc_receipt; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_receipt (
    id bigint NOT NULL,
    id_card bigint NOT NULL,
    date timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    title character varying(50) NOT NULL,
    description text NOT NULL,
    status smallint DEFAULT '0'::smallint NOT NULL
);


--
-- Name: cc_receipt_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_receipt_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_receipt_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_receipt_id_seq OWNED BY public.cc_receipt.id;


--
-- Name: cc_receipt_item; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_receipt_item (
    id bigint NOT NULL,
    id_receipt bigint NOT NULL,
    date timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    price numeric(15,5) DEFAULT '0'::numeric NOT NULL,
    description text NOT NULL,
    id_ext bigint,
    type_ext character varying(10) DEFAULT NULL::character varying
);


--
-- Name: cc_receipt_item_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_receipt_item_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_receipt_item_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_receipt_item_id_seq OWNED BY public.cc_receipt_item.id;


--
-- Name: cc_restricted_phonenumber; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_restricted_phonenumber (
    id bigint NOT NULL,
    number character varying(50) NOT NULL,
    id_card bigint NOT NULL
);


--
-- Name: cc_restricted_phonenumber_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_restricted_phonenumber_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_restricted_phonenumber_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_restricted_phonenumber_id_seq OWNED BY public.cc_restricted_phonenumber.id;


--
-- Name: cc_server_group; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_server_group (
    id bigint NOT NULL,
    name text,
    description text
);


--
-- Name: cc_server_group_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_server_group_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_server_group_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_server_group_id_seq OWNED BY public.cc_server_group.id;


--
-- Name: cc_server_manager; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_server_manager (
    id bigint NOT NULL,
    id_group integer DEFAULT 1,
    server_ip text,
    manager_host text,
    manager_username text,
    manager_secret text,
    lasttime_used timestamp without time zone DEFAULT now()
);


--
-- Name: cc_server_manager_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_server_manager_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_server_manager_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_server_manager_id_seq OWNED BY public.cc_server_manager.id;


--
-- Name: cc_service; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_service (
    id bigint NOT NULL,
    name text NOT NULL,
    amount double precision NOT NULL,
    period integer DEFAULT 1 NOT NULL,
    rule integer DEFAULT 0 NOT NULL,
    daynumber integer DEFAULT 0 NOT NULL,
    stopmode integer DEFAULT 0 NOT NULL,
    maxnumbercycle integer DEFAULT 0 NOT NULL,
    status integer DEFAULT 0 NOT NULL,
    numberofrun integer DEFAULT 0 NOT NULL,
    datecreate timestamp(0) without time zone DEFAULT now(),
    datelastrun timestamp(0) without time zone DEFAULT now(),
    emailreport text,
    totalcredit double precision DEFAULT 0 NOT NULL,
    totalcardperform integer DEFAULT 0 NOT NULL,
    operate_mode smallint DEFAULT 0,
    dialplan integer DEFAULT 0,
    use_group smallint DEFAULT 0
);


--
-- Name: cc_service_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_service_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_service_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_service_id_seq OWNED BY public.cc_service.id;


--
-- Name: cc_service_report; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_service_report (
    id bigint NOT NULL,
    cc_service_id bigint NOT NULL,
    daterun timestamp(0) without time zone DEFAULT now(),
    totalcardperform integer,
    totalcredit double precision
);


--
-- Name: cc_service_report_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_service_report_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_service_report_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_service_report_id_seq OWNED BY public.cc_service_report.id;


--
-- Name: cc_sip_buddies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_sip_buddies (
    id integer NOT NULL,
    id_cc_card integer DEFAULT 0 NOT NULL,
    name character varying(80) DEFAULT ''::character varying NOT NULL,
    type character varying(6) DEFAULT 'friend'::character varying NOT NULL,
    username character varying(80) DEFAULT ''::character varying NOT NULL,
    accountcode character varying(20),
    regexten character varying(20),
    callerid character varying(80),
    amaflags character varying(7),
    secret character varying(80),
    md5secret character varying(80),
    nat character varying(3) DEFAULT 'yes'::character varying NOT NULL,
    dtmfmode character varying(7) DEFAULT 'RFC2833'::character varying NOT NULL,
    disallow character varying(100) DEFAULT 'all'::character varying,
    allow character varying(100) DEFAULT 'gsm,ulaw,alaw'::character varying,
    host character varying(31) DEFAULT ''::character varying NOT NULL,
    qualify character varying(7) DEFAULT 'yes'::character varying NOT NULL,
    canreinvite character varying(20) DEFAULT 'yes'::character varying,
    callgroup character varying(10),
    context character varying(80),
    defaultip character varying(15),
    fromuser character varying(80),
    fromdomain character varying(80),
    insecure character varying(20),
    language character varying(2),
    mailbox character varying(50),
    permit character varying(95),
    deny character varying(95),
    mask character varying(95),
    pickupgroup character varying(10),
    port character varying(5) DEFAULT ''::character varying NOT NULL,
    restrictcid character varying(1),
    rtptimeout character varying(3),
    rtpholdtimeout character varying(3),
    musiconhold character varying(100),
    regseconds integer DEFAULT 0 NOT NULL,
    ipaddr character varying(15) DEFAULT ''::character varying NOT NULL,
    cancallforward character varying(3) DEFAULT 'yes'::character varying,
    fullcontact character varying(80),
    setvar character varying(100) DEFAULT ''::character varying NOT NULL,
    regserver character varying(20),
    lastms character varying(11)
);


--
-- Name: cc_sip_buddies_empty; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.cc_sip_buddies_empty AS
 SELECT cc_sip_buddies.id,
    cc_sip_buddies.id_cc_card,
    cc_sip_buddies.name,
    cc_sip_buddies.accountcode,
    cc_sip_buddies.regexten,
    cc_sip_buddies.amaflags,
    cc_sip_buddies.callgroup,
    cc_sip_buddies.callerid,
    cc_sip_buddies.canreinvite,
    cc_sip_buddies.context,
    cc_sip_buddies.defaultip,
    cc_sip_buddies.dtmfmode,
    cc_sip_buddies.fromuser,
    cc_sip_buddies.fromdomain,
    cc_sip_buddies.host,
    cc_sip_buddies.insecure,
    cc_sip_buddies.language,
    cc_sip_buddies.mailbox,
    cc_sip_buddies.md5secret,
    cc_sip_buddies.nat,
    cc_sip_buddies.permit,
    cc_sip_buddies.deny,
    cc_sip_buddies.mask,
    cc_sip_buddies.pickupgroup,
    cc_sip_buddies.port,
    cc_sip_buddies.qualify,
    cc_sip_buddies.restrictcid,
    cc_sip_buddies.rtptimeout,
    cc_sip_buddies.rtpholdtimeout,
    ''::text AS secret,
    cc_sip_buddies.type,
    cc_sip_buddies.username,
    cc_sip_buddies.disallow,
    cc_sip_buddies.allow,
    cc_sip_buddies.musiconhold,
    cc_sip_buddies.regseconds,
    cc_sip_buddies.ipaddr,
    cc_sip_buddies.cancallforward,
    cc_sip_buddies.fullcontact,
    cc_sip_buddies.setvar
   FROM public.cc_sip_buddies;


--
-- Name: cc_sip_buddies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_sip_buddies_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_sip_buddies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_sip_buddies_id_seq OWNED BY public.cc_sip_buddies.id;


--
-- Name: cc_speeddial; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_speeddial (
    id bigint NOT NULL,
    id_cc_card bigint DEFAULT 0 NOT NULL,
    phone text NOT NULL,
    name text NOT NULL,
    speeddial integer DEFAULT 0,
    creationdate timestamp without time zone DEFAULT now()
);


--
-- Name: cc_speeddial_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_speeddial_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_speeddial_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_speeddial_id_seq OWNED BY public.cc_speeddial.id;


--
-- Name: cc_status_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_status_log (
    id bigint NOT NULL,
    status integer NOT NULL,
    id_cc_card bigint NOT NULL,
    updated_date timestamp without time zone DEFAULT now()
);


--
-- Name: cc_status_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_status_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_status_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_status_log_id_seq OWNED BY public.cc_status_log.id;


--
-- Name: cc_subscription_fee; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_subscription_fee (
    id bigint NOT NULL,
    label text NOT NULL,
    fee numeric(12,4) NOT NULL,
    currency character varying(3) DEFAULT 'USD'::character varying,
    status integer DEFAULT 0 NOT NULL,
    numberofrun integer DEFAULT 0 NOT NULL,
    datecreate timestamp(0) without time zone DEFAULT now(),
    datelastrun timestamp(0) without time zone DEFAULT now(),
    emailreport text,
    totalcredit double precision DEFAULT 0 NOT NULL,
    totalcardperform integer DEFAULT 0 NOT NULL
);


--
-- Name: cc_subscription_fee_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_subscription_fee_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_subscription_fee_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_subscription_fee_id_seq OWNED BY public.cc_subscription_fee.id;


--
-- Name: cc_support; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_support (
    id integer NOT NULL,
    name character varying(50) NOT NULL
);


--
-- Name: cc_support_component; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_support_component (
    id integer NOT NULL,
    id_support integer NOT NULL,
    name character varying(50) DEFAULT ''::character varying NOT NULL,
    activated smallint DEFAULT 1 NOT NULL,
    type_user smallint DEFAULT '2'::smallint NOT NULL
);


--
-- Name: cc_support_component_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_support_component_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_support_component_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_support_component_id_seq OWNED BY public.cc_support_component.id;


--
-- Name: cc_support_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_support_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_support_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_support_id_seq OWNED BY public.cc_support.id;


--
-- Name: cc_system_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_system_log (
    id bigint NOT NULL,
    iduser integer DEFAULT 0 NOT NULL,
    loglevel integer DEFAULT 0 NOT NULL,
    action text NOT NULL,
    description text,
    data text,
    tablename character varying(255),
    pagename character varying(255),
    ipaddress character varying(255),
    creationdate timestamp(0) without time zone DEFAULT now()
);


--
-- Name: cc_system_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_system_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_system_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_system_log_id_seq OWNED BY public.cc_system_log.id;


--
-- Name: cc_tariffgroup; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_tariffgroup (
    id integer NOT NULL,
    iduser integer DEFAULT 0 NOT NULL,
    idtariffplan integer DEFAULT 0 NOT NULL,
    tariffgroupname text NOT NULL,
    lcrtype integer DEFAULT 0 NOT NULL,
    creationdate timestamp without time zone DEFAULT now(),
    removeinterprefix integer DEFAULT 0 NOT NULL,
    id_cc_package_offer bigint DEFAULT 0 NOT NULL
);


--
-- Name: cc_tariffgroup_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_tariffgroup_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_tariffgroup_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_tariffgroup_id_seq OWNED BY public.cc_tariffgroup.id;


--
-- Name: cc_tariffgroup_plan; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_tariffgroup_plan (
    idtariffgroup integer NOT NULL,
    idtariffplan integer NOT NULL
);


--
-- Name: cc_tariffplan; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_tariffplan (
    id integer NOT NULL,
    iduser integer DEFAULT 0 NOT NULL,
    tariffname text NOT NULL,
    creationdate timestamp without time zone DEFAULT now(),
    startingdate timestamp without time zone DEFAULT now(),
    expirationdate timestamp without time zone,
    description text,
    id_trunk integer DEFAULT 0,
    secondusedreal integer DEFAULT 0,
    secondusedcarrier integer DEFAULT 0,
    secondusedratecard integer DEFAULT 0,
    reftariffplan integer DEFAULT 0,
    idowner integer DEFAULT 0,
    dnidprefix text DEFAULT 'all'::text NOT NULL,
    calleridprefix text DEFAULT 'all'::text NOT NULL
);


--
-- Name: cc_tariffplan_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_tariffplan_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_tariffplan_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_tariffplan_id_seq OWNED BY public.cc_tariffplan.id;


--
-- Name: cc_templatemail; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_templatemail (
    id integer NOT NULL,
    mailtype text,
    fromemail text,
    fromname text,
    subject text,
    messagetext text,
    messagehtml text,
    id_language character varying(20) DEFAULT 'en'::character varying
);


--
-- Name: cc_templatemail_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_templatemail_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_templatemail_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_templatemail_id_seq OWNED BY public.cc_templatemail.id;


--
-- Name: cc_ticket; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_ticket (
    id bigint NOT NULL,
    id_component integer NOT NULL,
    title character varying(100) NOT NULL,
    description text,
    priority smallint DEFAULT 0 NOT NULL,
    creationdate timestamp without time zone DEFAULT now() NOT NULL,
    creator bigint NOT NULL,
    status integer DEFAULT 0 NOT NULL,
    creator_type smallint DEFAULT '0'::smallint NOT NULL,
    viewed_cust smallint DEFAULT '1'::smallint NOT NULL,
    viewed_agent smallint DEFAULT '1'::smallint NOT NULL,
    viewed_admin smallint DEFAULT '1'::smallint NOT NULL
);


--
-- Name: cc_ticket_comment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_ticket_comment (
    id bigint NOT NULL,
    date timestamp without time zone DEFAULT now() NOT NULL,
    id_ticket bigint NOT NULL,
    description text,
    creator bigint NOT NULL,
    creator_type smallint DEFAULT '0'::smallint NOT NULL,
    viewed_cust smallint DEFAULT '1'::smallint NOT NULL,
    viewed_agent smallint DEFAULT '1'::smallint NOT NULL,
    viewed_admin smallint DEFAULT '1'::smallint NOT NULL
);


--
-- Name: cc_ticket_comment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_ticket_comment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_ticket_comment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_ticket_comment_id_seq OWNED BY public.cc_ticket_comment.id;


--
-- Name: cc_ticket_comment_id_ticket_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_ticket_comment_id_ticket_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_ticket_comment_id_ticket_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_ticket_comment_id_ticket_seq OWNED BY public.cc_ticket_comment.id_ticket;


--
-- Name: cc_ticket_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_ticket_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_ticket_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_ticket_id_seq OWNED BY public.cc_ticket.id;


--
-- Name: cc_timezone; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_timezone (
    id integer NOT NULL,
    gmtzone character varying(255),
    gmttime character varying(255),
    gmtoffset bigint DEFAULT 0 NOT NULL
);


--
-- Name: cc_timezone_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_timezone_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_timezone_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_timezone_id_seq OWNED BY public.cc_timezone.id;


--
-- Name: cc_trunk; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_trunk (
    id_trunk integer NOT NULL,
    trunkcode text NOT NULL,
    trunkprefix text,
    providertech text NOT NULL,
    providerip text NOT NULL,
    removeprefix text,
    secondusedreal integer DEFAULT 0,
    secondusedcarrier integer DEFAULT 0,
    secondusedratecard integer DEFAULT 0,
    creationdate timestamp(0) without time zone DEFAULT now(),
    failover_trunk integer,
    addparameter text,
    id_provider integer,
    inuse integer DEFAULT 0,
    maxuse integer DEFAULT '-1'::integer,
    status integer DEFAULT 1,
    if_max_use integer DEFAULT 0
);


--
-- Name: cc_trunk_id_trunk_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_trunk_id_trunk_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_trunk_id_trunk_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_trunk_id_trunk_seq OWNED BY public.cc_trunk.id_trunk;


--
-- Name: cc_ui_authen; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_ui_authen (
    userid bigint NOT NULL,
    login text NOT NULL,
    pwd_encoded text NOT NULL,
    groupid integer,
    perms integer,
    confaddcust integer,
    name text,
    direction text,
    zipcode text,
    state text,
    phone text,
    fax text,
    email character varying(70),
    datecreation timestamp without time zone DEFAULT now()
);


--
-- Name: cc_ui_authen_userid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_ui_authen_userid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_ui_authen_userid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_ui_authen_userid_seq OWNED BY public.cc_ui_authen.userid;


--
-- Name: cc_voucher; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cc_voucher (
    id bigint NOT NULL,
    creationdate timestamp without time zone DEFAULT now(),
    usedate timestamp without time zone,
    expirationdate timestamp without time zone,
    voucher text NOT NULL,
    usedcardnumber text,
    tag text,
    credit numeric(12,4) NOT NULL,
    activated boolean DEFAULT true NOT NULL,
    used integer DEFAULT 0,
    currency character varying(3) DEFAULT 'USD'::character varying
);


--
-- Name: cc_voucher_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cc_voucher_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_voucher_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cc_voucher_id_seq OWNED BY public.cc_voucher.id;


--
-- Name: cc_agent id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_agent ALTER COLUMN id SET DEFAULT nextval('public.cc_agent_id_seq'::regclass);


--
-- Name: cc_agent_commission id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_agent_commission ALTER COLUMN id SET DEFAULT nextval('public.cc_agent_commission_id_seq'::regclass);


--
-- Name: cc_agent_signup id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_agent_signup ALTER COLUMN id SET DEFAULT nextval('public.cc_agent_signup_id_seq'::regclass);


--
-- Name: cc_alarm id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_alarm ALTER COLUMN id SET DEFAULT nextval('public.cc_alarm_id_seq'::regclass);


--
-- Name: cc_alarm_report id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_alarm_report ALTER COLUMN id SET DEFAULT nextval('public.cc_alarm_report_id_seq'::regclass);


--
-- Name: cc_autorefill_report id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_autorefill_report ALTER COLUMN id SET DEFAULT nextval('public.cc_autorefill_report_id_seq'::regclass);


--
-- Name: cc_backup id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_backup ALTER COLUMN id SET DEFAULT nextval('public.cc_backup_id_seq'::regclass);


--
-- Name: cc_billing_customer id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_billing_customer ALTER COLUMN id SET DEFAULT nextval('public.cc_billing_customer_id_seq'::regclass);


--
-- Name: cc_call id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_call ALTER COLUMN id SET DEFAULT nextval('public.cc_call_id_seq'::regclass);


--
-- Name: cc_call_archive id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_call_archive ALTER COLUMN id SET DEFAULT nextval('public.cc_call_archive_id_seq'::regclass);


--
-- Name: cc_callback_spool id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_callback_spool ALTER COLUMN id SET DEFAULT nextval('public.cc_callback_spool_id_seq'::regclass);


--
-- Name: cc_callerid id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_callerid ALTER COLUMN id SET DEFAULT nextval('public.cc_callerid_id_seq'::regclass);


--
-- Name: cc_campaign id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_campaign ALTER COLUMN id SET DEFAULT nextval('public.cc_campaign_id_seq'::regclass);


--
-- Name: cc_campaign_config id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_campaign_config ALTER COLUMN id SET DEFAULT nextval('public.cc_campaign_config_id_seq'::regclass);


--
-- Name: cc_card id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_card ALTER COLUMN id SET DEFAULT nextval('public.cc_card_id_seq'::regclass);


--
-- Name: cc_card_archive id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_card_archive ALTER COLUMN id SET DEFAULT nextval('public.cc_card_archive_id_seq'::regclass);


--
-- Name: cc_card_group id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_card_group ALTER COLUMN id SET DEFAULT nextval('public.cc_card_group_id_seq'::regclass);


--
-- Name: cc_card_history id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_card_history ALTER COLUMN id SET DEFAULT nextval('public.cc_card_history_id_seq'::regclass);


--
-- Name: cc_card_package_offer id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_card_package_offer ALTER COLUMN id SET DEFAULT nextval('public.cc_card_package_offer_id_seq'::regclass);


--
-- Name: cc_card_seria id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_card_seria ALTER COLUMN id SET DEFAULT nextval('public.cc_card_seria_id_seq'::regclass);


--
-- Name: cc_card_subscription id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_card_subscription ALTER COLUMN id SET DEFAULT nextval('public.cc_card_subscription_id_seq'::regclass);


--
-- Name: cc_charge id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_charge ALTER COLUMN id SET DEFAULT nextval('public.cc_charge_id_seq'::regclass);


--
-- Name: cc_config id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_config ALTER COLUMN id SET DEFAULT nextval('public.cc_config_id_seq'::regclass);


--
-- Name: cc_config_group id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_config_group ALTER COLUMN id SET DEFAULT nextval('public.cc_config_group_id_seq'::regclass);


--
-- Name: cc_configuration configuration_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_configuration ALTER COLUMN configuration_id SET DEFAULT nextval('public.cc_configuration_configuration_id_seq'::regclass);


--
-- Name: cc_country id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_country ALTER COLUMN id SET DEFAULT nextval('public.cc_country_id_seq'::regclass);


--
-- Name: cc_currencies id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_currencies ALTER COLUMN id SET DEFAULT nextval('public.cc_currencies_id_seq'::regclass);


--
-- Name: cc_did id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_did ALTER COLUMN id SET DEFAULT nextval('public.cc_did_id_seq'::regclass);


--
-- Name: cc_did_destination id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_did_destination ALTER COLUMN id SET DEFAULT nextval('public.cc_did_destination_id_seq'::regclass);


--
-- Name: cc_did_use id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_did_use ALTER COLUMN id SET DEFAULT nextval('public.cc_did_use_id_seq'::regclass);


--
-- Name: cc_didgroup id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_didgroup ALTER COLUMN id SET DEFAULT nextval('public.cc_didgroup_id_seq'::regclass);


--
-- Name: cc_ecommerce_product id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_ecommerce_product ALTER COLUMN id SET DEFAULT nextval('public.cc_ecommerce_product_id_seq'::regclass);


--
-- Name: cc_epayment_log id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_epayment_log ALTER COLUMN id SET DEFAULT nextval('public.cc_epayment_log_id_seq'::regclass);


--
-- Name: cc_epayment_log_agent id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_epayment_log_agent ALTER COLUMN id SET DEFAULT nextval('public.cc_epayment_log_agent_id_seq'::regclass);


--
-- Name: cc_iax_buddies id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_iax_buddies ALTER COLUMN id SET DEFAULT nextval('public.cc_iax_buddies_id_seq'::regclass);


--
-- Name: cc_invoice id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_invoice ALTER COLUMN id SET DEFAULT nextval('public.cc_invoice_id_seq'::regclass);


--
-- Name: cc_invoice_conf id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_invoice_conf ALTER COLUMN id SET DEFAULT nextval('public.cc_invoice_conf_id_seq'::regclass);


--
-- Name: cc_invoice_item id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_invoice_item ALTER COLUMN id SET DEFAULT nextval('public.cc_invoice_item_id_seq'::regclass);


--
-- Name: cc_logpayment id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_logpayment ALTER COLUMN id SET DEFAULT nextval('public.cc_logpayment_id_seq'::regclass);


--
-- Name: cc_logpayment_agent id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_logpayment_agent ALTER COLUMN id SET DEFAULT nextval('public.cc_logpayment_agent_id_seq'::regclass);


--
-- Name: cc_logrefill id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_logrefill ALTER COLUMN id SET DEFAULT nextval('public.cc_logrefill_id_seq'::regclass);


--
-- Name: cc_logrefill_agent id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_logrefill_agent ALTER COLUMN id SET DEFAULT nextval('public.cc_logrefill_agent_id_seq'::regclass);


--
-- Name: cc_notification id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_notification ALTER COLUMN id SET DEFAULT nextval('public.cc_notification_id_seq'::regclass);


--
-- Name: cc_outbound_cid_group id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_outbound_cid_group ALTER COLUMN id SET DEFAULT nextval('public.cc_outbound_cid_group_id_seq'::regclass);


--
-- Name: cc_outbound_cid_list id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_outbound_cid_list ALTER COLUMN id SET DEFAULT nextval('public.cc_outbound_cid_list_id_seq'::regclass);


--
-- Name: cc_package_group id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_package_group ALTER COLUMN id SET DEFAULT nextval('public.cc_package_group_id_seq'::regclass);


--
-- Name: cc_package_offer id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_package_offer ALTER COLUMN id SET DEFAULT nextval('public.cc_package_offer_id_seq'::regclass);


--
-- Name: cc_payment_methods id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_payment_methods ALTER COLUMN id SET DEFAULT nextval('public.cc_payment_methods_id_seq'::regclass);


--
-- Name: cc_payments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_payments ALTER COLUMN id SET DEFAULT nextval('public.cc_payments_id_seq'::regclass);


--
-- Name: cc_payments_agent id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_payments_agent ALTER COLUMN id SET DEFAULT nextval('public.cc_payments_agent_id_seq'::regclass);


--
-- Name: cc_payments_status id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_payments_status ALTER COLUMN id SET DEFAULT nextval('public.cc_payments_status_id_seq'::regclass);


--
-- Name: cc_paypal id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_paypal ALTER COLUMN id SET DEFAULT nextval('public.cc_paypal_id_seq'::regclass);


--
-- Name: cc_phonebook id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_phonebook ALTER COLUMN id SET DEFAULT nextval('public.cc_phonebook_id_seq'::regclass);


--
-- Name: cc_phonenumber id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_phonenumber ALTER COLUMN id SET DEFAULT nextval('public.cc_phonenumber_id_seq'::regclass);


--
-- Name: cc_prefix prefix; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_prefix ALTER COLUMN prefix SET DEFAULT nextval('public.cc_prefix_prefix_seq'::regclass);


--
-- Name: cc_provider id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_provider ALTER COLUMN id SET DEFAULT nextval('public.cc_provider_id_seq'::regclass);


--
-- Name: cc_ratecard id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_ratecard ALTER COLUMN id SET DEFAULT nextval('public.cc_ratecard_id_seq'::regclass);


--
-- Name: cc_receipt id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_receipt ALTER COLUMN id SET DEFAULT nextval('public.cc_receipt_id_seq'::regclass);


--
-- Name: cc_receipt_item id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_receipt_item ALTER COLUMN id SET DEFAULT nextval('public.cc_receipt_item_id_seq'::regclass);


--
-- Name: cc_restricted_phonenumber id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_restricted_phonenumber ALTER COLUMN id SET DEFAULT nextval('public.cc_restricted_phonenumber_id_seq'::regclass);


--
-- Name: cc_server_group id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_server_group ALTER COLUMN id SET DEFAULT nextval('public.cc_server_group_id_seq'::regclass);


--
-- Name: cc_server_manager id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_server_manager ALTER COLUMN id SET DEFAULT nextval('public.cc_server_manager_id_seq'::regclass);


--
-- Name: cc_service id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_service ALTER COLUMN id SET DEFAULT nextval('public.cc_service_id_seq'::regclass);


--
-- Name: cc_service_report id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_service_report ALTER COLUMN id SET DEFAULT nextval('public.cc_service_report_id_seq'::regclass);


--
-- Name: cc_sip_buddies id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_sip_buddies ALTER COLUMN id SET DEFAULT nextval('public.cc_sip_buddies_id_seq'::regclass);


--
-- Name: cc_speeddial id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_speeddial ALTER COLUMN id SET DEFAULT nextval('public.cc_speeddial_id_seq'::regclass);


--
-- Name: cc_status_log id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_status_log ALTER COLUMN id SET DEFAULT nextval('public.cc_status_log_id_seq'::regclass);


--
-- Name: cc_subscription_fee id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_subscription_fee ALTER COLUMN id SET DEFAULT nextval('public.cc_subscription_fee_id_seq'::regclass);


--
-- Name: cc_support id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_support ALTER COLUMN id SET DEFAULT nextval('public.cc_support_id_seq'::regclass);


--
-- Name: cc_support_component id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_support_component ALTER COLUMN id SET DEFAULT nextval('public.cc_support_component_id_seq'::regclass);


--
-- Name: cc_system_log id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_system_log ALTER COLUMN id SET DEFAULT nextval('public.cc_system_log_id_seq'::regclass);


--
-- Name: cc_tariffgroup id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_tariffgroup ALTER COLUMN id SET DEFAULT nextval('public.cc_tariffgroup_id_seq'::regclass);


--
-- Name: cc_tariffplan id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_tariffplan ALTER COLUMN id SET DEFAULT nextval('public.cc_tariffplan_id_seq'::regclass);


--
-- Name: cc_templatemail id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_templatemail ALTER COLUMN id SET DEFAULT nextval('public.cc_templatemail_id_seq'::regclass);


--
-- Name: cc_ticket id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_ticket ALTER COLUMN id SET DEFAULT nextval('public.cc_ticket_id_seq'::regclass);


--
-- Name: cc_ticket_comment id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_ticket_comment ALTER COLUMN id SET DEFAULT nextval('public.cc_ticket_comment_id_seq'::regclass);


--
-- Name: cc_ticket_comment id_ticket; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_ticket_comment ALTER COLUMN id_ticket SET DEFAULT nextval('public.cc_ticket_comment_id_ticket_seq'::regclass);


--
-- Name: cc_timezone id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_timezone ALTER COLUMN id SET DEFAULT nextval('public.cc_timezone_id_seq'::regclass);


--
-- Name: cc_trunk id_trunk; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_trunk ALTER COLUMN id_trunk SET DEFAULT nextval('public.cc_trunk_id_trunk_seq'::regclass);


--
-- Name: cc_ui_authen userid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_ui_authen ALTER COLUMN userid SET DEFAULT nextval('public.cc_ui_authen_userid_seq'::regclass);


--
-- Name: cc_voucher id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_voucher ALTER COLUMN id SET DEFAULT nextval('public.cc_voucher_id_seq'::regclass);


--
-- Data for Name: cc_agent; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_agent (id, datecreation, active, login, passwd, location, language, id_tariffgroup, options, credit, currency, locale, commission, vat, banner, perms, lastname, firstname, address, city, state, country, zipcode, phone, email, fax, company) FROM stdin;
\.


--
-- Data for Name: cc_agent_commission; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_agent_commission (id, id_payment, id_card, date, amount, paid_status, description, id_agent) FROM stdin;
\.


--
-- Data for Name: cc_agent_signup; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_agent_signup (id, id_agent, code, id_tariffgroup, id_group) FROM stdin;
\.


--
-- Data for Name: cc_agent_tariffgroup; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_agent_tariffgroup (id_agent, id_tariffgroup) FROM stdin;
\.


--
-- Data for Name: cc_alarm; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_alarm (id, name, periode, type, maxvalue, minvalue, id_trunk, status, numberofrun, numberofalarm, datecreate, datelastrun, emailreport) FROM stdin;
\.


--
-- Data for Name: cc_alarm_report; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_alarm_report (id, cc_alarm_id, calculatedvalue, daterun) FROM stdin;
\.


--
-- Data for Name: cc_autorefill_report; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_autorefill_report (id, daterun, totalcardperform, totalcredit) FROM stdin;
\.


--
-- Data for Name: cc_backup; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_backup (id, name, path, creationdate) FROM stdin;
\.


--
-- Data for Name: cc_billing_customer; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_billing_customer (id, id_card, date, id_invoice) FROM stdin;
\.


--
-- Data for Name: cc_call; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_call (id, card_id, sessionid, uniqueid, nasipaddress, starttime, stoptime, sessiontime, calledstation, destination, terminatecauseid, sessionbill, id_tariffgroup, id_tariffplan, id_ratecard, id_trunk, sipiax, src, id_did, buycost, id_card_package_offer, real_sessiontime, dnid, a2b_custom1, a2b_custom2) FROM stdin;
1	3	PJSIP/0351234567-00000063	1787831340.99		2026-08-27 11:49:01.000705	2026-08-27 11:50:00.000705	59	0352345678	0	1	-0	1	1	1	1	0	9218079042	\N	0.00000	\N	59	0352345678		
2	3	PJSIP/0351234567-00000065	1787831410.101		2026-08-27 11:50:11.398957	2026-08-27 11:50:39.398957	28	0352345678	0	1	-0	1	1	1	1	0	9218079042	\N	0.00000	\N	28	0352345678		
3	3	PJSIP/0351234567-0000006e	1787848283.110		2026-08-27 16:31:24.111316	2026-08-27 16:31:38.111316	14	0352345678	0	1	-0	1	1	1	1	0	9218079042	\N	0.00000	\N	14	0352345678		
4	3	PJSIP/0351234567-00000070	1787851825.112		2026-08-27 17:30:44.090153	2026-08-27 17:30:44.090153	0	0352345678	0	4	-0	1	1	1	1	0	9218079042	\N	0.00000	\N	0	0352345678		
5	3	PJSIP/0351234567-00000072	1787852066.114		2026-08-27 17:34:38.480427	2026-08-27 17:34:38.480427	0	0352345678	0	6	-0	1	1	1	0	0	9218079042	\N	0.00000	\N	0	0352345678		
6	3	PJSIP/0351234567-00000076	1787853780.118		2026-08-27 18:03:00.434928	2026-08-27 18:04:37.434928	97	0352345678	0	1	1.204	1	1	1	1	0	9218079042	\N	0.13600	\N	97	0352345678		
7	3	PJSIP/0351234567-00000078	1787853946.120		2026-08-27 18:05:46.836062	2026-08-27 18:07:27.836062	101	0352345678	0	1	1.204	1	1	1	1	0	9218079042	\N	0.13600	\N	101	0352345678		
8	3	PJSIP/0351234567-0000007a	1787854173.122		2026-08-27 18:09:34.315721	2026-08-27 18:13:32.315721	238	0352345678	0	1	41	1	1	1	1	0	9218079042	\N	20.00000	\N	238	0352345678		
9	3	PJSIP/0351234567-0000007d	1787867926.125		2026-08-27 21:58:46.762798	2026-08-27 21:59:14.762798	28	0352345678	0	1	51	1	1	1	1	0	Tojo	\N	25.00000	\N	28	0352345678		
10	3	PJSIP/0351234567-0000007f	1787868061.127		2026-08-27 22:01:01.698857	2026-08-27 22:02:20.698857	79	0352345678	0	1	141	1	1	1	1	0	Tojo	\N	70.00000	\N	79	0352345678		
11	3	PJSIP/0351234567-00000081	1787868433.129		2026-08-27 22:07:13.774948	2026-08-27 22:07:52.774948	39	0352345678	0	1	71	1	1	1	1	0	Jeda	\N	35.00000	\N	39	0352345678		
12	3	PJSIP/0351234567-00000083	1787895102.131		2026-08-28 05:31:43.513318	2026-08-28 05:33:04.513318	81	0352345678	0	1	141	1	1	1	1	0	Jeda	\N	70.00000	\N	81	0352345678		
13	3	PJSIP/0351234567-0000008d	1787895850.143		2026-08-28 05:44:42.417359	2026-08-28 05:44:42.417359	0	0352345678	0	4	-0	1	1	1	1	0	Jeda	\N	0.00000	\N	0	0352345678		
14	3	PJSIP/0351234567-00000093	1787900229.149		2026-08-28 06:57:10.101661	2026-08-28 06:57:42.101661	32	0352345678	0	1	61	1	1	1	1	0	Jeda	\N	30.00000	\N	32	0352345678		
15	3	PJSIP/0351234567-0000009e	1787901688.164		2026-08-28 07:21:29.122329	2026-08-28 07:21:55.122329	26	0352345678	0	1	51	1	1	1	1	0	Jeda	\N	25.00000	\N	26	0352345678		
\.


--
-- Data for Name: cc_call_archive; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_call_archive (id, card_id, sessionid, uniqueid, nasipaddress, starttime, stoptime, sessiontime, calledstation, destination, terminatecauseid, sessionbill, id_tariffgroup, id_tariffplan, id_ratecard, id_trunk, sipiax, src, id_did, buycost, id_card_package_offer, real_sessiontime, dnid) FROM stdin;
\.


--
-- Data for Name: cc_callback_spool; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_callback_spool (id, uniqueid, entry_time, status, server_ip, num_attempt, last_attempt_time, manager_result, agi_result, callback_time, channel, exten, context, priority, application, data, timeout, callerid, variable, account, async, actionid, id_server, id_server_group) FROM stdin;
\.


--
-- Data for Name: cc_callerid; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_callerid (id, cid, id_cc_card, activated) FROM stdin;
1	0352345678	2	t
2	0351234567	3	t
\.


--
-- Data for Name: cc_campaign; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_campaign (id, name, creationdate, startingdate, expirationdate, description, id_card, secondusedreal, nb_callmade, status, frequency, forward_number, daily_start_time, daily_stop_time, monday, tuesday, wednesday, thursday, friday, saturday, sunday, id_cid_group, id_campaign_config, callerid) FROM stdin;
\.


--
-- Data for Name: cc_campaign_config; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_campaign_config (id, name, flatrate, context, description) FROM stdin;
\.


--
-- Data for Name: cc_campaign_phonebook; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_campaign_phonebook (id_campaign, id_phonebook) FROM stdin;
\.


--
-- Data for Name: cc_campaign_phonestatus; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_campaign_phonestatus (id_phonenumber, id_campaign, id_callback, status, lastuse) FROM stdin;
\.


--
-- Data for Name: cc_campaignconf_cardgroup; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_campaignconf_cardgroup (id_campaign_config, id_card_group) FROM stdin;
\.


--
-- Data for Name: cc_card; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_card (id, creationdate, firstusedate, expirationdate, enableexpire, expiredays, username, useralias, uipass, credit, tariff, id_didgroup, activated, lastname, firstname, address, city, state, country, zipcode, phone, email, fax, inuse, simultaccess, currency, lastuse, nbused, typepaid, creditlimit, voipcall, sip_buddy, iax_buddy, language, redial, runservice, nbservice, id_campaign, num_trials_done, vat, servicelastrun, initialbalance, invoiceday, autorefill, loginkey, mac_addr, id_timezone, status, tag, voicemail_permitted, voicemail_activated, last_notification, email_notification, notify_email, credit_notification, id_group, company_name, company_website, vat_rn, traffic, traffic_target, discount, restriction, id_seria, serial, block, lock_pin) FROM stdin;
2	2026-08-26 18:30:23.360639	\N	2036-08-26 18:29:35	0	0	0352345678	0352345678	73840hnyxrgwznayfi2t	0.0000	1	-1	f	Tojo	ANDRIANARIVONJY	LOT IVM 38 SJA Andohotapenaka	67ha	\N	MDG	101	0345351885	\N	\N	0	1	MGA	2026-08-26	0	1	0	0	1	1	en	\N	0	0	-1	0	0.000	\N	0.0000	1	0	\N	00-00-00-00-00-00	40	1	\N	0	0	\N	\N	0	-1	1	\N	\N	\N	0	\N	0.00	0	-1	\N	0	0
3	2026-08-26 18:43:57.969397	2026-08-27 07:43:24.079432	2036-08-26 18:41:28	0	0	0351234567	0351234567	32593wy7ne5odgnrnipz	1888.0000	1	-1	f	Jeda	\N	LOT IVM 38 SJA Andohotapenaka	67ha	\N	USA	101	\N	\N	\N	0	1	MGA	2026-08-28	23	0	0	0	1	1	en	0352345678	0	0	-1	0	0.000	\N	0.0000	1	0	\N	00-00-00-00-00-00	67	1	\N	0	0	\N	\N	0	-1	1	\N	\N	\N	0	\N	0.00	0	-1	\N	0	0
1	2026-08-25 01:29:31.324297	\N	2036-08-25 01:28:58	0	0	4834067797	823177036003397	phone1	0.0000	1	-1	f	Fenitra	\N	\N	\N	\N	MDG	\N	\N	\N	\N	0	1	MGA	2026-08-25	0	1	0	0	1	1	en	\N	0	0	-1	0	0.000	\N	0.0000	1	0	\N	00-00-00-00-00-00	40	1	\N	0	0	\N	\N	0	-1	1	\N	\N	\N	0	\N	0.00	0	-1	\N	0	0
\.


--
-- Data for Name: cc_card_archive; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_card_archive (id, creationdate, firstusedate, expirationdate, enableexpire, expiredays, username, useralias, uipass, credit, tariff, id_didgroup, activated, lastname, firstname, address, city, state, country, zipcode, phone, email, fax, inuse, simultaccess, currency, lastuse, nbused, typepaid, creditlimit, voipcall, sip_buddy, iax_buddy, language, redial, runservice, nbservice, id_campaign, num_trials_done, vat, servicelastrun, initialbalance, invoiceday, autorefill, loginkey, mac_addr, id_timezone, status, tag, voicemail_permitted, voicemail_activated, last_notification, email_notification, notify_email, credit_notification, id_group, company_name, company_website, vat_rn, traffic, traffic_target, discount, restriction, id_seria, serial) FROM stdin;
\.


--
-- Data for Name: cc_card_group; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_card_group (id, name, description, users_perms, id_agent, flatrate, campaign_context) FROM stdin;
1	DEFAULT	This group is the default group used when you create a customer. It's forbidden to delete it because you need at least one group but you can edit it.	129022	\N	0.00000	\N
\.


--
-- Data for Name: cc_card_history; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_card_history (id, id_cc_card, datecreated, description) FROM stdin;
\.


--
-- Data for Name: cc_card_package_offer; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_card_package_offer (id, id_cc_card, id_cc_package_offer, date_consumption, used_secondes) FROM stdin;
\.


--
-- Data for Name: cc_card_seria; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_card_seria (id, name, description, value) FROM stdin;
1	Recharge_1000Ar               	Carte de recharge 1000 Ariary	1000
\.


--
-- Data for Name: cc_card_subscription; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_card_subscription (id, id_cc_card, id_subscription_fee, startdate, stopdate, product_id, product_name) FROM stdin;
1	100000	-1	2026-08-26 18:34:33	2038-01-01 00:00:00	\N	\N
2	9890930847	-1	2026-08-26 18:34:55	2038-01-01 00:00:00	\N	\N
\.


--
-- Data for Name: cc_cardgroup_service; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_cardgroup_service (id_card_group, id_service) FROM stdin;
\.


--
-- Data for Name: cc_charge; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_charge (id, id_cc_card, iduser, creationdate, amount, currency, chargetype, description, id_cc_did, id_cc_card_subscription, cover_from, cover_to, charged_status, invoiced_status) FROM stdin;
\.


--
-- Data for Name: cc_config; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_config (id, config_title, config_key, config_value, config_description, config_valuetype, config_listvalues, config_group_title) FROM stdin;
1	Card Number length	interval_len_cardnumber	10-15	Card Number length, You can define a Range e.g: 10-15.	0	10-15,5-20,10-30	global
2	Card Alias length	len_aliasnumber	15	Card Number Alias Length e.g: 15.	0	\N	global
3	Voucher length	len_voucher	15	Voucher Number Length.	0	\N	global
5	Invoice Image	invoice_image	asterisk01.jpg	Image to Display on the Top of Invoice	0	\N	global
6	Admin Email	admin_email	root@localhost	Web Administrator Email Address.	0	\N	global
7	DID Bill Payment Day	didbilling_daytopay	5	DID Bill Payment Day of Month	0	\N	global
8	Manager Host	manager_host	localhost	Manager Host Address	0	\N	global
9	Manager User ID	manager_username	myasterisk	Manger Host User Name	0	\N	global
10	Manager Password	manager_secret	mycode	Manager Host Password	0	\N	global
11	Use SMTP Server	smtp_server	0	Define if you want to use an STMP server or Send Mail (value yes for server SMTP)	1	yes,no	global
12	SMTP Host	smtp_host	localhost	SMTP Hostname	0	\N	global
13	SMTP UserName	smtp_username		User Name to connect on the SMTP server	0	\N	global
14	SMTP Password	smtp_password		Password to connect on the SMTP server	0	\N	global
15	Use Realtime	use_realtime	1	if Disabled, it will generate the config files and offer an option to reload asterisk after an update on the Voip settings	1	yes,no	global
16	Go To Customer	customer_ui_url	../../customer/index.php	Link to the customer account	0	\N	global
17	Context Callback	context_callback	a2billing-callback	Contaxt to use in Callback	0	\N	callback
18	Extension	extension	1000	Extension to call while callback.	0	\N	callback
19	Wait before callback	sec_wait_before_callback	10	Seconds to wait before callback.	0	\N	callback
20	Avoid Repeat Duration	sec_avoid_repeate	10	Number of seconds before the call-back can be re-initiated from the web page to prevent repeated and unwanted calls.	0	\N	callback
21	Time out	timeout	20	if the callback doesnt succeed within the value below, then the call is deemed to have failed.	0	\N	callback
22	Answer on Call	answer_call	1	if we want to manage the answer on the call. Disabling this for callback trigger numbers makes it ring not hang up.	1	yes,no	callback
23	No of Predictive Calls	nb_predictive_call	10	number of calls an agent will do when the call button is clicked.	0	\N	callback
24	Delay for Availability	nb_day_wait_before_retry	1	Number of days to wait before the number becomes available to call again.	0	\N	callback
25	PD Contect	context_preditctivedialer	a2billing-predictivedialer	The context to redirect the call for the predictive dialer.	0	\N	callback
26	Max Time to call	predictivedialer_maxtime_tocall	5400	When a call is made we need to limit the call duration : amount in seconds.	0	\N	callback
27	PD Caller ID	callerid	123456	Set the callerID for the predictive dialer and call-back.	0	\N	callback
28	Callback CallPlan ID	all_callback_tariff	1	ID Call Plan to use when you use the all-callback mode, check the ID in the "list Call Plan" - WebUI.	0	\N	callback
29	Server Group ID	id_server_group	1	Define the group of servers that are going to be used by the callback.	0	\N	callback
30	Audio Intro	callback_audio_intro	prepaid-callback_intro	Audio intro message when the callback is initiate.	0	\N	callback
31	Signup URL	signup_page_url		url of the signup page to show up on the sign in page (if empty no link will show up).	0	\N	webcustomerui
32	Payment Method	paymentmethod	1	Enable or disable the payment methods; yes for multi-payment or no for single payment method option.	1	yes,no	webcustomerui
33	Personal Info	personalinfo	1	Enable or disable the page which allow customer to modify its personal information.	1	yes,no	webcustomerui
34	Payment Info	customerinfo	1	Enable display of the payment interface - yes or no.	1	yes,no	webcustomerui
238	DIDX ID	didx_id	708XXX	DIDX parameter : ID	0	\N	webui
47	WebPhone Server	webphoneserver	localhost	IP address or domain name of asterisk server that would be used by the web-phone.	0	\N	webcustomerui
49	Password	password	1	Let the user change the webui password.	1	yes,no	webcustomerui
50	CallerID Limit	limit_callerid	5	The total number of callerIDs for CLI Recognition that can be add by the customer.	0	\N	webcustomerui
51	Trunk Name	sip_iax_info_trunkname	YourDomain	Trunk Name to show in sip/iax info.	0	\N	sip-iax-info
52	Codecs Allowed	sip_iax_info_allowcodec	g729	Allowed Codec, ulaw, gsm, g729.	0	\N	sip-iax-info
53	Host	sip_iax_info_host	YourDomain.com	Host information.	0	\N	sip-iax-info
54	IAX Parms	iax_additional_parameters	canreinvite = no	IAX Additional Parameters.	0	\N	sip-iax-info
55	SIP Parms	sip_additional_parameters	trustrpid = yes | sendrpid = yes | canreinvite = no	SIP Additional Parameters.	0	\N	sip-iax-info
56	Enable	enable	1	Enable/Disable.	1	yes,no	epayment_method
57	HTTP Server Customer	http_server	http://www.YourDomain.com	Set the Server Address of Customer Website, It should be empty for productive Servers.	0	\N	epayment_method
58	HTTPS Server Customer	https_server	https://www.YourDomain.com	https://localhost - Enter here your Secure Customers Server Address, should not be empty for productive servers.	0	\N	epayment_method
59	Server Customer IP/Domain	http_cookie_domain	26.63.165.200	Enter your Domain Name or IP Address for the Customers application, eg, 26.63.165.200.	0	\N	epayment_method
60	Secure Server Customer IP/Domain	https_cookie_domain	26.63.165.200	Enter your Secure server Domain Name or IP Address for the Customers application, eg, 26.63.165.200.	0	\N	epayment_method
61	Application Customer Path	http_cookie_path	/customer/	Enter the Physical path of your Customers Application on your server.	0	\N	epayment_method
62	Secure Application Customer Path	https_cookie_path	/customer/	Enter the Physical path of your Customers Application on your Secure Server.	0	\N	epayment_method
4	Base Currency	base_currency	mga	Base Currency to use for application.	0	\N	global
63	Application Customer Physical Path	dir_ws_http_catalog	/customer/	Enter the Physical path of your Customers Application on your server.	0	\N	epayment_method
64	Secure Application Customer Physical Path	dir_ws_https_catalog	/customer/	Enter the Physical path of your Customers Application on your Secure server.	0	\N	epayment_method
65	Enable SSL	enable_ssl	1	secure webserver for checkout procedure?	1	yes,no	epayment_method
66	HTTP Domain	http_domain	26.63.165.200	Http Address.	0	\N	epayment_method
67	Directory Path	dir_ws_http	/customer/	Directory Path.	0	\N	epayment_method
68	Payment Amount	purchase_amount	1:2:5:10:20	define the different amount of purchase that would be available - 5 amount maximum (5:10:15).	0	\N	epayment_method
69	Item Name	item_name	Credit Purchase	Item name that would be display to the user when he will buy credit.	0	\N	epayment_method
70	Currency Code	currency_code	USD	Currency for the Credit purchase, only one can be define here.	0	\N	epayment_method
71	Paypal Payment URL	paypal_payment_url	https://secure.paypal.com/cgi-bin/webscr	Define here the URL of paypal gateway the payment (to test with paypal sandbox).	0	\N	epayment_method
72	Paypal Verify URL	paypal_verify_url	ssl://www.paypal.com	paypal transaction verification url.	0	\N	epayment_method
73	Authorize.NET Payment URL	authorize_payment_url	https://secure.authorize.net/gateway/transact.dll	Define here the URL of Authorize gateway.	0	\N	epayment_method
74	PayPal Store Name	store_name	Asterisk2Billing	paypal store name to show in the paypal site when customer will go to pay.	0	\N	epayment_method
75	Transaction Key	transaction_key	asdf1212fasd121554sd4f5s45sdf	Transaction Key for security of Epayment Max length of 60 Characters.	0	\N	epayment_method
76	Secret Word	moneybookers_secretword		Moneybookers secret word.	0	\N	epayment_method
77	Enable	enable_signup	0	Enable Signup Module.	1	yes,no	signup
78	Captcha Security	enable_captcha	1	enable Captcha on the signup module (value : YES or NO).	1	yes,no	signup
79	Credit	credit	0	amount of credit applied to a new user.	0	\N	signup
80	CallPlan ID List	callplan_id_list	1,2	the list of id of call plans which will be shown in signup.	0	\N	signup
81	Card Activation	activated	0	Specify whether the card is created as active or pending.	1	yes,no	signup
82	Access Type	simultaccess	0	Simultaneous or non concurrent access with the card - 0 = INDIVIDUAL ACCESS or 1 = SIMULTANEOUS ACCESS.	0	\N	signup
83	Paid Type	typepaid	0	PREPAID CARD  =  0 - POSTPAY CARD  =  1.	0	\N	signup
84	Credit Limit	creditlimit	0	Define credit limit, which is only used for a POSTPAY card.	0	\N	signup
85	Run Service	runservice	0	Authorise the recurring service to apply on this card  -  Yes 1 - No 0.	0	\N	signup
86	Enable Expire	enableexpire	0	Enable the expiry of the card  -  Yes 1 - No 0.	0	\N	signup
87	Date Format	expirationdate		Expiry Date format YYYY-MM-DD HH:MM:SS. For instance 2004-12-31 00:00:00	0	\N	signup
88	Expire Limit	expiredays	0	The number of days after which the card will expire.	0	\N	signup
89	Create SIP	sip_account	1	Create a sip account from signup ( default : yes ).	1	yes,no	signup
90	Create IAX	iax_account	1	Create an iax account from signup ( default : yes ).	1	yes,no	signup
91	Activate Card	activatedbyuser	0	active card after the new signup. if No, the Signup confirmation is needed and an email will be sent to the user with a link for activation (need to put the link into the Signup mail template).	1	yes,no	signup
92	Customer Interface URL	urlcustomerinterface	http://localhost/customer/	url of the customer interface to display after activation.	0	\N	signup
93	Asterisk Reload	reload_asterisk_if_sipiax_created	0	Define if you want to reload Asterisk when a SIP / IAX Friend is created at signup time.	1	yes,no	signup
94	Backup Path	backup_path	/tmp	Path to store backup of database.	0	\N	backup
95	GZIP Path	gzip_exe	/bin/gzip	Path for gzip.	0	\N	backup
96	GunZip Path	gunzip_exe	/bin/gunzip	Path for gunzip .	0	\N	backup
97	MySql Dump Path	mysqldump	/usr/bin/mysqldump	path for mysqldump.	0	\N	backup
98	PGSql Dump Path	pg_dump	/usr/bin/pg_dump	path for pg_dump.	0	\N	backup
99	MySql Path	mysql	/usr/bin/mysql	Path for MySql.	0	\N	backup
100	PSql Path	psql	/usr/bin/psql	Path for PSql.	0	\N	backup
101	SIP File Path	buddy_sip_file	/etc/asterisk/additional_a2billing_sip.conf	Path to store the asterisk configuration files SIP.	0	\N	webui
102	IAX File Path	buddy_iax_file	/etc/asterisk/additional_a2billing_iax.conf	Path to store the asterisk configuration files IAX.	0	\N	webui
103	API Security Key	api_security_key	Ae87v56zzl34v	API have a security key to validate the http request, the key has to be sent after applying md5, Valid characters are [a-z,A-Z,0-9].	0	\N	webui
104	Authorized IP	api_ip_auth	127.0.0.1	API to restrict the IPs authorised to make a request, Define The the list of ips separated by ';'.	0	\N	webui
105	Admin Email	email_admin	root@localhost	Administative Email.	0	\N	webui
106	MOH Directory	dir_store_mohmp3	/var/lib/asterisk/mohmp3	MOH (Music on Hold) base directory.	0	\N	webui
107	MOH Classes	num_musiconhold_class	10	Number of MOH classes you have created in musiconhold.conf : acc_1, acc_2... acc_10 class\tetc....	0	\N	webui
108	Display Help	show_help	1	Display the help section inside the admin interface  (YES - NO).	1	yes,no	webui
109	Max File Upload Size	my_max_file_size_import	1024000	File Upload parameters, PLEASE CHECK ALSO THE VALUE IN YOUR PHP.INI THE LIMIT IS 2MG BY DEFAULT .	0	\N	webui
110	Audio Directory Path	dir_store_audio	/var/lib/asterisk/sounds/a2billing	Not used yet, The goal is to upload files and use them in the IVR.	0	\N	webui
111	Max Audio File Size	my_max_file_size_audio	3072000	upload maximum file size.	0	\N	webui
112	Extensions Allowed	file_ext_allow	gsm, mp3, wav	File type extensions permitted to be uploaded such as "gsm, mp3, wav" (separated by ,).	0	\N	webui
113	Muzic Files Allowed	file_ext_allow_musiconhold	mp3	File type extensions permitted to be uploaded for the musiconhold such as "gsm, mp3, wav" (separate by ,).	0	\N	webui
114	Link Audio	link_audio_file	0	Enable link on the CDR viewer to the recordings. (YES - NO).	1	yes,no	webui
115	Monitor Path	monitor_path	/var/spool/asterisk/monitor	Path to link the recorded monitor files.	0	\N	webui
116	Monitor Format	monitor_formatfile	gsm	FORMAT OF THE RECORDED MONITOR FILE.	0	\N	webui
117	Invoice Icon	show_icon_invoice	1	Display the icon in the invoice.	1	yes,no	webui
118	Show Top Frame	show_top_frame	0	Display the top frame (useful if you want to save space on your little tiny screen ) .	1	yes,no	webui
119	Currency	currency_choose	usd, eur, cad, hkd	Allow the customer to chose the most appropriate currency ("all" can be used).	0	\N	webui
121	Vouvher Export Fields	voucher_export_field_list	voucher, credit, tag, activated, usedcardnumber, usedate, currency	Field to export in csv format from cc_voucher table.	0	\N	webui
122	Advance Mode	advanced_mode	0	Advanced mode - Display additional configuration options on the ratecard (progressive rates, musiconhold, ...).	1	yes,no	webui
123	SIP/IAX Delete	delete_fk_card	1	Delete the SIP/IAX Friend & callerid when a card is deleted.	1	yes,no	webui
124	Type	type	friend	Refer to sip.conf & iax.conf documentation for the meaning of those parameters.	0	\N	peer_friend
125	Allow	allow	ulaw,alaw,gsm,g729	Refer to sip.conf & iax.conf documentation for the meaning of those parameters.	0	\N	peer_friend
126	Context	context	a2billing	Refer to sip.conf & iax.conf documentation for the meaning of those parameters.	0	\N	peer_friend
127	Nat	nat	yes	Refer to sip.conf & iax.conf documentation for the meaning of those parameters.	0	\N	peer_friend
128	AMA Flag	amaflag	billing	Refer to sip.conf & iax.conf documentation for the meaning of those parameters.	0	\N	peer_friend
129	Qualify	qualify	yes	Refer to sip.conf & iax.conf documentation for the meaning of those parameters.	0	\N	peer_friend
130	Host	host	dynamic	Refer to sip.conf & iax.conf documentation for the meaning of those parameters.	0	\N	peer_friend
131	DTMF Mode	dtmfmode	RFC2833	Refer to sip.conf & iax.conf documentation for the meaning of those parameters.	0	\N	peer_friend
132	Alarm Log File	cront_alarm	/var/log/a2billing/cront_a2b_alarm.log	To disable application logging, remove/comment the log file name aside service.	0	\N	log-files
133	Auto refill Log File	cront_autorefill	/var/log/a2billing/cront_a2b_autorefill.log	To disable application logging, remove/comment the log file name aside service.	0	\N	log-files
134	Bactch Process Log File	cront_batch_process	/var/log/a2billing/cront_a2b_batch_process.log	To disable application logging, remove/comment the log file name aside service .	0	\N	log-files
135	Archive Log File	cront_archive_data	/var/log/a2billing/cront_a2b_archive_data.log	To disable application logging, remove/comment the log file name aside service .	0	\N	log-files
136	DID Billing Log File	cront_bill_diduse	/var/log/a2billing/cront_a2b_bill_diduse.log	To disable application logging, remove/comment the log file name aside service .	0	\N	log-files
137	Subscription Fee Log File	cront_subscriptionfee	/var/log/a2billing/cront_a2b_subscription_fee.log	To disable application logging, remove/comment the log file name aside service.	0	\N	log-files
138	Currency Cront Log File	cront_currency_update	/var/log/a2billing/cront_a2b_currency_update.log	To disable application logging, remove/comment the log file name aside service.	0	\N	log-files
139	Invoice Cront Log File	cront_invoice	/var/log/a2billing/cront_a2b_invoice.log	To disable application logging, remove/comment the log file name aside service.	0	\N	log-files
140	Cornt Log File	cront_check_account	/var/log/a2billing/cront_a2b_check_account.log	To disable application logging, remove/comment the log file name aside service .	0	\N	log-files
141	Paypal Log File	paypal	/var/log/a2billing/a2billing_paypal.log	paypal log file, to log all the transaction & error.	0	\N	log-files
142	EPayment Log File	epayment	/var/log/a2billing/a2billing_epayment.log	epayment log file, to log all the transaction & error .	0	\N	log-files
143	ECommerce Log File	api_ecommerce	/var/log/a2billing/a2billing_api_ecommerce_request.log	Log file to store the ecommerce API requests .	0	\N	log-files
144	Callback Log File	api_callback	/var/log/a2billing/a2billing_api_callback_request.log	Log file to store the CallBack API requests.	0	\N	log-files
145	Webservice Card Log File	api_card	/var/log/a2billing/a2billing_api_card.log	Log file to store the Card Webservice Logs	0	\N	log-files
146	AGI Log File	agi	/var/log/a2billing/a2billing_agi.log	File to log.	0	\N	log-files
147	Description	description	agi-config	Description/notes field	0	\N	agi-conf1
148	Asterisk Version	asterisk_version	1_4	Asterisk Version Information, 1_1,1_2,1_4 By Default it will take 1_2 or higher .	0	\N	agi-conf1
149	Answer Call	answer_call	1	Manage the answer on the call. Disabling this for callback trigger numbers makes it ring not hang up.	1	yes,no	agi-conf1
150	Play Audio	play_audio	1	Play audio - this will disable all stream file but not the Get Data , for wholesale ensure that the authentication works and than number_try = 1.	1	yes,no	agi-conf1
151	Say GoodBye	say_goodbye	0	play the goodbye message when the user has finished.	1	yes,no	agi-conf1
152	Play Language Menu	play_menulanguage	0	enable the menu to choose the language, press 1 for English, pulsa 2 para el español, Pressez 3 pour Français	1	yes,no	agi-conf1
153	Force Language	force_language		force the use of a language, if you dont want to use it leave the option empty, Values : ES, EN, FR, etc... (according to the audio you have installed).	0	\N	agi-conf1
154	Intro Prompt	intro_prompt		Introduction prompt : to specify an additional prompt to play at the beginning of the application .	0	\N	agi-conf1
155	Min Call Credit	min_credit_2call	0	Minimum amount of credit to use the application .	0	\N	agi-conf1
156	Min Bill Duration	min_duration_2bill	0	this is the minimum duration in seconds of a call in order to be billed any call with a length less than min_duration_2bill will have a 0 cost useful not to charge callers for system errors when a call was answered but it actually didn't connect.	0	\N	agi-conf1
157	Not Enough Credit	notenoughcredit_cardnumber	0	if user doesn't have enough credit to call a destination, prompt him to enter another cardnumber .	1	yes,no	agi-conf1
158	New Caller ID	notenoughcredit_assign_newcardnumber_cid	0	if notenoughcredit_cardnumber = YES  then\tassign the CallerID to the new cardnumber.	1	yes,no	agi-conf1
160	Not Use DNID	no_auth_dnid	2400,2300	list the dnid on which you want to avoid the use of the previous option "use_dnid" .	0	\N	agi-conf1
162	Force CallPlan	force_callplan_id		this will force to select a specific call plan by the Rate Engine.	0	\N	agi-conf1
163	Say Balance After Auth	say_balance_after_auth	1	Play the balance to the user after the authentication (values : yes - no).	1	yes,no	agi-conf1
164	Say Balance After Call	say_balance_after_call	0	Play the balance to the user after the call (values : yes - no).	1	yes,no	agi-conf1
165	Say Rate	say_rateinitial	0	Play the initial cost of the route (values : yes - no)	1	yes,no	agi-conf1
166	Say Duration	say_timetocall	1	Play the amount of time that the user can call (values : yes - no).	1	yes,no	agi-conf1
167	Auto Set CLID	auto_setcallerid	1	enable the setup of the callerID number before the outbound is made, by default the user callerID value will be use.	1	yes,no	agi-conf1
168	Force CLID	force_callerid		If auto_setcallerid is enabled, the value of force_callerid will be set as CallerID.	0	\N	agi-conf1
169	CLID Sanitize	cid_sanitize	0	If force_callerid is not set, then the following option ensures that CID is set to one of the card's configured caller IDs or blank if none available.(NO - disable this feature, caller ID can be anything, CID - Caller ID must be one of the customers caller IDs, DID - Caller ID must be one of the customers DID nos, BOTH - Caller ID must be one of the above two items)	0	\N	agi-conf1
171	Ask PIN	cid_askpincode_ifnot_callerid	1	if the CID does not exist, then the caller will be prompt to enter his cardnumber .	1	yes,no	agi-conf1
172	FailOver LCR/LCD Prefix	failover_lc_prefix	0	if we will failover for LCR/LCD prefix. For instance if you have 346 and 34 for if 346 fail it will try to outbound with 34 route.	1	yes,no	agi-conf1
173	Auto CLID	cid_auto_assign_card_to_cid	1	if the callerID authentication is enable and the authentication fails then the user will be prompt to enter his cardnumber;this option will bound the cardnumber entered to the current callerID so that next call will be directly authenticate.	1	yes,no	agi-conf1
174	Auto Create Card	cid_auto_create_card	0	if the callerID is captured on a2billing, this option will create automatically a new card and add the callerID to it.	1	yes,no	agi-conf1
175	Auto Create Card Length	cid_auto_create_card_len	10	set the length of the card that will be auto create (ie, 10).	0	\N	agi-conf1
176	Auto Create Card Type	cid_auto_create_card_typepaid	POSTPAY	billing type of the new card( value : POSTPAY or PREPAY) .	0	\N	agi-conf1
177	Auto Create Card Credit	cid_auto_create_card_credit	0	amount of credit of the new card.	0	\N	agi-conf1
178	Auto Create Card Limit	cid_auto_create_card_credit_limit	1000	if postpay, define the credit limit for the card.	0	\N	agi-conf1
179	Auto Create Card TariffGroup	cid_auto_create_card_tariffgroup	6	the tariffgroup to use for the new card (this is the ID that you can find on the admin web interface) .	0	\N	agi-conf1
181	SIP Call	sip_iax_friends	0	enable the option to call sip/iax friend for free (values : YES - NO).	1	yes,no	agi-conf1
182	SIP Call Prefix	sip_iax_pstn_direct_call_prefix	555	if SIP_IAX_FRIENDS is active, you can define a prefix for the dialed digits to call a pstn number .	0	\N	agi-conf1
183	Direct Call	sip_iax_pstn_direct_call	0	this will enable a prompt to enter your destination number. if number start by sip_iax_pstn_direct_call_prefix we do directly a sip iax call, if not we do a normal call.	1	yes,no	agi-conf1
184	IVR Voucher Refill	ivr_voucher	0	enable the option to refill card with voucher in IVR (values : YES - NO) .	1	yes,no	agi-conf1
185	IVR Voucher Prefix	ivr_voucher_prefix	8	if ivr_voucher is active, you can define a prefix for the voucher number to refill your card, values : number - don't forget to change prepaid-refill_card_with_voucher audio accordingly .	0	\N	agi-conf1
186	IVR Low Credit	jump_voucher_if_min_credit	0	When the user credit are below the minimum credit to call min_credit jump directly to the voucher IVR menu  (values: YES - NO) .	1	yes,no	agi-conf1
189	Outbound Call	switchdialcommand	0	Define the order to make the outbound call<br>YES -> SIP/dialedphonenumber@gateway_ip - NO  SIP/gateway_ip/dialedphonenumber<br>Both should work exactly the same but i experimented one case when gateway was supporting dialedphonenumber@gateway_ip, So in case of trouble, try it out.	1	yes,no	agi-conf1
180	Auto CLID Security	callerid_authentication_over_cardnumber	1	to check callerID over the cardnumber authentication (to guard against spoofing).	1	yes,no	agi-conf1
170	CLID Enable	cid_enable	1	enable the callerid authentication if this option is active the CC system will check the CID of caller  .	1	yes,no	agi-conf1
159	Use DNID	use_dnid	1	if YES it will use the DNID and try to dial out, without asking for the phonenumber to call.	1	yes,no	agi-conf1
188	SIP/IAX Dial Command Params	dialcommand_param_sipiax_friend	,60,HiL(3600000:61000:30000)	by default (3600000  =  1HOUR MAX CALL).	0	\N	agi-conf1
161	Try Count	number_try	1	number of times the user can dial different number.	0	\N	agi-conf1
190	Failover Retry Limit	failover_recursive_limit	2	failover recursive search - define how many time we want to authorize the research of the failover trunk when a call fails (value : 0 - 20) .	0	\N	agi-conf1
191	Max Time	maxtime_tocall_negatif_free_route	5400	This setting specifies an upper limit for the duration of a call to a destination for which the selling rate is less than or equal to 0.	0	\N	agi-conf1
192	Send Reminder	send_reminder	0	Send a reminder email to the user when they are under min_credit_2call.	1	yes,no	agi-conf1
193	Record Call	record_call	0	enable to monitor the call (to record all the conversations) value : YES - NO .	1	yes,no	agi-conf1
194	Monitor File Format	monitor_formatfile	gsm	format of the recorded monitor file.	0	\N	agi-conf1
195	AGI Force Currency	agi_force_currency		Force to play the balance to the caller in a predefined currency, to use the currency set for by the customer leave this field empty.	0	\N	agi-conf1
196	Currency Associated	currency_association	usd:dollars,mxn:pesos,eur:euros,all:credit	Define all the audio (without file extensions) that you want to play according to currency (use , to separate, ie "usd:prepaid-dollar,mxn:pesos,eur:Euro,all:credit").	0	\N	agi-conf1
197	Minor Currency Associated	currency_association_minor	usd:prepaid-cents,eur:prepaid-cents,gbp:prepaid-pence,all:credit	Define all the audio (without file extensions) that you want to play according to minor currency (use , to separate, ie "usd:prepaid-cents,eur:prepaid-cents,gbp:prepaid-pence,all:credit").	0	\N	agi-conf1
198	File Enter Destination	file_conf_enter_destination	prepaid-enter-dest	Please enter the file name you want to play when we prompt the calling party to enter the destination number, file_conf_enter_destination = prepaid-enter-number-u-calling-1-or-011.	0	\N	agi-conf1
199	Bill Callback	callback_bill_1stleg_ifcall_notconnected	1	Define if you want to bill the 1st leg on callback even if the call is not connected to the destination.	1	yes,no	agi-conf1
200	International prefixes	international_prefixes	011,00,09,1	List the prefixes you want stripped off if the call plan requires it	0	\N	agi-conf1
201	Server GMT	server_GMT	GMT+10:00	Define the sever gmt time	0	\N	global
202	Invoice Template Path	invoice_template_path	../invoice/	gives invoice template path from default one	0	\N	global
203	Outstanding Template Path	outstanding_template_path	../outstanding/	gives outstanding template path from default one	0	\N	global
204	Sales Template Path	sales_template_path	../sales/	gives sales template path from default one	0	\N	global
206	CallPlan threshold Deck switch	callplan_deck_minute_threshold		CallPlan threshold Deck switch. <br/>This option will switch the user callplan from one call plan ID to and other Callplan ID\nThe parameters are as follow : <br/>\n-- ID of the first callplan : called seconds needed to switch to the next CallplanID <br/>\n-- ID of the second callplan : called seconds needed to switch to the next CallplanID <br/>\n-- if not needed seconds are defined it will automatically switch to the next one <br/>\n-- if defined we will sum the previous needed seconds and check if the caller had done at least the amount of calls necessary to go to the next step and have the amount of seconds needed<br/>\nvalue example for callplan_deck_minute_threshold = 1:300, 2:60, 3	0	\N	agi-conf1
207	Max Time For Unlimited Calls	maxtime_tounlimited_calls	5400	For unlimited calls, limit the duration: amount in seconds .	0	\N	agi-conf1
208	Max Time For Free Calls	maxtime_tofree_calls	5400	For free calls, limit the duration: amount in seconds .	0	\N	agi-conf1
209	Payment Amount	purchase_amount_agent	100:200:500:1000	define the different amount of purchase that would be available.	0	\N	epayment_method
210	List of possible values to notify	values_notifications	10:20:50:100:500:1000	Possible values to choose when the user receive a notification. You can define a List e.g: 10:20:100.	0	\N	notifications
211	Notifications Modules	notification	1	Enable or Disable the module of notification for the customers	1	yes,no	webcustomerui
212	Notications Cron Module	cron_notifications	1	Enable or Disable the cron module of notification for the customers. If it correctly configured in the crontab	0	yes,no	notifications
213	Notications Delay	delay_notifications	1	Delay in number of days to send an other notification for the customers. If the value is 0, it will notify the user everytime the cront is running.	0	\N	notifications
215	Extra charge DIDs	extracharge_did	1800,1900	Add extra per-minute charges to this comma-separated list of DNIDs; needs "extracharge_fee" and "extracharge_buyfee"	0	\N	agi-conf1
218	Card Serial Pad Length	card_serial_length	7	Value of zero padding for serial. If this value set to 3 serial wil looks like 001	0	\N	webui
219	Dial Balance reservation	dial_balance_reservation	0.25	Credit to reserve from the balance when a call is made. This will prevent negative balance on huge peak.	0	\N	agi-conf1
220	Menu Language Order	conf_order_menulang	en:fr:es	Enter the list of languages authorized for the menu.Use the code language separate by a colon charactere e.g: en:es:fr	0	\N	agi-conf1
221	Disable annoucement the second of the times that the card can call	disable_announcement_seconds	0	Desactived the annoucement of the seconds when there are more of one minutes (values : yes - no)	1	yes,no	agi-conf1
222	Charge for the paypal extra fees	charge_paypal_fee	0	Actived, if you want assum the fee of paypal and don't apply it on the customer (values : yes - no)	1	yes,no	epayment_method
223	Cents Currency Associated	currency_cents_association		Define all the audio (without file extensions) that you want to play according to cents currency (use , to separate, ie "amd:lumas").By default the file used is "prepaid-cents" .Use plural to define the cents currency sound, but import two sounds but cents currency defined : ending by 's' and not ending by 's' (i.e. for lumas , add 2 files : 'lumas' and 'luma') 	0	\N	agi-conf1
224	Context Campaign's Callback	context_campaign_callback	a2billing-campaign-callback	Context to use in Campaign of Callback	0	\N	callback
225	Default Context forward Campaign's Callback 	default_context_campaign	campaign	Context to use by default to forward the call in Campaign of Callback	0	\N	callback
226	Card Show Fields	card_show_field_list	id:,username:, useralias:, lastname:,id_group:, id_agent:,  credit:, tariff:, status:, language:, inuse:, currency:, sip_buddy:, iax_buddy:, nbused, id_seria, serial:	Fields to show in Customer. Order is important. You can setup size of field using "fieldname:10%" notation or "fieldname:" for harcoded size,"fieldname" for autosize. <br/>You can use:<br/> id,username, useralias, lastname, id_group, id_agent,  credit, tariff, status, language, inuse, currency, sip_buddy, iax_buddy, nbused, firstname, email, discount, callerid	0	\N	webui
227	Enable CDR local cache	cache_enabled	0	If you want enabled the local cache to save the CDR in a SQLite Database.	1	yes,no	global
228	Path for the CDR cache file	cache_path	/etc/asterisk/cache_a2billing	Defined the file that you want use for the CDR cache to save the CDR in a local SQLite database.	0	\N	global
229	PNL Pay Phones	report_pnl_pay_phones	(8887798764,0.02,0.06)	Info for PNL report. Must be in form "(number1,buycost,sellcost),(number2,buycost,sellcost)", number can be prefix, i.e 1800	0	\N	webui
230	PNL Toll Free Numbers	report_pnl_toll_free	(6136864646,0.1,0),(6477249717,0.1,0)	Info for PNL report. must be in form "(number1,buycost,sellcost),(number2,buycost,sellcost)", number can be prefix, i.e 1800	0	\N	webui
231	Verbosity	verbosity_level	0	0 = FATAL; 1 = ERROR; WARN = 2 ; INFO = 3 ; DEBUG = 4	0	\N	agi-conf1
232	Logging	logging_level	3	0 = FATAL; 1 = ERROR; WARN = 2 ; INFO = 3 ; DEBUG = 4	0	\N	agi-conf1
233	Enable info module about customers	customer_info_enabled	LEFT	If you want enabled the info module customer and place it somewhere on the home page.	0	NONE,LEFT,CENTER,RIGHT	dashboard
234	Enable info module about refills	refill_info_enabled	CENTER	If you want enabled the info module refills and place it somewhere on the home page.	0	NONE,LEFT,CENTER,RIGHT	dashboard
235	Enable info module about payments	payment_info_enabled	CENTER	If you want enabled the info module payments and place it somewhere on the home page.	0	NONE,LEFT,CENTER,RIGHT	dashboard
236	Enable info module about calls	call_info_enabled	RIGHT	If you want enabled the info module calls and place it somewhere on the home page.	0	NONE,LEFT,CENTER,RIGHT	dashboard
237	PlugnPay Payment URL	plugnpay_payment_url	https://pay1.plugnpay.com/payment/pnpremote.cgi	Define here the URL of PlugnPay gateway.	0	\N	epayment_method
239	DIDX PASS	didx_pass	XXXXXXXXXX	DIDX parameter : Password	0	\N	webui
240	DIDX MIN RATING	didx_min_rating	0	DIDX parameter : min rating	0	\N	webui
241	DIDX RING TO	didx_ring_to	0	DIDX parameter : ring to	0	\N	webui
242	HTTP Server Agent	http_server_agent	http://www.YourDomain.com	Set the Server Address of Agent Website, It should be empty for productive Servers.	0	\N	epayment_method
243	HTTPS Server Agent	https_server_agent	https://www.YourDomain.com	https://localhost - Enter here your Secure Agents Server Address, should not be empty for productive servers.	0	\N	epayment_method
244	Server Agent IP/Domain	http_cookie_domain_agent	26.63.165.200	Enter your Domain Name or IP Address for the Agents application, eg, 26.63.165.200.	0	\N	5
245	Secure Server Agent IP/Domain	https_cookie_domain_agent	26.63.165.200	Enter your Secure server Domain Name or IP Address for the Agents application, eg, 26.63.165.200.	0	\N	epayment_method
246	Application Agent Path	http_cookie_path_agent	/agent/Public/	Enter the Physical path of your Agents Application on your server.	0	\N	epayment_method
247	Secure Application Agent Path	https_cookie_path_agent	/agent/Public/	Enter the Physical path of your Agents Application on your Secure Server.	0	\N	epayment_method
248	Application Agent Physical Path	dir_ws_http_catalog_agent	/agent/Public/	Enter the Physical path of your Agents Application on your server.	0	\N	epayment_method
249	Secure Application Agent Physical Path	dir_ws_https_catalog_agent	/agent/Public/	Enter the Physical path of your Agents Application on your Secure server.	0	\N	epayment_method
250	Personal Info	personalinfo	1	Enable or disable the page which allow agent to modify its personal information.	0	yes,no	webagentui
251	Return URL distant Login	return_url_distant_login		URL for specific return if an error occur after login	0	\N	webcustomerui
252	Return URL distant Forget Password	return_url_distant_forgetpassword		URL for specific return if an error occur after forgetpassword	0	\N	webcustomerui
216	Extra charge DID fees	extracharge_fee	0,0	Comma-separated list of extra sell-rate charges corresponding to the DIDs in "extracharge_did" - ie : 0.08,0.18	0	\N	agi-conf1
217	Extra charge DID buy fees	extracharge_buyfee	0,0	Comma-separated list of extra buy-rate charges corresponding to the DIDs in "extracharge_did" - ie : 0.04,0.13	0	\N	agi-conf1
120	Card Export Fields	card_export_field_list	cc_card.id, username, useralias, lastname, credit, tariff, activated, language, inuse, currency, sip_buddy, iax_buddy, nbused, mac_addr	Fields to export in csv format from cc_card table.	0	\N	webui
253	SMTP Port	smtp_port	25	Port to connect on the SMTP server	0	\N	global
254	SMTP Secure	smtp_secure		sets the prefix to the SMTP server : tls ; ssl	0	\N	global
187	Dial Command Params	dialcommand_param	,60,HRirL(%timeout%:61000:30000)	More information about the Dial : http://voip-info.org/wiki-Asterisk+cmd+dial<br>30 :  The timeout parameter is optional. If not specifed, the Dial command will wait indefinitely, exiting only when the originating channel hangs up, or all the dialed channels return a busy or error condition. Otherwise it specifies a maximum time, in seconds, that the Dial command is to wait for a channel to answer.<br>H: Allow the caller to hang up by dialing * <br>r: Generate a ringing tone for the calling party<br>R: Indicate ringing to the calling party when the called party indicates ringing, pass no audio until answered.<br>g: When the called party hangs up, exit to execute more commands in the current context. (new in 1.4)<br>i: Asterisk will ignore any forwarding (302 Redirect) requests received. Essential for DID usage to prevent fraud. (new in 1.4)<br>m: Provide Music on Hold to the calling party until the called channel answers.<br>L(x[:y][:z]): Limit the call to 'x' ms, warning when 'y' ms are left, repeated every 'z' ms)<br>%timeout% tag is replaced by the calculated timeout according the credit & destination rate!.	0	\N	agi-conf1
\.


--
-- Data for Name: cc_config_group; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_config_group (id, group_title, group_description) FROM stdin;
1	global	This configuration group handles the global settings for application.
2	callback	This configuration group handles calllback settings.
3	webcustomerui	This configuration group handles Web Customer User Interface.
4	sip-iax-info	SIP & IAX client configuration information.
5	epayment_method	Epayment Methods Configuration.
6	signup	This configuration group handles the signup related settings.
7	backup	This configuration group handles the backup/restore related settings.
8	webui	This configuration group handles the WEBUI and API Configuration.
9	peer_friend	This configuration group define parameters for the friends creation.
10	log-files	This configuration group handles the Log Files Directory Paths.
11	agi-conf1	This configuration group handles the AGI Configuration.
12	notifications	This configuration group handles the notifcations configuration
13	dashboard	This configuration group handles the dashboard configuration
14	webagentui	This configuration group handles Web Agent Interface.
\.


--
-- Data for Name: cc_configuration; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_configuration (configuration_id, configuration_title, configuration_key, configuration_value, configuration_description, configuration_type, use_function, set_function) FROM stdin;
1	Login Username	MODULE_PAYMENT_AUTHORIZENET_LOGIN	testing	The login username used for the Authorize.net service	0	\N	\N
2	Transaction Key	MODULE_PAYMENT_AUTHORIZENET_TXNKEY	Test	Transaction Key used for encrypting TP data	0	\N	\N
3	Transaction Mode	MODULE_PAYMENT_AUTHORIZENET_TESTMODE	Test	Transaction mode used for processing orders	0	\N	tep_cfg_select_option(array('Test', 'Production'), 
4	Transaction Method	MODULE_PAYMENT_AUTHORIZENET_METHOD	Credit Card	Transaction method used for processing orders	0	\N	tep_cfg_select_option(array('Credit Card', 'eCheck'), 
5	Customer Notifications	MODULE_PAYMENT_AUTHORIZENET_EMAIL_CUSTOMER	False	Should Authorize.Net e-mail a receipt to the customer?	0	\N	tep_cfg_select_option(array('True', 'False'), 
7	Enable PayPal Module	MODULE_PAYMENT_PAYPAL_STATUS	True	Do you want to accept PayPal payments?	0	\N	tep_cfg_select_option(array('True', 'False'), 
8	E-Mail Address	MODULE_PAYMENT_PAYPAL_ID	you@yourbusiness.com	The e-mail address to use for the PayPal service	0	\N	\N
9	Transaction Currency	MODULE_PAYMENT_PAYPAL_CURRENCY	Alternative Transaction Currency	The alternative currency to use for credit card transactions if the system currency is not usable	0	\N	tep_cfg_select_option(array('USD','CAD','EUR','GBP','JPY'), 
10	E-Mail Address	MODULE_PAYMENT_MONEYBOOKERS_ID	you@yourbusiness.com	The eMail address to use for the moneybookers service	0	\N	\N
11	Referral ID	MODULE_PAYMENT_MONEYBOOKERS_REFID	989999	Your personal Referral ID from moneybookers.com	0	\N	\N
12	Transaction Currency	MODULE_PAYMENT_MONEYBOOKERS_CURRENCY	Alternative Transaction Currency	The alternative currency to use for credit card transactions if the system currency is not usable	0	\N	tep_cfg_select_option(array('EUR', 'USD', 'GBP', 'HKD', 'SGD', 'JPY', 'CAD', 'AUD', 'CHF', 'DKK', 'SEK', 'NOK', 'ILS', 'MYR', 'NZD', 'TWD', 'THB', 'CZK', 'HUF', 'SKK', 'ISK', 'INR'), 
13	Transaction Language	MODULE_PAYMENT_MONEYBOOKERS_LANGUAGE	Selected Language	The default language for the payment transactions	0	\N	tep_cfg_select_option(array('Selected Language','EN', 'DE', 'ES', 'FR'), 
14	Enable moneybookers Module	MODULE_PAYMENT_MONEYBOOKERS_STATUS	True	Do you want to accept moneybookers payments?	0	\N	tep_cfg_select_option(array('True', 'False'), 
15	Enable PlugnPay Module	MODULE_PAYMENT_PLUGNPAY_STATUS	True	Do you want to accept payments through PlugnPay?	0	\N	tep_cfg_select_option(array('True', 'False'), 
16	Login Username	MODULE_PAYMENT_PLUGNPAY_LOGIN	Your Login Name	Enter your PlugnPay account username	0	\N	\N
17	Publisher Email	MODULE_PAYMENT_PLUGNPAY_PUBLISHER_EMAIL	Enter Your Email Address	The email address you want PlugnPay conformations sent to	0	\N	\N
18	cURL Setup	MODULE_PAYMENT_PLUGNPAY_CURL	Not Compiled	Whether cURL is compiled into PHP or not.  Windows users, select not compiled.	0	\N	tep_cfg_select_option(array('Not Compiled', 'Compiled'), 
19	cURL Path	MODULE_PAYMENT_PLUGNPAY_CURL_PATH	The Path To cURL	For Not Compiled mode only, input path to the cURL binary (i.e. c:/curl/curl)	0	\N	\N
20	Transaction Mode	MODULE_PAYMENT_PLUGNPAY_TESTMODE	Test	Transaction mode used for processing orders	0	\N	tep_cfg_select_option(array('Test', 'Test And Debug', 'Production'), 
21	Require CVV	MODULE_PAYMENT_PLUGNPAY_CVV	yes	Ask For CVV information	0	\N	tep_cfg_select_option(array('yes', 'no'), 
22	Transaction Method	MODULE_PAYMENT_PLUGNPAY_PAYMETHOD	credit	Transaction method used for processing orders.<br><b>NOTE:</b> Selecting 'onlinecheck' assumes you will offer 'credit' as well.	0	\N	tep_cfg_select_option(array('credit', 'onlinecheck'), 
23	Authorization Type	MODULE_PAYMENT_PLUGNPAY_CCMODE	authpostauth	Credit card processing mode	0	\N	tep_cfg_select_option(array('authpostauth', 'authonly'), 
24	Customer Notifications	MODULE_PAYMENT_PLUGNPAY_DONTSNDMAIL	yes	Should PlugnPay not email a receipt to the customer?	0	\N	tep_cfg_select_option(array('yes', 'no'), 
25	Accepted Credit Cards	MODULE_PAYMENT_PLUGNPAY_ACCEPTED_CC	Mastercard, Visa	The credit cards you currently accept	0	\N	_selectOptions(array('Amex','Discover', 'Mastercard', 'Visa'), 
6	Enable Authorize.net Module	MODULE_PAYMENT_AUTHORIZENET_STATUS	False	Do you want to accept Authorize.net payments?	0	\N	tep_cfg_select_option(array('True', 'False'), 
\.


--
-- Data for Name: cc_country; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_country (id, countrycode, countryprefix, countryname) FROM stdin;
1	AFG	93	Afghanistan
2	ALB	355	Albania
3	DZA	213	Algeria
4	ASM	684	American Samoa
5	AND	376	Andorra
6	AGO	244	Angola
7	AIA	1264	Anguilla
8	ATA	672	Antarctica
9	ATG	1268	Antigua And Barbuda
10	ARG	54	Argentina
11	ARM	374	Armenia
12	ABW	297	Aruba
13	AUS	61	Australia
14	AUT	43	Austria
15	AZE	994	Azerbaijan
16	BHS	1242	Bahamas
17	BHR	973	Bahrain
18	BGD	880	Bangladesh
19	BRB	1246	Barbados
20	BLR	375	Belarus
21	BEL	32	Belgium
22	BLZ	501	Belize
23	BEN	229	Benin
24	BMU	1441	Bermuda
25	BTN	975	Bhutan
26	BOL	591	Bolivia
27	BIH	387	Bosnia And Herzegovina
28	BWA	267	Botswana
29	BVT	0	Bouvet Island
30	BRA	55	Brazil
31	IOT	1284	British Indian Ocean Territory
32	BRN	673	Brunei Darussalam
33	BGR	359	Bulgaria
34	BFA	226	Burkina Faso
35	BDI	257	Burundi
36	KHM	855	Cambodia
37	CMR	237	Cameroon
38	CAN	1	Canada
39	CPV	238	Cape Verde
40	CYM	1345	Cayman Islands
41	CAF	236	Central African Republic
42	TCD	235	Chad
43	CHL	56	Chile
44	CHN	86	China
45	CXR	618	Christmas Island
46	CCK	61	Cocos (Keeling); Islands
47	COL	57	Colombia
48	COM	269	Comoros
49	COG	242	Congo
50	COD	243	Congo, The Democratic Republic Of The
51	COK	682	Cook Islands
52	CRI	506	Costa Rica
54	HRV	385	Croatia
55	CUB	53	Cuba
56	CYP	357	Cyprus
57	CZE	420	Czech Republic
58	DNK	45	Denmark
59	DJI	253	Djibouti
60	DMA	1767	Dominica
61	DOM	1809	Dominican Republic
62	ECU	593	Ecuador
63	EGY	20	Egypt
64	SLV	503	El Salvador
65	GNQ	240	Equatorial Guinea
66	ERI	291	Eritrea
67	EST	372	Estonia
68	ETH	251	Ethiopia
69	FLK	500	Falkland Islands (Malvinas);
70	FRO	298	Faroe Islands
71	FJI	679	Fiji
72	FIN	358	Finland
73	FRA	33	France
74	GUF	596	French Guiana
75	PYF	594	French Polynesia
76	ATF	689	French Southern Territories
77	GAB	241	Gabon
78	GMB	220	Gambia
79	GEO	995	Georgia
80	DEU	49	Germany
81	GHA	233	Ghana
82	GIB	350	Gibraltar
83	GRC	30	Greece
84	GRL	299	Greenland
85	GRD	1473	Grenada
86	GLP	590	Guadeloupe
87	GUM	1671	Guam
88	GTM	502	Guatemala
89	GIN	224	Guinea
90	GNB	245	Guinea-Bissau
91	GUY	592	Guyana
92	HTI	509	Haiti
93	HMD	0	Heard Island And McDonald Islands
94	VAT	0	Holy See (Vatican City State);
95	HND	504	Honduras
96	HKG	852	Hong Kong
97	HUN	36	Hungary
98	ISL	354	Iceland
99	IND	91	India
100	IDN	62	Indonesia
101	IRN	98	Iran, Islamic Republic Of
102	IRQ	964	Iraq
103	IRL	353	Ireland
104	ISR	972	Israel
105	ITA	39	Italy
106	JAM	1876	Jamaica
107	JPN	81	Japan
108	JOR	962	Jordan
109	KAZ	7	Kazakhstan
110	KEN	254	Kenya
111	KIR	686	Kiribati
112	PRK	850	Korea, Democratic People's Republic Of
113	KOR	82	Korea, Republic of
114	KWT	965	Kuwait
115	KGZ	996	Kyrgyzstan
116	LAO	856	Lao People's Democratic Republic
117	LVA	371	Latvia
118	LBN	961	Lebanon
119	LSO	266	Lesotho
120	LBR	231	Liberia
121	LBY	218	Libyan Arab Jamahiriya
122	LIE	423	Liechtenstein
123	LTU	370	Lithuania
124	LUX	352	Luxembourg
125	MAC	853	Macao
126	MKD	389	Macedonia, The Former Yugoslav Republic Of
127	MDG	261	Madagascar
128	MWI	265	Malawi
129	MYS	60	Malaysia
130	MDV	960	Maldives
131	MLI	223	Mali
132	MLT	356	Malta
133	MHL	692	Marshall islands
134	MTQ	596	Martinique
135	MRT	222	Mauritania
136	MUS	230	Mauritius
137	MYT	269	Mayotte
138	MEX	52	Mexico
139	FSM	691	Micronesia, Federated States Of
140	MDA	1808	Moldova, Republic Of
141	MCO	377	Monaco
142	MNG	976	Mongolia
143	MSR	1664	Montserrat
144	MAR	212	Morocco
145	MOZ	258	Mozambique
146	MMR	95	Myanmar
147	NAM	264	Namibia
148	NRU	674	Nauru
149	NPL	977	Nepal
150	NLD	31	Netherlands
151	ANT	599	Netherlands Antilles
152	NCL	687	New Caledonia
153	NZL	64	New Zealand
154	NIC	505	Nicaragua
155	NER	227	Niger
156	NGA	234	Nigeria
157	NIU	683	Niue
158	NFK	672	Norfolk Island
159	MNP	1670	Northern Mariana Islands
160	NOR	47	Norway
161	OMN	968	Oman
162	PAK	92	Pakistan
163	PLW	680	Palau
164	PSE	970	Palestinian Territory, Occupied
165	PAN	507	Panama
166	PNG	675	Papua New Guinea
167	PRY	595	Paraguay
168	PER	51	Peru
169	PHL	63	Philippines
170	PCN	0	Pitcairn
171	POL	48	Poland
172	PRT	351	Portugal
173	PRI	1787	Puerto Rico
174	QAT	974	Qatar
175	REU	262	Reunion
176	ROU	40	Romania
177	RUS	7	Russian Federation
178	RWA	250	Rwanda
179	SHN	290	Saint Helena
180	KNA	1869	Saint Kitts And Nevis
181	LCA	1758	Saint Lucia
182	SPM	508	Saint Pierre And Miquelon
183	VCT	1784	Saint Vincent And The Grenadines
184	WSM	685	Samoa
185	SMR	378	San Marino
186	STP	239	São Tomé And Principe
187	SAU	966	Saudi Arabia
188	SEN	221	Senegal
189	SYC	248	Seychelles
190	SLE	232	Sierra Leone
191	SGP	65	Singapore
192	SVK	421	Slovakia
193	SVN	386	Slovenia
194	SLB	677	Solomon Islands
195	SOM	252	Somalia
196	ZAF	27	South Africa
197	SGS	0	South Georgia And The South Sandwich Islands
198	ESP	34	Spain
199	LKA	94	Sri Lanka
200	SDN	249	Sudan
201	SUR	597	Suriname
202	SJM	0	Svalbard and Jan Mayen
203	SWZ	268	Swaziland
204	SWE	46	Sweden
205	CHE	41	Switzerland
206	SYR	963	Syrian Arab Republic
207	TWN	886	Taiwan, Province Of China
208	TJK	992	Tajikistan
209	TZA	255	Tanzania, United Republic Of
210	THA	66	Thailand
211	TLS	670	Timor-Leste
212	TGO	228	Togo
213	TKL	690	Tokelau
214	TON	676	Tonga
215	TTO	1868	Trinidad And Tobago
216	TUN	216	Tunisia
217	TUR	90	Turkey
218	TKM	993	Turkmenistan
219	TCA	1649	Turks And Caicos Islands
220	TUV	688	Tuvalu
221	UGA	256	Uganda
222	UKR	380	Ukraine
223	ARE	971	United Arab Emirates
224	GBR	44	United Kingdom
225	USA	1	United States
226	UMI	0	United States Minor Outlying Islands
227	URY	598	Uruguay
228	UZB	998	Uzbekistan
229	VUT	678	Vanuatu
230	VEN	58	Venezuela
231	VNM	84	Vietnam
232	VGB	1284	Virgin Islands, British
233	VIR	808	Virgin Islands, U.S.
234	WLF	681	Wallis And Futuna
235	ESH	0	Western Sahara
236	YEM	967	Yemen
237	YUG	0	Yugoslavia
238	ZMB	260	Zambia
239	ZWE	263	Zimbabwe
240	ASC	0	Ascension Island
241	DGA	0	Diego Garcia
242	XNM	0	Inmarsat
243	TMP	0	East timor
244	AK	0	Alaska
245	HI	0	Hawaii
53	CIV	225	Côte d'Ivoire
246	ALA	35818	Aland Islands
247	BLM	0	Saint Barthelemy
248	GGY	441481	Guernsey
249	IMN	441624	Isle of Man
250	JEY	441534	Jersey
251	MAF	0	Saint Martin
252	MNE	382	Montenegro, Republic of
253	SRB	381	Serbia, Republic of
254	CPT	0	Clipperton Island
255	TAA	0	Tristan da Cunha
\.


--
-- Data for Name: cc_currencies; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_currencies (id, currency, name, value, lastupdate, basecurrency) FROM stdin;
1	ALL	Albanian Lek (ALL)	0.00974	2026-08-20 07:30:39.703147	USD
2	DZD	Algerian Dinar (DZD)	0.01345	2026-08-20 07:30:39.703147	USD
3	XAL	Aluminium Ounces (XAL)	1.08295	2026-08-20 07:30:39.703147	USD
4	ARS	Argentine Peso (ARS)	0.32455	2026-08-20 07:30:39.703147	USD
5	AWG	Aruba Florin (AWG)	0.55866	2026-08-20 07:30:39.703147	USD
6	AUD	Australian Dollar (AUD)	0.73384	2026-08-20 07:30:39.703147	USD
7	BSD	Bahamian Dollar (BSD)	1.00000	2026-08-20 07:30:39.703147	USD
8	BHD	Bahraini Dinar (BHD)	2.65322	2026-08-20 07:30:39.703147	USD
9	BDT	Bangladesh Taka (BDT)	0.01467	2026-08-20 07:30:39.703147	USD
10	BBD	Barbados Dollar (BBD)	0.50000	2026-08-20 07:30:39.703147	USD
11	BYR	Belarus Ruble (BYR)	0.00046	2026-08-20 07:30:39.703147	USD
12	BZD	Belize Dollar (BZD)	0.50569	2026-08-20 07:30:39.703147	USD
13	BMD	Bermuda Dollar (BMD)	1.00000	2026-08-20 07:30:39.703147	USD
14	BTN	Bhutan Ngultrum (BTN)	0.02186	2026-08-20 07:30:39.703147	USD
15	BOB	Bolivian Boliviano (BOB)	0.12500	2026-08-20 07:30:39.703147	USD
16	BRL	Brazilian Real (BRL)	0.46030	2026-08-20 07:30:39.703147	USD
17	GBP	British Pound (GBP)	1.73702	2026-08-20 07:30:39.703147	USD
18	BND	Brunei Dollar (BND)	0.61290	2026-08-20 07:30:39.703147	USD
19	BGN	Bulgarian Lev (BGN)	0.60927	2026-08-20 07:30:39.703147	USD
20	BIF	Burundi Franc (BIF)	0.00103	2026-08-20 07:30:39.703147	USD
21	KHR	Cambodia Riel (KHR)	0.00000	2026-08-20 07:30:39.703147	USD
22	CAD	Canadian Dollar (CAD)	0.86386	2026-08-20 07:30:39.703147	USD
23	KYD	Cayman Islands Dollar (KYD)	1.16496	2026-08-20 07:30:39.703147	USD
24	XOF	CFA Franc (BCEAO) (XOF)	0.00182	2026-08-20 07:30:39.703147	USD
25	XAF	CFA Franc (BEAC) (XAF)	0.00182	2026-08-20 07:30:39.703147	USD
26	CLP	Chilean Peso (CLP)	0.00187	2026-08-20 07:30:39.703147	USD
27	CNY	Chinese Yuan (CNY)	0.12425	2026-08-20 07:30:39.703147	USD
28	COP	Colombian Peso (COP)	0.00044	2026-08-20 07:30:39.703147	USD
29	KMF	Comoros Franc (KMF)	0.00242	2026-08-20 07:30:39.703147	USD
30	XCP	Copper Ounces (XCP)	2.16403	2026-08-20 07:30:39.703147	USD
31	CRC	Costa Rica Colon (CRC)	0.00199	2026-08-20 07:30:39.703147	USD
32	HRK	Croatian Kuna (HRK)	0.16249	2026-08-20 07:30:39.703147	USD
33	CUP	Cuban Peso (CUP)	1.00000	2026-08-20 07:30:39.703147	USD
34	CYP	Cyprus Pound (CYP)	2.07426	2026-08-20 07:30:39.703147	USD
35	CZK	Czech Koruna (CZK)	0.04133	2026-08-20 07:30:39.703147	USD
36	DKK	Danish Krone (DKK)	0.15982	2026-08-20 07:30:39.703147	USD
37	DJF	Dijibouti Franc (DJF)	0.00000	2026-08-20 07:30:39.703147	USD
38	DOP	Dominican Peso (DOP)	0.03035	2026-08-20 07:30:39.703147	USD
39	XCD	East Caribbean Dollar (XCD)	0.37037	2026-08-20 07:30:39.703147	USD
40	ECS	Ecuador Sucre (ECS)	0.00004	2026-08-20 07:30:39.703147	USD
41	EGP	Egyptian Pound (EGP)	0.17433	2026-08-20 07:30:39.703147	USD
42	SVC	El Salvador Colon (SVC)	0.11426	2026-08-20 07:30:39.703147	USD
43	ERN	Eritrea Nakfa (ERN)	0.00000	2026-08-20 07:30:39.703147	USD
44	EEK	Estonian Kroon (EEK)	0.07615	2026-08-20 07:30:39.703147	USD
45	ETB	Ethiopian Birr (ETB)	0.11456	2026-08-20 07:30:39.703147	USD
46	EUR	Euro (EUR)	1.19175	2026-08-20 07:30:39.703147	USD
47	FKP	Falkland Islands Pound (FKP)	0.00000	2026-08-20 07:30:39.703147	USD
48	GMD	Gambian Dalasi (GMD)	0.03515	2026-08-20 07:30:39.703147	USD
49	GHC	Ghanian Cedi (GHC)	0.00011	2026-08-20 07:30:39.703147	USD
50	GIP	Gibraltar Pound (GIP)	0.00000	2026-08-20 07:30:39.703147	USD
51	XAU	Gold Ounces (XAU)	555.55556	2026-08-20 07:30:39.703147	USD
52	GTQ	Guatemala Quetzal (GTQ)	0.13103	2026-08-20 07:30:39.703147	USD
53	GNF	Guinea Franc (GNF)	0.00022	2026-08-20 07:30:39.703147	USD
54	HTG	Haiti Gourde (HTG)	0.02387	2026-08-20 07:30:39.703147	USD
55	HNL	Honduras Lempira (HNL)	0.05292	2026-08-20 07:30:39.703147	USD
56	HKD	Hong Kong Dollar (HKD)	0.12884	2026-08-20 07:30:39.703147	USD
57	HUF	Hungarian Forint (HUF)	0.00461	2026-08-20 07:30:39.703147	USD
58	ISK	Iceland Krona (ISK)	0.01436	2026-08-20 07:30:39.703147	USD
59	INR	Indian Rupee (INR)	0.02253	2026-08-20 07:30:39.703147	USD
60	IDR	Indonesian Rupiah (IDR)	0.00011	2026-08-20 07:30:39.703147	USD
61	IRR	Iran Rial (IRR)	0.00011	2026-08-20 07:30:39.703147	USD
62	ILS	Israeli Shekel (ILS)	0.21192	2026-08-20 07:30:39.703147	USD
63	JMD	Jamaican Dollar (JMD)	0.01536	2026-08-20 07:30:39.703147	USD
64	JPY	Japanese Yen (JPY)	0.00849	2026-08-20 07:30:39.703147	USD
65	JOD	Jordanian Dinar (JOD)	1.41044	2026-08-20 07:30:39.703147	USD
66	KZT	Kazakhstan Tenge (KZT)	0.00773	2026-08-20 07:30:39.703147	USD
67	KES	Kenyan Shilling (KES)	0.01392	2026-08-20 07:30:39.703147	USD
68	KRW	Korean Won (KRW)	0.00102	2026-08-20 07:30:39.703147	USD
69	KWD	Kuwaiti Dinar (KWD)	3.42349	2026-08-20 07:30:39.703147	USD
70	LAK	Lao Kip (LAK)	0.00000	2026-08-20 07:30:39.703147	USD
71	LVL	Latvian Lat (LVL)	1.71233	2026-08-20 07:30:39.703147	USD
72	LBP	Lebanese Pound (LBP)	0.00067	2026-08-20 07:30:39.703147	USD
73	LSL	Lesotho Loti (LSL)	0.15817	2026-08-20 07:30:39.703147	USD
74	LYD	Libyan Dinar (LYD)	0.00000	2026-08-20 07:30:39.703147	USD
75	LTL	Lithuanian Lita (LTL)	0.34510	2026-08-20 07:30:39.703147	USD
76	MOP	Macau Pataca (MOP)	0.12509	2026-08-20 07:30:39.703147	USD
77	MKD	Macedonian Denar (MKD)	0.01945	2026-08-20 07:30:39.703147	USD
78	MGF	Malagasy Franc (MGF)	0.00011	2026-08-20 07:30:39.703147	USD
79	MWK	Malawi Kwacha (MWK)	0.00752	2026-08-20 07:30:39.703147	USD
80	MYR	Malaysian Ringgit (MYR)	0.26889	2026-08-20 07:30:39.703147	USD
81	MVR	Maldives Rufiyaa (MVR)	0.07813	2026-08-20 07:30:39.703147	USD
82	MTL	Maltese Lira (MTL)	2.77546	2026-08-20 07:30:39.703147	USD
83	MRO	Mauritania Ougulya (MRO)	0.00369	2026-08-20 07:30:39.703147	USD
84	MUR	Mauritius Rupee (MUR)	0.03258	2026-08-20 07:30:39.703147	USD
85	MXN	Mexican Peso (MXN)	0.09320	2026-08-20 07:30:39.703147	USD
86	MDL	Moldovan Leu (MDL)	0.07678	2026-08-20 07:30:39.703147	USD
87	MNT	Mongolian Tugrik (MNT)	0.00084	2026-08-20 07:30:39.703147	USD
88	MAD	Moroccan Dirham (MAD)	0.10897	2026-08-20 07:30:39.703147	USD
89	MZM	Mozambique Metical (MZM)	0.00004	2026-08-20 07:30:39.703147	USD
90	NAD	Namibian Dollar (NAD)	0.15817	2026-08-20 07:30:39.703147	USD
91	NPR	Nepalese Rupee (NPR)	0.01408	2026-08-20 07:30:39.703147	USD
92	ANG	Neth Antilles Guilder (ANG)	0.55866	2026-08-20 07:30:39.703147	USD
93	TRY	New Turkish Lira (TRY)	0.73621	2026-08-20 07:30:39.703147	USD
94	NZD	New Zealand Dollar (NZD)	0.65096	2026-08-20 07:30:39.703147	USD
95	NIO	Nicaragua Cordoba (NIO)	0.05828	2026-08-20 07:30:39.703147	USD
96	NGN	Nigerian Naira (NGN)	0.00777	2026-08-20 07:30:39.703147	USD
97	NOK	Norwegian Krone (NOK)	0.14867	2026-08-20 07:30:39.703147	USD
98	OMR	Omani Rial (OMR)	2.59740	2026-08-20 07:30:39.703147	USD
99	XPF	Pacific Franc (XPF)	0.00999	2026-08-20 07:30:39.703147	USD
100	PKR	Pakistani Rupee (PKR)	0.01667	2026-08-20 07:30:39.703147	USD
101	XPD	Palladium Ounces (XPD)	277.77778	2026-08-20 07:30:39.703147	USD
102	PAB	Panama Balboa (PAB)	1.00000	2026-08-20 07:30:39.703147	USD
103	PGK	Papua New Guinea Kina (PGK)	0.33125	2026-08-20 07:30:39.703147	USD
104	PYG	Paraguayan Guarani (PYG)	0.00017	2026-08-20 07:30:39.703147	USD
105	PEN	Peruvian Nuevo Sol (PEN)	0.29999	2026-08-20 07:30:39.703147	USD
106	PHP	Philippine Peso (PHP)	0.01945	2026-08-20 07:30:39.703147	USD
107	XPT	Platinum Ounces (XPT)	1000.00000	2026-08-20 07:30:39.703147	USD
108	PLN	Polish Zloty (PLN)	0.30574	2026-08-20 07:30:39.703147	USD
109	QAR	Qatar Rial (QAR)	0.27476	2026-08-20 07:30:39.703147	USD
110	ROL	Romanian Leu (ROL)	0.00000	2026-08-20 07:30:39.703147	USD
111	RON	Romanian New Leu (RON)	0.34074	2026-08-20 07:30:39.703147	USD
112	RUB	Russian Rouble (RUB)	0.03563	2026-08-20 07:30:39.703147	USD
113	RWF	Rwanda Franc (RWF)	0.00185	2026-08-20 07:30:39.703147	USD
114	WST	Samoa Tala (WST)	0.35492	2026-08-20 07:30:39.703147	USD
115	STD	Sao Tome Dobra (STD)	0.00000	2026-08-20 07:30:39.703147	USD
116	SAR	Saudi Arabian Riyal (SAR)	0.26665	2026-08-20 07:30:39.703147	USD
117	SCR	Seychelles Rupee (SCR)	0.18114	2026-08-20 07:30:39.703147	USD
118	SLL	Sierra Leone Leone (SLL)	0.00034	2026-08-20 07:30:39.703147	USD
119	XAG	Silver Ounces (XAG)	9.77517	2026-08-20 07:30:39.703147	USD
120	SGD	Singapore Dollar (SGD)	0.61290	2026-08-20 07:30:39.703147	USD
121	SKK	Slovak Koruna (SKK)	0.03157	2026-08-20 07:30:39.703147	USD
122	SIT	Slovenian Tolar (SIT)	0.00498	2026-08-20 07:30:39.703147	USD
123	SOS	Somali Shilling (SOS)	0.00000	2026-08-20 07:30:39.703147	USD
124	ZAR	South African Rand (ZAR)	0.15835	2026-08-20 07:30:39.703147	USD
125	LKR	Sri Lanka Rupee (LKR)	0.00974	2026-08-20 07:30:39.703147	USD
126	SHP	St Helena Pound (SHP)	0.00000	2026-08-20 07:30:39.703147	USD
127	SDD	Sudanese Dinar (SDD)	0.00427	2026-08-20 07:30:39.703147	USD
128	SRG	Surinam Guilder (SRG)	0.36496	2026-08-20 07:30:39.703147	USD
129	SZL	Swaziland Lilageni (SZL)	0.15817	2026-08-20 07:30:39.703147	USD
130	SEK	Swedish Krona (SEK)	0.12609	2026-08-20 07:30:39.703147	USD
131	CHF	Swiss Franc (CHF)	0.76435	2026-08-20 07:30:39.703147	USD
132	SYP	Syrian Pound (SYP)	0.00000	2026-08-20 07:30:39.703147	USD
133	TWD	Taiwan Dollar (TWD)	0.03075	2026-08-20 07:30:39.703147	USD
134	TZS	Tanzanian Shilling (TZS)	0.00083	2026-08-20 07:30:39.703147	USD
135	THB	Thai Baht (THB)	0.02546	2026-08-20 07:30:39.703147	USD
136	TOP	Tonga Paanga (TOP)	0.48244	2026-08-20 07:30:39.703147	USD
137	TTD	Trinidad&Tobago Dollar (TTD)	0.15863	2026-08-20 07:30:39.703147	USD
138	TND	Tunisian Dinar (TND)	0.73470	2026-08-20 07:30:39.703147	USD
139	USD	U.S. Dollar (USD)	1.00000	2026-08-20 07:30:39.703147	USD
140	AED	UAE Dirham (AED)	0.27228	2026-08-20 07:30:39.703147	USD
141	UGX	Ugandan Shilling (UGX)	0.00055	2026-08-20 07:30:39.703147	USD
142	UAH	Ukraine Hryvnia (UAH)	0.19755	2026-08-20 07:30:39.703147	USD
143	UYU	Uruguayan New Peso (UYU)	0.04119	2026-08-20 07:30:39.703147	USD
144	VUV	Vanuatu Vatu (VUV)	0.00870	2026-08-20 07:30:39.703147	USD
145	VEB	Venezuelan Bolivar (VEB)	0.00037	2026-08-20 07:30:39.703147	USD
146	VND	Vietnam Dong (VND)	0.00006	2026-08-20 07:30:39.703147	USD
147	YER	Yemen Riyal (YER)	0.00510	2026-08-20 07:30:39.703147	USD
148	ZMK	Zambian Kwacha (ZMK)	0.00031	2026-08-20 07:30:39.703147	USD
149	ZWD	Zimbabwe Dollar (ZWD)	0.00001	2026-08-20 07:30:39.703147	USD
150	GYD	Guyana Dollar (GYD)	0.00527	2026-08-20 07:30:39.703147	USD
151	MGA	Ariary Malgache (MGA)	1.00000	2026-08-25 01:12:40.478957	MGA
\.


--
-- Data for Name: cc_did; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_did (id, id_cc_didgroup, id_cc_country, activated, reserved, iduser, did, creationdate, startingdate, expirationdate, description, secondusedreal, billingtype, fixrate) FROM stdin;
\.


--
-- Data for Name: cc_did_destination; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_did_destination (id, destination, priority, id_cc_card, id_cc_did, creationdate, activated, secondusedreal, voip_call) FROM stdin;
\.


--
-- Data for Name: cc_did_use; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_did_use (id, id_cc_card, id_did, reservationdate, releasedate, activated, month_payed, reminded) FROM stdin;
\.


--
-- Data for Name: cc_didgroup; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_didgroup (id, iduser, creationdate, didgroupname) FROM stdin;
\.


--
-- Data for Name: cc_ecommerce_product; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_ecommerce_product (id, product_name, creationdate, description, expirationdate, enableexpire, expiredays, credit, tariff, id_didgroup, mailtype, activated, simultaccess, currency, typepaid, creditlimit, language, runservice, sip_friend, iax_friend) FROM stdin;
\.


--
-- Data for Name: cc_epayment_log; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_epayment_log (id, cardid, amount, vat, paymentmethod, cc_owner, cc_number, cc_expires, creationdate, status, cvv, credit_card_type, currency, transaction_detail, item_type, item_id) FROM stdin;
\.


--
-- Data for Name: cc_epayment_log_agent; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_epayment_log_agent (id, agent_id, amount, vat, paymentmethod, cc_owner, cc_number, cc_expires, creationdate, status, cvv, credit_card_type, currency, transaction_detail) FROM stdin;
\.


--
-- Data for Name: cc_iax_buddies; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_iax_buddies (id, id_cc_card, name, type, username, accountcode, regexten, callerid, amaflags, secret, md5secret, nat, dtmfmode, disallow, allow, host, qualify, canreinvite, callgroup, context, defaultip, fromuser, fromdomain, insecure, language, mailbox, permit, deny, mask, pickupgroup, port, restrictcid, rtptimeout, rtpholdtimeout, musiconhold, regseconds, ipaddr, cancallforward, trunk) FROM stdin;
\.


--
-- Data for Name: cc_invoice; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_invoice (id, reference, id_card, date, paid_status, status, title, description) FROM stdin;
1	202600000001	1	2026-08-26 18:36:34	1	1	REFILL	Invoice for refill
2	202600000002	2	2026-08-26 18:38:33	1	1	REFILL	Invoice for refill
3	202600000003	3	2026-08-26 18:44:09	1	1	REFILL	Invoice for refill
4	202600000004	3	2026-08-26 18:48:17	1	1	REFILL	Invoice for refill
5	202600000005	4	2026-08-26 19:10:12	1	1	REFILL	Invoice for refill
\.


--
-- Data for Name: cc_invoice_conf; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_invoice_conf (id, key_val, value) FROM stdin;
1	company_name	My company
2	address	address
3	zipcode	xxxx
4	country	country
5	city	city
6	phone	xxxxxxxxxxx
7	fax	xxxxxxxxxxx
8	email	xxxxxxx@xxxxxxx.xxx
9	vat	xxxxxxxxxx
10	web	www.xxxxxxx.xxx
11	count_2026	5
\.


--
-- Data for Name: cc_invoice_item; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_invoice_item (id, id_invoice, date, price, vat, description, id_ext, type_ext) FROM stdin;
\.


--
-- Data for Name: cc_invoice_payment; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_invoice_payment (id_invoice, id_payment) FROM stdin;
\.


--
-- Data for Name: cc_iso639; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_iso639 (code, name, lname, charset) FROM stdin;
ab	Abkhazian       	                	ISO-8859-1      
om	Afan (Oromo)    	                	ISO-8859-1      
aa	Afar            	                	ISO-8859-1      
af	Afrikaans       	                	ISO-8859-1      
sq	Albanian        	                	ISO-8859-1      
am	Amharic         	                	ISO-8859-1      
ar	Arabic          	                	ISO-8859-1      
hy	Armenian        	                	ISO-8859-1      
as	Assamese        	                	ISO-8859-1      
ay	Aymara          	                	ISO-8859-1      
az	Azerbaijani     	                	ISO-8859-1      
ba	Bashkir         	                	ISO-8859-1      
eu	Basque          	Euskera         	ISO-8859-15     
bn	Bengali Bangla  	                	ISO-8859-1      
dz	Bhutani         	                	ISO-8859-1      
bh	Bihari          	                	ISO-8859-1      
bi	Bislama         	                	ISO-8859-1      
br	Breton          	                	ISO-8859-1      
bg	Bulgarian       	                	ISO-8859-1      
my	Burmese         	                	ISO-8859-1      
be	Byelorussian    	                	ISO-8859-1      
km	Cambodian       	                	ISO-8859-1      
ca	Catalan         	          \t\t    	ISO-8859-15     
zh	Chinese         	                	ISO-8859-1      
co	Corsican        	                	ISO-8859-1      
hr	Croatian        	                	ISO-8859-1      
cs	Czech           	                	ISO-8859-1      
da	Danish          	                	ISO-8859-1      
nl	Dutch           	                	ISO-8859-1      
en	English         	                	ISO-8859-1      
eo	Esperanto       	                	ISO-8859-1      
et	Estonian        	                	ISO-8859-1      
fo	Faroese         	                	ISO-8859-1      
fj	Fiji            	                	ISO-8859-1      
fi	Finnish         	                	ISO-8859-1      
fr	French          	                	ISO-8859-1      
fy	Frisian         	                	ISO-8859-1      
gl	Galician        	                	ISO-8859-1      
ka	Georgian        	                	ISO-8859-1      
de	German          	                	ISO-8859-1      
el	Greek           	                	ISO-8859-1      
kl	Greenlandic     	                	ISO-8859-1      
gn	Guarani         	                	ISO-8859-1      
gu	Gujarati        	                	ISO-8859-1      
ha	Hausa           	                	ISO-8859-1      
he	Hebrew          	                	ISO-8859-1      
hi	Hindi           	                	ISO-8859-1      
hu	Hungarian       	                	ISO-8859-1      
is	Icelandic       	                	ISO-8859-1      
id	Indonesian      	                	ISO-8859-1      
ia	Interlingua     	                	ISO-8859-1      
ie	Interlingue     	                	ISO-8859-1      
iu	Inuktitut       	                	ISO-8859-1      
ik	Inupiak         	                	ISO-8859-1      
ga	Irish           	                	ISO-8859-1      
it	Italian         	                	ISO-8859-1      
ja	Japanese        	                	ISO-8859-1      
jv	Javanese        	                	ISO-8859-1      
kn	Kannada         	                	ISO-8859-1      
ks	Kashmiri        	                	ISO-8859-1      
kk	Kazakh          	                	ISO-8859-1      
rw	Kinyarwanda     	                	ISO-8859-1      
ky	Kirghiz         	                	ISO-8859-1      
rn	Kurundi         	                	ISO-8859-1      
ko	Korean          	                	ISO-8859-1      
ku	Kurdish         	                	ISO-8859-1      
lo	Laothian        	                	ISO-8859-1      
la	Latin           	                	ISO-8859-1      
lv	Latvian Lettish 	                	ISO-8859-1      
ln	Lingala         	                	ISO-8859-1      
lt	Lithuanian      	                	ISO-8859-1      
mk	Macedonian      	                	ISO-8859-1      
mg	Malagasy        	                	ISO-8859-1      
ms	Malay           	                	ISO-8859-1      
ml	Malayalam       	                	ISO-8859-1      
mt	Maltese         	                	ISO-8859-1      
mi	Maori           	                	ISO-8859-1      
mr	Marathi         	                	ISO-8859-1      
mo	Moldavian       	                	ISO-8859-1      
mn	Mongolian       	                	ISO-8859-1      
na	Nauru           	                	ISO-8859-1      
ne	Nepali          	                	ISO-8859-1      
no	Norwegian       	                	ISO-8859-1      
oc	Occitan         	                	ISO-8859-1      
or	Oriya           	                	ISO-8859-1      
ps	Pashto Pushto   	                	ISO-8859-1      
fa	Persian (Farsi) 	                	ISO-8859-1      
pl	Polish          	                	ISO-8859-1      
pt	Portuguese      	                	ISO-8859-1      
pa	Punjabi         	                	ISO-8859-1      
qu	Quechua         	                	ISO-8859-1      
rm	Rhaeto-Romance  	                	ISO-8859-1      
ro	Romanian        	                	ISO-8859-1      
ru	Russian         	                	ISO-8859-1      
sm	Samoan          	                	ISO-8859-1      
sg	Sangho          	                	ISO-8859-1      
sa	Sanskrit        	                	ISO-8859-1      
gd	Scots Gaelic    	                	ISO-8859-1      
sr	Serbian         	                	ISO-8859-1      
sh	Serbo-Croatian  	                	ISO-8859-1      
st	Sesotho         	                	ISO-8859-1      
tn	Setswana        	                	ISO-8859-1      
sn	Shona           	                	ISO-8859-1      
sd	Sindhi          	                	ISO-8859-1      
si	Singhalese      	                	ISO-8859-1      
ss	Siswati         	                	ISO-8859-1      
sk	Slovak          	                	ISO-8859-1      
sl	Slovenian       	                	ISO-8859-1      
so	Somali          	                	ISO-8859-1      
es	Spanish         	         \t\t     	ISO-8859-15     
su	Sundanese       	                	ISO-8859-1      
sw	Swahili         	                	ISO-8859-1      
sv	Swedish         	                	ISO-8859-1      
tl	Tagalog         	                	ISO-8859-1      
tg	Tajik           	                	ISO-8859-1      
ta	Tamil           	                	ISO-8859-1      
tt	Tatar           	                	ISO-8859-1      
te	Telugu          	                	ISO-8859-1      
th	Thai            	                	ISO-8859-1      
bo	Tibetan         	                	ISO-8859-1      
ti	Tigrinya        	                	ISO-8859-1      
to	Tonga           	                	ISO-8859-1      
ts	Tsonga          	                	ISO-8859-1      
tr	Turkish         	                	ISO-8859-1      
tk	Turkmen         	                	ISO-8859-1      
tw	Twi             	                	ISO-8859-1      
ug	Uigur           	                	ISO-8859-1      
uk	Ukrainian       	                	ISO-8859-1      
ur	Urdu            	                	ISO-8859-1      
uz	Uzbek           	                	ISO-8859-1      
vi	Vietnamese      	                	ISO-8859-1      
vo	Volapuk         	                	ISO-8859-1      
cy	Welsh           	                	ISO-8859-1      
wo	Wolof           	                	ISO-8859-1      
xh	Xhosa           	                	ISO-8859-1      
yi	Yiddish         	                	ISO-8859-1      
yo	Yoruba          	                	ISO-8859-1      
za	Zhuang          	                	ISO-8859-1      
zu	Zulu            	                	ISO-8859-1      
\.


--
-- Data for Name: cc_logpayment; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_logpayment (id, date, payment, card_id, id_logrefill, description, added_refill, payment_type, added_commission) FROM stdin;
1	2026-08-26 18:35:27	10000000.00000	9890930847	\N	\N	0	0	0
2	2026-08-26 18:36:34	10000000.00000	1	\N	\N	1	0	0
3	2026-08-26 18:38:33	200000.00000	2	\N	\N	1	0	0
4	2026-08-26 18:44:09	20000.00000	3	\N	\N	1	0	0
5	2026-08-26 18:48:01	2500.00000	1	\N	\N	0	0	0
6	2026-08-26 18:48:17	2500.00000	3	\N	\N	1	0	0
7	2026-08-26 19:10:12	300000.00000	4	\N	\N	1	0	0
\.


--
-- Data for Name: cc_logpayment_agent; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_logpayment_agent (id, date, payment, agent_id, id_logrefill, description, added_refill, payment_type, added_commission) FROM stdin;
\.


--
-- Data for Name: cc_logrefill; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_logrefill (id, date, credit, card_id, description, refill_type, added_invoice) FROM stdin;
1	2026-08-26 18:36:34	10000000.00000	1		0	0
2	2026-08-26 18:38:33	200000.00000	2		0	0
3	2026-08-26 18:44:09	20000.00000	3		0	0
4	2026-08-26 18:48:17	2500.00000	3		0	0
5	2026-08-26 19:10:12	300000.00000	4		0	0
\.


--
-- Data for Name: cc_logrefill_agent; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_logrefill_agent (id, date, credit, agent_id, description, refill_type) FROM stdin;
\.


--
-- Data for Name: cc_notification; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_notification (id, key_value, date, priority, from_type, from_id) FROM stdin;
\.


--
-- Data for Name: cc_notification_admin; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_notification_admin (id_notification, id_admin, viewed) FROM stdin;
\.


--
-- Data for Name: cc_outbound_cid_group; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_outbound_cid_group (id, creationdate, group_name) FROM stdin;
\.


--
-- Data for Name: cc_outbound_cid_list; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_outbound_cid_list (id, outbound_cid_group, cid, activated, creationdate) FROM stdin;
\.


--
-- Data for Name: cc_package_group; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_package_group (id, name, description) FROM stdin;
\.


--
-- Data for Name: cc_package_offer; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_package_offer (id, creationdate, label, packagetype, billingtype, startday, freetimetocall) FROM stdin;
\.


--
-- Data for Name: cc_package_rate; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_package_rate (package_id, rate_id) FROM stdin;
\.


--
-- Data for Name: cc_packgroup_package; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_packgroup_package (packagegroup_id, package_id) FROM stdin;
\.


--
-- Data for Name: cc_payment_methods; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_payment_methods (id, payment_method, payment_filename) FROM stdin;
1	paypal	paypal.php
3	MoneyBookers	moneybookers.php
4	plugnpay	plugnpay.php
\.


--
-- Data for Name: cc_payments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_payments (id, customers_id, customers_name, customers_email_address, item_name, item_id, item_quantity, payment_method, cc_type, cc_owner, cc_number, cc_expires, orders_status, orders_amount, last_modified, date_purchased, orders_date_finished, currency, currency_value) FROM stdin;
\.


--
-- Data for Name: cc_payments_agent; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_payments_agent (id, agent_id, agent_name, agent_email_address, item_name, item_id, item_quantity, payment_method, cc_type, cc_owner, cc_number, cc_expires, orders_status, orders_amount, last_modified, date_purchased, orders_date_finished, currency, currency_value) FROM stdin;
\.


--
-- Data for Name: cc_payments_status; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_payments_status (id, status_id, status_name) FROM stdin;
1	-2	Failed
2	-1	Denied
3	0	Pending
4	1	In-Progress
5	2	Completed
6	3	Processed
7	4	Refunded
8	5	Unknown
\.


--
-- Data for Name: cc_paypal; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_paypal (id, payer_id, payment_date, txn_id, first_name, last_name, payer_email, payer_status, payment_type, memo, item_name, item_number, quantity, mc_gross, mc_fee, tax, mc_currency, address_name, address_street, address_city, address_state, address_zip, address_country, address_status, payer_business_name, payment_status, pending_reason, reason_code, txn_type) FROM stdin;
\.


--
-- Data for Name: cc_phonebook; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_phonebook (id, name, description, id_card) FROM stdin;
\.


--
-- Data for Name: cc_phonenumber; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_phonenumber (id, id_phonebook, number, name, creationdate, status, info, amount) FROM stdin;
\.


--
-- Data for Name: cc_prefix; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_prefix (prefix, destination) FROM stdin;
\.


--
-- Data for Name: cc_provider; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_provider (id, provider_name, creationdate, description) FROM stdin;
\.


--
-- Data for Name: cc_ratecard; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_ratecard (id, idtariffplan, dialprefix, destination, buyrate, buyrateinitblock, buyrateincrement, rateinitial, initblock, billingblock, connectcharge, disconnectcharge, stepchargea, chargea, timechargea, billingblocka, stepchargeb, chargeb, timechargeb, billingblockb, stepchargec, chargec, timechargec, billingblockc, startdate, stopdate, starttime, endtime, id_trunk, musiconhold, id_outbound_cidgroup, rounding_calltime, rounding_threshold, additional_block_charge, additional_block_charge_time, tag, is_merged, additional_grace, minimal_cost, announce_time_correction, disconnectcharge_after) FROM stdin;
1	1	035	0	50.00000	6	6	100.00000	6	6	0.00000	0.00000	1.00000	100.00000	60	6	0.00000	0.00000	0	0	0.00000	0.00000	0	0	2026-08-26 20:48:23	\N	0	10079	1	\N	-1	0	0	0.00000	0	\N	0	0	0.00000	1.000	0
\.


--
-- Data for Name: cc_receipt; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_receipt (id, id_card, date, title, description, status) FROM stdin;
\.


--
-- Data for Name: cc_receipt_item; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_receipt_item (id, id_receipt, date, price, description, id_ext, type_ext) FROM stdin;
\.


--
-- Data for Name: cc_restricted_phonenumber; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_restricted_phonenumber (id, number, id_card) FROM stdin;
\.


--
-- Data for Name: cc_server_group; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_server_group (id, name, description) FROM stdin;
1	default	default group of server
\.


--
-- Data for Name: cc_server_manager; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_server_manager (id, id_group, server_ip, manager_host, manager_username, manager_secret, lasttime_used) FROM stdin;
1	1	localhost	localhost	myasterisk	mycode	2026-08-20 07:30:39.703147
\.


--
-- Data for Name: cc_service; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_service (id, name, amount, period, rule, daynumber, stopmode, maxnumbercycle, status, numberofrun, datecreate, datelastrun, emailreport, totalcredit, totalcardperform, operate_mode, dialplan, use_group) FROM stdin;
\.


--
-- Data for Name: cc_service_report; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_service_report (id, cc_service_id, daterun, totalcardperform, totalcredit) FROM stdin;
\.


--
-- Data for Name: cc_sip_buddies; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_sip_buddies (id, id_cc_card, name, type, username, accountcode, regexten, callerid, amaflags, secret, md5secret, nat, dtmfmode, disallow, allow, host, qualify, canreinvite, callgroup, context, defaultip, fromuser, fromdomain, insecure, language, mailbox, permit, deny, mask, pickupgroup, port, restrictcid, rtptimeout, rtpholdtimeout, musiconhold, regseconds, ipaddr, cancallforward, fullcontact, setvar, regserver, lastms) FROM stdin;
2	1	4834067797	friend	4834067797	4834067797	4834067797	823177036003397	billing	24274yom072vs6889130	\N	yes	RFC2833	all	ulaw,alaw,gsm,g729	dynamic	yes	yes	\N	a2billing	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N		\N	\N	\N	\N	0		yes	\N		\N	\N
3	3	0351234567	friend	0351234567	0351234567	0351234567	9218079042	billing	phone1	\N	yes	RFC2833	all	ulaw,alaw,gsm,g729	dynamic	yes	yes	\N	internal	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N		\N	\N	\N	\N	0		yes	\N		\N	\N
1	2	0352345678	friend	0352345678	9890930847	9890930847	594116422844764	billing	86539m9zonaw64745580	\N	yes	RFC2833	all	ulaw,alaw,gsm,g729	dynamic	yes	yes	\N	a2billing	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N		\N	\N	\N	\N	0		yes	\N		\N	\N
\.


--
-- Data for Name: cc_speeddial; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_speeddial (id, id_cc_card, phone, name, speeddial, creationdate) FROM stdin;
\.


--
-- Data for Name: cc_status_log; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_status_log (id, status, id_cc_card, updated_date) FROM stdin;
\.


--
-- Data for Name: cc_subscription_fee; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_subscription_fee (id, label, fee, currency, status, numberofrun, datecreate, datelastrun, emailreport, totalcredit, totalcardperform) FROM stdin;
\.


--
-- Data for Name: cc_support; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_support (id, name) FROM stdin;
1	DEFAULT
\.


--
-- Data for Name: cc_support_component; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_support_component (id, id_support, name, activated, type_user) FROM stdin;
1	1	DEFAULT	1	2
\.


--
-- Data for Name: cc_system_log; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_system_log (id, iduser, loglevel, action, description, data, tablename, pagename, ipaddress, creationdate) FROM stdin;
1	1	1	User Logged In	User Logged in to website			PP_Intro.php	192.168.10.1	2026-08-20 09:05:45
2	1	1	Page Visit	User Visited the Page			dashboard.php	192.168.10.1	2026-08-20 09:05:53
3	1	1	Page Visit	User Visited the Page			customers_lastmonth.php	192.168.10.1	2026-08-20 09:05:53
4	1	1	Page Visit	User Visited the Page			refills_lastmonth.php	192.168.10.1	2026-08-20 09:05:53
5	1	1	Page Visit	User Visited the Page			payments_lastmonth.php	192.168.10.1	2026-08-20 09:05:54
6	1	1	Page Visit	User Visited the Page			calls_lastmonth.php	192.168.10.1	2026-08-20 09:05:54
7	1	1	Page Visit	User Visited the Page			A2B_notification.php	192.168.10.1	2026-08-20 09:05:57
8	1	1	Page Visit	User Visited the Page			PP_intro.php	192.168.10.1	2026-08-20 09:05:58
9	1	1	Page Visit	User Visited the Page			dashboard.php	192.168.10.1	2026-08-20 09:06:00
10	1	1	Page Visit	User Visited the Page			customers_lastmonth.php	192.168.10.1	2026-08-20 09:06:01
11	1	1	Page Visit	User Visited the Page			refills_lastmonth.php	192.168.10.1	2026-08-20 09:06:01
12	1	1	Page Visit	User Visited the Page			payments_lastmonth.php	192.168.10.1	2026-08-20 09:06:01
13	1	1	Page Visit	User Visited the Page			calls_lastmonth.php	192.168.10.1	2026-08-20 09:06:01
14	1	1	Page Visit	User Visited the Page			call-count-reporting.php	192.168.10.1	2026-08-20 09:06:09
15	1	1	Page Visit	User Visited the Page			call-log-customers.php	192.168.10.1	2026-08-20 09:06:10
16	1	1	User Logged In	User Logged in to website			PP_Intro.php	192.168.10.1	2026-08-20 11:10:36
17	1	1	Page Visit	User Visited the Page			dashboard.php	192.168.10.1	2026-08-20 11:10:45
18	1	1	Page Visit	User Visited the Page			customers_lastmonth.php	192.168.10.1	2026-08-20 11:10:45
19	1	1	Page Visit	User Visited the Page			payments_lastmonth.php	192.168.10.1	2026-08-20 11:10:45
20	1	1	Page Visit	User Visited the Page			calls_lastmonth.php	192.168.10.1	2026-08-20 11:10:45
21	1	1	Page Visit	User Visited the Page			refills_lastmonth.php	192.168.10.1	2026-08-20 11:10:45
22	1	1	Page Visit	User Visited the Page			dashboard.php	192.168.10.1	2026-08-20 11:10:50
23	1	1	Page Visit	User Visited the Page			customers_lastmonth.php	192.168.10.1	2026-08-20 11:10:50
24	1	1	Page Visit	User Visited the Page			refills_lastmonth.php	192.168.10.1	2026-08-20 11:10:50
25	1	1	Page Visit	User Visited the Page			calls_lastmonth.php	192.168.10.1	2026-08-20 11:10:50
26	1	1	Page Visit	User Visited the Page			payments_lastmonth.php	192.168.10.1	2026-08-20 11:10:50
27	1	1	Page Visit	User Visited the Page			dashboard.php	192.168.10.1	2026-08-20 11:10:51
28	1	1	Page Visit	User Visited the Page			customers_lastmonth.php	192.168.10.1	2026-08-20 11:10:51
29	1	1	Page Visit	User Visited the Page			refills_lastmonth.php	192.168.10.1	2026-08-20 11:10:51
30	1	1	Page Visit	User Visited the Page			payments_lastmonth.php	192.168.10.1	2026-08-20 11:10:51
31	1	1	Page Visit	User Visited the Page			calls_lastmonth.php	192.168.10.1	2026-08-20 11:10:51
32	1	1	Page Visit	User Visited the Page			dashboard.php	192.168.10.1	2026-08-20 11:10:51
33	1	1	Page Visit	User Visited the Page			customers_lastmonth.php	192.168.10.1	2026-08-20 11:10:52
34	1	1	Page Visit	User Visited the Page			refills_lastmonth.php	192.168.10.1	2026-08-20 11:10:52
35	1	1	Page Visit	User Visited the Page			payments_lastmonth.php	192.168.10.1	2026-08-20 11:10:52
36	1	1	Page Visit	User Visited the Page			calls_lastmonth.php	192.168.10.1	2026-08-20 11:10:52
37	1	1	Page Visit	User Visited the Page			dashboard.php	192.168.10.1	2026-08-20 11:10:52
38	1	1	Page Visit	User Visited the Page			customers_lastmonth.php	192.168.10.1	2026-08-20 11:10:52
39	1	1	Page Visit	User Visited the Page			payments_lastmonth.php	192.168.10.1	2026-08-20 11:10:52
40	1	1	Page Visit	User Visited the Page			calls_lastmonth.php	192.168.10.1	2026-08-20 11:10:52
41	1	1	Page Visit	User Visited the Page			refills_lastmonth.php	192.168.10.1	2026-08-20 11:10:53
42	1	1	Page Visit	User Visited the Page			dashboard.php	192.168.10.1	2026-08-20 11:10:53
43	1	1	Page Visit	User Visited the Page			customers_lastmonth.php	192.168.10.1	2026-08-20 11:10:53
44	1	1	Page Visit	User Visited the Page			refills_lastmonth.php	192.168.10.1	2026-08-20 11:10:53
45	1	1	Page Visit	User Visited the Page			payments_lastmonth.php	192.168.10.1	2026-08-20 11:10:53
46	1	1	Page Visit	User Visited the Page			calls_lastmonth.php	192.168.10.1	2026-08-20 11:10:53
47	1	1	Page Visit	User Visited the Page			A2B_notification.php	192.168.10.1	2026-08-20 11:10:53
48	1	1	Page Visit	User Visited the Page			PP_intro.php	192.168.10.1	2026-08-20 11:10:57
49	1	1	Page Visit	User Visited the Page			CC_card_import.php	192.168.10.1	2026-08-20 11:16:25
50	1	1	Page Visit	User Visited the Page			PP_intro.php	192.168.10.1	2026-08-20 11:16:33
51	1	1	Page Visit	User Visited the Page			A2B_entity_card_seria.php	192.168.10.1	2026-08-20 11:25:26
52	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-20 11:27:31
53	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-20 11:28:23
54	1	1	User Logged In	User Logged in to website			PP_Intro.php	192.168.10.1	2026-08-20 13:57:55
55	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-20 13:58:25
56	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-20 13:58:35
57	1	1	Page Visit	User Visited the Page			A2B_notification.php	192.168.10.1	2026-08-20 13:58:39
58	1	1	Page Visit	User Visited the Page			A2B_entity_password.php	192.168.10.1	2026-08-20 13:58:44
59	1	1	Page Visit	User Visited the Page			A2B_entity_password.php	192.168.10.1	2026-08-20 13:59:10
60	1	1	Page Visit	User Visited the Page			logout.php	192.168.10.1	2026-08-20 13:59:13
61	1	1	USER LOGGED OUT	User Logged out from website			logout.php	192.168.10.1	2026-08-20 13:59:13
62	1	1	User Logged In	User Logged in to website			PP_Intro.php	192.168.10.1	2026-08-20 13:59:16
63	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-20 14:01:44
64	1	1	Page Visit	User Visited the Page			CC_card_import.php	192.168.10.1	2026-08-20 14:01:46
65	1	1	Page Visit	User Visited the Page			A2B_entity_callerid.php	192.168.10.1	2026-08-20 14:01:49
66	1	1	Page Visit	User Visited the Page			A2B_notifications.php	192.168.10.1	2026-08-20 14:01:50
67	1	1	Page Visit	User Visited the Page			A2B_entity_config.php	192.168.10.1	2026-08-20 14:01:55
68	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-20 14:02:01
69	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-20 14:02:25
70	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-20 14:03:00
71	1	2	NEW CARD CREATED	User added a new record in database	username = 0206308044| useralias =  494500679868654| uipass =  17255bgm0ul0uyfhmlus| credit =  0| id_group =  1| id_seria =  -1| country =  USA| typepaid =  0| id_didgroup =  -1| id_timezone =  67| language =  en| currency =  USD| status =  1| block =  0| lock_pin =  0| simultaccess =  1| runservice =  0| credit_notification =  -1| notify_email =  0| id_campaign =  -1| enableexpire =  0| expirationdate =  2036-08-20 14:02:24| expiredays =  0| sip_buddy =  1| iax_buddy =  1| autorefill =  0| initialbalance =  0| invoiceday =  1| vat =  0| discount =  0.00| restriction =  0	cc_card	A2B_entity_card.php	192.168.10.1	2026-08-20 14:03:00
72	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-20 14:03:08
73	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-20 14:03:11
74	1	1	Page Visit	User Visited the Page			PP_intro.php	192.168.10.1	2026-08-20 14:03:19
75	1	1	User Logged In	User Logged in to website			PP_Intro.php	192.168.10.1	2026-08-20 14:03:19
76	1	1	Page Visit	User Visited the Page			CC_card_import.php	192.168.10.1	2026-08-20 14:03:21
77	1	1	Page Visit	User Visited the Page			A2B_entity_friend.php	192.168.10.1	2026-08-20 14:03:27
78	1	1	Page Visit	User Visited the Page			PP_intro.php	192.168.10.1	2026-08-20 14:04:17
79	1	1	Page Visit	User Visited the Page			dashboard.php	192.168.10.1	2026-08-20 14:04:22
80	1	1	Page Visit	User Visited the Page			customers_lastmonth.php	192.168.10.1	2026-08-20 14:04:23
81	1	1	Page Visit	User Visited the Page			payments_lastmonth.php	192.168.10.1	2026-08-20 14:04:23
82	1	1	Page Visit	User Visited the Page			calls_lastmonth.php	192.168.10.1	2026-08-20 14:04:23
83	1	1	Page Visit	User Visited the Page			refills_lastmonth.php	192.168.10.1	2026-08-20 14:04:23
84	1	1	Page Visit	User Visited the Page			customers_lastmonth.php	192.168.10.1	2026-08-20 14:04:26
85	1	1	Page Visit	User Visited the Page			customers_lastmonth.php	192.168.10.1	2026-08-20 14:04:27
86	1	1	Page Visit	User Visited the Page			A2B_notification.php	192.168.10.1	2026-08-20 14:04:29
87	1	1	Page Visit	User Visited the Page			A2B_entity_callerid.php	192.168.10.1	2026-08-20 14:04:31
88	1	1	Page Visit	User Visited the Page			A2B_notifications.php	192.168.10.1	2026-08-20 14:04:32
89	1	1	Page Visit	User Visited the Page			A2B_entity_card_group.php	192.168.10.1	2026-08-20 14:04:34
90	1	1	Page Visit	User Visited the Page			A2B_entity_speeddial.php	192.168.10.1	2026-08-20 14:04:36
91	1	1	Page Visit	User Visited the Page			card-history.php	192.168.10.1	2026-08-20 14:04:37
92	1	1	Page Visit	User Visited the Page			CC_card_import.php	192.168.10.1	2026-08-20 14:04:48
93	1	1	Page Visit	User Visited the Page			CC_card_import.php	192.168.10.1	2026-08-20 14:04:54
94	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-20 14:04:56
95	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-20 14:05:05
96	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-20 14:06:01
97	1	2	NEW CARD CREATED	User added a new record in database	username = 7005898742| useralias =  945871206338759| uipass =  78548shqbdopdloviwyx| credit =  1000| id_group =  1| id_seria =  -1| lastname =  Hoby| country =  USA| phone =  0351234567| typepaid =  1| id_didgroup =  -1| id_timezone =  67| language =  en| currency =  USD| status =  1| block =  0| lock_pin =  0| simultaccess =  1| runservice =  0| credit_notification =  -1| notify_email =  0| id_campaign =  -1| enableexpire =  0| expirationdate =  2036-08-20 14:05:05| expiredays =  0| sip_buddy =  1| iax_buddy =  1| autorefill =  0| initialbalance =  0| invoiceday =  1| vat =  0| discount =  0.00| restriction =  0	cc_card	A2B_entity_card.php	192.168.10.1	2026-08-20 14:06:01
98	1	1	Page Visit	User Visited the Page			A2B_entity_voucher.php	192.168.10.1	2026-08-20 14:06:12
99	1	1	Page Visit	User Visited the Page			A2B_currencies.php	192.168.10.1	2026-08-20 14:06:16
100	1	1	Page Visit	User Visited the Page			A2B_currencies.php	192.168.10.1	2026-08-20 14:06:28
101	1	1	Page Visit	User Visited the Page			A2B_currencies.php	192.168.10.1	2026-08-20 14:06:34
102	1	1	Page Visit	User Visited the Page			A2B_entity_commission_agent.php	192.168.10.1	2026-08-20 14:06:41
103	1	1	Page Visit	User Visited the Page			A2B_entity_charge.php	192.168.10.1	2026-08-20 14:06:43
104	1	1	Page Visit	User Visited the Page			A2B_currencies.php	192.168.10.1	2026-08-20 14:08:57
105	1	1	Page Visit	User Visited the Page			A2B_currencies.php	192.168.10.1	2026-08-20 14:09:02
106	1	1	Page Visit	User Visited the Page			A2B_currencies.php	192.168.10.1	2026-08-20 14:09:17
107	1	1	Page Visit	User Visited the Page			A2B_currencies.php	192.168.10.1	2026-08-20 14:09:25
108	1	1	Page Visit	User Visited the Page			A2B_currencies.php	192.168.10.1	2026-08-20 14:09:34
109	1	1	Page Visit	User Visited the Page			A2B_currencies.php	192.168.10.1	2026-08-20 14:09:38
110	1	1	Page Visit	User Visited the Page			A2B_entity_tariffplan.php	192.168.10.1	2026-08-20 14:11:08
111	1	1	Page Visit	User Visited the Page			A2B_entity_tariffplan.php	192.168.10.1	2026-08-20 14:11:11
112	1	1	Page Visit	User Visited the Page			A2B_entity_tariffplan.php	192.168.10.1	2026-08-20 14:11:55
113	1	2	NEW RATECARD CREATED	User added a new record in database	tariffname = Madagascar| startingdate =  2026-08-20 14:11:10| expirationdate =  2036-08-20 14:11:10| id_trunk =  1| dnidprefix =  all| calleridprefix =  all	cc_tariffplan	A2B_entity_tariffplan.php	192.168.10.1	2026-08-20 14:11:55
114	1	1	Page Visit	User Visited the Page			CC_ratecard_import.php	192.168.10.1	2026-08-20 14:11:59
115	1	1	Page Visit	User Visited the Page			CC_entity_sim_ratecard.php	192.168.10.1	2026-08-20 14:12:06
116	1	1	Page Visit	User Visited the Page			A2B_entity_def_ratecard.php	192.168.10.1	2026-08-20 14:12:07
117	1	1	Page Visit	User Visited the Page			A2B_entity_tariffplan.php	192.168.10.1	2026-08-20 14:12:30
118	1	1	Page Visit	User Visited the Page			A2B_entity_tariffplan.php	192.168.10.1	2026-08-20 14:12:34
119	1	1	Page Visit	User Visited the Page			A2B_entity_tariffplan.php	192.168.10.1	2026-08-20 14:14:05
120	1	3	A RATECARD UPDATED	A RECORD IS UPDATED, EDITION CALUSE USED IS  id=1 	tariffname = Madagascar | startingdate = 2026-08-20 14:11:10 | expirationdate = 2030-12-31 23:59:59 | id_trunk = 1 | description = Tarifs appels Madagascar en MGA | dnidprefix = all | calleridprefix = all 	cc_tariffplan	A2B_entity_tariffplan.php	192.168.10.1	2026-08-20 14:14:05
121	1	1	Page Visit	User Visited the Page			A2B_entity_tariffplan.php	192.168.10.1	2026-08-20 14:14:05
122	1	1	Page Visit	User Visited the Page			A2B_entity_tariffplan.php	192.168.10.1	2026-08-20 14:14:39
123	1	1	Page Visit	User Visited the Page			A2B_entity_tariffplan.php	192.168.10.1	2026-08-20 14:14:42
124	1	1	Page Visit	User Visited the Page			A2B_entity_def_ratecard.php	192.168.10.1	2026-08-20 14:15:24
125	1	1	User Logged In	User Logged in to website			PP_Intro.php	192.168.10.1	2026-08-20 16:26:22
126	1	1	User Logged In	User Logged in to website			PP_Intro.php	192.168.10.1	2026-08-23 08:53:21
127	1	1	User Logged In	User Logged in to website			PP_Intro.php	192.168.10.1	2026-08-23 08:57:56
128	1	1	Page Visit	User Visited the Page			dashboard.php	192.168.10.1	2026-08-23 09:03:49
129	1	1	Page Visit	User Visited the Page			refills_lastmonth.php	192.168.10.1	2026-08-23 09:03:49
130	1	1	Page Visit	User Visited the Page			customers_lastmonth.php	192.168.10.1	2026-08-23 09:03:49
131	1	1	Page Visit	User Visited the Page			payments_lastmonth.php	192.168.10.1	2026-08-23 09:03:49
132	1	1	Page Visit	User Visited the Page			calls_lastmonth.php	192.168.10.1	2026-08-23 09:03:50
133	1	1	User Logged In	User Logged in to website			PP_Intro.php	192.168.10.40	2026-08-23 09:08:45
134	1	1	Page Visit	User Visited the Page			dashboard.php	192.168.10.40	2026-08-23 09:08:51
135	1	1	Page Visit	User Visited the Page			customers_lastmonth.php	192.168.10.40	2026-08-23 09:08:51
136	1	1	Page Visit	User Visited the Page			refills_lastmonth.php	192.168.10.40	2026-08-23 09:08:52
137	1	1	Page Visit	User Visited the Page			payments_lastmonth.php	192.168.10.40	2026-08-23 09:08:52
138	1	1	Page Visit	User Visited the Page			calls_lastmonth.php	192.168.10.40	2026-08-23 09:08:52
139	1	1	User Logged In	User Logged in to website			PP_Intro.php	192.168.10.1	2026-08-25 00:42:18
140	1	1	Page Visit	User Visited the Page			dashboard.php	192.168.10.1	2026-08-25 00:55:43
141	1	1	Page Visit	User Visited the Page			customers_lastmonth.php	192.168.10.1	2026-08-25 00:55:43
142	1	1	Page Visit	User Visited the Page			refills_lastmonth.php	192.168.10.1	2026-08-25 00:55:43
143	1	1	Page Visit	User Visited the Page			calls_lastmonth.php	192.168.10.1	2026-08-25 00:55:43
144	1	1	Page Visit	User Visited the Page			payments_lastmonth.php	192.168.10.1	2026-08-25 00:55:43
145	1	1	Page Visit	User Visited the Page			A2B_entity_voucher.php	192.168.10.1	2026-08-25 00:55:55
146	1	1	Page Visit	User Visited the Page			A2B_entity_voucher_multi.php	192.168.10.1	2026-08-25 00:56:14
147	1	1	Page Visit	User Visited the Page			A2B_currencies.php	192.168.10.1	2026-08-25 00:57:41
148	1	1	Page Visit	User Visited the Page			A2B_currencies.php	192.168.10.1	2026-08-25 00:57:49
149	1	1	Page Visit	User Visited the Page			A2B_currencies.php	192.168.10.1	2026-08-25 00:59:10
150	1	2	NEW CURRENCIES CREATED	User added a new record in database	name = Ariary Malagasy| currency =  MGA| value =  4300| basecurrency =  USD	cc_currencies	A2B_currencies.php	192.168.10.1	2026-08-25 00:59:10
151	1	1	Page Visit	User Visited the Page			A2B_currencies.php	192.168.10.1	2026-08-25 00:59:18
152	1	1	Page Visit	User Visited the Page			A2B_currencies.php	192.168.10.1	2026-08-25 00:59:23
153	1	1	Page Visit	User Visited the Page			A2B_currencies.php	192.168.10.1	2026-08-25 00:59:29
154	1	1	Page Visit	User Visited the Page			A2B_currencies.php	192.168.10.1	2026-08-25 00:59:34
155	1	1	Page Visit	User Visited the Page			A2B_currencies.php	192.168.10.1	2026-08-25 00:59:36
156	1	1	Page Visit	User Visited the Page			A2B_currencies.php	192.168.10.1	2026-08-25 00:59:38
157	1	1	Page Visit	User Visited the Page			A2B_currencies.php	192.168.10.1	2026-08-25 00:59:41
158	1	1	Page Visit	User Visited the Page			asterisk&section=18	192.168.10.1	2026-08-25 01:00:43
159	1	1	Page Visit	User Visited the Page			A2B_entity_config_generate_confirm.php	192.168.10.1	2026-08-25 01:00:46
160	1	1	Page Visit	User Visited the Page			A2B_entity_config_group.php	192.168.10.1	2026-08-25 01:00:49
161	1	1	Page Visit	User Visited the Page			A2B_entity_config.php	192.168.10.1	2026-08-25 01:01:41
162	1	1	Page Visit	User Visited the Page			A2B_entity_config.php	192.168.10.1	2026-08-25 01:01:52
163	1	1	Page Visit	User Visited the Page			A2B_entity_config.php	192.168.10.1	2026-08-25 01:02:21
164	1	1	Page Visit	User Visited the Page			A2B_entity_config.php	192.168.10.1	2026-08-25 01:02:24
165	1	1	Page Visit	User Visited the Page			A2B_entity_config.php	192.168.10.1	2026-08-25 01:02:28
166	1	1	Page Visit	User Visited the Page			A2B_entity_config.php	192.168.10.1	2026-08-25 01:02:41
167	1	3	A CONFIGURATION UPDATED	A RECORD IS UPDATED, EDITION CALUSE USED IS id = 4	config_group_title = global | config_title = Base Currency | config_key = base_currency | config_value = mga 	cc_config	A2B_entity_config.php	192.168.10.1	2026-08-25 01:02:41
168	1	1	Page Visit	User Visited the Page			A2B_entity_config.php	192.168.10.1	2026-08-25 01:02:41
169	1	1	Page Visit	User Visited the Page			A2B_currencies.php	192.168.10.1	2026-08-25 01:03:15
170	1	1	Page Visit	User Visited the Page			A2B_currencies.php	192.168.10.1	2026-08-25 01:03:20
171	1	1	Page Visit	User Visited the Page			A2B_currencies.php	192.168.10.1	2026-08-25 01:03:34
172	1	1	Page Visit	User Visited the Page			A2B_currencies.php	192.168.10.1	2026-08-25 01:03:42
173	1	1	Page Visit	User Visited the Page			A2B_currencies.php	192.168.10.1	2026-08-25 01:03:48
174	1	1	Page Visit	User Visited the Page			A2B_currencies.php	192.168.10.1	2026-08-25 01:03:51
175	1	1	Page Visit	User Visited the Page			A2B_currencies.php	192.168.10.1	2026-08-25 01:03:52
176	1	1	Page Visit	User Visited the Page			A2B_currencies.php	192.168.10.1	2026-08-25 01:03:55
177	1	1	Page Visit	User Visited the Page			A2B_currencies.php	192.168.10.1	2026-08-25 01:03:56
178	1	1	Page Visit	User Visited the Page			A2B_currencies.php	192.168.10.1	2026-08-25 01:03:58
179	1	1	Page Visit	User Visited the Page			A2B_currencies.php	192.168.10.1	2026-08-25 01:04:02
180	1	1	Page Visit	User Visited the Page			A2B_currencies.php	192.168.10.1	2026-08-25 01:04:07
181	1	1	Page Visit	User Visited the Page			A2B_currencies.php	192.168.10.1	2026-08-25 01:04:10
182	1	1	Page Visit	User Visited the Page			A2B_currencies.php	192.168.10.1	2026-08-25 01:04:14
183	1	1	Page Visit	User Visited the Page			A2B_currencies.php	192.168.10.1	2026-08-25 01:04:21
184	1	1	Page Visit	User Visited the Page			A2B_currencies.php	192.168.10.1	2026-08-25 01:04:32
185	1	1	Page Visit	User Visited the Page			A2B_entity_config.php	192.168.10.1	2026-08-25 01:05:35
186	1	1	Page Visit	User Visited the Page			A2B_entity_config.php	192.168.10.1	2026-08-25 01:05:41
187	1	1	Page Visit	User Visited the Page			A2B_currencies.php	192.168.10.1	2026-08-25 01:06:20
188	1	1	Page Visit	User Visited the Page			A2B_currencies.php	192.168.10.1	2026-08-25 01:06:23
189	1	1	Page Visit	User Visited the Page			A2B_currencies.php	192.168.10.1	2026-08-25 01:06:31
190	1	1	Page Visit	User Visited the Page			A2B_currencies.php	192.168.10.1	2026-08-25 01:06:34
191	1	1	Page Visit	User Visited the Page			A2B_currencies.php	192.168.10.1	2026-08-25 01:06:49
192	1	2	NEW CURRENCIES CREATED	User added a new record in database	name = Ariary Malagasy| currency =  MGA| value =  1| basecurrency =  MGA	cc_currencies	A2B_currencies.php	192.168.10.1	2026-08-25 01:06:49
193	1	1	Page Visit	User Visited the Page			A2B_currencies.php	192.168.10.1	2026-08-25 01:13:04
194	1	1	Page Visit	User Visited the Page			A2B_currencies.php	192.168.10.1	2026-08-25 01:13:12
195	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-25 01:13:22
196	1	1	Page Visit	User Visited the Page			A2B_entity_card_multi.php	192.168.10.1	2026-08-25 01:13:24
197	1	1	Page Visit	User Visited the Page			CC_card_import.php	192.168.10.1	2026-08-25 01:14:39
198	1	1	Page Visit	User Visited the Page			A2B_entity_voucher.php	192.168.10.1	2026-08-25 01:15:27
199	1	1	Page Visit	User Visited the Page			A2B_entity_voucher.php	192.168.10.1	2026-08-25 01:15:36
200	1	1	Page Visit	User Visited the Page			A2B_entity_voucher.php	192.168.10.1	2026-08-25 01:16:59
201	1	2	NEW VOUCHER CREATED	User added a new record in database	voucher = 893818342366055| credit =  1000| tag =  RECHARGE_1000AR| activated =  t| currency =  MGA| expirationdate =  2036-08-25 01:15:35	cc_voucher	A2B_entity_voucher.php	192.168.10.1	2026-08-25 01:16:59
202	1	1	Page Visit	User Visited the Page			A2B_entity_voucher.php	192.168.10.1	2026-08-25 01:17:05
203	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-25 01:17:35
204	1	1	Page Visit	User Visited the Page			CC_card_import.php	192.168.10.1	2026-08-25 01:17:40
205	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-25 01:17:42
206	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-25 01:18:02
207	1	1	Page Visit	User Visited the Page			A2B_entity_card_multi.php	192.168.10.1	2026-08-25 01:18:07
208	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-25 01:18:10
209	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-25 01:18:12
210	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-25 01:21:14
211	1	2	NEW CARD CREATED	User added a new record in database	username = 9204293968| useralias =  user1| uipass =  phone1| credit =  0| id_group =  1| id_seria =  -1| lastname =  Fenitra| country =  USA| typepaid =  1| id_didgroup =  -1| id_timezone =  40| language =  en| currency =  MGA| status =  1| block =  0| lock_pin =  0| simultaccess =  1| runservice =  0| credit_notification =  -1| notify_email =  0| id_campaign =  -1| enableexpire =  0| expirationdate =  2036-08-25 01:18:11| expiredays =  0| sip_buddy =  1| iax_buddy =  1| autorefill =  0| initialbalance =  0| invoiceday =  1| vat =  0| discount =  0.00| restriction =  0	cc_card	A2B_entity_card.php	192.168.10.1	2026-08-25 01:21:14
212	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-25 01:21:28
213	1	2	NEW CARD CREATED	User added a new record in database	username = 9204293968| useralias =  0351234567| uipass =  phone1| credit =  0| id_group =  1| id_seria =  -1| lastname =  Fenitra| country =  AFG| typepaid =  0| id_didgroup =  -1| id_timezone =  1| language =  en| currency =  MGA| status =  1| lock_pin =  0| simultaccess =  1| credit_notification =  -1| id_campaign =  -1| enableexpire =  0| expirationdate =  2036-08-25 01:18:11| expiredays =  0| sip_buddy =  1| initialbalance =  0| invoiceday =  1| vat =  0| discount =  0.00| restriction =  0	cc_card	A2B_entity_card.php	192.168.10.1	2026-08-25 01:21:28
214	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-25 01:21:37
215	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-25 01:21:42
216	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-25 01:22:43
217	1	2	NEW CARD CREATED	User added a new record in database	username = 6468763925| useralias =  fenitra| uipass =  phone1| credit =  0| id_group =  1| id_seria =  -1| lastname =  Fenitra| country =  MDG| typepaid =  1| id_didgroup =  -1| id_timezone =  40| language =  en| currency =  MGA| status =  1| block =  0| lock_pin =  0| simultaccess =  1| runservice =  0| credit_notification =  -1| notify_email =  0| id_campaign =  -1| enableexpire =  0| expirationdate =  2036-08-25 01:21:42| expiredays =  0| sip_buddy =  1| iax_buddy =  1| autorefill =  0| initialbalance =  0| invoiceday =  1| vat =  0| discount =  0.00| restriction =  0	cc_card	A2B_entity_card.php	192.168.10.1	2026-08-25 01:22:43
218	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-25 01:23:12
219	1	2	NEW CARD CREATED	User added a new record in database	username = 6468763925| useralias =  0351234567| uipass =  phone1| credit =  0| id_group =  1| id_seria =  -1| lastname =  Fenitra| country =  AFG| typepaid =  0| id_didgroup =  -1| id_timezone =  1| language =  en| currency =  MGA| status =  1| lock_pin =  0| simultaccess =  1| credit_notification =  -1| id_campaign =  -1| enableexpire =  0| expirationdate =  2036-08-25 01:21:42| expiredays =  0| sip_buddy =  1| initialbalance =  0| invoiceday =  1| vat =  0| discount =  0.00| restriction =  0	cc_card	A2B_entity_card.php	192.168.10.1	2026-08-25 01:23:12
220	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-25 01:23:21
221	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-25 01:23:27
222	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-25 01:23:29
223	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-25 01:23:52
306	1	1	Page Visit	User Visited the Page			A2B_entity_voucher.php	192.168.10.1	2026-08-26 18:57:30
307	1	1	Page Visit	User Visited the Page			A2B_entity_voucher.php	192.168.10.1	2026-08-26 18:58:16
224	1	2	NEW CARD CREATED	User added a new record in database	username = 6422795882| useralias =  577739327194933| uipass =  phone1| credit =  0| id_group =  1| id_seria =  -1| lastname =  Fenitra| country =  MDG| typepaid =  1| id_didgroup =  -1| id_timezone =  67| language =  en| currency =  MGA| status =  1| block =  0| lock_pin =  0| simultaccess =  1| runservice =  0| credit_notification =  -1| notify_email =  0| id_campaign =  -1| enableexpire =  0| expirationdate =  2036-08-25 01:23:28| expiredays =  0| sip_buddy =  1| iax_buddy =  1| autorefill =  0| initialbalance =  0| invoiceday =  1| vat =  0| discount =  0.00| restriction =  0	cc_card	A2B_entity_card.php	192.168.10.1	2026-08-25 01:23:52
225	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-25 01:24:38
226	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-25 01:25:24
227	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-25 01:28:56
228	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-25 01:28:59
229	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-25 01:29:31
230	1	2	NEW CARD CREATED	User added a new record in database	username = 4834067797| useralias =  823177036003397| uipass =  phone1| credit =  0| id_group =  1| id_seria =  -1| lastname =  Fenitra| country =  MDG| typepaid =  1| id_didgroup =  -1| id_timezone =  40| language =  en| currency =  MGA| status =  1| block =  0| lock_pin =  0| simultaccess =  1| runservice =  0| credit_notification =  -1| notify_email =  0| id_campaign =  -1| enableexpire =  0| expirationdate =  2036-08-25 01:28:58| expiredays =  0| sip_buddy =  1| iax_buddy =  1| autorefill =  0| initialbalance =  0| invoiceday =  1| vat =  0| discount =  0.00| restriction =  0	cc_card	A2B_entity_card.php	192.168.10.1	2026-08-25 01:29:31
231	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-25 01:31:14
232	1	1	Page Visit	User Visited the Page			PP_intro.php	192.168.10.1	2026-08-25 01:32:33
233	1	1	User Logged In	User Logged in to website			PP_Intro.php	192.168.10.1	2026-08-25 02:37:51
234	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-25 02:37:56
235	1	1	User Logged In	User Logged in to website			PP_Intro.php	192.168.10.1	2026-08-26 18:28:32
236	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-26 18:28:42
237	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-26 18:29:36
238	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-26 18:30:23
239	1	2	NEW CARD CREATED	User added a new record in database	username = 9890930847| useralias =  594116422844764| uipass =  73840hnyxrgwznayfi2t| credit =  0| id_group =  1| id_seria =  -1| lastname =  Tojo| firstname =  ANDRIANARIVONJY| address =  LOT IVM 38 SJA Andohotapenaka| city =  67ha| country =  MDG| zipcode =  101| phone =  0345351885| typepaid =  1| id_didgroup =  -1| id_timezone =  40| language =  en| currency =  MGA| status =  1| block =  0| lock_pin =  0| simultaccess =  1| runservice =  0| credit_notification =  -1| notify_email =  0| id_campaign =  -1| enableexpire =  0| expirationdate =  2036-08-26 18:29:35| expiredays =  0| sip_buddy =  1| iax_buddy =  1| autorefill =  0| initialbalance =  0| invoiceday =  1| vat =  0| discount =  0.00| restriction =  0	cc_card	A2B_entity_card.php	192.168.10.1	2026-08-26 18:30:23
240	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-26 18:30:27
241	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-26 18:30:41
242	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-26 18:30:55
243	1	3	A CARD UPDATED	A RECORD IS UPDATED, EDITION CALUSE USED IS  id=2 	username =  | useralias = 0351234567 | uipass = phone1 | credit =  | id_group = 1 | id_seria = -1 | lastname =  | firstname =  | email =  | address =  | city =  | state =  | country = AFG | zipcode =  | phone =  | fax =  | company_name =  | company_website =  | tariff =  | id_didgroup = -1 | id_timezone = 1 | language = en | currency = MGA | status = 1 | block =  | lock_pin =  | simultaccess = 1 | runservice =  | creditlimit = NULL | credit_notification = -1 | notify_email =  | email_notification =  | id_campaign = -1 | firstusedate = NULL | enableexpire = 0 | expirationdate = NULL | expiredays =  | sip_buddy =  | iax_buddy =  | mac_addr =  | inuse =  | max_concurrent =  | autorefill =  | initialbalance =  | invoiceday = 1 | vat =  | vat_rn =  | discount = 0.00 | traffic =  | traffic_target =  | restriction = 0 	cc_card	A2B_entity_card.php	192.168.10.1	2026-08-26 18:30:55
244	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-26 18:30:59
245	1	3	A CARD UPDATED	A RECORD IS UPDATED, EDITION CALUSE USED IS  id=2 	username =  | useralias = 0351234567 | uipass = phone1 | credit =  | id_group = 1 | id_seria = -1 | lastname =  | firstname =  | email =  | address =  | city =  | state =  | country = AFG | zipcode =  | phone =  | fax =  | company_name =  | company_website =  | tariff =  | id_didgroup = -1 | id_timezone = 1 | language = en | currency = MGA | status = 1 | block =  | lock_pin =  | simultaccess = 1 | runservice =  | creditlimit = NULL | credit_notification = -1 | notify_email =  | email_notification =  | id_campaign = -1 | firstusedate = NULL | enableexpire = 0 | expirationdate = NULL | expiredays =  | sip_buddy =  | iax_buddy =  | mac_addr =  | inuse =  | max_concurrent =  | autorefill =  | initialbalance =  | invoiceday = 1 | vat =  | vat_rn =  | discount = 0.00 | traffic =  | traffic_target =  | restriction = 0 	cc_card	A2B_entity_card.php	192.168.10.1	2026-08-26 18:30:59
246	1	1	Page Visit	User Visited the Page			A2B_entity_voucher.php	192.168.10.1	2026-08-26 18:32:03
247	1	1	Page Visit	User Visited the Page			A2B_entity_card_seria.php	192.168.10.1	2026-08-26 18:33:36
248	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-26 18:34:10
249	1	1	Page Visit	User Visited the Page			A2B_mass_mail.php	192.168.10.1	2026-08-26 18:34:29
250	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-26 18:34:32
251	1	1	Page Visit	User Visited the Page			A2B_entity_subscriber.php	192.168.10.1	2026-08-26 18:34:34
252	1	1	Page Visit	User Visited the Page			A2B_entity_subscriber.php	192.168.10.1	2026-08-26 18:34:44
253	1	2	NEW SUBSCRIBER CREATED	User added a new record in database	id_cc_card = 100000| id_subscription_fee =  -1| startdate =  2026-08-26 18:34:33| stopdate =  2038-01-01 00:00:00	cc_card_subscription	A2B_entity_subscriber.php	192.168.10.1	2026-08-26 18:34:44
254	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-26 18:34:47
255	1	1	Page Visit	User Visited the Page			A2B_entity_subscriber.php	192.168.10.1	2026-08-26 18:34:56
256	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-26 18:35:01
257	1	1	Page Visit	User Visited the Page			A2B_entity_subscriber.php	192.168.10.1	2026-08-26 18:35:18
258	1	2	NEW SUBSCRIBER CREATED	User added a new record in database	id_cc_card = 9890930847| id_subscription_fee =  -1| startdate =  2026-08-26 18:34:55| stopdate =  2038-01-01 00:00:00	cc_card_subscription	A2B_entity_subscriber.php	192.168.10.1	2026-08-26 18:35:18
259	1	1	Page Visit	User Visited the Page			CC_card_import.php	192.168.10.1	2026-08-26 18:35:21
260	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-26 18:35:22
261	1	1	Page Visit	User Visited the Page			A2B_entity_payment.php	192.168.10.1	2026-08-26 18:35:27
262	1	1	Page Visit	User Visited the Page			A2B_entity_payment.php	192.168.10.1	2026-08-26 18:35:48
263	1	2	NEW PAYMENT CREATED	User added a new record in database	card_id = 9890930847| date =  2026-08-26 18:35:27| payment =  10000000| added_refill =  0| added_commission =  0| payment_type =  0	cc_logpayment	A2B_entity_payment.php	192.168.10.1	2026-08-26 18:35:48
264	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-26 18:35:51
265	1	1	Page Visit	User Visited the Page			A2B_entity_payment.php	192.168.10.1	2026-08-26 18:36:34
266	1	1	Page Visit	User Visited the Page			A2B_entity_payment.php	192.168.10.1	2026-08-26 18:37:07
267	1	2	NEW PAYMENT CREATED	User added a new record in database	card_id = 1| date =  2026-08-26 18:36:34| payment =  10000000| added_refill =  1| added_commission =  0| payment_type =  0	cc_logpayment	A2B_entity_payment.php	192.168.10.1	2026-08-26 18:37:07
268	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-26 18:37:18
269	1	1	Page Visit	User Visited the Page			A2B_entity_payment.php	192.168.10.1	2026-08-26 18:38:34
270	1	1	Page Visit	User Visited the Page			A2B_entity_payment.php	192.168.10.1	2026-08-26 18:38:49
271	1	2	NEW PAYMENT CREATED	User added a new record in database	card_id = 2| date =  2026-08-26 18:38:33| payment =  200000| added_refill =  1| added_commission =  0| payment_type =  0	cc_logpayment	A2B_entity_payment.php	192.168.10.1	2026-08-26 18:38:49
272	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-26 18:38:51
273	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-26 18:41:22
274	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-26 18:41:28
275	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-26 18:43:58
276	1	2	NEW CARD CREATED	User added a new record in database	username = 9218079042| useralias =  870142072166365| uipass =  32593wy7ne5odgnrnipz| credit =  0| id_group =  1| id_seria =  -1| lastname =  Jeda| address =  LOT IVM 38 SJA Andohotapenaka| city =  67ha| country =  USA| zipcode =  101| typepaid =  0| id_didgroup =  -1| id_timezone =  67| language =  en| currency =  MGA| status =  1| block =  0| lock_pin =  0| simultaccess =  1| runservice =  0| credit_notification =  -1| notify_email =  0| id_campaign =  -1| enableexpire =  0| expirationdate =  2036-08-26 18:41:28| expiredays =  0| sip_buddy =  1| iax_buddy =  1| autorefill =  0| initialbalance =  0| invoiceday =  1| vat =  0| discount =  0.00| restriction =  0	cc_card	A2B_entity_card.php	192.168.10.1	2026-08-26 18:43:58
277	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-26 18:44:06
278	1	1	Page Visit	User Visited the Page			A2B_entity_payment.php	192.168.10.1	2026-08-26 18:44:10
279	1	1	Page Visit	User Visited the Page			A2B_entity_payment.php	192.168.10.1	2026-08-26 18:44:21
280	1	2	NEW PAYMENT CREATED	User added a new record in database	card_id = 3| date =  2026-08-26 18:44:09| payment =  20000| added_refill =  1| added_commission =  0| payment_type =  0	cc_logpayment	A2B_entity_payment.php	192.168.10.1	2026-08-26 18:44:21
281	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-26 18:44:23
282	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-26 18:47:54
283	1	1	Page Visit	User Visited the Page			A2B_entity_payment.php	192.168.10.1	2026-08-26 18:48:02
284	1	1	Page Visit	User Visited the Page			A2B_entity_payment.php	192.168.10.1	2026-08-26 18:48:11
285	1	2	NEW PAYMENT CREATED	User added a new record in database	card_id = 1| date =  2026-08-26 18:48:01| payment =  2500| added_refill =  0| added_commission =  0| payment_type =  0	cc_logpayment	A2B_entity_payment.php	192.168.10.1	2026-08-26 18:48:11
286	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-26 18:48:12
287	1	1	Page Visit	User Visited the Page			A2B_entity_payment.php	192.168.10.1	2026-08-26 18:48:18
288	1	1	Page Visit	User Visited the Page			A2B_entity_payment.php	192.168.10.1	2026-08-26 18:48:24
289	1	2	NEW PAYMENT CREATED	User added a new record in database	card_id = 3| date =  2026-08-26 18:48:17| payment =  2500| added_refill =  1| added_commission =  0| payment_type =  0	cc_logpayment	A2B_entity_payment.php	192.168.10.1	2026-08-26 18:48:24
290	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-26 18:48:26
291	1	1	Page Visit	User Visited the Page			A2B_entity_voucher.php	192.168.10.1	2026-08-26 18:55:12
292	1	1	Page Visit	User Visited the Page			A2B_entity_moneysituation.php	192.168.10.1	2026-08-26 18:55:29
293	1	1	Page Visit	User Visited the Page			A2B_entity_transactions.php	192.168.10.1	2026-08-26 18:55:32
294	1	1	Page Visit	User Visited the Page			A2B_entity_billing_customer.php	192.168.10.1	2026-08-26 18:55:33
295	1	1	Page Visit	User Visited the Page			A2B_entity_agentsituation.php	192.168.10.1	2026-08-26 18:55:34
296	1	1	Page Visit	User Visited the Page			A2B_entity_payment_configuration.php	192.168.10.1	2026-08-26 18:55:37
297	1	1	Page Visit	User Visited the Page			A2B_currencies.php	192.168.10.1	2026-08-26 18:55:39
298	1	1	Page Visit	User Visited the Page			A2B_entity_moneysituation.php	192.168.10.1	2026-08-26 18:55:43
299	1	1	Page Visit	User Visited the Page			A2B_entity_voucher.php	192.168.10.1	2026-08-26 18:55:45
300	1	1	Page Visit	User Visited the Page			A2B_entity_voucher_multi.php	192.168.10.1	2026-08-26 18:56:12
301	1	1	Page Visit	User Visited the Page			A2B_entity_voucher_multi.php	192.168.10.1	2026-08-26 18:56:25
302	1	1	Page Visit	User Visited the Page			A2B_entity_voucher.php	192.168.10.1	2026-08-26 18:56:29
303	1	1	Page Visit	User Visited the Page			A2B_entity_voucher.php	192.168.10.1	2026-08-26 18:56:35
304	1	1	Page Visit	User Visited the Page			A2B_entity_voucher.php	192.168.10.1	2026-08-26 18:57:27
305	1	2	NEW VOUCHER CREATED	User added a new record in database	voucher = 158742690895968| credit =  2000| tag =  RECHARGE_2000AR| activated =  t| currency =  MGA| expirationdate =  2036-08-26 18:56:35	cc_voucher	A2B_entity_voucher.php	192.168.10.1	2026-08-26 18:57:27
308	1	1	Page Visit	User Visited the Page			A2B_entity_voucher.php	192.168.10.1	2026-08-26 18:59:46
309	1	2	NEW VOUCHER CREATED	User added a new record in database	voucher = 962144109568479| credit =  5000| tag =  RECHARGE_5000AR| activated =  t| currency =  MGA| expirationdate =  2036-08-26 18:58:15	cc_voucher	A2B_entity_voucher.php	192.168.10.1	2026-08-26 18:59:46
310	1	1	Page Visit	User Visited the Page			A2B_entity_voucher.php	192.168.10.1	2026-08-26 18:59:48
311	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-26 19:07:34
312	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-26 19:09:39
313	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-26 19:09:48
314	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-26 19:09:50
315	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-26 19:10:06
316	1	2	NEW CARD CREATED	User added a new record in database	username = 9036867057| useralias =  0351234567| uipass =  phone1| credit =  0| id_group =  1| id_seria =  -1| lastname =  Hoby| country =  USA| typepaid =  0| id_didgroup =  -1| id_timezone =  67| language =  en| currency =  MGA| status =  1| block =  0| lock_pin =  0| simultaccess =  1| runservice =  0| credit_notification =  -1| notify_email =  0| id_campaign =  -1| enableexpire =  0| expirationdate =  2036-08-26 19:09:49| expiredays =  0| sip_buddy =  1| iax_buddy =  1| autorefill =  0| initialbalance =  0| invoiceday =  1| vat =  0| discount =  0.00| restriction =  0	cc_card	A2B_entity_card.php	192.168.10.1	2026-08-26 19:10:06
317	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-26 19:10:08
318	1	1	Page Visit	User Visited the Page			A2B_entity_payment.php	192.168.10.1	2026-08-26 19:10:12
319	1	1	Page Visit	User Visited the Page			A2B_entity_payment.php	192.168.10.1	2026-08-26 19:10:26
320	1	2	NEW PAYMENT CREATED	User added a new record in database	card_id = 4| date =  2026-08-26 19:10:12| payment =  300000| added_refill =  1| added_commission =  0| payment_type =  0	cc_logpayment	A2B_entity_payment.php	192.168.10.1	2026-08-26 19:10:26
321	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-26 19:10:28
322	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-26 19:12:39
323	1	1	User Logged In	User Logged in to website			PP_Intro.php	192.168.10.1	2026-08-26 20:21:21
324	1	1	Page Visit	User Visited the Page			A2B_entity_voucher.php	192.168.10.1	2026-08-26 20:21:25
325	1	1	Page Visit	User Visited the Page			A2B_entity_voucher_multi.php	192.168.10.1	2026-08-26 20:21:41
326	1	1	Page Visit	User Visited the Page			A2B_entity_voucher.php	192.168.10.1	2026-08-26 20:21:59
327	1	1	Page Visit	User Visited the Page			A2B_entity_voucher_multi.php	192.168.10.1	2026-08-26 20:22:20
328	1	1	Page Visit	User Visited the Page			A2B_entity_voucher_multi.php	192.168.10.1	2026-08-26 20:22:35
329	1	1	Page Visit	User Visited the Page			A2B_entity_voucher_multi.php	192.168.10.1	2026-08-26 20:22:58
330	1	1	Page Visit	User Visited the Page			A2B_entity_voucher_multi.php	192.168.10.1	2026-08-26 20:23:05
331	1	1	Page Visit	User Visited the Page			A2B_entity_voucher.php	192.168.10.1	2026-08-26 20:23:17
332	1	1	Page Visit	User Visited the Page			A2B_entity_voucher_multi.php	192.168.10.1	2026-08-26 20:24:02
333	1	1	Page Visit	User Visited the Page			A2B_entity_voucher_multi.php	192.168.10.1	2026-08-26 20:24:16
334	1	1	Page Visit	User Visited the Page			A2B_entity_voucher.php	192.168.10.1	2026-08-26 20:24:19
335	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-26 20:54:41
336	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-26 20:54:51
337	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-26 20:55:09
338	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-26 20:55:12
339	1	1	Page Visit	User Visited the Page			CC_card_import.php	192.168.10.1	2026-08-26 20:59:07
340	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-26 20:59:08
341	1	1	Page Visit	User Visited the Page			A2B_entity_friend.php	192.168.10.1	2026-08-26 20:59:13
342	1	2	NEW SIP CONFIG CREATED	User added a new record in database	id_cc_card = 2| name =  9890930847| accountcode =  9890930847| regexten =  9890930847| callerid =  594116422844764| amaflags =  billing| secret =  86539m9zonaw64745580| qualify =  yes| allow =  ulaw| host = alaw| context = gsm| username = g729| nat =  dynamic| dtmfmode =  a2billing	cc_sip_buddies	A2B_entity_friend.php	192.168.10.1	2026-08-26 20:59:13
343	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-26 20:59:16
344	1	1	Page Visit	User Visited the Page			A2B_entity_friend.php	192.168.10.1	2026-08-26 20:59:22
345	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-26 20:59:22
346	1	1	Page Visit	User Visited the Page			A2B_entity_friend.php	192.168.10.1	2026-08-26 20:59:54
347	1	2	NEW SIP CONFIG CREATED	User added a new record in database	id_cc_card = 1| name =  4834067797| accountcode =  4834067797| regexten =  4834067797| callerid =  823177036003397| amaflags =  billing| secret =  24274yom072vs6889130| qualify =  yes| allow =  ulaw| host = alaw| context = gsm| username = g729| nat =  dynamic| dtmfmode =  a2billing	cc_sip_buddies	A2B_entity_friend.php	192.168.10.1	2026-08-26 20:59:54
348	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-26 21:00:07
349	1	1	User Logged In	User Logged in to website			PP_Intro.php	192.168.10.1	2026-08-27 07:02:54
350	1	1	Page Visit	User Visited the Page			A2B_entity_voucher.php	192.168.10.1	2026-08-27 07:02:58
351	1	1	Page Visit	User Visited the Page			A2B_entity_voucher.php	192.168.10.1	2026-08-27 07:03:42
352	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-27 07:19:47
353	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-27 07:19:55
354	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-27 07:19:59
355	1	3	A CARD DELETED	A RECORD IS DELETED, EDITION CLAUSE USED IS  id=4 		cc_card	A2B_entity_card.php	192.168.10.1	2026-08-27 07:19:59
356	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-27 07:19:59
357	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-27 07:52:15
358	1	1	User Logged In	User Logged in to website			PP_Intro.php	192.168.10.1	2026-08-27 08:32:32
359	1	1	Page Visit	User Visited the Page			dashboard.php	192.168.10.1	2026-08-27 08:48:13
360	1	1	Page Visit	User Visited the Page			customers_lastmonth.php	192.168.10.1	2026-08-27 08:48:14
361	1	1	Page Visit	User Visited the Page			refills_lastmonth.php	192.168.10.1	2026-08-27 08:48:14
362	1	1	Page Visit	User Visited the Page			payments_lastmonth.php	192.168.10.1	2026-08-27 08:48:14
363	1	1	Page Visit	User Visited the Page			calls_lastmonth.php	192.168.10.1	2026-08-27 08:48:14
364	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-27 08:48:44
365	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-27 08:49:05
366	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-27 08:49:18
367	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-27 08:49:39
368	1	3	A CARD UPDATED	A RECORD IS UPDATED, EDITION CALUSE USED IS  id=3 	username =  | useralias = 0351234567 | uipass = phone1 | credit =  | id_group = 1 | id_seria = -1 | lastname =  | firstname =  | email =  | address =  | city =  | state =  | country = AFG | zipcode =  | phone =  | fax =  | company_name =  | company_website =  | tariff = 1 | id_didgroup = -1 | id_timezone = 1 | language = en | currency = MGA | status = 1 | block =  | lock_pin =  | simultaccess = 1 | runservice =  | creditlimit = NULL | credit_notification = -1 | notify_email =  | email_notification =  | id_campaign = -1 | firstusedate = NULL | enableexpire = 0 | expirationdate = NULL | expiredays =  | sip_buddy =  | iax_buddy =  | mac_addr =  | inuse =  | max_concurrent =  | autorefill =  | initialbalance =  | invoiceday = 1 | vat =  | vat_rn =  | discount = 0.00 | traffic =  | traffic_target =  | restriction = 0 	cc_card	A2B_entity_card.php	192.168.10.1	2026-08-27 08:49:39
369	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-27 08:49:49
370	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-27 08:49:57
371	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-27 08:50:14
372	1	3	A CARD UPDATED	A RECORD IS UPDATED, EDITION CALUSE USED IS  id=3 	username =  | useralias = 0351234567 | uipass = phone1 | credit =  | id_group = 1 | id_seria = -1 | lastname =  | firstname =  | email =  | address =  | city =  | state =  | country = AFG | zipcode =  | phone =  | fax =  | company_name =  | company_website =  | tariff = 1 | id_didgroup = -1 | id_timezone = 1 | language = en | currency = MGA | status = 1 | block =  | lock_pin =  | simultaccess = 1 | runservice =  | creditlimit = NULL | credit_notification = -1 | notify_email =  | email_notification =  | id_campaign = -1 | firstusedate = NULL | enableexpire = 0 | expirationdate = NULL | expiredays =  | sip_buddy =  | iax_buddy =  | mac_addr =  | inuse =  | max_concurrent =  | autorefill =  | initialbalance =  | invoiceday = 1 | vat =  | vat_rn =  | discount = 0.00 | traffic =  | traffic_target =  | restriction = 0 	cc_card	A2B_entity_card.php	192.168.10.1	2026-08-27 08:50:14
373	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-27 08:50:19
374	1	3	A CARD UPDATED	A RECORD IS UPDATED, EDITION CALUSE USED IS  id=3 	username =  | useralias = 0351234567 | uipass = phone1 | credit =  | id_group = 1 | id_seria = -1 | lastname =  | firstname =  | email =  | address =  | city =  | state =  | country = AFG | zipcode =  | phone =  | fax =  | company_name =  | company_website =  | tariff = 1 | id_didgroup = -1 | id_timezone = 1 | language = en | currency = MGA | status = 1 | block =  | lock_pin =  | simultaccess = 1 | runservice =  | creditlimit = NULL | credit_notification = -1 | notify_email =  | email_notification =  | id_campaign = -1 | firstusedate = NULL | enableexpire = 0 | expirationdate = NULL | expiredays =  | sip_buddy =  | iax_buddy =  | mac_addr =  | inuse =  | max_concurrent =  | autorefill =  | initialbalance =  | invoiceday = 1 | vat =  | vat_rn =  | discount = 0.00 | traffic =  | traffic_target =  | restriction = 0 	cc_card	A2B_entity_card.php	192.168.10.1	2026-08-27 08:50:19
375	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-27 08:53:24
376	1	3	A CARD UPDATED	A RECORD IS UPDATED, EDITION CALUSE USED IS  id=3 	username =  | useralias = 0351234567 | uipass = phone1 | credit =  | id_group = 1 | id_seria = -1 | lastname =  | firstname =  | email =  | address =  | city =  | state =  | country = AFG | zipcode =  | phone =  | fax =  | company_name =  | company_website =  | tariff = 1 | id_didgroup = -1 | id_timezone = 1 | language = en | currency = MGA | status = 1 | block =  | lock_pin =  | simultaccess = 1 | runservice =  | creditlimit = NULL | credit_notification = -1 | notify_email =  | email_notification =  | id_campaign = -1 | firstusedate = NULL | enableexpire = 0 | expirationdate = NULL | expiredays =  | sip_buddy =  | iax_buddy =  | mac_addr =  | inuse =  | max_concurrent =  | autorefill =  | initialbalance =  | invoiceday = 1 | vat =  | vat_rn =  | discount = 0.00 | traffic =  | traffic_target =  | restriction = 0 	cc_card	A2B_entity_card.php	192.168.10.1	2026-08-27 08:53:24
377	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-27 08:56:04
378	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-27 08:57:42
379	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-27 08:58:22
380	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-27 08:58:28
381	1	1	Page Visit	User Visited the Page			A2B_entity_didgroup.php	192.168.10.1	2026-08-27 08:58:43
382	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-27 09:02:04
383	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-27 09:02:06
384	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-27 09:02:21
385	1	1	User Logged In	User Logged in to website			PP_Intro.php	192.168.10.1	2026-08-27 10:37:37
386	1	1	Page Visit	User Visited the Page			A2B_entity_tariffgroup.php	192.168.10.1	2026-08-27 10:37:59
387	1	1	Page Visit	User Visited the Page			A2B_entity_tariffgroup.php	192.168.10.1	2026-08-27 10:38:02
388	1	1	Page Visit	User Visited the Page			A2B_entity_def_ratecard.php	192.168.10.1	2026-08-27 10:38:14
389	1	1	User Logged In	User Logged in to website			PP_Intro.php	192.168.10.1	2026-08-27 18:03:07
390	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-27 18:03:11
391	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-27 18:05:56
392	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-27 18:06:23
393	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-27 18:06:30
394	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-27 18:06:33
395	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-27 18:06:50
396	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-27 18:06:52
397	1	3	A CARD UPDATED	A RECORD IS UPDATED, EDITION CALUSE USED IS  id=1 	username =  | useralias =  | uipass =  | credit =  | id_group = 1 | id_seria = -1 | lastname =  | firstname =  | email =  | address =  | city =  | state =  | country = AFG | zipcode =  | phone =  | fax =  | company_name =  | company_website =  | tariff = 1 | id_didgroup = -1 | id_timezone = 1 | language = en | currency = MGA | status = 1 | block =  | lock_pin =  | simultaccess = 1 | runservice =  | creditlimit = NULL | credit_notification = -1 | notify_email =  | email_notification =  | id_campaign = -1 | firstusedate = NULL | enableexpire = 0 | expirationdate = NULL | expiredays =  | sip_buddy =  | iax_buddy =  | mac_addr =  | inuse =  | max_concurrent =  | autorefill =  | initialbalance =  | invoiceday = 1 | vat =  | vat_rn =  | discount = 0.00 | traffic =  | traffic_target =  | restriction = 0 	cc_card	A2B_entity_card.php	192.168.10.1	2026-08-27 18:06:52
398	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-27 18:07:01
399	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-27 18:07:06
400	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-27 18:07:09
401	1	3	A CARD UPDATED	A RECORD IS UPDATED, EDITION CALUSE USED IS  id=3 	username =  | useralias =  | uipass =  | credit =  | id_group = 1 | id_seria = -1 | lastname =  | firstname =  | email =  | address =  | city =  | state =  | country = AFG | zipcode =  | phone =  | fax =  | company_name =  | company_website =  | tariff = 1 | id_didgroup = -1 | id_timezone = 1 | language = en | currency = MGA | status = 1 | block =  | lock_pin =  | simultaccess = 1 | runservice =  | creditlimit = NULL | credit_notification = -1 | notify_email =  | email_notification =  | id_campaign = -1 | firstusedate = NULL | enableexpire = 0 | expirationdate = NULL | expiredays =  | sip_buddy =  | iax_buddy =  | mac_addr =  | inuse =  | max_concurrent =  | autorefill =  | initialbalance =  | invoiceday = 1 | vat =  | vat_rn =  | discount = 0.00 | traffic =  | traffic_target =  | restriction = 0 	cc_card	A2B_entity_card.php	192.168.10.1	2026-08-27 18:07:09
402	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-27 18:12:46
403	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-27 18:12:50
404	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-27 18:12:53
405	1	3	A CARD UPDATED	A RECORD IS UPDATED, EDITION CALUSE USED IS  id=2 	username =  | useralias =  | uipass =  | credit =  | id_group = 1 | id_seria = -1 | lastname =  | firstname =  | email =  | address =  | city =  | state =  | country = AFG | zipcode =  | phone =  | fax =  | company_name =  | company_website =  | tariff = 1 | id_didgroup = -1 | id_timezone = 1 | language = en | currency = MGA | status = 1 | block =  | lock_pin =  | simultaccess = 1 | runservice =  | creditlimit = NULL | credit_notification = -1 | notify_email =  | email_notification =  | id_campaign = -1 | firstusedate = NULL | enableexpire = 0 | expirationdate = NULL | expiredays =  | sip_buddy =  | iax_buddy =  | mac_addr =  | inuse =  | max_concurrent =  | autorefill =  | initialbalance =  | invoiceday = 1 | vat =  | vat_rn =  | discount = 0.00 | traffic =  | traffic_target =  | restriction = 0 	cc_card	A2B_entity_card.php	192.168.10.1	2026-08-27 18:12:53
406	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-27 18:13:21
407	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-27 18:13:23
408	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-27 18:13:25
409	1	3	A CARD UPDATED	A RECORD IS UPDATED, EDITION CALUSE USED IS  id=3 	username =  | useralias =  | uipass =  | credit =  | id_group = 1 | id_seria = -1 | lastname =  | firstname =  | email =  | address =  | city =  | state =  | country = AFG | zipcode =  | phone =  | fax =  | company_name =  | company_website =  | tariff = 1 | id_didgroup = -1 | id_timezone = 1 | language = en | currency = MGA | status = 1 | block =  | lock_pin =  | simultaccess = 1 | runservice =  | creditlimit = NULL | credit_notification = -1 | notify_email =  | email_notification =  | id_campaign = -1 | firstusedate = NULL | enableexpire = 0 | expirationdate = NULL | expiredays =  | sip_buddy =  | iax_buddy =  | mac_addr =  | inuse =  | max_concurrent =  | autorefill =  | initialbalance =  | invoiceday = 1 | vat =  | vat_rn =  | discount = 0.00 | traffic =  | traffic_target =  | restriction = 0 	cc_card	A2B_entity_card.php	192.168.10.1	2026-08-27 18:13:25
410	1	1	User Logged In	User Logged in to website			PP_Intro.php	192.168.10.1	2026-08-27 21:59:36
411	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-27 21:59:41
412	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-27 21:59:46
413	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-27 21:59:48
414	1	3	A CARD UPDATED	A RECORD IS UPDATED, EDITION CALUSE USED IS  id=2 	username =  | useralias =  | uipass =  | credit =  | id_group = 1 | id_seria = -1 | lastname =  | firstname =  | email =  | address =  | city =  | state =  | country = AFG | zipcode =  | phone =  | fax =  | company_name =  | company_website =  | tariff = 1 | id_didgroup = -1 | id_timezone = 1 | language = en | currency = MGA | status = 1 | block =  | lock_pin =  | simultaccess = 1 | runservice =  | creditlimit = NULL | credit_notification = -1 | notify_email =  | email_notification =  | id_campaign = -1 | firstusedate = NULL | enableexpire = 0 | expirationdate = NULL | expiredays =  | sip_buddy =  | iax_buddy =  | mac_addr =  | inuse =  | max_concurrent =  | autorefill =  | initialbalance =  | invoiceday = 1 | vat =  | vat_rn =  | discount = 0.00 | traffic =  | traffic_target =  | restriction = 0 	cc_card	A2B_entity_card.php	192.168.10.1	2026-08-27 21:59:48
415	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-27 22:00:06
416	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-27 22:00:09
417	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-27 22:00:11
418	1	3	A CARD UPDATED	A RECORD IS UPDATED, EDITION CALUSE USED IS  id=3 	username =  | useralias =  | uipass =  | credit =  | id_group = 1 | id_seria = -1 | lastname =  | firstname =  | email =  | address =  | city =  | state =  | country = AFG | zipcode =  | phone =  | fax =  | company_name =  | company_website =  | tariff = 1 | id_didgroup = -1 | id_timezone = 1 | language = en | currency = MGA | status = 1 | block =  | lock_pin =  | simultaccess = 1 | runservice =  | creditlimit = NULL | credit_notification = -1 | notify_email =  | email_notification =  | id_campaign = -1 | firstusedate = NULL | enableexpire = 0 | expirationdate = NULL | expiredays =  | sip_buddy =  | iax_buddy =  | mac_addr =  | inuse =  | max_concurrent =  | autorefill =  | initialbalance =  | invoiceday = 1 | vat =  | vat_rn =  | discount = 0.00 | traffic =  | traffic_target =  | restriction = 0 	cc_card	A2B_entity_card.php	192.168.10.1	2026-08-27 22:00:11
419	1	1	User Logged In	User Logged in to website			PP_Intro.php	192.168.10.40	2026-08-28 05:30:43
420	1	1	Page Visit	User Visited the Page			CC_card_import.php	192.168.10.40	2026-08-28 05:33:24
421	1	1	Page Visit	User Visited the Page			CC_card_import.php	192.168.10.40	2026-08-28 05:33:25
422	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.40	2026-08-28 05:33:35
423	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.40	2026-08-28 05:33:45
424	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.40	2026-08-28 05:33:47
425	1	3	A CARD UPDATED	A RECORD IS UPDATED, EDITION CALUSE USED IS  id=3 	username =  | useralias =  | uipass =  | credit =  | id_group = 1 | id_seria = -1 | lastname =  | firstname =  | email =  | address =  | city =  | state =  | country = AFG | zipcode =  | phone =  | fax =  | company_name =  | company_website =  | tariff = 1 | id_didgroup = -1 | id_timezone = 1 | language = en | currency = MGA | status = 1 | block =  | lock_pin =  | simultaccess = 1 | runservice =  | creditlimit = NULL | credit_notification = -1 | notify_email =  | email_notification =  | id_campaign = -1 | firstusedate = NULL | enableexpire = 0 | expirationdate = NULL | expiredays =  | sip_buddy =  | iax_buddy =  | mac_addr =  | inuse =  | max_concurrent =  | autorefill =  | initialbalance =  | invoiceday = 1 | vat =  | vat_rn =  | discount = 0.00 | traffic =  | traffic_target =  | restriction = 0 	cc_card	A2B_entity_card.php	192.168.10.40	2026-08-28 05:33:47
426	1	1	Page Visit	User Visited the Page			A2B_entity_voucher.php	192.168.10.40	2026-08-28 05:34:38
427	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.40	2026-08-28 05:34:46
428	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.40	2026-08-28 05:34:50
429	1	1	Page Visit	User Visited the Page			A2B_entity_voucher.php	192.168.10.40	2026-08-28 05:35:11
430	1	1	Page Visit	User Visited the Page			A2B_entity_voucher.php	192.168.10.40	2026-08-28 05:40:35
431	1	1	User Logged In	User Logged in to website			PP_Intro.php	192.168.10.1	2026-08-28 05:51:08
432	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-28 05:51:12
433	1	1	Page Visit	User Visited the Page			A2B_entity_voucher.php	192.168.10.1	2026-08-28 05:51:17
434	1	1	Page Visit	User Visited the Page			A2B_entity_voucher.php	192.168.10.1	2026-08-28 05:51:21
435	1	1	Page Visit	User Visited the Page			A2B_entity_voucher.php	192.168.10.1	2026-08-28 05:51:25
436	1	3	A VOUCHER DELETED	A RECORD IS DELETED, EDITION CLAUSE USED IS  id=1 		cc_voucher	A2B_entity_voucher.php	192.168.10.1	2026-08-28 05:51:25
437	1	1	Page Visit	User Visited the Page			A2B_entity_voucher.php	192.168.10.1	2026-08-28 05:51:25
438	1	1	Page Visit	User Visited the Page			A2B_entity_voucher.php	192.168.10.1	2026-08-28 05:51:27
439	1	1	Page Visit	User Visited the Page			A2B_entity_voucher.php	192.168.10.1	2026-08-28 05:51:31
440	1	3	A VOUCHER DELETED	A RECORD IS DELETED, EDITION CLAUSE USED IS  id=2 		cc_voucher	A2B_entity_voucher.php	192.168.10.1	2026-08-28 05:51:31
441	1	1	Page Visit	User Visited the Page			A2B_entity_voucher.php	192.168.10.1	2026-08-28 05:51:31
442	1	1	Page Visit	User Visited the Page			A2B_entity_voucher.php	192.168.10.1	2026-08-28 05:51:41
443	1	1	Page Visit	User Visited the Page			A2B_entity_voucher_multi.php	192.168.10.1	2026-08-28 05:51:55
444	1	1	Page Visit	User Visited the Page			A2B_entity_voucher_multi.php	192.168.10.1	2026-08-28 05:52:13
445	1	1	Page Visit	User Visited the Page			A2B_entity_voucher_multi.php	192.168.10.1	2026-08-28 05:52:16
446	1	1	Page Visit	User Visited the Page			A2B_entity_voucher_multi.php	192.168.10.1	2026-08-28 05:52:30
447	1	1	Page Visit	User Visited the Page			A2B_entity_voucher_multi.php	192.168.10.1	2026-08-28 05:52:33
448	1	1	Page Visit	User Visited the Page			A2B_entity_voucher_multi.php	192.168.10.1	2026-08-28 05:52:34
449	1	1	Page Visit	User Visited the Page			A2B_entity_voucher.php	192.168.10.1	2026-08-28 05:52:44
450	1	1	Page Visit	User Visited the Page			A2B_entity_voucher_multi.php	192.168.10.1	2026-08-28 05:52:57
451	1	1	Page Visit	User Visited the Page			A2B_entity_voucher_multi.php	192.168.10.1	2026-08-28 05:53:05
452	1	1	Page Visit	User Visited the Page			A2B_entity_voucher.php	192.168.10.1	2026-08-28 05:53:07
453	1	1	User Logged In	User Logged in to website			PP_Intro.php	192.168.10.1	2026-08-28 06:56:33
454	1	1	Page Visit	User Visited the Page			A2B_entity_voucher.php	192.168.10.1	2026-08-28 06:56:41
455	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-28 06:57:52
456	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-28 06:57:56
457	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-28 06:57:58
458	1	3	A CARD UPDATED	A RECORD IS UPDATED, EDITION CALUSE USED IS  id=3 	username =  | useralias =  | uipass =  | credit =  | id_group = 1 | id_seria = -1 | lastname =  | firstname =  | email =  | address =  | city =  | state =  | country = AFG | zipcode =  | phone =  | fax =  | company_name =  | company_website =  | tariff = 1 | id_didgroup = -1 | id_timezone = 1 | language = en | currency = MGA | status = 1 | block =  | lock_pin =  | simultaccess = 1 | runservice =  | creditlimit = NULL | credit_notification = -1 | notify_email =  | email_notification =  | id_campaign = -1 | firstusedate = NULL | enableexpire = 0 | expirationdate = NULL | expiredays =  | sip_buddy =  | iax_buddy =  | mac_addr =  | inuse =  | max_concurrent =  | autorefill =  | initialbalance =  | invoiceday = 1 | vat =  | vat_rn =  | discount = 0.00 | traffic =  | traffic_target =  | restriction = 0 	cc_card	A2B_entity_card.php	192.168.10.1	2026-08-28 06:57:58
459	1	1	Page Visit	User Visited the Page			CC_card_import.php	192.168.10.1	2026-08-28 07:02:27
460	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-28 07:02:28
461	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-28 07:02:29
462	1	1	Page Visit	User Visited the Page			A2B_entity_voucher.php	192.168.10.1	2026-08-28 07:04:42
463	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-28 07:10:08
464	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-28 07:10:12
465	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-28 07:10:13
466	1	3	A CARD UPDATED	A RECORD IS UPDATED, EDITION CALUSE USED IS  id=3 	username =  | useralias =  | uipass =  | credit =  | id_group = 1 | id_seria = -1 | lastname =  | firstname =  | email =  | address =  | city =  | state =  | country = AFG | zipcode =  | phone =  | fax =  | company_name =  | company_website =  | tariff = 1 | id_didgroup = -1 | id_timezone = 1 | language = en | currency = MGA | status = 1 | block =  | lock_pin =  | simultaccess = 1 | runservice =  | creditlimit = NULL | credit_notification = -1 | notify_email =  | email_notification =  | id_campaign = -1 | firstusedate = NULL | enableexpire = 0 | expirationdate = NULL | expiredays =  | sip_buddy =  | iax_buddy =  | mac_addr =  | inuse =  | max_concurrent =  | autorefill =  | initialbalance =  | invoiceday = 1 | vat =  | vat_rn =  | discount = 0.00 | traffic =  | traffic_target =  | restriction = 0 	cc_card	A2B_entity_card.php	192.168.10.1	2026-08-28 07:10:13
467	1	1	Page Visit	User Visited the Page			A2B_entity_card.php	192.168.10.1	2026-08-28 07:10:39
468	1	1	Page Visit	User Visited the Page			A2B_entity_voucher.php	192.168.10.1	2026-08-28 07:20:09
469	1	1	Page Visit	User Visited the Page			A2B_entity_password.php	192.168.10.1	2026-08-30 09:50:41
470	1	1	Page Visit	User Visited the Page			A2B_entity_password.php	192.168.10.1	2026-08-30 09:51:21
471	1	1	Page Visit	User Visited the Page			A2B_entity_password.php	192.168.10.1	2026-08-30 09:51:23
472	1	1	Page Visit	User Visited the Page			Public	192.168.10.1	2026-08-30 09:51:28
473	1	1	Page Visit	User Visited the Page			PP_intro.php	192.168.10.1	2026-08-30 09:51:44
474	1	1	User Logged In	User Logged in to website			PP_Intro.php	192.168.10.1	2026-08-30 09:51:44
475	1	1	Page Visit	User Visited the Page			A2B_entity_password.php	192.168.10.1	2026-08-30 09:51:46
476	1	1	Page Visit	User Visited the Page			A2B_entity_password.php	192.168.10.1	2026-08-30 09:52:04
477	1	1	Page Visit	User Visited the Page			PP_intro.php	192.168.10.1	2026-08-30 10:18:04
478	1	1	Page Visit	User Visited the Page			PP_intro.php	192.168.10.1	2026-08-30 10:18:06
479	1	1	Page Visit	User Visited the Page			PP_intro.php	192.168.10.1	2026-08-30 10:18:14
480	1	1	User Logged In	User Logged in to website			PP_Intro.php	192.168.10.1	2026-08-30 10:18:14
\.


--
-- Data for Name: cc_tariffgroup; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_tariffgroup (id, iduser, idtariffplan, tariffgroupname, lcrtype, creationdate, removeinterprefix, id_cc_package_offer) FROM stdin;
1	0	1	Madagascar Group	0	2026-08-27 07:31:37.94688	0	0
\.


--
-- Data for Name: cc_tariffgroup_plan; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_tariffgroup_plan (idtariffgroup, idtariffplan) FROM stdin;
1	1
\.


--
-- Data for Name: cc_tariffplan; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_tariffplan (id, iduser, tariffname, creationdate, startingdate, expirationdate, description, id_trunk, secondusedreal, secondusedcarrier, secondusedratecard, reftariffplan, idowner, dnidprefix, calleridprefix) FROM stdin;
1	0	Madagascar	2026-08-20 14:11:55.153901	2026-08-20 14:11:10	2030-12-31 23:59:59	Tarifs appels Madagascar en MGA	1	2302	0	0	0	0	all	all
\.


--
-- Data for Name: cc_templatemail; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_templatemail (id, mailtype, fromemail, fromname, subject, messagetext, messagehtml, id_language) FROM stdin;
1	signup	info@YourDomain.com	YourDomain	SIGNUP CONFIRMATION	\nThank you for registering with us\nPlease click on below link to activate your account.\n\nhttp://YourDomain.com/activate.php?key$loginkey\n\nPlease make sure you active your account by making payment to us either by\ncredit card, wire transfer, money order, cheque, and western union money\ntransfer, money Gram, and Pay pal.\n\n\nKind regards,\nYourDomain\n		en
2	epaymentverify	info@YourDomain.com	YourDomain	Epayment Gateway Security Verification Failed	Dear Administrator\n\nPlease check the e-payment logs, the system has logged an e-payment security failure. This may be an attack attempt on epayment module.\n\nTime of Transaction: $time\nPayment Gateway: $paymentgateway\nAmount: $amount\n\n\nKind regards,\nYourDomain\n		en
3	reminder	info@YourDomain.com	YourDomain	REMINDER	\n\nYour YourDomain Account number $cardnumber is running low on credit.\n\nThere is currently only $credit_currency $currency left on your account which is lower than the warning level defined ($credit_notification)\n\n\nPlease top up your account ASAP to ensure continued service\n\nIf you no longer wish to receive these notifications or would like to change the balance amount at which these warnings are generated,\nplease connect on your myaccount panel and change the appropriate parameters\n\n\nyour account information :\nYour account number for VOIP authentication : $cardnumber\n\nhttp://myaccount.YourDomain.com/\nYour account login : $cardalias\nYour account password : $password\n\n\nThanks,\nYourDomain\n 		en
4	forgetpassword	info@YourDomain.com	YourDomain	Login Information	Your login information is as below:\n\nYour account is $card_gen\n\nYour password is $password\n\nYour cardalias is $cardalias\n\nhttp://YourDomain.com/A2BCustomer_UI/\n\n\nKind regards,\nYourDomain\n		en
5	signupconfirmed	info@YourDomain.com	YourDomain	SIGNUP CONFIRMATION	Thank you for registering with us\n\nPlease make sure you active your account by making payment to us either by\ncredit card, wire transfer, money order, cheque, and western union money\ntransfer, money Gram, and Pay pal.\n\nYour account is $card_gen\n\nYour password is $password\n\nTo go to your account :\nhttp://YourDomain.com/customer/\n\nKind regards,\nYourDomain\n		en
6	payment	info@YourDomain.com	YourDomain	PAYMENT CONFIRMATION	Thank you for shopping at YourDomain.\n\nShopping details is as below.\n\nItem Name = <b>$itemName</b>\nItem ID = <b>$itemID</b>\nAmount = <b>$itemAmount</b>\nPayment Method = <b>$paymentMethod</b>\nStatus = <b>$paymentStatus</b>\n\n\nKind regards,\nYourDomain\n		en
7	invoice	info@YourDomain.com	YourDomain	A2BILLING INVOICE	Dear Customer.\n\nAttached is the invoice.\n\nKind regards,\nYourDomain\n		en
\.


--
-- Data for Name: cc_ticket; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_ticket (id, id_component, title, description, priority, creationdate, creator, status, creator_type, viewed_cust, viewed_agent, viewed_admin) FROM stdin;
\.


--
-- Data for Name: cc_ticket_comment; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_ticket_comment (id, date, id_ticket, description, creator, creator_type, viewed_cust, viewed_agent, viewed_admin) FROM stdin;
\.


--
-- Data for Name: cc_timezone; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_timezone (id, gmtzone, gmttime, gmtoffset) FROM stdin;
1	(GMT-12:00) International Date Line West	GMT-12:00	-43200
2	(GMT-11:00) Midway Island, Samoa	GMT-11:00	-39600
3	(GMT-10:00) Hawaii	GMT-10:00	-36000
4	(GMT-09:00) Alaska	GMT-09:00	-32400
5	(GMT-08:00) Pacific Time (US & Canada) Tijuana	GMT-08:00	-28800
6	(GMT-07:00) Arizona	GMT-07:00	-25200
7	(GMT-07:00) Chihuahua, La Paz, Mazatlan	GMT-07:00	-25200
8	(GMT-07:00) Mountain Time(US & Canada)	GMT-07:00	-25200
9	(GMT-06:00) Central America	GMT-06:00	-21600
10	(GMT-06:00) Central Time (US & Canada)	GMT-06:00	-21600
11	(GMT-06:00) Guadalajara, Mexico City, Monterrey	GMT-06:00	-21600
12	(GMT-06:00) Saskatchewan	GMT-06:00	-21600
13	(GMT-05:00) Bogota, Lima, Quito	GMT-05:00	-18000
14	(GMT-05:00) Eastern Time (US & Canada)	GMT-05:00	-18000
15	(GMT-05:00) Indiana (East)	GMT-05:00	-18000
16	(GMT-04:00) Atlantic Time (Canada)	GMT-04:00	-14400
17	(GMT-04:00) Caracas, La Paz	GMT-04:00	-14400
18	(GMT-04:00) Santiago	GMT-04:00	-14400
19	(GMT-03:30) NewFoundland	GMT-03:30	-12600
20	(GMT-03:00) Brasillia	GMT-03:00	-10800
21	(GMT-03:00) Buenos Aires, Georgetown	GMT-03:00	-10800
22	(GMT-03:00) Greenland	GMT-03:00	-10800
23	(GMT-03:00) Mid-Atlantic	GMT-03:00	-10800
24	(GMT-01:00) Azores	GMT-01:00	-3600
25	(GMT-01:00) Cape Verd Is.	GMT-01:00	-3600
26	(GMT) Casablanca, Monrovia	GMT+00:00	0
27	(GMT) Greenwich Mean Time : Dublin, Edinburgh, Lisbon,  London	GMT	0
28	(GMT+01:00) Amsterdam, Berlin, Bern, Rome, Stockholm, Vienna	GMT+01:00	3600
29	(GMT+01:00) Belgrade, Bratislava, Budapest, Ljubljana, Prague	GMT+01:00	3600
30	(GMT+01:00) Brussels, Copenhagen, Madrid, Paris	GMT+01:00	3600
31	(GMT+01:00) Sarajevo, Skopje, Warsaw, Zagreb	GMT+01:00	3600
32	(GMT+01:00) West Central Africa	GMT+01:00	3600
33	(GMT+02:00) Athens, Istanbul, Minsk	GMT+02:00	7200
34	(GMT+02:00) Bucharest	GMT+02:00	7200
35	(GMT+02:00) Cairo	GMT+02:00	7200
36	(GMT+02:00) Harere, Pretoria	GMT+02:00	7200
37	(GMT+02:00) Helsinki, Kyiv, Riga, Sofia, Tallinn, Vilnius	GMT+02:00	7200
38	(GMT+02:00) Jeruasalem	GMT+02:00	7200
39	(GMT+03:00) Baghdad	GMT+03:00	10800
40	(GMT+03:00) Kuwait, Riyadh	GMT+03:00	10800
41	(GMT+03:00) Moscow, St.Petersburg, Volgograd	GMT+03:00	10800
42	(GMT+03:00) Nairobi	GMT+03:00	10800
43	(GMT+03:30) Tehran	GMT+03:30	12600
44	(GMT+04:00) Abu Dhabi, Muscat	GMT+04:00	14400
45	(GMT+04:00) Baku, Tbillisi, Yerevan	GMT+04:00	14400
46	(GMT+04:30) Kabul	GMT+04:30	16200
47	(GMT+05:00) Ekaterinburg	GMT+05:00	18000
48	(GMT+05:00) Islamabad, Karachi, Tashkent	GMT+05:00	18000
49	(GMT+05:30) Chennai, Kolkata, Mumbai, New Delhi	GMT+05:30	19800
50	(GMT+05:45) Kathmandu	GMT+05:45	20700
51	(GMT+06:00) Almaty, Novosibirsk	GMT+06:00	21600
52	(GMT+06:00) Astana, Dhaka	GMT+06:00	21600
53	(GMT+06:00) Sri Jayawardenepura	GMT+06:00	21600
54	(GMT+06:30) Rangoon	GMT+06:30	23400
55	(GMT+07:00) Bangkok, Hanoi, Jakarta	GMT+07:00	25200
56	(GMT+07:00) Krasnoyarsk	GMT+07:00	25200
57	(GMT+08:00) Beijiing, Chongging, Hong Kong, Urumqi	GMT+08:00	28800
58	(GMT+08:00) Irkutsk, Ulaan Bataar	GMT+08:00	28800
59	(GMT+08:00) Kuala Lumpur, Singapore	GMT+08:00	28800
60	(GMT+08:00) Perth	GMT+08:00	28800
61	(GMT+08:00) Taipei	GMT+08:00	28800
62	(GMT+09:00) Osaka, Sapporo, Tokyo	GMT+09:00	32400
63	(GMT+09:00) Seoul	GMT+09:00	32400
64	(GMT+09:00) Yakutsk	GMT+09:00	32400
65	(GMT+09:00) Adelaide	GMT+09:00	32400
66	(GMT+09:30) Darwin	GMT+09:30	34200
67	(GMT+10:00) Brisbane	GMT+10:00	36000
68	(GMT+10:00) Canberra, Melbourne, Sydney	GMT+10:00	36000
69	(GMT+10:00) Guam, Port Moresby	GMT+10:00	36000
70	(GMT+10:00) Hobart	GMT+10:00	36000
71	(GMT+10:00) Vladivostok	GMT+10:00	36000
72	(GMT+11:00) Magadan, Solomon Is., New Caledonia	GMT+11:00	39600
73	(GMT+12:00) Auckland, Wellington	GMT+1200	43200
74	(GMT+12:00) Fiji, Kamchatka, Marshall Is.	GMT+12:00	43200
75	(GMT+13:00) Nuku alofa	GMT+13:00	46800
\.


--
-- Data for Name: cc_trunk; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_trunk (id_trunk, trunkcode, trunkprefix, providertech, providerip, removeprefix, secondusedreal, secondusedcarrier, secondusedratecard, creationdate, failover_trunk, addparameter, id_provider, inuse, maxuse, status, if_max_use) FROM stdin;
1	DEFAULT		PJSIP	%dialingnumber%		2302	0	0	2005-03-14 01:01:36	0		\N	0	-1	1	0
\.


--
-- Data for Name: cc_ui_authen; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_ui_authen (userid, login, pwd_encoded, groupid, perms, confaddcust, name, direction, zipcode, state, phone, fax, email, datecreation) FROM stdin;
2	admin	410fc6268dd3332226de95e42d9efa4046c5463769d7493b85e65cfa5c26362dc2455cc23c0bc5831deb008def4ab11a9eaa9b76ba3f377da134f39ec60dd758	0	5242879	\N	\N	\N	\N	\N	\N	\N	2005-02-26 21:14:05.391501-05	2026-08-20 07:30:39.703147
1	root	3eee2bd37d6e1ca6eb0483f20c9bbae00be4d2d45bb64f4a741e07c2a276c78ff3ed4900c59e99ee1d6fcce1cf511332da1003eef956ab1f9d4175c7f7d6255d	0	5242879	\N	\N	\N	\N	\N	\N	\N	2005-02-26 20:33:27.691314-05	2026-08-20 07:30:39.703147
\.


--
-- Data for Name: cc_voucher; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cc_voucher (id, creationdate, usedate, expirationdate, voucher, usedcardnumber, tag, credit, activated, used, currency) FROM stdin;
7	2026-08-26 20:22:35.248543	\N	2036-08-26 20:22:19	788165709351857	\N	RECHARGE_1000AR	1000.0000	t	0	MGA
8	2026-08-26 20:22:35.249921	\N	2036-08-26 20:22:19	684331383104959	\N	RECHARGE_1000AR	1000.0000	t	0	MGA
9	2026-08-26 20:22:57.764448	\N	2036-08-26 20:22:19	606449716501439	\N	RECHARGE_1000AR	1000.0000	t	0	MGA
10	2026-08-26 20:22:57.766056	\N	2036-08-26 20:22:19	614395482708821	\N	RECHARGE_1000AR	1000.0000	t	0	MGA
11	2026-08-26 20:22:57.767425	\N	2036-08-26 20:22:19	406444956432272	\N	RECHARGE_1000AR	1000.0000	t	0	MGA
12	2026-08-26 20:22:57.768748	\N	2036-08-26 20:22:19	673839478147928	\N	RECHARGE_1000AR	1000.0000	t	0	MGA
13	2026-08-26 20:22:57.770217	\N	2036-08-26 20:22:19	835728179087084	\N	RECHARGE_1000AR	1000.0000	t	0	MGA
14	2026-08-26 20:23:05.102992	\N	2036-08-26 20:22:19	409062330215530	\N	RECHARGE_1000AR	1000.0000	t	0	MGA
15	2026-08-26 20:23:05.105283	\N	2036-08-26 20:22:19	813034566430333	\N	RECHARGE_1000AR	1000.0000	t	0	MGA
16	2026-08-26 20:23:05.10647	\N	2036-08-26 20:22:19	762703522720262	\N	RECHARGE_1000AR	1000.0000	t	0	MGA
17	2026-08-26 20:23:05.107636	\N	2036-08-26 20:22:19	539678584531819	\N	RECHARGE_1000AR	1000.0000	t	0	MGA
18	2026-08-26 20:23:05.108929	\N	2036-08-26 20:22:19	576087667427662	\N	RECHARGE_1000AR	1000.0000	t	0	MGA
19	2026-08-26 20:24:16.298723	\N	2036-08-26 20:24:02	932403261560780	\N	RECHARGE_5000AR	5000.0000	t	0	MGA
20	2026-08-26 20:24:16.300208	\N	2036-08-26 20:24:02	788453973102760	\N	RECHARGE_5000AR	5000.0000	t	0	MGA
21	2026-08-26 20:24:16.30145	\N	2036-08-26 20:24:02	395258482430337	\N	RECHARGE_5000AR	5000.0000	t	0	MGA
22	2026-08-26 20:24:16.302813	\N	2036-08-26 20:24:02	228541365597777	\N	RECHARGE_5000AR	5000.0000	t	0	MGA
23	2026-08-26 20:24:16.304116	\N	2036-08-26 20:24:02	946335765368564	\N	RECHARGE_5000AR	5000.0000	t	0	MGA
3	2026-08-26 18:59:45.527262	2026-08-27 07:03:29.833629	2036-08-26 18:58:15	962144109568479	0351234567	RECHARGE_5000AR	5000.0000	f	1	MGA
4	2026-08-26 20:22:35.244498	2026-08-28 05:40:08.917953	2036-08-26 20:22:19	433538007348601	0351234567	RECHARGE_1000AR	1000.0000	f	1	MGA
24	2026-08-28 05:52:13.250684	\N	2036-08-28 05:51:54	819075281791749	\N	RECHARGE_2000AR	2000.0000	t	0	MGA
25	2026-08-28 05:52:13.253557	\N	2036-08-28 05:51:54	648820327902085	\N	RECHARGE_2000AR	2000.0000	t	0	MGA
26	2026-08-28 05:52:13.255081	\N	2036-08-28 05:51:54	160076297713702	\N	RECHARGE_2000AR	2000.0000	t	0	MGA
27	2026-08-28 05:52:13.256491	\N	2036-08-28 05:51:54	778377227656796	\N	RECHARGE_2000AR	2000.0000	t	0	MGA
28	2026-08-28 05:52:13.257695	\N	2036-08-28 05:51:54	792832607785540	\N	RECHARGE_2000AR	2000.0000	t	0	MGA
29	2026-08-28 05:52:13.259353	\N	2036-08-28 05:51:54	738859660583228	\N	RECHARGE_2000AR	2000.0000	t	0	MGA
30	2026-08-28 05:52:13.261816	\N	2036-08-28 05:51:54	034834839520217	\N	RECHARGE_2000AR	2000.0000	t	0	MGA
31	2026-08-28 05:52:13.263217	\N	2036-08-28 05:51:54	922071795857566	\N	RECHARGE_2000AR	2000.0000	t	0	MGA
32	2026-08-28 05:52:13.264524	\N	2036-08-28 05:51:54	268773247262168	\N	RECHARGE_2000AR	2000.0000	t	0	MGA
33	2026-08-28 05:52:13.265697	\N	2036-08-28 05:51:54	234776837054631	\N	RECHARGE_2000AR	2000.0000	t	0	MGA
34	2026-08-28 05:52:16.033902	\N	2036-08-28 05:51:54	679304934752662	\N	RECHARGE_2000AR	2000.0000	t	0	MGA
35	2026-08-28 05:52:16.036184	\N	2036-08-28 05:51:54	097308865603967	\N	RECHARGE_2000AR	2000.0000	t	0	MGA
36	2026-08-28 05:52:16.038089	\N	2036-08-28 05:51:54	005501444943513	\N	RECHARGE_2000AR	2000.0000	t	0	MGA
37	2026-08-28 05:52:16.039315	\N	2036-08-28 05:51:54	170461410469309	\N	RECHARGE_2000AR	2000.0000	t	0	MGA
38	2026-08-28 05:52:16.040676	\N	2036-08-28 05:51:54	111357154110941	\N	RECHARGE_2000AR	2000.0000	t	0	MGA
39	2026-08-28 05:52:16.042353	\N	2036-08-28 05:51:54	072787125311298	\N	RECHARGE_2000AR	2000.0000	t	0	MGA
40	2026-08-28 05:52:16.044425	\N	2036-08-28 05:51:54	406946172921515	\N	RECHARGE_2000AR	2000.0000	t	0	MGA
41	2026-08-28 05:52:16.045848	\N	2036-08-28 05:51:54	936240287549561	\N	RECHARGE_2000AR	2000.0000	t	0	MGA
42	2026-08-28 05:52:16.047295	\N	2036-08-28 05:51:54	007196493601703	\N	RECHARGE_2000AR	2000.0000	t	0	MGA
43	2026-08-28 05:52:16.04874	\N	2036-08-28 05:51:54	137670864704543	\N	RECHARGE_2000AR	2000.0000	t	0	MGA
44	2026-08-28 05:52:29.555207	\N	2036-08-28 05:51:54	997195029517426	\N	RECHARGE_2000AR	2000.0000	t	0	MGA
45	2026-08-28 05:52:29.557036	\N	2036-08-28 05:51:54	032875227802675	\N	RECHARGE_2000AR	2000.0000	t	0	MGA
46	2026-08-28 05:52:29.559298	\N	2036-08-28 05:51:54	678469957278011	\N	RECHARGE_2000AR	2000.0000	t	0	MGA
47	2026-08-28 05:52:29.560645	\N	2036-08-28 05:51:54	457962802848388	\N	RECHARGE_2000AR	2000.0000	t	0	MGA
48	2026-08-28 05:52:29.56247	\N	2036-08-28 05:51:54	837823640862043	\N	RECHARGE_2000AR	2000.0000	t	0	MGA
49	2026-08-28 05:52:29.564666	\N	2036-08-28 05:51:54	085140356633163	\N	RECHARGE_2000AR	2000.0000	t	0	MGA
50	2026-08-28 05:52:29.567152	\N	2036-08-28 05:51:54	976828781927701	\N	RECHARGE_2000AR	2000.0000	t	0	MGA
51	2026-08-28 05:52:29.569851	\N	2036-08-28 05:51:54	802889298464951	\N	RECHARGE_2000AR	2000.0000	t	0	MGA
52	2026-08-28 05:52:29.571316	\N	2036-08-28 05:51:54	217997861885335	\N	RECHARGE_2000AR	2000.0000	t	0	MGA
53	2026-08-28 05:52:29.572606	\N	2036-08-28 05:51:54	714036113578329	\N	RECHARGE_2000AR	2000.0000	t	0	MGA
54	2026-08-28 05:53:04.634329	\N	2036-08-28 05:52:57	796649632743372	\N	RECHARGE_5000AR	5000.0000	t	0	MGA
55	2026-08-28 05:53:04.636164	\N	2036-08-28 05:52:57	264249339901241	\N	RECHARGE_5000AR	5000.0000	t	0	MGA
56	2026-08-28 05:53:04.637714	\N	2036-08-28 05:52:57	193502173801075	\N	RECHARGE_5000AR	5000.0000	t	0	MGA
57	2026-08-28 05:53:04.640031	\N	2036-08-28 05:52:57	301127195144977	\N	RECHARGE_5000AR	5000.0000	t	0	MGA
58	2026-08-28 05:53:04.641528	\N	2036-08-28 05:52:57	284448170988957	\N	RECHARGE_5000AR	5000.0000	t	0	MGA
6	2026-08-26 20:22:35.247197	2026-08-28 06:56:23.304148	2036-08-26 20:22:19	521744440491052	0351234567	RECHARGE_1000AR	1000.0000	f	1	MGA
5	2026-08-26 20:22:35.245921	2026-08-28 07:21:20.641398	2036-08-26 20:22:19	937620824299127	0351234567	RECHARGE_1000AR	1000.0000	f	1	MGA
\.


--
-- Name: cc_agent_commission_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_agent_commission_id_seq', 1, false);


--
-- Name: cc_agent_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_agent_id_seq', 1, false);


--
-- Name: cc_agent_signup_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_agent_signup_id_seq', 1, false);


--
-- Name: cc_alarm_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_alarm_id_seq', 1, false);


--
-- Name: cc_alarm_report_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_alarm_report_id_seq', 1, false);


--
-- Name: cc_autorefill_report_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_autorefill_report_id_seq', 1, false);


--
-- Name: cc_backup_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_backup_id_seq', 1, false);


--
-- Name: cc_billing_customer_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_billing_customer_id_seq', 1, false);


--
-- Name: cc_call_archive_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_call_archive_id_seq', 1, false);


--
-- Name: cc_call_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_call_id_seq', 15, true);


--
-- Name: cc_callback_spool_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_callback_spool_id_seq', 1, false);


--
-- Name: cc_callerid_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_callerid_id_seq', 2, true);


--
-- Name: cc_campaign_config_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_campaign_config_id_seq', 1, false);


--
-- Name: cc_campaign_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_campaign_id_seq', 1, false);


--
-- Name: cc_card_archive_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_card_archive_id_seq', 1, false);


--
-- Name: cc_card_group_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_card_group_id_seq', 1, true);


--
-- Name: cc_card_history_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_card_history_id_seq', 1, false);


--
-- Name: cc_card_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_card_id_seq', 4, true);


--
-- Name: cc_card_package_offer_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_card_package_offer_id_seq', 1, false);


--
-- Name: cc_card_seria_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_card_seria_id_seq', 1, true);


--
-- Name: cc_card_subscription_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_card_subscription_id_seq', 2, true);


--
-- Name: cc_charge_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_charge_id_seq', 1, false);


--
-- Name: cc_config_group_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_config_group_id_seq', 14, true);


--
-- Name: cc_config_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_config_id_seq', 254, true);


--
-- Name: cc_configuration_configuration_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_configuration_configuration_id_seq', 25, true);


--
-- Name: cc_country_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_country_id_seq', 1, false);


--
-- Name: cc_currencies_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_currencies_id_seq', 151, true);


--
-- Name: cc_did_destination_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_did_destination_id_seq', 1, false);


--
-- Name: cc_did_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_did_id_seq', 1, false);


--
-- Name: cc_did_use_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_did_use_id_seq', 1, false);


--
-- Name: cc_didgroup_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_didgroup_id_seq', 1, false);


--
-- Name: cc_ecommerce_product_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_ecommerce_product_id_seq', 1, false);


--
-- Name: cc_epayment_log_agent_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_epayment_log_agent_id_seq', 1, false);


--
-- Name: cc_epayment_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_epayment_log_id_seq', 1, false);


--
-- Name: cc_iax_buddies_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_iax_buddies_id_seq', 1, false);


--
-- Name: cc_invoice_conf_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_invoice_conf_id_seq', 11, true);


--
-- Name: cc_invoice_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_invoice_id_seq', 5, true);


--
-- Name: cc_invoice_item_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_invoice_item_id_seq', 1, false);


--
-- Name: cc_logpayment_agent_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_logpayment_agent_id_seq', 1, false);


--
-- Name: cc_logpayment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_logpayment_id_seq', 7, true);


--
-- Name: cc_logrefill_agent_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_logrefill_agent_id_seq', 1, false);


--
-- Name: cc_logrefill_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_logrefill_id_seq', 5, true);


--
-- Name: cc_notification_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_notification_id_seq', 1, false);


--
-- Name: cc_outbound_cid_group_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_outbound_cid_group_id_seq', 1, false);


--
-- Name: cc_outbound_cid_list_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_outbound_cid_list_id_seq', 1, false);


--
-- Name: cc_package_group_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_package_group_id_seq', 1, false);


--
-- Name: cc_package_offer_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_package_offer_id_seq', 1, false);


--
-- Name: cc_payment_methods_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_payment_methods_id_seq', 4, true);


--
-- Name: cc_payments_agent_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_payments_agent_id_seq', 1, false);


--
-- Name: cc_payments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_payments_id_seq', 1, false);


--
-- Name: cc_payments_status_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_payments_status_id_seq', 8, true);


--
-- Name: cc_paypal_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_paypal_id_seq', 1, false);


--
-- Name: cc_phonebook_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_phonebook_id_seq', 1, false);


--
-- Name: cc_phonenumber_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_phonenumber_id_seq', 1, false);


--
-- Name: cc_prefix_prefix_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_prefix_prefix_seq', 1, false);


--
-- Name: cc_provider_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_provider_id_seq', 1, false);


--
-- Name: cc_ratecard_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_ratecard_id_seq', 1, true);


--
-- Name: cc_receipt_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_receipt_id_seq', 1, false);


--
-- Name: cc_receipt_item_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_receipt_item_id_seq', 1, false);


--
-- Name: cc_restricted_phonenumber_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_restricted_phonenumber_id_seq', 1, false);


--
-- Name: cc_server_group_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_server_group_id_seq', 1, false);


--
-- Name: cc_server_manager_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_server_manager_id_seq', 1, true);


--
-- Name: cc_service_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_service_id_seq', 1, false);


--
-- Name: cc_service_report_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_service_report_id_seq', 1, false);


--
-- Name: cc_sip_buddies_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_sip_buddies_id_seq', 3, true);


--
-- Name: cc_speeddial_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_speeddial_id_seq', 1, false);


--
-- Name: cc_status_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_status_log_id_seq', 1, false);


--
-- Name: cc_subscription_fee_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_subscription_fee_id_seq', 1, false);


--
-- Name: cc_support_component_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_support_component_id_seq', 1, false);


--
-- Name: cc_support_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_support_id_seq', 1, false);


--
-- Name: cc_system_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_system_log_id_seq', 480, true);


--
-- Name: cc_tariffgroup_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_tariffgroup_id_seq', 1, true);


--
-- Name: cc_tariffplan_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_tariffplan_id_seq', 1, true);


--
-- Name: cc_templatemail_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_templatemail_id_seq', 7, true);


--
-- Name: cc_ticket_comment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_ticket_comment_id_seq', 1, false);


--
-- Name: cc_ticket_comment_id_ticket_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_ticket_comment_id_ticket_seq', 1, false);


--
-- Name: cc_ticket_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_ticket_id_seq', 1, false);


--
-- Name: cc_timezone_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_timezone_id_seq', 75, true);


--
-- Name: cc_trunk_id_trunk_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_trunk_id_trunk_seq', 1, false);


--
-- Name: cc_ui_authen_userid_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_ui_authen_userid_seq', 1, false);


--
-- Name: cc_voucher_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cc_voucher_id_seq', 58, true);


--
-- Name: cc_agent_commission cc_agent_commission_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_agent_commission
    ADD CONSTRAINT cc_agent_commission_pkey PRIMARY KEY (id);


--
-- Name: cc_agent cc_agent_login_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_agent
    ADD CONSTRAINT cc_agent_login_key UNIQUE (login);


--
-- Name: cc_agent cc_agent_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_agent
    ADD CONSTRAINT cc_agent_pkey PRIMARY KEY (id);


--
-- Name: cc_agent_signup cc_agent_signup_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_agent_signup
    ADD CONSTRAINT cc_agent_signup_code_key UNIQUE (code);


--
-- Name: cc_agent_signup cc_agent_signup_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_agent_signup
    ADD CONSTRAINT cc_agent_signup_pkey PRIMARY KEY (id);


--
-- Name: cc_agent_tariffgroup cc_agent_tariffgroup_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_agent_tariffgroup
    ADD CONSTRAINT cc_agent_tariffgroup_pkey PRIMARY KEY (id_agent, id_tariffgroup);


--
-- Name: cc_alarm cc_alarm_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_alarm
    ADD CONSTRAINT cc_alarm_pkey PRIMARY KEY (id);


--
-- Name: cc_alarm_report cc_alarm_report_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_alarm_report
    ADD CONSTRAINT cc_alarm_report_pkey PRIMARY KEY (id);


--
-- Name: cc_autorefill_report cc_autorefill_report_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_autorefill_report
    ADD CONSTRAINT cc_autorefill_report_pkey PRIMARY KEY (id);


--
-- Name: cc_backup cc_backup_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_backup
    ADD CONSTRAINT cc_backup_name_key UNIQUE (name);


--
-- Name: cc_backup cc_backup_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_backup
    ADD CONSTRAINT cc_backup_pkey PRIMARY KEY (id);


--
-- Name: cc_billing_customer cc_billing_customer_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_billing_customer
    ADD CONSTRAINT cc_billing_customer_pkey PRIMARY KEY (id);


--
-- Name: cc_call_archive cc_call_archive_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_call_archive
    ADD CONSTRAINT cc_call_archive_pkey PRIMARY KEY (id);


--
-- Name: cc_call cc_call_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_call
    ADD CONSTRAINT cc_call_pkey PRIMARY KEY (id);


--
-- Name: cc_callback_spool cc_callback_spool_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_callback_spool
    ADD CONSTRAINT cc_callback_spool_pkey PRIMARY KEY (id);


--
-- Name: cc_callback_spool cc_callback_spool_uniqueid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_callback_spool
    ADD CONSTRAINT cc_callback_spool_uniqueid_key UNIQUE (uniqueid);


--
-- Name: cc_callerid cc_callerid_cid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_callerid
    ADD CONSTRAINT cc_callerid_cid_key UNIQUE (cid);


--
-- Name: cc_callerid cc_callerid_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_callerid
    ADD CONSTRAINT cc_callerid_pkey PRIMARY KEY (id);


--
-- Name: cc_campaign_config cc_campaign_config_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_campaign_config
    ADD CONSTRAINT cc_campaign_config_pkey PRIMARY KEY (id);


--
-- Name: cc_campaign cc_campaign_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_campaign
    ADD CONSTRAINT cc_campaign_name_key UNIQUE (name);


--
-- Name: cc_campaign_phonebook cc_campaign_phonebook_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_campaign_phonebook
    ADD CONSTRAINT cc_campaign_phonebook_pkey PRIMARY KEY (id_campaign, id_phonebook);


--
-- Name: cc_campaign_phonestatus cc_campaign_phonestatus_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_campaign_phonestatus
    ADD CONSTRAINT cc_campaign_phonestatus_pkey PRIMARY KEY (id_phonenumber, id_campaign);


--
-- Name: cc_campaign cc_campaign_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_campaign
    ADD CONSTRAINT cc_campaign_pkey PRIMARY KEY (id);


--
-- Name: cc_campaignconf_cardgroup cc_campaignconf_cardgroup_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_campaignconf_cardgroup
    ADD CONSTRAINT cc_campaignconf_cardgroup_pkey PRIMARY KEY (id_campaign_config, id_card_group);


--
-- Name: cc_card_archive cc_card_archive_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_card_archive
    ADD CONSTRAINT cc_card_archive_pkey PRIMARY KEY (id);


--
-- Name: cc_card_archive cc_card_archive_useralias_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_card_archive
    ADD CONSTRAINT cc_card_archive_useralias_key UNIQUE (useralias);


--
-- Name: cc_card_archive cc_card_archive_username_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_card_archive
    ADD CONSTRAINT cc_card_archive_username_key UNIQUE (username);


--
-- Name: cc_card_group cc_card_group_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_card_group
    ADD CONSTRAINT cc_card_group_pkey PRIMARY KEY (id);


--
-- Name: cc_card_history cc_card_history_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_card_history
    ADD CONSTRAINT cc_card_history_pkey PRIMARY KEY (id);


--
-- Name: cc_card cc_card_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_card
    ADD CONSTRAINT cc_card_pkey PRIMARY KEY (id);


--
-- Name: cc_card_seria cc_card_seria_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_card_seria
    ADD CONSTRAINT cc_card_seria_pkey PRIMARY KEY (id);


--
-- Name: cc_card_subscription cc_card_subscription_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_card_subscription
    ADD CONSTRAINT cc_card_subscription_pkey PRIMARY KEY (id);


--
-- Name: cc_card cc_card_useralias_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_card
    ADD CONSTRAINT cc_card_useralias_key UNIQUE (useralias);


--
-- Name: cc_card cc_card_username_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_card
    ADD CONSTRAINT cc_card_username_key UNIQUE (username);


--
-- Name: cc_charge cc_charge_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_charge
    ADD CONSTRAINT cc_charge_pkey PRIMARY KEY (id);


--
-- Name: cc_config_group cc_config_group_group_title_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_config_group
    ADD CONSTRAINT cc_config_group_group_title_key UNIQUE (group_title);


--
-- Name: cc_config_group cc_config_group_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_config_group
    ADD CONSTRAINT cc_config_group_pkey PRIMARY KEY (id);


--
-- Name: cc_config cc_config_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_config
    ADD CONSTRAINT cc_config_pkey PRIMARY KEY (id);


--
-- Name: cc_configuration cc_configuration_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_configuration
    ADD CONSTRAINT cc_configuration_pkey PRIMARY KEY (configuration_id);


--
-- Name: cc_country cc_country_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_country
    ADD CONSTRAINT cc_country_pkey PRIMARY KEY (id);


--
-- Name: cc_currencies cc_currencies_currency_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_currencies
    ADD CONSTRAINT cc_currencies_currency_key UNIQUE (currency);


--
-- Name: cc_currencies cc_currencies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_currencies
    ADD CONSTRAINT cc_currencies_pkey PRIMARY KEY (id);


--
-- Name: cc_did_destination cc_did_destination_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_did_destination
    ADD CONSTRAINT cc_did_destination_pkey PRIMARY KEY (id);


--
-- Name: cc_did cc_did_did_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_did
    ADD CONSTRAINT cc_did_did_key UNIQUE (did);


--
-- Name: cc_did cc_did_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_did
    ADD CONSTRAINT cc_did_pkey PRIMARY KEY (id);


--
-- Name: cc_did_use cc_did_use_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_did_use
    ADD CONSTRAINT cc_did_use_pkey PRIMARY KEY (id);


--
-- Name: cc_didgroup cc_didgroup_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_didgroup
    ADD CONSTRAINT cc_didgroup_pkey PRIMARY KEY (id);


--
-- Name: cc_ecommerce_product cc_ecommerce_product_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_ecommerce_product
    ADD CONSTRAINT cc_ecommerce_product_pkey PRIMARY KEY (id);


--
-- Name: cc_epayment_log_agent cc_epayment_log_agent_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_epayment_log_agent
    ADD CONSTRAINT cc_epayment_log_agent_pkey PRIMARY KEY (id);


--
-- Name: cc_epayment_log cc_epayment_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_epayment_log
    ADD CONSTRAINT cc_epayment_log_pkey PRIMARY KEY (id);


--
-- Name: cc_iax_buddies cc_iax_buddies_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_iax_buddies
    ADD CONSTRAINT cc_iax_buddies_name_key UNIQUE (name);


--
-- Name: cc_iax_buddies cc_iax_buddies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_iax_buddies
    ADD CONSTRAINT cc_iax_buddies_pkey PRIMARY KEY (id);


--
-- Name: cc_invoice_conf cc_invoice_conf_key_val_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_invoice_conf
    ADD CONSTRAINT cc_invoice_conf_key_val_key UNIQUE (key_val);


--
-- Name: cc_invoice_conf cc_invoice_conf_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_invoice_conf
    ADD CONSTRAINT cc_invoice_conf_pkey PRIMARY KEY (id);


--
-- Name: cc_invoice_item cc_invoice_item_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_invoice_item
    ADD CONSTRAINT cc_invoice_item_pkey PRIMARY KEY (id);


--
-- Name: cc_invoice_payment cc_invoice_payment_id_payment_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_invoice_payment
    ADD CONSTRAINT cc_invoice_payment_id_payment_key UNIQUE (id_payment);


--
-- Name: cc_invoice_payment cc_invoice_payment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_invoice_payment
    ADD CONSTRAINT cc_invoice_payment_pkey PRIMARY KEY (id_invoice, id_payment);


--
-- Name: cc_invoice cc_invoice_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_invoice
    ADD CONSTRAINT cc_invoice_pkey PRIMARY KEY (id);


--
-- Name: cc_invoice cc_invoice_reference_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_invoice
    ADD CONSTRAINT cc_invoice_reference_key UNIQUE (reference);


--
-- Name: cc_iso639 cc_iso639_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_iso639
    ADD CONSTRAINT cc_iso639_name_key UNIQUE (name);


--
-- Name: cc_iso639 cc_iso639_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_iso639
    ADD CONSTRAINT cc_iso639_pkey PRIMARY KEY (code);


--
-- Name: cc_logpayment_agent cc_logpayment_agent_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_logpayment_agent
    ADD CONSTRAINT cc_logpayment_agent_pkey PRIMARY KEY (id);


--
-- Name: cc_logpayment cc_logpayment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_logpayment
    ADD CONSTRAINT cc_logpayment_pkey PRIMARY KEY (id);


--
-- Name: cc_logrefill_agent cc_logrefill_agent_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_logrefill_agent
    ADD CONSTRAINT cc_logrefill_agent_pkey PRIMARY KEY (id);


--
-- Name: cc_logrefill cc_logrefill_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_logrefill
    ADD CONSTRAINT cc_logrefill_pkey PRIMARY KEY (id);


--
-- Name: cc_notification_admin cc_notification_admin_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_notification_admin
    ADD CONSTRAINT cc_notification_admin_pkey PRIMARY KEY (id_notification, id_admin);


--
-- Name: cc_notification cc_notification_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_notification
    ADD CONSTRAINT cc_notification_pkey PRIMARY KEY (id);


--
-- Name: cc_outbound_cid_group cc_outbound_cid_group_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_outbound_cid_group
    ADD CONSTRAINT cc_outbound_cid_group_pkey PRIMARY KEY (id);


--
-- Name: cc_outbound_cid_list cc_outbound_cid_list_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_outbound_cid_list
    ADD CONSTRAINT cc_outbound_cid_list_pkey PRIMARY KEY (id);


--
-- Name: cc_package_group cc_package_group_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_package_group
    ADD CONSTRAINT cc_package_group_pkey PRIMARY KEY (id);


--
-- Name: cc_package_rate cc_package_rate_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_package_rate
    ADD CONSTRAINT cc_package_rate_pkey PRIMARY KEY (package_id, rate_id);


--
-- Name: cc_packgroup_package cc_packgroup_package_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_packgroup_package
    ADD CONSTRAINT cc_packgroup_package_pkey PRIMARY KEY (packagegroup_id, package_id);


--
-- Name: cc_payment_methods cc_payment_methods_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_payment_methods
    ADD CONSTRAINT cc_payment_methods_pkey PRIMARY KEY (id);


--
-- Name: cc_payments_agent cc_payments_agent_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_payments_agent
    ADD CONSTRAINT cc_payments_agent_pkey PRIMARY KEY (id);


--
-- Name: cc_payments cc_payments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_payments
    ADD CONSTRAINT cc_payments_pkey PRIMARY KEY (id);


--
-- Name: cc_payments_status cc_payments_status_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_payments_status
    ADD CONSTRAINT cc_payments_status_pkey PRIMARY KEY (id);


--
-- Name: cc_paypal cc_paypal_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_paypal
    ADD CONSTRAINT cc_paypal_pkey PRIMARY KEY (id);


--
-- Name: cc_paypal cc_paypal_txn_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_paypal
    ADD CONSTRAINT cc_paypal_txn_id_key UNIQUE (txn_id);


--
-- Name: cc_phonebook cc_phonebook_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_phonebook
    ADD CONSTRAINT cc_phonebook_pkey PRIMARY KEY (id);


--
-- Name: cc_phonenumber cc_phonenumber_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_phonenumber
    ADD CONSTRAINT cc_phonenumber_pkey PRIMARY KEY (id);


--
-- Name: cc_prefix cc_prefix_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_prefix
    ADD CONSTRAINT cc_prefix_pkey PRIMARY KEY (prefix);


--
-- Name: cc_provider cc_provider_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_provider
    ADD CONSTRAINT cc_provider_pkey PRIMARY KEY (id);


--
-- Name: cc_provider cc_provider_provider_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_provider
    ADD CONSTRAINT cc_provider_provider_name_key UNIQUE (provider_name);


--
-- Name: cc_ratecard cc_ratecard_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_ratecard
    ADD CONSTRAINT cc_ratecard_pkey PRIMARY KEY (id);


--
-- Name: cc_receipt_item cc_receipt_item_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_receipt_item
    ADD CONSTRAINT cc_receipt_item_pkey PRIMARY KEY (id);


--
-- Name: cc_receipt cc_receipt_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_receipt
    ADD CONSTRAINT cc_receipt_pkey PRIMARY KEY (id);


--
-- Name: cc_restricted_phonenumber cc_restricted_phonenumber_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_restricted_phonenumber
    ADD CONSTRAINT cc_restricted_phonenumber_pkey PRIMARY KEY (id);


--
-- Name: cc_server_group cc_server_group_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_server_group
    ADD CONSTRAINT cc_server_group_pkey PRIMARY KEY (id);


--
-- Name: cc_server_manager cc_server_manager_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_server_manager
    ADD CONSTRAINT cc_server_manager_pkey PRIMARY KEY (id);


--
-- Name: cc_service cc_service_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_service
    ADD CONSTRAINT cc_service_pkey PRIMARY KEY (id);


--
-- Name: cc_service_report cc_service_report_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_service_report
    ADD CONSTRAINT cc_service_report_pkey PRIMARY KEY (id);


--
-- Name: cc_sip_buddies cc_sip_buddies_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_sip_buddies
    ADD CONSTRAINT cc_sip_buddies_name_key UNIQUE (name);


--
-- Name: cc_sip_buddies cc_sip_buddies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_sip_buddies
    ADD CONSTRAINT cc_sip_buddies_pkey PRIMARY KEY (id);


--
-- Name: cc_speeddial cc_speeddial_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_speeddial
    ADD CONSTRAINT cc_speeddial_pkey PRIMARY KEY (id);


--
-- Name: cc_status_log cc_status_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_status_log
    ADD CONSTRAINT cc_status_log_pkey PRIMARY KEY (id);


--
-- Name: cc_subscription_fee cc_subscription_fee_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_subscription_fee
    ADD CONSTRAINT cc_subscription_fee_pkey PRIMARY KEY (id);


--
-- Name: cc_support_component cc_support_component_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_support_component
    ADD CONSTRAINT cc_support_component_pkey PRIMARY KEY (id);


--
-- Name: cc_support cc_support_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_support
    ADD CONSTRAINT cc_support_pkey PRIMARY KEY (id);


--
-- Name: cc_system_log cc_system_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_system_log
    ADD CONSTRAINT cc_system_log_pkey PRIMARY KEY (id);


--
-- Name: cc_tariffgroup cc_tariffgroup_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_tariffgroup
    ADD CONSTRAINT cc_tariffgroup_pkey PRIMARY KEY (id);


--
-- Name: cc_tariffgroup_plan cc_tariffgroup_plan_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_tariffgroup_plan
    ADD CONSTRAINT cc_tariffgroup_plan_pkey PRIMARY KEY (idtariffgroup, idtariffplan);


--
-- Name: cc_tariffplan cc_tariffplan_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_tariffplan
    ADD CONSTRAINT cc_tariffplan_pkey PRIMARY KEY (id);


--
-- Name: cc_ticket_comment cc_ticket_comment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_ticket_comment
    ADD CONSTRAINT cc_ticket_comment_pkey PRIMARY KEY (id);


--
-- Name: cc_ticket cc_ticket_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_ticket
    ADD CONSTRAINT cc_ticket_pkey PRIMARY KEY (id);


--
-- Name: cc_timezone cc_timezone_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_timezone
    ADD CONSTRAINT cc_timezone_pkey PRIMARY KEY (id);


--
-- Name: cc_trunk cc_trunk_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_trunk
    ADD CONSTRAINT cc_trunk_pkey PRIMARY KEY (id_trunk);


--
-- Name: cc_ui_authen cc_ui_authen_login_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_ui_authen
    ADD CONSTRAINT cc_ui_authen_login_key UNIQUE (login);


--
-- Name: cc_ui_authen cc_ui_authen_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_ui_authen
    ADD CONSTRAINT cc_ui_authen_pkey PRIMARY KEY (userid);


--
-- Name: cc_voucher cc_voucher_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_voucher
    ADD CONSTRAINT cc_voucher_pkey PRIMARY KEY (id);


--
-- Name: cc_voucher cc_voucher_voucher_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_voucher
    ADD CONSTRAINT cc_voucher_voucher_key UNIQUE (voucher);


--
-- Name: cc_cardgroup_service cons_cc_cardgroup_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_cardgroup_service
    ADD CONSTRAINT cons_cc_cardgroup_unique UNIQUE (id_card_group, id_service);


--
-- Name: cc_speeddial cons_cc_speeddial_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_speeddial
    ADD CONSTRAINT cons_cc_speeddial_pkey UNIQUE (id_cc_card, speeddial);


--
-- Name: cc_templatemail cons_cc_templatemail_mailtype; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_templatemail
    ADD CONSTRAINT cons_cc_templatemail_mailtype UNIQUE (mailtype, id_language);


--
-- Name: cc_tariffplan cons_iduser_tariffname; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_tariffplan
    ADD CONSTRAINT cons_iduser_tariffname UNIQUE (iduser, tariffname);


--
-- Name: cc_call_archive_calledstation_ind; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cc_call_archive_calledstation_ind ON public.cc_call_archive USING btree (calledstation);


--
-- Name: cc_call_archive_starttime_ind; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cc_call_archive_starttime_ind ON public.cc_call_archive USING btree (starttime);


--
-- Name: cc_call_archive_terminatecause_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cc_call_archive_terminatecause_id ON public.cc_call_archive USING btree (terminatecauseid);


--
-- Name: cc_call_archive_username_ind; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cc_call_archive_username_ind ON public.cc_call_archive USING btree (card_id);


--
-- Name: cc_call_calledstation_ind; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cc_call_calledstation_ind ON public.cc_call USING btree (calledstation);


--
-- Name: cc_call_starttime_ind; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cc_call_starttime_ind ON public.cc_call USING btree (starttime);


--
-- Name: cc_call_terminatecause_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cc_call_terminatecause_id ON public.cc_call USING btree (terminatecauseid);


--
-- Name: cc_call_username_ind; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cc_call_username_ind ON public.cc_call USING btree (card_id);


--
-- Name: cc_card_archive_creationdate_ind; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cc_card_archive_creationdate_ind ON public.cc_card_archive USING btree (creationdate);


--
-- Name: cc_card_archive_username_ind; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cc_card_archive_username_ind ON public.cc_card_archive USING btree (username);


--
-- Name: cc_card_creationdate_ind; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cc_card_creationdate_ind ON public.cc_card USING btree (creationdate);


--
-- Name: cc_card_username_ind; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cc_card_username_ind ON public.cc_card USING btree (username);


--
-- Name: cc_iax_buddies_host; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cc_iax_buddies_host ON public.cc_iax_buddies USING btree (host);


--
-- Name: cc_iax_buddies_ipaddr; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cc_iax_buddies_ipaddr ON public.cc_iax_buddies USING btree (ipaddr);


--
-- Name: cc_iax_buddies_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cc_iax_buddies_name ON public.cc_iax_buddies USING btree (name);


--
-- Name: cc_iax_buddies_port; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cc_iax_buddies_port ON public.cc_iax_buddies USING btree (port);


--
-- Name: cc_prefix_dest; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cc_prefix_dest ON public.cc_prefix USING btree (destination);


--
-- Name: cc_sip_buddies_host; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cc_sip_buddies_host ON public.cc_sip_buddies USING btree (host);


--
-- Name: cc_sip_buddies_ipaddr; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cc_sip_buddies_ipaddr ON public.cc_sip_buddies USING btree (ipaddr);


--
-- Name: cc_sip_buddies_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cc_sip_buddies_name ON public.cc_sip_buddies USING btree (name);


--
-- Name: cc_sip_buddies_port; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cc_sip_buddies_port ON public.cc_sip_buddies USING btree (port);


--
-- Name: ind_cc_card_package_offer_date_consumption; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ind_cc_card_package_offer_date_consumption ON public.cc_card_package_offer USING btree (date_consumption);


--
-- Name: ind_cc_card_package_offer_id_card; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ind_cc_card_package_offer_id_card ON public.cc_card_package_offer USING btree (id_cc_card);


--
-- Name: ind_cc_card_package_offer_id_package_offer; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ind_cc_card_package_offer_id_package_offer ON public.cc_card_package_offer USING btree (id_cc_package_offer);


--
-- Name: ind_cc_charge_creationdate; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ind_cc_charge_creationdate ON public.cc_charge USING btree (creationdate);


--
-- Name: ind_cc_charge_id_cc_card; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ind_cc_charge_id_cc_card ON public.cc_charge USING btree (id_cc_card);


--
-- Name: ind_cc_ratecard_dialprefix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ind_cc_ratecard_dialprefix ON public.cc_ratecard USING btree (dialprefix);


--
-- Name: cc_card cc_card_serial; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER cc_card_serial BEFORE INSERT ON public.cc_card FOR EACH ROW EXECUTE FUNCTION public.cc_card_serial_set();


--
-- Name: cc_card cc_card_serial_upd; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER cc_card_serial_upd BEFORE UPDATE ON public.cc_card FOR EACH ROW EXECUTE FUNCTION public.cc_card_serial_update();


--
-- Name: cc_ratecard cc_ratecard_validate_regex; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER cc_ratecard_validate_regex BEFORE INSERT OR UPDATE ON public.cc_ratecard FOR EACH ROW EXECUTE FUNCTION public.cc_ratecard_validate_regex();


--
-- Name: cc_agent cc_agent_id_tariffgroup_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_agent
    ADD CONSTRAINT cc_agent_id_tariffgroup_fkey FOREIGN KEY (id_tariffgroup) REFERENCES public.cc_tariffgroup(id);


--
-- Name: cc_support_component cc_support_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_support_component
    ADD CONSTRAINT cc_support_id_fkey FOREIGN KEY (id_support) REFERENCES public.cc_support(id) ON DELETE CASCADE;


--
-- Name: cc_ticket_comment cc_ticket_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cc_ticket_comment
    ADD CONSTRAINT cc_ticket_id_fkey FOREIGN KEY (id_ticket) REFERENCES public.cc_ticket(id) ON DELETE CASCADE;


--
-- Name: FUNCTION cc_card_serial_set(); Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON FUNCTION public.cc_card_serial_set() TO a2billing_dbuser;


--
-- Name: FUNCTION cc_card_serial_update(); Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON FUNCTION public.cc_card_serial_update() TO a2billing_dbuser;


--
-- Name: FUNCTION cc_ratecard_validate_regex(); Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON FUNCTION public.cc_ratecard_validate_regex() TO a2billing_dbuser;


--
-- Name: TABLE cc_sip_buddies_empty; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.cc_sip_buddies_empty TO a2billing_dbuser;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: -
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES  TO a2billing_dbuser;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: -
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS  TO a2billing_dbuser;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: -
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES  TO a2billing_dbuser;


--
-- PostgreSQL database dump complete
--

\unrestrict YqB7rbSlCi1SIrdrzc5eI6v1cyk0SObhA31wvDcGTD0f5mGXJzSh8RZfnAeJO3K

