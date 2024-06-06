--
-- PostgreSQL database dump
--

-- Dumped from database version 11.11 (Ubuntu 11.11-1.pgdg20.04+1)
-- Dumped by pg_dump version 12.3

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
-- Name: glims_v2; Type: DATABASE; Schema: -; Owner: braup
--

CREATE DATABASE glims_v2 WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8';


ALTER DATABASE glims_v2 OWNER TO braup;

\connect glims_v2

CREATE SCHEMA data;

ALTER DATABASE glims_v2 SET search_path TO data, public;

CREATE EXTENSION postgis SCHEMA data;

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

SET default_tablespace = '';

--
-- Name: area_histogram; Type: TABLE; Schema: data; Owner: braup
--

CREATE TABLE data.area_histogram (
    area_histogram_id integer NOT NULL,
    analysis_id integer NOT NULL,
    bin_width numeric(5,1) NOT NULL,
    registration character(1) NOT NULL
);


ALTER TABLE data.area_histogram OWNER TO braup;

--
-- Name: area_histogram_data; Type: TABLE; Schema: data; Owner: braup
--

CREATE TABLE data.area_histogram_data (
    area_histogram_id integer NOT NULL,
    elevation real NOT NULL,
    area real NOT NULL
);


ALTER TABLE data.area_histogram_data OWNER TO braup;

--
-- Name: country; Type: TABLE; Schema: data; Owner: braup
--

CREATE TABLE data.country (
    gid integer NOT NULL,
    country_code2 character(2) NOT NULL,
    country_code3 character(3),
    cntry_name character varying,
    sovereign character varying,
    pop_cntry bigint,
    sqkm_cntry double precision,
    sqmi_cntry double precision,
    curr_type character varying,
    curr_code character varying,
    landlocked boolean,
    color_map character varying,
    borders data.geometry,
    CONSTRAINT enforce_dims_borders CHECK ((data.st_ndims(borders) = 2)),
    CONSTRAINT enforce_geotype_borders CHECK (((data.geometrytype(borders) = 'MULTIPOLYGON'::text) OR (borders IS NULL))),
    CONSTRAINT enforce_srid_borders CHECK ((data.st_srid(borders) = 4326))
);


ALTER TABLE data.country OWNER TO braup;

--
-- Name: country_gid_seq; Type: SEQUENCE; Schema: data; Owner: braup
--

CREATE SEQUENCE data.country_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE data.country_gid_seq OWNER TO braup;

--
-- Name: country_gid_seq; Type: SEQUENCE OWNED BY; Schema: data; Owner: braup
--

ALTER SEQUENCE data.country_gid_seq OWNED BY data.country.gid;


--
-- Name: dominant_mass_source_valids; Type: TABLE; Schema: data; Owner: braup
--

CREATE TABLE data.dominant_mass_source_valids (
    dominant_mass_source integer NOT NULL,
    description text
);


ALTER TABLE data.dominant_mass_source_valids OWNER TO braup;

--
-- Name: glacier_static; Type: TABLE; Schema: data; Owner: braup
--

CREATE TABLE data.glacier_static (
    glacier_id character varying(20) NOT NULL,
    glacier_name text,
    wgms_id character varying(30),
    local_glacier_id character varying(30),
    parent_icemass_id character varying(20),
    record_status character varying(20),
    glac_static_points data.geometry,
    glacier_status character varying(20),
    submission_id integer,
    id_num integer NOT NULL,
    est_disappear_date date,
    est_disappear_unc integer,
    CONSTRAINT enforce_dims_glac_static_points CHECK ((data.st_ndims(glac_static_points) = 3)),
    CONSTRAINT enforce_geotype_glac_static_points CHECK (((data.geometrytype(glac_static_points) = 'POINT'::text) OR (glac_static_points IS NULL))),
    CONSTRAINT enforce_srid_glac_static_points CHECK ((data.st_srid(glac_static_points) = 4326))
);


ALTER TABLE data.glacier_static OWNER TO braup;

--
-- Name: extinct_glaciers_view; Type: VIEW; Schema: data; Owner: braup
--

CREATE VIEW data.extinct_glaciers_view AS
 SELECT glacier_static.glac_static_points AS glac_points,
    glacier_static.glacier_name AS glac_name,
    glacier_static.glacier_id AS glac_id,
    glacier_static.wgms_id,
    glacier_static.local_glacier_id AS local_id,
    glacier_static.glacier_status AS glac_stat,
    glacier_static.est_disappear_date AS gone_date,
    glacier_static.est_disappear_unc AS gone_dt_e
   FROM data.glacier_static
  WHERE ((glacier_static.glacier_status)::text = 'gone'::text);


ALTER TABLE data.extinct_glaciers_view OWNER TO braup;

--
-- Name: form_valids; Type: TABLE; Schema: data; Owner: braup
--

CREATE TABLE data.form_valids (
    form integer NOT NULL,
    description text
);


ALTER TABLE data.form_valids OWNER TO braup;

--
-- Name: frontal_characteristics_valids; Type: TABLE; Schema: data; Owner: braup
--

CREATE TABLE data.frontal_characteristics_valids (
    frontal_characteristics integer NOT NULL,
    description text
);


ALTER TABLE data.frontal_characteristics_valids OWNER TO braup;

--
-- Name: glacier_countries; Type: TABLE; Schema: data; Owner: braup
--

CREATE TABLE data.glacier_countries (
    glacier_id character varying(20) NOT NULL,
    country_id integer NOT NULL
);


ALTER TABLE data.glacier_countries OWNER TO braup;

--
-- Name: glacier_dynamic; Type: TABLE; Schema: data; Owner: braup
--

CREATE TABLE data.glacier_dynamic (
    analysis_id integer NOT NULL,
    glacier_id character varying(20) NOT NULL,
    analysis_timestamp timestamp without time zone NOT NULL,
    rc_id integer NOT NULL,
    contact_id integer NOT NULL,
    three_d_desc text,
    width real,
    length real,
    area real,
    abzone_area real,
    speed real,
    snowline_elev real,
    ela real,
    ela_desc text,
    primary_classification smallint,
    primary_classification2 smallint,
    form smallint,
    frontal_characteristics smallint,
    frontal_characteristics2 smallint,
    longitudinal_characteristics smallint,
    dominant_mass_source smallint,
    tongue_activity smallint,
    tongue_activity2 smallint,
    moraine_code1 smallint,
    moraine_code2 smallint,
    debris_cover smallint,
    record_status character varying(20),
    icesheet_conn_level smallint,
    source_timestamp timestamp without time zone NOT NULL,
    min_elev integer,
    mean_elev integer,
    max_elev integer,
    orientation_accum numeric(5,2),
    basin_code character(5),
    num_basins integer,
    avg_slope real,
    db_calculated_area real,
    submission_id integer,
    orientation_ablat numeric(5,2),
    thickness_m real,
    orientation numeric(5,2),
    median_elev integer,
    rgiid character(18),
    rgi_glactype character(4),
    rgi_join_count integer,
    rgi_maxlength_m integer,
    gtng_o1region integer,
    gtng_o2region integer,
    rgiflag character(4),
    src_time_end timestamp without time zone,
    surge_type integer,
    term_type integer
);


ALTER TABLE data.glacier_dynamic OWNER TO braup;

--
-- Name: glacier_image_info; Type: TABLE; Schema: data; Owner: braup
--

CREATE TABLE data.glacier_image_info (
    analysis_id integer NOT NULL,
    image_id integer NOT NULL
);


ALTER TABLE data.glacier_image_info OWNER TO braup;

--
-- Name: people; Type: TABLE; Schema: data; Owner: braup
--

CREATE TABLE data.people (
    contact_id integer NOT NULL,
    surname text,
    givennames text,
    prof_title text,
    affiliation text,
    department text,
    address1 text,
    address2 text,
    city text,
    state_province text,
    postal_code text,
    country_code character(2),
    office_loc text,
    url_primary text,
    url_additional text,
    workphone_primary text,
    workphone_additional text,
    workfax text,
    homephone text,
    mobilephone text,
    email_primary text,
    email_additional text,
    prof_interest text,
    glims_role text,
    add_date date,
    mod_date date,
    affiliation_points data.geometry,
    principal_flag boolean,
    comment text,
    status integer,
    CONSTRAINT enforce_dims_affiliation_points CHECK ((data.st_ndims(affiliation_points) = 3)),
    CONSTRAINT enforce_geotype_affiliation_points CHECK (((data.geometrytype(affiliation_points) = 'POINT'::text) OR (affiliation_points IS NULL))),
    CONSTRAINT enforce_srid_affiliation_points CHECK ((data.st_srid(affiliation_points) = 4326))
);


ALTER TABLE data.people OWNER TO braup;

--
-- Name: regional_centers; Type: TABLE; Schema: data; Owner: braup
--

CREATE TABLE data.regional_centers (
    rc_id integer NOT NULL,
    parent_rc integer,
    geog_area text,
    chief integer,
    main_contact integer,
    url_primary text,
    url_additional text,
    mou_status text,
    comments text,
    sort_key text,
    password text,
    regional_center_polys data.geometry,
    status integer,
    CONSTRAINT enforce_geotype_regional_center_polys CHECK (((data.geometrytype(regional_center_polys) = 'POLYGON'::text) OR (regional_center_polys IS NULL))),
    CONSTRAINT enforce_srid_regional_center_polys CHECK ((data.st_srid(regional_center_polys) = 4326))
);


ALTER TABLE data.regional_centers OWNER TO braup;

--
-- Name: submission_info; Type: TABLE; Schema: data; Owner: braup
--

CREATE TABLE data.submission_info (
    submission_id integer NOT NULL,
    submitter_id integer NOT NULL,
    rc_id integer NOT NULL,
    file_name text NOT NULL,
    file_size integer NOT NULL,
    submission_time timestamp without time zone NOT NULL,
    geocoding_with_image boolean,
    georegistration_gpcs boolean,
    orthorectification_dem_dtm boolean,
    dn_radiance_conversion boolean,
    sun_elev_correction boolean,
    image_radiometric_correction boolean,
    model_radiometric_correction boolean,
    anisotropic_reflectance boolean,
    slope_aspect_correction boolean,
    band_ratio_linear_trans boolean,
    spatial_filtering boolean,
    geomorphological_analysis boolean,
    texture_analysis boolean,
    manual_digitization boolean,
    percent_manual_editing character varying(20),
    supervised_classification boolean,
    supervised_title character varying(50),
    unsupervised_classification boolean,
    unsupervised_title character varying(50),
    process_description text,
    analysis_tools text,
    analysis_tools_other text,
    embargo_period character varying(50),
    region_label text,
    ingest_time timestamp without time zone NOT NULL,
    ingest_sw_version character varying(10),
    xfer_spec_version character varying(10),
    release_okay_date timestamp without time zone
);


ALTER TABLE data.submission_info OWNER TO braup;

--
-- Name: submission_rc_info; Type: VIEW; Schema: data; Owner: postgres
--

CREATE VIEW data.submission_rc_info AS
 SELECT submission_info.submission_id,
    submission_info.rc_id,
    people.surname AS chief_surn,
    people.givennames AS chief_givn,
    people.affiliation AS chief_affl,
    regional_centers.url_primary,
    regional_centers.geog_area,
    people.country_code
   FROM data.submission_info,
    data.people,
    data.regional_centers
  WHERE ((submission_info.rc_id = regional_centers.rc_id) AND (regional_centers.chief = people.contact_id));


ALTER TABLE data.submission_rc_info OWNER TO postgres;

--
-- Name: glacier_entities; Type: TABLE; Schema: data; Owner: braup
--

CREATE TABLE data.glacier_entities (
    analysis_id integer NOT NULL,
    line_type text NOT NULL,
    entity_geom data.geometry NOT NULL,
    CONSTRAINT enforce_srid_entity_geom CHECK ((data.st_srid(entity_geom) = 4326))
);


ALTER TABLE data.glacier_entities OWNER TO braup;

--
-- Name: glacier_lines_disp; Type: VIEW; Schema: data; Owner: postgres
--

CREATE VIEW data.glacier_lines_disp AS
 SELECT glacier_entities.entity_geom,
    glacier_entities.analysis_id AS anlys_id,
    glacier_entities.line_type,
    glacier_dynamic.glacier_id AS glac_id,
    glacier_dynamic.record_status AS rec_status,
    glacier_dynamic.source_timestamp AS src_date
   FROM data.glacier_entities,
    data.glacier_dynamic
  WHERE ((glacier_entities.analysis_id = glacier_dynamic.analysis_id) AND ((glacier_dynamic.record_status)::text = 'okay'::text));


ALTER TABLE data.glacier_lines_disp OWNER TO postgres;

--
-- Name: glacier_map_info; Type: TABLE; Schema: data; Owner: braup
--

CREATE TABLE data.glacier_map_info (
    analysis_id integer NOT NULL,
    map_id integer NOT NULL
);


ALTER TABLE data.glacier_map_info OWNER TO braup;

--
-- Name: submission_analyst; Type: TABLE; Schema: data; Owner: braup
--

CREATE TABLE data.submission_analyst (
    submission_id integer NOT NULL,
    analyst_id integer NOT NULL,
    sort_order integer
);


ALTER TABLE data.submission_analyst OWNER TO braup;

--
-- Name: submission_anlst_names; Type: VIEW; Schema: data; Owner: postgres
--

CREATE VIEW data.submission_anlst_names AS
 SELECT submission_info.submission_id,
    people.surname,
    people.givennames,
    people.affiliation,
    people.url_primary,
    people.country_code
   FROM data.submission_info,
    data.people,
    data.submission_analyst
  WHERE ((submission_info.submission_id = submission_analyst.submission_id) AND (submission_analyst.analyst_id = people.contact_id));


ALTER TABLE data.submission_anlst_names OWNER TO postgres;

--
-- Name: submission_submitter; Type: VIEW; Schema: data; Owner: postgres
--

CREATE VIEW data.submission_submitter AS
 SELECT submission_info.submission_id,
    people.surname,
    people.givennames,
    people.affiliation,
    people.url_primary,
    people.country_code
   FROM data.submission_info,
    data.people
  WHERE (submission_info.submitter_id = people.contact_id);


ALTER TABLE data.submission_submitter OWNER TO postgres;

--
-- Name: glacier_query_no_people; Type: VIEW; Schema: data; Owner: braup
--

CREATE VIEW data.glacier_query_no_people AS
 SELECT glacier_entities.entity_geom AS glac_polys,
    glacier_entities.line_type,
    glacier_dynamic.analysis_id AS anlys_id,
    glacier_dynamic.glacier_id AS glac_id,
    glacier_dynamic.analysis_timestamp AS anlys_time,
    glacier_dynamic.area,
    glacier_dynamic.db_calculated_area AS db_area,
    glacier_dynamic.width,
    glacier_dynamic.length,
    glacier_dynamic.primary_classification AS primeclass,
    glacier_dynamic.min_elev,
    glacier_dynamic.mean_elev,
    glacier_dynamic.max_elev,
    glacier_dynamic.source_timestamp AS src_date,
    glacier_dynamic.record_status AS rec_status,
    glacier_dynamic.icesheet_conn_level AS conn_lvl,
    glacier_static.glacier_name AS glac_name,
    glacier_static.wgms_id,
    glacier_static.local_glacier_id AS local_id,
    glacier_static.glacier_status AS glac_stat,
    submission_info.submission_id AS subm_id,
    submission_info.release_okay_date AS release_dt,
    submission_info.process_description AS proc_desc,
    submission_info.rc_id,
    submission_rc_info.geog_area,
    submission_rc_info.chief_affl,
    glacier_static.parent_icemass_id AS parent_id
   FROM data.glacier_entities,
    data.glacier_dynamic,
    data.glacier_static,
    data.submission_info,
    data.submission_rc_info
  WHERE ((glacier_entities.analysis_id = glacier_dynamic.analysis_id) AND ((glacier_dynamic.glacier_id)::text = (glacier_static.glacier_id)::text) AND (glacier_dynamic.submission_id = submission_info.submission_id) AND (submission_info.submission_id = submission_rc_info.submission_id) AND ((glacier_dynamic.record_status)::text = 'okay'::text));


ALTER TABLE data.glacier_query_no_people OWNER TO braup;

--
-- Name: glacier_reference; Type: TABLE; Schema: data; Owner: braup
--

CREATE TABLE data.glacier_reference (
    glacier_id character varying(20) NOT NULL,
    reference_doc_id integer NOT NULL
);


ALTER TABLE data.glacier_reference OWNER TO braup;

--
-- Name: glacier_static_id_num_seq1; Type: SEQUENCE; Schema: data; Owner: braup
--

CREATE SEQUENCE data.glacier_static_id_num_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE data.glacier_static_id_num_seq1 OWNER TO braup;

--
-- Name: glacier_static_id_num_seq1; Type: SEQUENCE OWNED BY; Schema: data; Owner: braup
--

ALTER SEQUENCE data.glacier_static_id_num_seq1 OWNED BY data.glacier_static.id_num;


--
-- Name: glims_v2_field_dictionary; Type: TABLE; Schema: data; Owner: braup
--

CREATE TABLE data.glims_field_dictionary (
    field_name character varying(100) NOT NULL,
    short_name character varying(100),
    display_name character varying(100),
    description text,
    shapefile character varying(50),
    sort_order integer
);


ALTER TABLE data.glims_field_dictionary OWNER TO braup;

--
-- Name: glims_v2_table_fields; Type: TABLE; Schema: data; Owner: braup
--

CREATE TABLE data.glims_table_fields (
    table_name character varying(100) NOT NULL,
    field_name character varying(100) NOT NULL
);


ALTER TABLE data.glims_table_fields OWNER TO braup;

--
-- Name: gtng_order1regions; Type: TABLE; Schema: data; Owner: braup
--

CREATE TABLE data.gtng_order1regions (
    gid integer NOT NULL,
    full_name character varying(80),
    rgi_code integer,
    wgms_code character varying(80),
    geom data.geometry(MultiPolygon,4326)
);


ALTER TABLE data.gtng_order1regions OWNER TO braup;

--
-- Name: gtng_order1regions_gid_seq; Type: SEQUENCE; Schema: data; Owner: braup
--

CREATE SEQUENCE data.gtng_order1regions_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE data.gtng_order1regions_gid_seq OWNER TO braup;

--
-- Name: gtng_order1regions_gid_seq; Type: SEQUENCE OWNED BY; Schema: data; Owner: braup
--

ALTER SEQUENCE data.gtng_order1regions_gid_seq OWNED BY data.gtng_order1regions.gid;


--
-- Name: gtng_order2regions; Type: TABLE; Schema: data; Owner: braup
--

CREATE TABLE data.gtng_order2regions (
    gid integer NOT NULL,
    full_name character varying(80),
    rgi_code character varying(80),
    wgms_code character varying(80),
    geom data.geometry(MultiPolygon,4326)
);


ALTER TABLE data.gtng_order2regions OWNER TO braup;

--
-- Name: gtng_order2regions_gid_seq; Type: SEQUENCE; Schema: data; Owner: braup
--

CREATE SEQUENCE data.gtng_order2regions_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE data.gtng_order2regions_gid_seq OWNER TO braup;

--
-- Name: gtng_order2regions_gid_seq; Type: SEQUENCE OWNED BY; Schema: data; Owner: braup
--

ALTER SEQUENCE data.gtng_order2regions_gid_seq OWNED BY data.gtng_order2regions.gid;


--
-- Name: image; Type: TABLE; Schema: data; Owner: braup
--

CREATE TABLE data.image (
    image_id integer NOT NULL,
    instrument_id integer NOT NULL,
    orig_id character varying(100),
    is_mosaic boolean,
    mosaic_id integer,
    image_loc_url text,
    acq_timestamp timestamp without time zone,
    image_center_lon_unc double precision,
    image_center_lat_unc double precision,
    image_azim double precision,
    cloud_pct double precision,
    sun_azim double precision,
    sun_elev double precision,
    instrument_zenith double precision,
    instrument_azimuth double precision,
    projection text,
    image_center_loc data.geometry,
    comment text,
    CONSTRAINT enforce_dims_image_center_loc CHECK ((data.st_ndims(image_center_loc) = 3)),
    CONSTRAINT enforce_geotype_image_center_loc CHECK (((data.geometrytype(image_center_loc) = 'POINT'::text) OR (image_center_loc IS NULL))),
    CONSTRAINT enforce_srid_image_center_loc CHECK ((data.st_srid(image_center_loc) = 4326))
);


ALTER TABLE data.image OWNER TO braup;

--
-- Name: instrument; Type: TABLE; Schema: data; Owner: braup
--

CREATE TABLE data.instrument (
    instrument_id integer NOT NULL,
    instrument_long_name text NOT NULL,
    instrument_short_name character varying(10),
    instrument_platform_name character varying(50),
    altitude_km double precision,
    inclination double precision,
    num_bands integer,
    band_list text,
    eq_crossing_time time without time zone,
    start_date date,
    end_date date
);


ALTER TABLE data.instrument OWNER TO braup;

--
-- Name: image_info_view; Type: VIEW; Schema: data; Owner: braup
--

CREATE VIEW data.image_info_view AS
 SELECT image.image_id,
    instrument.instrument_short_name,
    image.orig_id,
    image.is_mosaic,
    image.mosaic_id,
    image.image_loc_url,
    image.acq_timestamp,
    image.image_azim,
    image.cloud_pct,
    image.sun_azim,
    image.sun_elev,
    image.instrument_zenith,
    image.instrument_azimuth,
    image.projection,
    data.st_astext(image.image_center_loc) AS image_center_loc,
    image.comment
   FROM data.image,
    data.instrument
  WHERE (image.instrument_id = instrument.instrument_id);


ALTER TABLE data.image_info_view OWNER TO braup;

--
-- Name: lon_char_valids; Type: TABLE; Schema: data; Owner: braup
--

CREATE TABLE data.lon_char_valids (
    longitudinal_characteristics integer NOT NULL,
    description text
);


ALTER TABLE data.lon_char_valids OWNER TO braup;

--
-- Name: map_metadata; Type: TABLE; Schema: data; Owner: braup
--

CREATE TABLE data.map_metadata (
    map_id integer NOT NULL,
    area_interest text,
    title text,
    author_publisher text,
    pub_date date,
    pub_location text,
    scale character varying(50),
    units_system character varying(20),
    projection text,
    series_edition text,
    sheet_number character varying(20),
    comment text,
    submission_id integer,
    asof_date date,
    user_map_id character varying(80)
);


ALTER TABLE data.map_metadata OWNER TO braup;

--
-- Name: primary_classification_valids; Type: TABLE; Schema: data; Owner: braup
--

CREATE TABLE data.primary_classification_valids (
    primary_classification integer NOT NULL,
    description character varying(30)
);


ALTER TABLE data.primary_classification_valids OWNER TO braup;

--
-- Name: rc_people; Type: TABLE; Schema: data; Owner: braup
--

CREATE TABLE data.rc_people (
    rc_id integer,
    contact_id integer,
    status integer
);


ALTER TABLE data.rc_people OWNER TO braup;

--
-- Name: rc_people_nocoords; Type: VIEW; Schema: data; Owner: braup
--

CREATE VIEW data.rc_people_nocoords AS
 SELECT rc_people.contact_id,
    rc_people.rc_id,
    people.surname,
    people.givennames,
    people.prof_title,
    people.affiliation,
    people.department,
    people.address1,
    people.address2,
    people.city,
    people.state_province,
    people.postal_code,
    people.country_code,
    people.office_loc,
    people.url_primary,
    people.url_additional,
    people.workphone_primary,
    people.workphone_additional,
    people.workfax,
    people.homephone,
    people.mobilephone,
    people.email_primary,
    people.email_additional,
    people.prof_interest,
    people.glims_role,
    people.add_date,
    people.mod_date,
    data.st_astext(people.affiliation_points) AS affiliation_points,
    regional_centers.parent_rc,
    regional_centers.geog_area,
    regional_centers.chief,
    regional_centers.main_contact,
    regional_centers.url_primary AS rc_url_prime,
    regional_centers.url_additional AS rc_url_add,
    regional_centers.mou_status,
    regional_centers.comments,
    regional_centers.sort_key,
    regional_centers.password
   FROM ((data.rc_people
     JOIN data.people ON ((rc_people.contact_id = people.contact_id)))
     JOIN data.regional_centers ON ((regional_centers.rc_id = rc_people.rc_id)));


ALTER TABLE data.rc_people_nocoords OWNER TO braup;

--
-- Name: rc_people_view; Type: VIEW; Schema: data; Owner: postgres
--

CREATE VIEW data.rc_people_view AS
 SELECT rc_people.contact_id,
    rc_people.rc_id,
    people.surname,
    people.givennames,
    people.prof_title,
    people.affiliation,
    people.department,
    people.address1,
    people.address2,
    people.city,
    people.state_province,
    people.postal_code,
    people.country_code,
    people.office_loc,
    people.url_primary,
    people.url_additional,
    people.workphone_primary,
    people.workphone_additional,
    people.workfax,
    people.homephone,
    people.mobilephone,
    people.email_primary,
    people.email_additional,
    people.prof_interest,
    people.glims_role,
    people.add_date,
    people.mod_date,
    people.affiliation_points,
    regional_centers.parent_rc,
    regional_centers.geog_area,
    regional_centers.chief,
    regional_centers.main_contact,
    regional_centers.url_primary AS rc_url_prime,
    regional_centers.url_additional AS rc_url_add,
    regional_centers.mou_status,
    regional_centers.comments,
    regional_centers.sort_key,
    regional_centers.password,
    regional_centers.regional_center_polys,
    rc_people.status AS rcp_status,
    people.status AS p_status,
    people.principal_flag
   FROM ((data.rc_people
     JOIN data.people ON ((rc_people.contact_id = people.contact_id)))
     JOIN data.regional_centers ON ((regional_centers.rc_id = rc_people.rc_id)));


ALTER TABLE data.rc_people_view OWNER TO postgres;

--
-- Name: reference_document; Type: TABLE; Schema: data; Owner: braup
--

CREATE TABLE data.reference_document (
    reference_doc_id integer NOT NULL,
    header_comments text,
    citation_type text,
    author_names text,
    corp_author text,
    title text,
    series text,
    journal text,
    bookname text,
    report_type text,
    volume character varying(15),
    num character varying(15),
    editor text,
    pages character varying(15),
    publisher text,
    city_of_publisher text,
    year integer,
    month integer,
    day integer,
    other_info_post_ref text,
    keywords text,
    label character varying(30),
    url text,
    abstract text,
    doc_filename character varying(120),
    chapter text,
    edition character varying(10),
    main_glims_pub boolean,
    doi character(50)
);


ALTER TABLE data.reference_document OWNER TO braup;

--
-- Name: ref_doc_id_seq; Type: SEQUENCE; Schema: data; Owner: braup
--

CREATE SEQUENCE data.ref_doc_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE data.ref_doc_id_seq OWNER TO braup;

--
-- Name: ref_doc_id_seq; Type: SEQUENCE OWNED BY; Schema: data; Owner: braup
--

ALTER SEQUENCE data.ref_doc_id_seq OWNED BY data.reference_document.reference_doc_id;


--
-- Name: status_def; Type: TABLE; Schema: data; Owner: braup
--

CREATE TABLE data.status_def (
    id integer,
    status_defn character(20),
    comment character varying
);


ALTER TABLE data.status_def OWNER TO braup;

--
-- Name: tongue_activity_valids; Type: TABLE; Schema: data; Owner: braup
--

CREATE TABLE data.tongue_activity_valids (
    tongue_activity integer NOT NULL,
    description character varying(30)
);


ALTER TABLE data.tongue_activity_valids OWNER TO braup;

--
-- Name: country gid; Type: DEFAULT; Schema: data; Owner: braup
--

ALTER TABLE ONLY data.country ALTER COLUMN gid SET DEFAULT nextval('data.country_gid_seq'::regclass);


--
-- Name: glacier_static id_num; Type: DEFAULT; Schema: data; Owner: braup
--

ALTER TABLE ONLY data.glacier_static ALTER COLUMN id_num SET DEFAULT nextval('data.glacier_static_id_num_seq1'::regclass);


--
-- Name: gtng_order1regions gid; Type: DEFAULT; Schema: data; Owner: braup
--

ALTER TABLE ONLY data.gtng_order1regions ALTER COLUMN gid SET DEFAULT nextval('data.gtng_order1regions_gid_seq'::regclass);


--
-- Name: gtng_order2regions gid; Type: DEFAULT; Schema: data; Owner: braup
--

ALTER TABLE ONLY data.gtng_order2regions ALTER COLUMN gid SET DEFAULT nextval('data.gtng_order2regions_gid_seq'::regclass);


--
-- Name: reference_document reference_doc_id; Type: DEFAULT; Schema: data; Owner: braup
--

ALTER TABLE ONLY data.reference_document ALTER COLUMN reference_doc_id SET DEFAULT nextval('data.ref_doc_id_seq'::regclass);


--
-- Name: area_histogram area_histogram_pkey; Type: CONSTRAINT; Schema: data; Owner: braup
--

ALTER TABLE ONLY data.area_histogram
    ADD CONSTRAINT area_histogram_pkey PRIMARY KEY (area_histogram_id);


--
-- Name: country country_gid_key; Type: CONSTRAINT; Schema: data; Owner: braup
--

ALTER TABLE ONLY data.country
    ADD CONSTRAINT country_gid_key UNIQUE (gid);


--
-- Name: country country_pkey; Type: CONSTRAINT; Schema: data; Owner: braup
--

ALTER TABLE ONLY data.country
    ADD CONSTRAINT country_pkey PRIMARY KEY (country_code2);


--
-- Name: dominant_mass_source_valids dominant_mass_source_valids_pkey; Type: CONSTRAINT; Schema: data; Owner: braup
--

ALTER TABLE ONLY data.dominant_mass_source_valids
    ADD CONSTRAINT dominant_mass_source_valids_pkey PRIMARY KEY (dominant_mass_source);


--
-- Name: form_valids form_valids_pkey; Type: CONSTRAINT; Schema: data; Owner: braup
--

ALTER TABLE ONLY data.form_valids
    ADD CONSTRAINT form_valids_pkey PRIMARY KEY (form);


--
-- Name: frontal_characteristics_valids frontal_characteristics_valids_pkey; Type: CONSTRAINT; Schema: data; Owner: braup
--

ALTER TABLE ONLY data.frontal_characteristics_valids
    ADD CONSTRAINT frontal_characteristics_valids_pkey PRIMARY KEY (frontal_characteristics);


--
-- Name: glacier_countries glacier_countries_pkey; Type: CONSTRAINT; Schema: data; Owner: braup
--

ALTER TABLE ONLY data.glacier_countries
    ADD CONSTRAINT glacier_countries_pkey PRIMARY KEY (glacier_id, country_id);


--
-- Name: glacier_dynamic glacier_dynamic_pkey; Type: CONSTRAINT; Schema: data; Owner: braup
--

ALTER TABLE ONLY data.glacier_dynamic
    ADD CONSTRAINT glacier_dynamic_pkey PRIMARY KEY (analysis_id);


--
-- Name: glacier_static glacier_static_pkey; Type: CONSTRAINT; Schema: data; Owner: braup
--

ALTER TABLE ONLY data.glacier_static
    ADD CONSTRAINT glacier_static_pkey PRIMARY KEY (glacier_id);


--
-- Name: gtng_order1regions gtng_order1regions_pkey; Type: CONSTRAINT; Schema: data; Owner: braup
--

ALTER TABLE ONLY data.gtng_order1regions
    ADD CONSTRAINT gtng_order1regions_pkey PRIMARY KEY (gid);


--
-- Name: gtng_order2regions gtng_order2regions_pkey; Type: CONSTRAINT; Schema: data; Owner: braup
--

ALTER TABLE ONLY data.gtng_order2regions
    ADD CONSTRAINT gtng_order2regions_pkey PRIMARY KEY (gid);


--
-- Name: image image_pkey; Type: CONSTRAINT; Schema: data; Owner: braup
--

ALTER TABLE ONLY data.image
    ADD CONSTRAINT image_pkey PRIMARY KEY (image_id);


--
-- Name: instrument instrument_pkey; Type: CONSTRAINT; Schema: data; Owner: braup
--

ALTER TABLE ONLY data.instrument
    ADD CONSTRAINT instrument_pkey PRIMARY KEY (instrument_id);


--
-- Name: lon_char_valids lon_char_valids_pkey; Type: CONSTRAINT; Schema: data; Owner: braup
--

ALTER TABLE ONLY data.lon_char_valids
    ADD CONSTRAINT lon_char_valids_pkey PRIMARY KEY (longitudinal_characteristics);


--
-- Name: map_metadata map_metadata_pkey; Type: CONSTRAINT; Schema: data; Owner: braup
--

ALTER TABLE ONLY data.map_metadata
    ADD CONSTRAINT map_metadata_pkey PRIMARY KEY (map_id);


--
-- Name: people people_pkey; Type: CONSTRAINT; Schema: data; Owner: braup
--

ALTER TABLE ONLY data.people
    ADD CONSTRAINT people_pkey PRIMARY KEY (contact_id);


--
-- Name: primary_classification_valids primary_classification_valids_pkey; Type: CONSTRAINT; Schema: data; Owner: braup
--

ALTER TABLE ONLY data.primary_classification_valids
    ADD CONSTRAINT primary_classification_valids_pkey PRIMARY KEY (primary_classification);


--
-- Name: reference_document reference_document_pkey; Type: CONSTRAINT; Schema: data; Owner: braup
--

ALTER TABLE ONLY data.reference_document
    ADD CONSTRAINT reference_document_pkey PRIMARY KEY (reference_doc_id);


--
-- Name: regional_centers regional_centers_pkey; Type: CONSTRAINT; Schema: data; Owner: braup
--

ALTER TABLE ONLY data.regional_centers
    ADD CONSTRAINT regional_centers_pkey PRIMARY KEY (rc_id);


--
-- Name: submission_info submission_info_pkey; Type: CONSTRAINT; Schema: data; Owner: braup
--

ALTER TABLE ONLY data.submission_info
    ADD CONSTRAINT submission_info_pkey PRIMARY KEY (submission_id);


--
-- Name: tongue_activity_valids tongue_activity_valids_pkey; Type: CONSTRAINT; Schema: data; Owner: braup
--

ALTER TABLE ONLY data.tongue_activity_valids
    ADD CONSTRAINT tongue_activity_valids_pkey PRIMARY KEY (tongue_activity);


--
-- Name: cntry_name_index; Type: INDEX; Schema: data; Owner: braup
--

CREATE INDEX cntry_name_index ON data.country USING btree (cntry_name);


--
-- Name: country_index; Type: INDEX; Schema: data; Owner: braup
--

CREATE INDEX country_index ON data.country USING gist (borders);


--
-- Name: glac_dyn_submission_id_index; Type: INDEX; Schema: data; Owner: braup
--

CREATE INDEX glac_dyn_submission_id_index ON data.glacier_dynamic USING btree (submission_id);


--
-- Name: glacier_dynamic_glacier_id; Type: INDEX; Schema: data; Owner: braup
--

CREATE INDEX glacier_dynamic_glacier_id ON data.glacier_dynamic USING btree (glacier_id);


--
-- Name: glacier_dynamic_record_status; Type: INDEX; Schema: data; Owner: braup
--

CREATE INDEX glacier_dynamic_record_status ON data.glacier_dynamic USING btree (record_status);


--
-- Name: glacier_dynamic_source_timestamp; Type: INDEX; Schema: data; Owner: braup
--

CREATE INDEX glacier_dynamic_source_timestamp ON data.glacier_dynamic USING btree (source_timestamp);


--
-- Name: glacier_poly_index; Type: INDEX; Schema: data; Owner: braup
--

CREATE INDEX glacier_poly_index ON data.glacier_entities USING gist (entity_geom);

ALTER TABLE data.glacier_entities CLUSTER ON glacier_poly_index;


--
-- Name: glacier_entities_anal_id_index; Type: INDEX; Schema: data; Owner: braup
--

CREATE INDEX glacier_entities_anal_id_index ON data.glacier_entities USING btree (analysis_id);


--
-- Name: glacier_static_point_index; Type: INDEX; Schema: data; Owner: braup
--

CREATE INDEX glacier_static_point_index ON data.glacier_static USING gist (glac_static_points);


--
-- Name: gtng_order1regions_geom_idx; Type: INDEX; Schema: data; Owner: braup
--

CREATE INDEX gtng_order1regions_geom_idx ON data.gtng_order1regions USING gist (geom);


--
-- Name: gtng_order2regions_geom_idx; Type: INDEX; Schema: data; Owner: braup
--

CREATE INDEX gtng_order2regions_geom_idx ON data.gtng_order2regions USING gist (geom);


--
-- Name: id_num_idx; Type: INDEX; Schema: data; Owner: braup
--

CREATE INDEX id_num_idx ON data.glacier_static USING btree (id_num);


--
-- Name: people_affiliation_index; Type: INDEX; Schema: data; Owner: braup
--

CREATE INDEX people_affiliation_index ON data.people USING btree (affiliation);


--
-- Name: people_ccode_index; Type: INDEX; Schema: data; Owner: braup
--

CREATE INDEX people_ccode_index ON data.people USING btree (country_code);


--
-- Name: people_givennames_index; Type: INDEX; Schema: data; Owner: braup
--

CREATE INDEX people_givennames_index ON data.people USING btree (givennames);


--
-- Name: people_points_index; Type: INDEX; Schema: data; Owner: braup
--

CREATE INDEX people_points_index ON data.people USING gist (affiliation_points);


--
-- Name: people_surname_index; Type: INDEX; Schema: data; Owner: braup
--

CREATE INDEX people_surname_index ON data.people USING btree (surname);


--
-- Name: people_url_primary_index; Type: INDEX; Schema: data; Owner: braup
--

CREATE INDEX people_url_primary_index ON data.people USING btree (url_primary);


--
-- Name: rc_poly_index; Type: INDEX; Schema: data; Owner: braup
--

CREATE INDEX rc_poly_index ON data.regional_centers USING gist (regional_center_polys);


--
-- Name: submission_info_rc_id_index; Type: INDEX; Schema: data; Owner: braup
--

CREATE INDEX submission_info_rc_id_index ON data.submission_info USING btree (rc_id);


--
-- Name: submission_info_rel_okay_date_index; Type: INDEX; Schema: data; Owner: braup
--

CREATE INDEX submission_info_rel_okay_date_index ON data.submission_info USING btree (release_okay_date);


--
-- Name: submission_info_submitter_id_index; Type: INDEX; Schema: data; Owner: braup
--

CREATE INDEX submission_info_submitter_id_index ON data.submission_info USING btree (submitter_id);


--
-- Name: area_histogram area_histogram_analysis_id_fkey; Type: FK CONSTRAINT; Schema: data; Owner: braup
--

ALTER TABLE ONLY data.area_histogram
    ADD CONSTRAINT area_histogram_analysis_id_fkey FOREIGN KEY (analysis_id) REFERENCES data.glacier_dynamic(analysis_id);


--
-- Name: area_histogram_data area_histogram_data_area_histogram_id_fkey; Type: FK CONSTRAINT; Schema: data; Owner: braup
--

ALTER TABLE ONLY data.area_histogram_data
    ADD CONSTRAINT area_histogram_data_area_histogram_id_fkey FOREIGN KEY (area_histogram_id) REFERENCES data.area_histogram(area_histogram_id);


--
-- Name: glacier_countries glacier_countries_country_id_fkey; Type: FK CONSTRAINT; Schema: data; Owner: braup
--

ALTER TABLE ONLY data.glacier_countries
    ADD CONSTRAINT glacier_countries_country_id_fkey FOREIGN KEY (country_id) REFERENCES data.country(gid);


--
-- Name: glacier_countries glacier_countries_glacier_id_fkey; Type: FK CONSTRAINT; Schema: data; Owner: braup
--

ALTER TABLE ONLY data.glacier_countries
    ADD CONSTRAINT glacier_countries_glacier_id_fkey FOREIGN KEY (glacier_id) REFERENCES data.glacier_static(glacier_id);


--
-- Name: glacier_dynamic glacier_dynamic_contact_id_fkey; Type: FK CONSTRAINT; Schema: data; Owner: braup
--

ALTER TABLE ONLY data.glacier_dynamic
    ADD CONSTRAINT glacier_dynamic_contact_id_fkey FOREIGN KEY (contact_id) REFERENCES data.people(contact_id);


--
-- Name: glacier_dynamic glacier_dynamic_glacier_id_fkey; Type: FK CONSTRAINT; Schema: data; Owner: braup
--

ALTER TABLE ONLY data.glacier_dynamic
    ADD CONSTRAINT glacier_dynamic_glacier_id_fkey FOREIGN KEY (glacier_id) REFERENCES data.glacier_static(glacier_id);


--
-- Name: glacier_dynamic glacier_dynamic_rc_id_fkey; Type: FK CONSTRAINT; Schema: data; Owner: braup
--

ALTER TABLE ONLY data.glacier_dynamic
    ADD CONSTRAINT glacier_dynamic_rc_id_fkey FOREIGN KEY (rc_id) REFERENCES data.regional_centers(rc_id);


--
-- Name: glacier_dynamic glacier_dynamic_submission_id_fkey; Type: FK CONSTRAINT; Schema: data; Owner: braup
--

ALTER TABLE ONLY data.glacier_dynamic
    ADD CONSTRAINT glacier_dynamic_submission_id_fkey FOREIGN KEY (submission_id) REFERENCES data.submission_info(submission_id);


--
-- Name: glacier_image_info glacier_image_info_analysis_id_fkey; Type: FK CONSTRAINT; Schema: data; Owner: braup
--

ALTER TABLE ONLY data.glacier_image_info
    ADD CONSTRAINT glacier_image_info_analysis_id_fkey FOREIGN KEY (analysis_id) REFERENCES data.glacier_dynamic(analysis_id);


--
-- Name: glacier_image_info glacier_image_info_image_id_fkey; Type: FK CONSTRAINT; Schema: data; Owner: braup
--

ALTER TABLE ONLY data.glacier_image_info
    ADD CONSTRAINT glacier_image_info_image_id_fkey FOREIGN KEY (image_id) REFERENCES data.image(image_id);


--
-- Name: glacier_map_info glacier_map_info_analysis_id_fkey; Type: FK CONSTRAINT; Schema: data; Owner: braup
--

ALTER TABLE ONLY data.glacier_map_info
    ADD CONSTRAINT glacier_map_info_analysis_id_fkey FOREIGN KEY (analysis_id) REFERENCES data.glacier_dynamic(analysis_id);


--
-- Name: glacier_map_info glacier_map_info_mad_id_fkey; Type: FK CONSTRAINT; Schema: data; Owner: braup
--

ALTER TABLE ONLY data.glacier_map_info
    ADD CONSTRAINT glacier_map_info_mad_id_fkey FOREIGN KEY (map_id) REFERENCES data.map_metadata(map_id);


--
-- Name: glacier_entities glacier_entities_analysis_id_fkey; Type: FK CONSTRAINT; Schema: data; Owner: braup
--

ALTER TABLE ONLY data.glacier_entities
    ADD CONSTRAINT glacier_entities_analysis_id_fkey FOREIGN KEY (analysis_id) REFERENCES data.glacier_dynamic(analysis_id);


--
-- Name: glacier_reference glacier_reference_glacier_id_fkey; Type: FK CONSTRAINT; Schema: data; Owner: braup
--

ALTER TABLE ONLY data.glacier_reference
    ADD CONSTRAINT glacier_reference_glacier_id_fkey FOREIGN KEY (glacier_id) REFERENCES data.glacier_static(glacier_id);


--
-- Name: glacier_reference glacier_reference_reference_doc_id_fkey; Type: FK CONSTRAINT; Schema: data; Owner: braup
--

ALTER TABLE ONLY data.glacier_reference
    ADD CONSTRAINT glacier_reference_reference_doc_id_fkey FOREIGN KEY (reference_doc_id) REFERENCES data.reference_document(reference_doc_id);


--
-- Name: glacier_static glacier_static_submission_id_fkey; Type: FK CONSTRAINT; Schema: data; Owner: braup
--

ALTER TABLE ONLY data.glacier_static
    ADD CONSTRAINT glacier_static_submission_id_fkey FOREIGN KEY (submission_id) REFERENCES data.submission_info(submission_id);


--
-- Name: image image_instrument_id_fkey; Type: FK CONSTRAINT; Schema: data; Owner: braup
--

ALTER TABLE ONLY data.image
    ADD CONSTRAINT image_instrument_id_fkey FOREIGN KEY (instrument_id) REFERENCES data.instrument(instrument_id);


--
-- Name: image image_mosaic_id_fkey; Type: FK CONSTRAINT; Schema: data; Owner: braup
--

ALTER TABLE ONLY data.image
    ADD CONSTRAINT image_mosaic_id_fkey FOREIGN KEY (mosaic_id) REFERENCES data.image(image_id);


--
-- Name: people people_country_code_fkey; Type: FK CONSTRAINT; Schema: data; Owner: braup
--

ALTER TABLE ONLY data.people
    ADD CONSTRAINT people_country_code_fkey FOREIGN KEY (country_code) REFERENCES data.country(country_code2);


--
-- Name: rc_people rc_people_contact_id_fkey; Type: FK CONSTRAINT; Schema: data; Owner: braup
--

ALTER TABLE ONLY data.rc_people
    ADD CONSTRAINT rc_people_contact_id_fkey FOREIGN KEY (contact_id) REFERENCES data.people(contact_id);


--
-- Name: rc_people rc_people_rc_id_fkey; Type: FK CONSTRAINT; Schema: data; Owner: braup
--

ALTER TABLE ONLY data.rc_people
    ADD CONSTRAINT rc_people_rc_id_fkey FOREIGN KEY (rc_id) REFERENCES data.regional_centers(rc_id);


--
-- Name: regional_centers regional_centers_chief_fkey; Type: FK CONSTRAINT; Schema: data; Owner: braup
--

ALTER TABLE ONLY data.regional_centers
    ADD CONSTRAINT regional_centers_chief_fkey FOREIGN KEY (chief) REFERENCES data.people(contact_id);


--
-- Name: regional_centers regional_centers_main_contact_fkey; Type: FK CONSTRAINT; Schema: data; Owner: braup
--

ALTER TABLE ONLY data.regional_centers
    ADD CONSTRAINT regional_centers_main_contact_fkey FOREIGN KEY (main_contact) REFERENCES data.people(contact_id);


--
-- Name: regional_centers regional_centers_parent_rc_fkey; Type: FK CONSTRAINT; Schema: data; Owner: braup
--

ALTER TABLE ONLY data.regional_centers
    ADD CONSTRAINT regional_centers_parent_rc_fkey FOREIGN KEY (parent_rc) REFERENCES data.regional_centers(rc_id);


--
-- Name: submission_analyst submission_analyst_analyst_id_fkey; Type: FK CONSTRAINT; Schema: data; Owner: braup
--

ALTER TABLE ONLY data.submission_analyst
    ADD CONSTRAINT submission_analyst_analyst_id_fkey FOREIGN KEY (analyst_id) REFERENCES data.people(contact_id);


--
-- Name: submission_analyst submission_analyst_submission_id_fkey; Type: FK CONSTRAINT; Schema: data; Owner: braup
--

ALTER TABLE ONLY data.submission_analyst
    ADD CONSTRAINT submission_analyst_submission_id_fkey FOREIGN KEY (submission_id) REFERENCES data.submission_info(submission_id);


--
-- Name: submission_info submission_info_rc_id_fkey; Type: FK CONSTRAINT; Schema: data; Owner: braup
--

ALTER TABLE ONLY data.submission_info
    ADD CONSTRAINT submission_info_rc_id_fkey FOREIGN KEY (rc_id) REFERENCES data.regional_centers(rc_id);


--
-- Name: submission_info submission_info_submitter_id_fkey; Type: FK CONSTRAINT; Schema: data; Owner: braup
--

ALTER TABLE ONLY data.submission_info
    ADD CONSTRAINT submission_info_submitter_id_fkey FOREIGN KEY (submitter_id) REFERENCES data.people(contact_id);


--
-- Name: DATABASE glims_v2; Type: ACL; Schema: -; Owner: braup
--

GRANT ALL ON SCHEMA data TO glims_rw;

REVOKE CONNECT,TEMPORARY ON DATABASE glims_v2 FROM PUBLIC;
GRANT CONNECT ON DATABASE glims_v2 TO glims_rc;
GRANT CONNECT,TEMPORARY ON DATABASE glims_v2 TO glims_ro;
GRANT CONNECT ON DATABASE glims_v2 TO aster_metadata;
GRANT ALL ON DATABASE glims_v2 TO glims_rw;
GRANT CONNECT ON DATABASE glims_v2 TO glu;
GRANT CONNECT ON DATABASE glims_v2 TO rgi_role;


--
-- Name: TABLE area_histogram; Type: ACL; Schema: data; Owner: braup
--

GRANT ALL ON TABLE data.area_histogram TO glims_rw;
GRANT SELECT ON TABLE data.area_histogram TO glims_rc;
GRANT SELECT ON TABLE data.area_histogram TO glims_ro;
GRANT SELECT ON TABLE data.area_histogram TO aster_metadata;
GRANT SELECT ON TABLE data.area_histogram TO glu;
GRANT SELECT ON TABLE data.area_histogram TO rgi_role;


--
-- Name: TABLE area_histogram_data; Type: ACL; Schema: data; Owner: braup
--

GRANT ALL ON TABLE data.area_histogram_data TO glims_rw;
GRANT SELECT ON TABLE data.area_histogram_data TO glims_rc;
GRANT SELECT ON TABLE data.area_histogram_data TO glims_ro;
GRANT SELECT ON TABLE data.area_histogram_data TO aster_metadata;
GRANT SELECT ON TABLE data.area_histogram_data TO glu;
GRANT SELECT ON TABLE data.area_histogram_data TO rgi_role;


--
-- Name: TABLE country; Type: ACL; Schema: data; Owner: braup
--

GRANT ALL ON TABLE data.country TO glims_rw;
GRANT SELECT ON TABLE data.country TO glims_rc;
GRANT SELECT ON TABLE data.country TO glims_ro;
GRANT SELECT ON TABLE data.country TO aster_metadata;
GRANT SELECT ON TABLE data.country TO glu;
GRANT SELECT ON TABLE data.country TO rgi_role;


--
-- Name: SEQUENCE country_gid_seq; Type: ACL; Schema: data; Owner: braup
--

GRANT ALL ON SEQUENCE data.country_gid_seq TO glims_rw;
GRANT SELECT ON SEQUENCE data.country_gid_seq TO glims_ro;


--
-- Name: TABLE dominant_mass_source_valids; Type: ACL; Schema: data; Owner: braup
--

GRANT ALL ON TABLE data.dominant_mass_source_valids TO glims_rw;
GRANT SELECT ON TABLE data.dominant_mass_source_valids TO glims_rc;
GRANT SELECT ON TABLE data.dominant_mass_source_valids TO glims_ro;
GRANT SELECT ON TABLE data.dominant_mass_source_valids TO aster_metadata;
GRANT SELECT ON TABLE data.dominant_mass_source_valids TO glu;
GRANT SELECT ON TABLE data.dominant_mass_source_valids TO rgi_role;


--
-- Name: TABLE glacier_static; Type: ACL; Schema: data; Owner: braup
--

GRANT ALL ON TABLE data.glacier_static TO glims_rw;
GRANT SELECT ON TABLE data.glacier_static TO glims_rc;
GRANT SELECT ON TABLE data.glacier_static TO glims_ro;
GRANT SELECT ON TABLE data.glacier_static TO aster_metadata;
GRANT SELECT ON TABLE data.glacier_static TO glu;
GRANT SELECT ON TABLE data.glacier_static TO rgi_role;


--
-- Name: TABLE extinct_glaciers_view; Type: ACL; Schema: data; Owner: braup
--

GRANT SELECT ON TABLE data.extinct_glaciers_view TO glims_ro;


--
-- Name: TABLE form_valids; Type: ACL; Schema: data; Owner: braup
--

GRANT ALL ON TABLE data.form_valids TO glims_rw;
GRANT SELECT ON TABLE data.form_valids TO glims_rc;
GRANT SELECT ON TABLE data.form_valids TO glims_ro;
GRANT SELECT ON TABLE data.form_valids TO aster_metadata;
GRANT SELECT ON TABLE data.form_valids TO glu;
GRANT SELECT ON TABLE data.form_valids TO rgi_role;


--
-- Name: TABLE frontal_characteristics_valids; Type: ACL; Schema: data; Owner: braup
--

GRANT ALL ON TABLE data.frontal_characteristics_valids TO glims_rw;
GRANT SELECT ON TABLE data.frontal_characteristics_valids TO glims_rc;
GRANT SELECT ON TABLE data.frontal_characteristics_valids TO glims_ro;
GRANT SELECT ON TABLE data.frontal_characteristics_valids TO aster_metadata;
GRANT SELECT ON TABLE data.frontal_characteristics_valids TO glu;
GRANT SELECT ON TABLE data.frontal_characteristics_valids TO rgi_role;


--
-- Name: TABLE glacier_countries; Type: ACL; Schema: data; Owner: braup
--

GRANT SELECT ON TABLE data.glacier_countries TO glims_ro;
GRANT SELECT,INSERT,UPDATE ON TABLE data.glacier_countries TO glims_rw;


--
-- Name: TABLE glacier_dynamic; Type: ACL; Schema: data; Owner: braup
--

GRANT ALL ON TABLE data.glacier_dynamic TO glims_rw;
GRANT SELECT ON TABLE data.glacier_dynamic TO glims_rc;
GRANT SELECT ON TABLE data.glacier_dynamic TO glims_ro;
GRANT SELECT ON TABLE data.glacier_dynamic TO aster_metadata;
GRANT SELECT ON TABLE data.glacier_dynamic TO glu;
GRANT SELECT ON TABLE data.glacier_dynamic TO rgi_role;


--
-- Name: TABLE glacier_image_info; Type: ACL; Schema: data; Owner: braup
--

GRANT ALL ON TABLE data.glacier_image_info TO glims_rw;
GRANT SELECT ON TABLE data.glacier_image_info TO glims_rc;
GRANT SELECT ON TABLE data.glacier_image_info TO glims_ro;
GRANT SELECT ON TABLE data.glacier_image_info TO aster_metadata;
GRANT SELECT ON TABLE data.glacier_image_info TO glu;
GRANT SELECT ON TABLE data.glacier_image_info TO rgi_role;


--
-- Name: TABLE people; Type: ACL; Schema: data; Owner: braup
--

GRANT ALL ON TABLE data.people TO glims_rw;
GRANT SELECT ON TABLE data.people TO glims_ro;
GRANT SELECT ON TABLE data.people TO aster_metadata;
GRANT SELECT ON TABLE data.people TO glu;
GRANT SELECT ON TABLE data.people TO rgi_role;
GRANT SELECT,UPDATE ON TABLE data.people TO glims_rc;


--
-- Name: TABLE regional_centers; Type: ACL; Schema: data; Owner: braup
--

GRANT ALL ON TABLE data.regional_centers TO glims_rw;
GRANT SELECT ON TABLE data.regional_centers TO glims_rc;
GRANT SELECT ON TABLE data.regional_centers TO glims_ro;
GRANT SELECT ON TABLE data.regional_centers TO aster_metadata;
GRANT SELECT ON TABLE data.regional_centers TO glu;
GRANT SELECT ON TABLE data.regional_centers TO rgi_role;


--
-- Name: TABLE submission_info; Type: ACL; Schema: data; Owner: braup
--

GRANT ALL ON TABLE data.submission_info TO glims_rw;
GRANT SELECT ON TABLE data.submission_info TO glims_rc;
GRANT SELECT ON TABLE data.submission_info TO glims_ro;
GRANT SELECT ON TABLE data.submission_info TO aster_metadata;
GRANT SELECT ON TABLE data.submission_info TO glu;
GRANT SELECT ON TABLE data.submission_info TO rgi_role;


--
-- Name: TABLE submission_rc_info; Type: ACL; Schema: data; Owner: postgres
--

GRANT SELECT ON TABLE data.submission_rc_info TO glu;
GRANT SELECT ON TABLE data.submission_rc_info TO rgi_role;
GRANT ALL ON TABLE data.submission_rc_info TO glims_rw;
GRANT SELECT ON TABLE data.submission_rc_info TO glims_rc;
GRANT SELECT ON TABLE data.submission_rc_info TO glims_ro;
GRANT ALL ON TABLE data.submission_rc_info TO braup;
GRANT SELECT ON TABLE data.submission_rc_info TO aster_metadata;


--
-- Name: TABLE glacier_entities; Type: ACL; Schema: data; Owner: braup
--

GRANT ALL ON TABLE data.glacier_entities TO glims_rw;
GRANT SELECT ON TABLE data.glacier_entities TO glims_rc;
GRANT SELECT ON TABLE data.glacier_entities TO glims_ro;
GRANT SELECT ON TABLE data.glacier_entities TO aster_metadata;
GRANT SELECT ON TABLE data.glacier_entities TO glu;
GRANT SELECT ON TABLE data.glacier_entities TO rgi_role;


--
-- Name: TABLE glacier_lines_disp; Type: ACL; Schema: data; Owner: postgres
--

GRANT SELECT ON TABLE data.glacier_lines_disp TO glu;
GRANT SELECT ON TABLE data.glacier_lines_disp TO rgi_role;
GRANT ALL ON TABLE data.glacier_lines_disp TO glims_rw;
GRANT SELECT ON TABLE data.glacier_lines_disp TO glims_rc;
GRANT SELECT ON TABLE data.glacier_lines_disp TO glims_ro;
GRANT ALL ON TABLE data.glacier_lines_disp TO braup;
GRANT SELECT ON TABLE data.glacier_lines_disp TO aster_metadata;


--
-- Name: TABLE glacier_map_info; Type: ACL; Schema: data; Owner: braup
--

GRANT ALL ON TABLE data.glacier_map_info TO glims_rw;
GRANT SELECT ON TABLE data.glacier_map_info TO glims_rc;
GRANT SELECT ON TABLE data.glacier_map_info TO glims_ro;
GRANT SELECT ON TABLE data.glacier_map_info TO aster_metadata;
GRANT SELECT ON TABLE data.glacier_map_info TO glu;
GRANT SELECT ON TABLE data.glacier_map_info TO rgi_role;


--
-- Name: TABLE submission_analyst; Type: ACL; Schema: data; Owner: braup
--

GRANT ALL ON TABLE data.submission_analyst TO glims_rw;
GRANT SELECT ON TABLE data.submission_analyst TO glims_rc;
GRANT SELECT ON TABLE data.submission_analyst TO glims_ro;
GRANT SELECT ON TABLE data.submission_analyst TO aster_metadata;
GRANT SELECT ON TABLE data.submission_analyst TO glu;
GRANT SELECT ON TABLE data.submission_analyst TO rgi_role;


--
-- Name: TABLE submission_anlst_names; Type: ACL; Schema: data; Owner: postgres
--

GRANT SELECT ON TABLE data.submission_anlst_names TO glu;
GRANT SELECT ON TABLE data.submission_anlst_names TO rgi_role;
GRANT ALL ON TABLE data.submission_anlst_names TO glims_rw;
GRANT SELECT ON TABLE data.submission_anlst_names TO glims_rc;
GRANT SELECT ON TABLE data.submission_anlst_names TO glims_ro;
GRANT ALL ON TABLE data.submission_anlst_names TO braup;
GRANT SELECT ON TABLE data.submission_anlst_names TO aster_metadata;


--
-- Name: TABLE submission_submitter; Type: ACL; Schema: data; Owner: postgres
--

GRANT SELECT ON TABLE data.submission_submitter TO glu;
GRANT SELECT ON TABLE data.submission_submitter TO rgi_role;
GRANT ALL ON TABLE data.submission_submitter TO glims_rw;
GRANT SELECT ON TABLE data.submission_submitter TO glims_rc;
GRANT SELECT ON TABLE data.submission_submitter TO glims_ro;
GRANT ALL ON TABLE data.submission_submitter TO braup;
GRANT SELECT ON TABLE data.submission_submitter TO aster_metadata;


--
-- Name: TABLE glacier_query_no_people; Type: ACL; Schema: data; Owner: braup
--

GRANT SELECT ON TABLE data.glacier_query_no_people TO glims_ro;


--
-- Name: TABLE glacier_reference; Type: ACL; Schema: data; Owner: braup
--

GRANT ALL ON TABLE data.glacier_reference TO glims_rw;
GRANT SELECT ON TABLE data.glacier_reference TO glims_rc;
GRANT SELECT ON TABLE data.glacier_reference TO glims_ro;
GRANT SELECT ON TABLE data.glacier_reference TO aster_metadata;
GRANT SELECT ON TABLE data.glacier_reference TO glu;
GRANT SELECT ON TABLE data.glacier_reference TO rgi_role;


--
-- Name: SEQUENCE glacier_static_id_num_seq1; Type: ACL; Schema: data; Owner: braup
--

GRANT SELECT,UPDATE ON SEQUENCE data.glacier_static_id_num_seq1 TO glims_rw;


--
-- Name: TABLE glims_field_dictionary; Type: ACL; Schema: data; Owner: braup
--

GRANT ALL ON TABLE data.glims_field_dictionary TO glims_rw;
GRANT SELECT ON TABLE data.glims_field_dictionary TO glims_rc;
GRANT SELECT ON TABLE data.glims_field_dictionary TO glims_ro;
GRANT SELECT ON TABLE data.glims_field_dictionary TO aster_metadata;
GRANT SELECT ON TABLE data.glims_field_dictionary TO glu;
GRANT SELECT ON TABLE data.glims_field_dictionary TO rgi_role;


--
-- Name: TABLE glims_table_fields; Type: ACL; Schema: data; Owner: braup
--

GRANT ALL ON TABLE data.glims_table_fields TO glims_rw;
GRANT SELECT ON TABLE data.glims_table_fields TO glims_rc;
GRANT SELECT ON TABLE data.glims_table_fields TO glims_ro;
GRANT SELECT ON TABLE data.glims_table_fields TO aster_metadata;
GRANT SELECT ON TABLE data.glims_table_fields TO glu;
GRANT SELECT ON TABLE data.glims_table_fields TO rgi_role;


--
-- Name: TABLE gtng_order1regions; Type: ACL; Schema: data; Owner: braup
--

GRANT SELECT ON TABLE data.gtng_order1regions TO glims_ro;
GRANT SELECT,INSERT,UPDATE ON TABLE data.gtng_order1regions TO glims_rw;


--
-- Name: SEQUENCE gtng_order1regions_gid_seq; Type: ACL; Schema: data; Owner: braup
--

GRANT SELECT ON SEQUENCE data.gtng_order1regions_gid_seq TO glims_ro;


--
-- Name: TABLE gtng_order2regions; Type: ACL; Schema: data; Owner: braup
--

GRANT SELECT ON TABLE data.gtng_order2regions TO glims_ro;
GRANT SELECT,INSERT,UPDATE ON TABLE data.gtng_order2regions TO glims_rw;


--
-- Name: SEQUENCE gtng_order2regions_gid_seq; Type: ACL; Schema: data; Owner: braup
--

GRANT SELECT ON SEQUENCE data.gtng_order2regions_gid_seq TO glims_ro;


--
-- Name: TABLE image; Type: ACL; Schema: data; Owner: braup
--

GRANT ALL ON TABLE data.image TO glims_rw;
GRANT SELECT ON TABLE data.image TO glims_rc;
GRANT SELECT ON TABLE data.image TO glims_ro;
GRANT SELECT ON TABLE data.image TO aster_metadata;
GRANT SELECT ON TABLE data.image TO glu;
GRANT SELECT ON TABLE data.image TO rgi_role;


--
-- Name: TABLE instrument; Type: ACL; Schema: data; Owner: braup
--

GRANT ALL ON TABLE data.instrument TO glims_rw;
GRANT SELECT ON TABLE data.instrument TO glims_rc;
GRANT SELECT ON TABLE data.instrument TO glims_ro;
GRANT SELECT ON TABLE data.instrument TO aster_metadata;
GRANT SELECT ON TABLE data.instrument TO glu;
GRANT SELECT ON TABLE data.instrument TO rgi_role;


--
-- Name: TABLE image_info_view; Type: ACL; Schema: data; Owner: braup
--

GRANT SELECT ON TABLE data.image_info_view TO glims_ro;
GRANT ALL ON TABLE data.image_info_view TO glims_rw;
GRANT SELECT ON TABLE data.image_info_view TO aster_metadata;
GRANT SELECT ON TABLE data.image_info_view TO glims_rc;
GRANT SELECT ON TABLE data.image_info_view TO glu;
GRANT SELECT ON TABLE data.image_info_view TO rgi_role;


--
-- Name: TABLE lon_char_valids; Type: ACL; Schema: data; Owner: braup
--

GRANT ALL ON TABLE data.lon_char_valids TO glims_rw;
GRANT SELECT ON TABLE data.lon_char_valids TO glims_rc;
GRANT SELECT ON TABLE data.lon_char_valids TO glims_ro;
GRANT SELECT ON TABLE data.lon_char_valids TO aster_metadata;
GRANT SELECT ON TABLE data.lon_char_valids TO glu;
GRANT SELECT ON TABLE data.lon_char_valids TO rgi_role;


--
-- Name: TABLE map_metadata; Type: ACL; Schema: data; Owner: braup
--

GRANT ALL ON TABLE data.map_metadata TO glims_rw;
GRANT SELECT ON TABLE data.map_metadata TO glims_rc;
GRANT SELECT ON TABLE data.map_metadata TO glims_ro;
GRANT SELECT ON TABLE data.map_metadata TO aster_metadata;
GRANT SELECT ON TABLE data.map_metadata TO glu;
GRANT SELECT ON TABLE data.map_metadata TO rgi_role;


--
-- Name: TABLE primary_classification_valids; Type: ACL; Schema: data; Owner: braup
--

GRANT ALL ON TABLE data.primary_classification_valids TO glims_rw;
GRANT SELECT ON TABLE data.primary_classification_valids TO glims_rc;
GRANT SELECT ON TABLE data.primary_classification_valids TO glims_ro;
GRANT SELECT ON TABLE data.primary_classification_valids TO aster_metadata;
GRANT SELECT ON TABLE data.primary_classification_valids TO glu;
GRANT SELECT ON TABLE data.primary_classification_valids TO rgi_role;


--
-- Name: TABLE rc_people; Type: ACL; Schema: data; Owner: braup
--

GRANT ALL ON TABLE data.rc_people TO glims_rw;
GRANT SELECT ON TABLE data.rc_people TO glims_rc;
GRANT SELECT ON TABLE data.rc_people TO glims_ro;
GRANT SELECT ON TABLE data.rc_people TO aster_metadata;
GRANT SELECT ON TABLE data.rc_people TO glu;
GRANT SELECT ON TABLE data.rc_people TO rgi_role;


--
-- Name: TABLE rc_people_nocoords; Type: ACL; Schema: data; Owner: braup
--

GRANT ALL ON TABLE data.rc_people_nocoords TO glims_rw;
GRANT SELECT ON TABLE data.rc_people_nocoords TO glims_rc;
GRANT SELECT ON TABLE data.rc_people_nocoords TO glims_ro;
GRANT SELECT ON TABLE data.rc_people_nocoords TO aster_metadata;
GRANT SELECT ON TABLE data.rc_people_nocoords TO glu;
GRANT SELECT ON TABLE data.rc_people_nocoords TO rgi_role;


--
-- Name: TABLE rc_people_view; Type: ACL; Schema: data; Owner: postgres
--

GRANT SELECT ON TABLE data.rc_people_view TO glu;
GRANT SELECT ON TABLE data.rc_people_view TO rgi_role;
GRANT ALL ON TABLE data.rc_people_view TO glims_rw;
GRANT SELECT ON TABLE data.rc_people_view TO glims_rc;
GRANT SELECT ON TABLE data.rc_people_view TO glims_ro;
GRANT ALL ON TABLE data.rc_people_view TO braup;
GRANT SELECT ON TABLE data.rc_people_view TO aster_metadata;


--
-- Name: TABLE reference_document; Type: ACL; Schema: data; Owner: braup
--

GRANT ALL ON TABLE data.reference_document TO glims_rw;
GRANT SELECT ON TABLE data.reference_document TO glims_rc;
GRANT SELECT ON TABLE data.reference_document TO glims_ro;
GRANT SELECT ON TABLE data.reference_document TO aster_metadata;
GRANT SELECT ON TABLE data.reference_document TO glu;
GRANT SELECT ON TABLE data.reference_document TO rgi_role;


--
-- Name: TABLE status_def; Type: ACL; Schema: data; Owner: braup
--

GRANT ALL ON TABLE data.status_def TO glims_rw;
GRANT SELECT ON TABLE data.status_def TO glims_rc;
GRANT SELECT ON TABLE data.status_def TO glims_ro;
GRANT SELECT ON TABLE data.status_def TO aster_metadata;
GRANT SELECT ON TABLE data.status_def TO glu;
GRANT SELECT ON TABLE data.status_def TO rgi_role;


--
-- Name: TABLE tongue_activity_valids; Type: ACL; Schema: data; Owner: braup
--

GRANT ALL ON TABLE data.tongue_activity_valids TO glims_rw;
GRANT SELECT ON TABLE data.tongue_activity_valids TO glims_rc;
GRANT SELECT ON TABLE data.tongue_activity_valids TO glims_ro;
GRANT SELECT ON TABLE data.tongue_activity_valids TO aster_metadata;
GRANT SELECT ON TABLE data.tongue_activity_valids TO glu;
GRANT SELECT ON TABLE data.tongue_activity_valids TO rgi_role;


--
-- PostgreSQL database dump complete
--

