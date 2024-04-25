-- WORK IN PROGRESS.  THIS FILE IS STARTING AS A COPY OF THE OLD SCHEMA, AND
-- WILL BE MODIFIED IN A SERIES OF COMMITS TO TRACK THE CHANGES.  This note
-- will be deleted when done.

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
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry, geography, and raster spatial types and functions';


--
-- Name: plpgsql_call_handler(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.plpgsql_call_handler() RETURNS language_handler
    LANGUAGE c
    AS '$libdir/plpgsql', 'plpgsql_call_handler';


ALTER FUNCTION public.plpgsql_call_handler() OWNER TO postgres;

--
-- Name: plpgsql_validator(oid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.plpgsql_validator(oid) RETURNS void
    LANGUAGE c
    AS '$libdir/plpgsql', 'plpgsql_validator';


ALTER FUNCTION public.plpgsql_validator(oid) OWNER TO postgres;

--
-- Name: segments_of_package(integer); Type: FUNCTION; Schema: public; Owner: braup
--

CREATE FUNCTION public.segments_of_package(integer) RETURNS integer
    LANGUAGE plpgsql
    AS $_$
DECLARE
  package_id            ALIAS FOR $1;
  pack_segs             segment.segment_id%TYPE;

BEGIN
SELECT INTO pack_segs segment_id FROM segment
WHERE     segment.segment_id         = glacier_line.segment_id
      AND glacier_line.analysis_id   = glacier_dynamic.analysis_id
      AND glacier_dynamic.package_id = package_id
;
RETURN (pack_segs);
END;
$_$;


ALTER FUNCTION public.segments_of_package(integer) OWNER TO braup;

--
-- Name: st_contains(public.geometry, public.geometry, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.st_contains(public.geometry, public.geometry, integer) RETURNS boolean
    LANGUAGE sql IMMUTABLE
    AS $_$SELECT $1 && $2 AND _ST_ContainsPrepared($1,$2,$3)$_$;


ALTER FUNCTION public.st_contains(public.geometry, public.geometry, integer) OWNER TO postgres;

--
-- Name: st_containsproperly(public.geometry, public.geometry, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.st_containsproperly(public.geometry, public.geometry, integer) RETURNS boolean
    LANGUAGE sql IMMUTABLE
    AS $_$SELECT $1 && $2 AND _ST_ContainsProperlyPrepared($1,$2,$3)$_$;


ALTER FUNCTION public.st_containsproperly(public.geometry, public.geometry, integer) OWNER TO postgres;

--
-- Name: st_covers(public.geometry, public.geometry, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.st_covers(public.geometry, public.geometry, integer) RETURNS boolean
    LANGUAGE sql IMMUTABLE
    AS $_$SELECT $1 && $2 AND _ST_CoversPrepared($1,$2,$3)$_$;


ALTER FUNCTION public.st_covers(public.geometry, public.geometry, integer) OWNER TO postgres;

--
-- Name: st_intersects(public.geometry, public.geometry, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.st_intersects(public.geometry, public.geometry, integer) RETURNS boolean
    LANGUAGE sql IMMUTABLE
    AS $_$SELECT $1 && $2 AND _ST_IntersectsPrepared($1,$2,$3)$_$;


ALTER FUNCTION public.st_intersects(public.geometry, public.geometry, integer) OWNER TO postgres;

--
-- Name: testfunc(integer, integer); Type: FUNCTION; Schema: public; Owner: braup
--

CREATE FUNCTION public.testfunc(integer, integer) RETURNS integer
    LANGUAGE plpgsql
    AS $_$
begin
  return( select $1 );
end;
$_$;


ALTER FUNCTION public.testfunc(integer, integer) OWNER TO braup;

SET default_tablespace = '';

--
-- Name: analyses_groups; Type: TABLE; Schema: public; Owner: braup
--

CREATE TABLE public.analyses_groups (
    analysis_id integer,
    group_id integer,
    state_id integer NOT NULL
);


ALTER TABLE public.analyses_groups OWNER TO braup;

--
-- Name: ancillary_data; Type: TABLE; Schema: public; Owner: braup
--

CREATE TABLE public.ancillary_data (
    data_type character varying(20) NOT NULL,
    location text NOT NULL,
    size integer,
    comment text,
    anc_data_id integer NOT NULL
);


ALTER TABLE public.ancillary_data OWNER TO braup;

--
-- Name: area_histogram; Type: TABLE; Schema: public; Owner: braup
--

CREATE TABLE public.area_histogram (
    area_histogram_id integer NOT NULL,
    analysis_id integer NOT NULL,
    bin_width numeric(5,1) NOT NULL,
    registration character(1) NOT NULL
);


ALTER TABLE public.area_histogram OWNER TO braup;

--
-- Name: area_histogram_data; Type: TABLE; Schema: public; Owner: braup
--

CREATE TABLE public.area_histogram_data (
    area_histogram_id integer NOT NULL,
    elevation real NOT NULL,
    area real NOT NULL
);


ALTER TABLE public.area_histogram_data OWNER TO braup;

--
-- Name: aster_footprints; Type: TABLE; Schema: public; Owner: aster_metadata
--

CREATE TABLE public.aster_footprints (
    aster_id integer NOT NULL,
    granule_id character varying(50) NOT NULL,
    edc_id integer NOT NULL,
    insert_time timestamp without time zone NOT NULL,
    browse_id character varying(100),
    short_name character varying(10),
    version_id integer,
    size_mb character varying(30),
    day_or_night character varying(10),
    production_date timestamp without time zone,
    capture_time time without time zone,
    capture_date date,
    missing_data integer,
    out_of_bounds integer,
    interpolated integer,
    cloud_cover integer,
    band12 character varying(30),
    band8 character varying(30),
    azimuth_angle character varying,
    processing_center character varying(10),
    aster_gains character varying(100),
    band9 character varying(30),
    band1 character varying(30),
    radiometricdbversion character varying(30),
    lr_cloud_cover integer,
    band2 character varying(30),
    band5 character varying(30),
    ll_cloud_cover integer,
    band10 character varying(30),
    vnir2_ob_mode character varying(5),
    band13 character varying(30),
    cloud_coverage integer,
    band6 character varying(30),
    resampling character varying(30),
    swir_observationmode character varying(5),
    generation_date character varying(30),
    band3b character varying(30),
    receiving_center character varying(30),
    band11 character varying(30),
    band14 character varying(30),
    band4 character varying(30),
    ul_cloud_cov integer,
    band7 character varying(30),
    ur_cloud_cov integer,
    elevation_angle character varying(50),
    tir_observationmode character varying(5),
    band3n character varying(30),
    dar_id character varying(80),
    map_projection character varying(50),
    geometric_dbversion character varying(50),
    vnir1_ob_mode character varying(5),
    swir_angle character varying(30),
    vnir_angle character varying(30),
    scene_orient_angle character varying(30),
    tir_angle character varying(50),
    glims_footprints public.geometry,
    edc_browse_url character varying(120),
    CONSTRAINT enforce_dims_footprint CHECK ((public.st_ndims(glims_footprints) = 2)),
    CONSTRAINT enforce_geotype_footprint CHECK (((public.geometrytype(glims_footprints) = 'POLYGON'::text) OR (glims_footprints IS NULL))),
    CONSTRAINT enforce_srid_footprint CHECK ((public.st_srid(glims_footprints) = 4326))
);


ALTER TABLE public.aster_footprints OWNER TO aster_metadata;

--
-- Name: band; Type: TABLE; Schema: public; Owner: braup
--

CREATE TABLE public.band (
    band_id integer NOT NULL,
    instrument_id integer NOT NULL,
    scan_type character varying(10),
    ifov_x double precision,
    ifov_y double precision,
    sample_interval_x double precision,
    sample_interval_y double precision,
    passband_low double precision,
    passband_high double precision,
    passband_unit character varying(5),
    num_bits integer,
    num_lines integer,
    num_samples integer,
    polarization character varying(5),
    band_name text
);


ALTER TABLE public.band OWNER TO braup;

--
-- Name: country; Type: TABLE; Schema: public; Owner: braup
--

CREATE TABLE public.country (
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
    borders public.geometry,
    CONSTRAINT enforce_dims_borders CHECK ((public.st_ndims(borders) = 2)),
    CONSTRAINT enforce_geotype_borders CHECK (((public.geometrytype(borders) = 'MULTIPOLYGON'::text) OR (borders IS NULL))),
    CONSTRAINT enforce_srid_borders CHECK ((public.st_srid(borders) = 4326))
);


ALTER TABLE public.country OWNER TO braup;

--
-- Name: country_gid_seq; Type: SEQUENCE; Schema: public; Owner: braup
--

CREATE SEQUENCE public.country_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.country_gid_seq OWNER TO braup;

--
-- Name: country_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: braup
--

ALTER SEQUENCE public.country_gid_seq OWNED BY public.country.gid;


--
-- Name: debris_cover_valids; Type: TABLE; Schema: public; Owner: braup
--

CREATE TABLE public.debris_cover_valids (
    debris_cover integer NOT NULL,
    description text
);


ALTER TABLE public.debris_cover_valids OWNER TO braup;

--
-- Name: debris_distribution_valids; Type: TABLE; Schema: public; Owner: braup
--

CREATE TABLE public.debris_distribution_valids (
    debris_distribution integer NOT NULL,
    description text
);


ALTER TABLE public.debris_distribution_valids OWNER TO braup;

--
-- Name: dominant_mass_source_valids; Type: TABLE; Schema: public; Owner: braup
--

CREATE TABLE public.dominant_mass_source_valids (
    dominant_mass_source integer NOT NULL,
    description text
);


ALTER TABLE public.dominant_mass_source_valids OWNER TO braup;

--
-- Name: glacier_static; Type: TABLE; Schema: public; Owner: braup
--

CREATE TABLE public.glacier_static (
    glacier_id character varying(20) NOT NULL,
    glacier_name text,
    wgms_id character varying(30),
    local_glacier_id character varying(30),
    parent_icemass_id character varying(20),
    record_status character varying(20),
    glac_static_points public.geometry,
    glacier_status character varying(20),
    submission_id integer,
    id_num integer NOT NULL,
    est_disappear_date date,
    est_disappear_unc integer,
    CONSTRAINT enforce_dims_glac_static_points CHECK ((public.st_ndims(glac_static_points) = 3)),
    CONSTRAINT enforce_geotype_glac_static_points CHECK (((public.geometrytype(glac_static_points) = 'POINT'::text) OR (glac_static_points IS NULL))),
    CONSTRAINT enforce_srid_glac_static_points CHECK ((public.st_srid(glac_static_points) = 4326))
);


ALTER TABLE public.glacier_static OWNER TO braup;

--
-- Name: extinct_glaciers_view; Type: VIEW; Schema: public; Owner: braup
--

CREATE VIEW public.extinct_glaciers_view AS
 SELECT glacier_static.glac_static_points AS glac_points,
    glacier_static.glacier_name AS glac_name,
    glacier_static.glacier_id AS glac_id,
    glacier_static.wgms_id,
    glacier_static.local_glacier_id AS local_id,
    glacier_static.glacier_status AS glac_stat,
    glacier_static.est_disappear_date AS gone_date,
    glacier_static.est_disappear_unc AS gone_dt_e
   FROM public.glacier_static
  WHERE ((glacier_static.glacier_status)::text = 'gone'::text);


ALTER TABLE public.extinct_glaciers_view OWNER TO braup;

--
-- Name: form_valids; Type: TABLE; Schema: public; Owner: braup
--

CREATE TABLE public.form_valids (
    form integer NOT NULL,
    description text
);


ALTER TABLE public.form_valids OWNER TO braup;

--
-- Name: frontal_characteristics_valids; Type: TABLE; Schema: public; Owner: braup
--

CREATE TABLE public.frontal_characteristics_valids (
    frontal_characteristics integer NOT NULL,
    description text
);


ALTER TABLE public.frontal_characteristics_valids OWNER TO braup;

--
-- Name: glacier_ancillary_info; Type: TABLE; Schema: public; Owner: braup
--

CREATE TABLE public.glacier_ancillary_info (
    analysis_id integer NOT NULL,
    anc_data_id integer NOT NULL
);


ALTER TABLE public.glacier_ancillary_info OWNER TO braup;

--
-- Name: glacier_countries; Type: TABLE; Schema: public; Owner: braup
--

CREATE TABLE public.glacier_countries (
    glacier_id character varying(20) NOT NULL,
    country_id integer NOT NULL
);


ALTER TABLE public.glacier_countries OWNER TO braup;

--
-- Name: glacier_dynamic; Type: TABLE; Schema: public; Owner: braup
--

CREATE TABLE public.glacier_dynamic (
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


ALTER TABLE public.glacier_dynamic OWNER TO braup;

--
-- Name: glacier_image_info; Type: TABLE; Schema: public; Owner: braup
--

CREATE TABLE public.glacier_image_info (
    analysis_id integer NOT NULL,
    image_id integer NOT NULL
);


ALTER TABLE public.glacier_image_info OWNER TO braup;

--
-- Name: glacier_line; Type: TABLE; Schema: public; Owner: braup
--

CREATE TABLE public.glacier_line (
    analysis_id integer NOT NULL,
    segment_id integer NOT NULL,
    segment_order integer NOT NULL,
    line_type character varying(20)
);


ALTER TABLE public.glacier_line OWNER TO braup;

--
-- Name: people; Type: TABLE; Schema: public; Owner: braup
--

CREATE TABLE public.people (
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
    affiliation_points public.geometry,
    principal_flag boolean,
    comment text,
    status integer,
    CONSTRAINT enforce_dims_affiliation_points CHECK ((public.st_ndims(affiliation_points) = 3)),
    CONSTRAINT enforce_geotype_affiliation_points CHECK (((public.geometrytype(affiliation_points) = 'POINT'::text) OR (affiliation_points IS NULL))),
    CONSTRAINT enforce_srid_affiliation_points CHECK ((public.st_srid(affiliation_points) = 4326))
);


ALTER TABLE public.people OWNER TO braup;

--
-- Name: regional_centers; Type: TABLE; Schema: public; Owner: braup
--

CREATE TABLE public.regional_centers (
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
    regional_center_polys public.geometry,
    status integer,
    CONSTRAINT enforce_geotype_regional_center_polys CHECK (((public.geometrytype(regional_center_polys) = 'POLYGON'::text) OR (regional_center_polys IS NULL))),
    CONSTRAINT enforce_srid_regional_center_polys CHECK ((public.st_srid(regional_center_polys) = 4326))
);


ALTER TABLE public.regional_centers OWNER TO braup;

--
-- Name: segment; Type: TABLE; Schema: public; Owner: braup
--

CREATE TABLE public.segment (
    segment_id integer NOT NULL,
    segment_type character varying(30) NOT NULL,
    segment_label character varying(32),
    segment_left_material character(3),
    segment_right_material character(3),
    orthocorrected boolean,
    loc_unc_x numeric(11,4),
    loc_unc_y numeric(11,4),
    glob_unc_x numeric(11,4),
    glob_unc_y numeric(11,4),
    seg_left_feature character(3),
    seg_right_feature character(3),
    segment_lines public.geometry,
    CONSTRAINT enforce_dims_segment_lines CHECK ((public.st_ndims(segment_lines) = 3)),
    CONSTRAINT enforce_geotype_segment_lines CHECK (((public.geometrytype(segment_lines) = 'MULTILINESTRING'::text) OR (segment_lines IS NULL))),
    CONSTRAINT enforce_srid_segment_lines CHECK ((public.st_srid(segment_lines) = 4326))
);


ALTER TABLE public.segment OWNER TO braup;

--
-- Name: submission_info; Type: TABLE; Schema: public; Owner: braup
--

CREATE TABLE public.submission_info (
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


ALTER TABLE public.submission_info OWNER TO braup;

--
-- Name: submission_rc_info; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.submission_rc_info AS
 SELECT submission_info.submission_id,
    submission_info.rc_id,
    people.surname AS chief_surn,
    people.givennames AS chief_givn,
    people.affiliation AS chief_affl,
    regional_centers.url_primary,
    regional_centers.geog_area,
    people.country_code
   FROM public.submission_info,
    public.people,
    public.regional_centers
  WHERE ((submission_info.rc_id = regional_centers.rc_id) AND (regional_centers.chief = people.contact_id));


ALTER TABLE public.submission_rc_info OWNER TO postgres;

--
-- Name: glacier_line_query_no_people; Type: VIEW; Schema: public; Owner: braup
--

CREATE VIEW public.glacier_line_query_no_people AS
 SELECT glacier_line.segment_id AS seg_id,
    glacier_line.segment_order AS seg_order,
    glacier_line.line_type,
    segment.segment_type AS seg_type,
    segment.segment_label AS seg_label,
    segment.segment_left_material AS seg_l_mat,
    segment.segment_right_material AS seg_r_mat,
    segment.orthocorrected AS orthocorr,
    segment.loc_unc_x,
    segment.loc_unc_y,
    segment.glob_unc_x,
    segment.glob_unc_y,
    segment.seg_left_feature AS seg_l_feat,
    segment.seg_right_feature AS seg_r_feat,
    segment.segment_lines AS seg_lines,
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
   FROM public.glacier_line,
    public.segment,
    public.glacier_dynamic,
    public.glacier_static,
    public.submission_info,
    public.submission_rc_info
  WHERE ((glacier_line.analysis_id = glacier_dynamic.analysis_id) AND (segment.segment_id = glacier_line.segment_id) AND ((glacier_dynamic.glacier_id)::text = (glacier_static.glacier_id)::text) AND (glacier_dynamic.submission_id = submission_info.submission_id) AND (submission_info.submission_id = submission_rc_info.submission_id) AND ((glacier_dynamic.record_status)::text = 'okay'::text));


ALTER TABLE public.glacier_line_query_no_people OWNER TO braup;

--
-- Name: glacier_line_query_no_people_v3; Type: VIEW; Schema: public; Owner: braup
--

CREATE VIEW public.glacier_line_query_no_people_v3 AS
 SELECT glacier_line.segment_id AS seg_id,
    glacier_line.segment_order AS seg_order,
    glacier_line.line_type,
    segment.segment_type AS seg_type,
    segment.segment_label AS seg_label,
    segment.segment_left_material AS seg_l_mat,
    segment.segment_right_material AS seg_r_mat,
    segment.orthocorrected AS orthocorr,
    segment.loc_unc_x,
    segment.loc_unc_y,
    segment.glob_unc_x,
    segment.glob_unc_y,
    segment.seg_left_feature AS seg_l_feat,
    segment.seg_right_feature AS seg_r_feat,
    segment.segment_lines AS seg_lines,
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
    glacier_static.glacier_name AS glac_name,
    glacier_static.wgms_id,
    glacier_static.local_glacier_id AS local_id,
    glacier_static.glacier_status AS glac_stat,
    glacier_static.est_disappear_date AS gone_date,
    glacier_static.est_disappear_unc AS gone_dt_e,
    submission_info.submission_id AS subm_id,
    submission_info.release_okay_date AS release_dt,
    submission_info.process_description AS proc_desc,
    submission_info.rc_id,
    submission_rc_info.geog_area,
    submission_rc_info.chief_affl,
    glacier_static.parent_icemass_id AS parent_id
   FROM public.glacier_line,
    public.segment,
    public.glacier_dynamic,
    public.glacier_static,
    public.submission_info,
    public.submission_rc_info
  WHERE ((glacier_line.analysis_id = glacier_dynamic.analysis_id) AND (segment.segment_id = glacier_line.segment_id) AND ((glacier_dynamic.glacier_id)::text = (glacier_static.glacier_id)::text) AND (glacier_dynamic.submission_id = submission_info.submission_id) AND (submission_info.submission_id = submission_rc_info.submission_id) AND ((glacier_dynamic.record_status)::text = 'okay'::text));


ALTER TABLE public.glacier_line_query_no_people_v3 OWNER TO braup;

--
-- Name: glacier_polygons; Type: TABLE; Schema: public; Owner: braup
--

CREATE TABLE public.glacier_polygons (
    analysis_id integer NOT NULL,
    line_type text NOT NULL,
    glacier_polys public.geometry NOT NULL,
    CONSTRAINT enforce_dims_glacier_polys CHECK ((public.st_ndims(glacier_polys) = 3)),
    CONSTRAINT enforce_geotype_glacier_polys CHECK (((public.geometrytype(glacier_polys) = 'POLYGON'::text) OR (glacier_polys IS NULL))),
    CONSTRAINT enforce_srid_glacier_polys CHECK ((public.st_srid(glacier_polys) = 4326))
);


ALTER TABLE public.glacier_polygons OWNER TO braup;

--
-- Name: glacier_lines_disp; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.glacier_lines_disp AS
 SELECT glacier_polygons.glacier_polys,
    glacier_polygons.analysis_id AS anlys_id,
    glacier_polygons.line_type,
    glacier_dynamic.glacier_id AS glac_id,
    glacier_dynamic.record_status AS rec_status,
    glacier_dynamic.source_timestamp AS src_date
   FROM public.glacier_polygons,
    public.glacier_dynamic
  WHERE ((glacier_polygons.analysis_id = glacier_dynamic.analysis_id) AND ((glacier_dynamic.record_status)::text = 'okay'::text));


ALTER TABLE public.glacier_lines_disp OWNER TO postgres;

--
-- Name: glacier_map_info; Type: TABLE; Schema: public; Owner: braup
--

CREATE TABLE public.glacier_map_info (
    analysis_id integer NOT NULL,
    map_id integer NOT NULL
);


ALTER TABLE public.glacier_map_info OWNER TO braup;

--
-- Name: submission_analyst; Type: TABLE; Schema: public; Owner: braup
--

CREATE TABLE public.submission_analyst (
    submission_id integer NOT NULL,
    analyst_id integer NOT NULL,
    sort_order integer
);


ALTER TABLE public.submission_analyst OWNER TO braup;

--
-- Name: submission_anlst_names; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.submission_anlst_names AS
 SELECT submission_info.submission_id,
    people.surname,
    people.givennames,
    people.affiliation,
    people.url_primary,
    people.country_code
   FROM public.submission_info,
    public.people,
    public.submission_analyst
  WHERE ((submission_info.submission_id = submission_analyst.submission_id) AND (submission_analyst.analyst_id = people.contact_id));


ALTER TABLE public.submission_anlst_names OWNER TO postgres;

--
-- Name: submission_submitter; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.submission_submitter AS
 SELECT submission_info.submission_id,
    people.surname,
    people.givennames,
    people.affiliation,
    people.url_primary,
    people.country_code
   FROM public.submission_info,
    public.people
  WHERE (submission_info.submitter_id = people.contact_id);


ALTER TABLE public.submission_submitter OWNER TO postgres;

--
-- Name: glacier_query_full3; Type: VIEW; Schema: public; Owner: braup
--

CREATE VIEW public.glacier_query_full3 AS
 SELECT glacier_polygons.glacier_polys,
    glacier_polygons.line_type,
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
    submission_info.submission_id AS subm_id,
    submission_info.release_okay_date,
    submission_info.process_description AS proc_desc,
    submission_submitter.surname AS submit_surn,
    submission_submitter.givennames AS submit_givn,
    submission_submitter.affiliation AS submit_affl,
    submission_submitter.url_primary AS submit_url,
    submission_submitter.country_code AS submit_ccode,
    submission_anlst_names.surname AS anlst_surn,
    submission_anlst_names.givennames AS anlst_givn,
    submission_anlst_names.affiliation AS anlst_affl,
    submission_anlst_names.url_primary AS anlst_url,
    submission_anlst_names.country_code AS anlst_ccode,
    submission_rc_info.chief_surn,
    submission_rc_info.chief_givn,
    submission_rc_info.chief_affl,
    submission_rc_info.url_primary AS rc_url,
    submission_rc_info.country_code AS rc_ccode,
    submission_info.rc_id,
    submission_rc_info.geog_area
   FROM public.glacier_polygons,
    public.glacier_dynamic,
    public.glacier_static,
    public.submission_info,
    public.submission_submitter,
    public.submission_anlst_names,
    public.submission_rc_info
  WHERE ((glacier_polygons.analysis_id = glacier_dynamic.analysis_id) AND ((glacier_dynamic.glacier_id)::text = (glacier_static.glacier_id)::text) AND (glacier_dynamic.submission_id = submission_info.submission_id) AND (submission_info.submission_id = submission_submitter.submission_id) AND (submission_info.submission_id = submission_anlst_names.submission_id) AND (submission_info.submission_id = submission_rc_info.submission_id) AND ((glacier_dynamic.record_status)::text = 'okay'::text));


ALTER TABLE public.glacier_query_full3 OWNER TO braup;

--
-- Name: glacier_query_full3_v2; Type: VIEW; Schema: public; Owner: braup
--

CREATE VIEW public.glacier_query_full3_v2 AS
 SELECT glacier_polygons.glacier_polys,
    glacier_polygons.line_type,
    glacier_dynamic.analysis_id AS anlys_id,
    glacier_dynamic.glacier_id AS glac_id,
    glacier_dynamic.analysis_timestamp AS anlys_time,
    glacier_dynamic.width,
    glacier_dynamic.length,
    glacier_dynamic.area,
    glacier_dynamic.abzone_area AS abzon_area,
    glacier_dynamic.speed,
    glacier_dynamic.db_calculated_area AS db_area,
    glacier_dynamic.primary_classification AS primeclass,
    glacier_dynamic.primary_classification2 AS primclass2,
    glacier_dynamic.form,
    glacier_dynamic.frontal_characteristics AS front_char,
    glacier_dynamic.frontal_characteristics2 AS front_char2,
    glacier_dynamic.longitudinal_characteristics AS long_char,
    glacier_dynamic.dominant_mass_source AS mass_src,
    glacier_dynamic.tongue_activity AS tong_act,
    glacier_dynamic.tongue_activity2 AS tong_act2,
    glacier_dynamic.moraine_code1 AS moraine1,
    glacier_dynamic.moraine_code2 AS moraine2,
    glacier_dynamic.debris_cover AS debriscov,
    glacier_dynamic.min_elev,
    glacier_dynamic.mean_elev,
    glacier_dynamic.median_elev AS med_elev,
    glacier_dynamic.max_elev,
    glacier_dynamic.snowline_elev AS snwln_elev,
    glacier_dynamic.ela,
    glacier_dynamic.ela_desc,
    glacier_dynamic.three_d_desc AS threeddesc,
    glacier_dynamic.orientation AS aspect,
    glacier_dynamic.orientation_ablat AS abl_aspect,
    glacier_dynamic.orientation_accum AS acc_aspect,
    glacier_dynamic.avg_slope,
    glacier_dynamic.thickness_m AS thick_m,
    glacier_dynamic.basin_code,
    glacier_dynamic.num_basins,
    glacier_dynamic.source_timestamp AS src_date,
    glacier_dynamic.src_time_end AS src_dt_end,
    glacier_dynamic.rgiid,
    glacier_dynamic.rgi_glactype AS rgi_gl_typ,
    glacier_dynamic.rgi_join_count AS rgi_join_n,
    glacier_dynamic.rgi_maxlength_m AS rgi_max_l,
    glacier_dynamic.gtng_o1region AS gtng_o1reg,
    glacier_dynamic.gtng_o2region AS gtng_o2reg,
    glacier_dynamic.rgiflag,
    glacier_dynamic.record_status AS rec_status,
    glacier_dynamic.icesheet_conn_level AS conn_lvl,
    glacier_dynamic.surge_type,
    glacier_dynamic.term_type,
    glacier_static.glacier_name AS glac_name,
    glacier_static.wgms_id,
    glacier_static.local_glacier_id AS local_id,
    glacier_static.glacier_status AS glac_stat,
    submission_info.submission_id AS subm_id,
    submission_info.release_okay_date AS release_dt,
    submission_info.process_description AS proc_desc,
    submission_submitter.surname AS submit_surn,
    submission_submitter.givennames AS submit_givn,
    submission_submitter.affiliation AS submit_affl,
    submission_submitter.url_primary AS submit_url,
    submission_submitter.country_code AS submit_ccode,
    submission_anlst_names.surname AS anlst_surn,
    submission_anlst_names.givennames AS anlst_givn,
    submission_anlst_names.affiliation AS anlst_affl,
    submission_anlst_names.url_primary AS anlst_url,
    submission_anlst_names.country_code AS anlst_ccode,
    submission_rc_info.chief_surn,
    submission_rc_info.chief_givn,
    submission_rc_info.chief_affl,
    submission_rc_info.url_primary AS rc_url,
    submission_rc_info.country_code AS rc_ccode,
    submission_info.rc_id,
    submission_rc_info.geog_area
   FROM public.glacier_polygons,
    public.glacier_dynamic,
    public.glacier_static,
    public.submission_info,
    public.submission_submitter,
    public.submission_anlst_names,
    public.submission_rc_info
  WHERE ((glacier_polygons.analysis_id = glacier_dynamic.analysis_id) AND ((glacier_dynamic.glacier_id)::text = (glacier_static.glacier_id)::text) AND (glacier_dynamic.submission_id = submission_info.submission_id) AND (submission_info.submission_id = submission_submitter.submission_id) AND (submission_info.submission_id = submission_anlst_names.submission_id) AND (submission_info.submission_id = submission_rc_info.submission_id) AND ((glacier_dynamic.record_status)::text = 'okay'::text));


ALTER TABLE public.glacier_query_full3_v2 OWNER TO braup;

--
-- Name: glacier_query_full3_v3; Type: VIEW; Schema: public; Owner: braup
--

CREATE VIEW public.glacier_query_full3_v3 AS
 SELECT glacier_polygons.glacier_polys,
    glacier_polygons.line_type,
    glacier_dynamic.analysis_id AS anlys_id,
    glacier_dynamic.glacier_id AS glac_id,
    glacier_dynamic.analysis_timestamp AS anlys_time,
    glacier_dynamic.width,
    glacier_dynamic.length,
    glacier_dynamic.area,
    glacier_dynamic.abzone_area AS abzon_area,
    glacier_dynamic.speed,
    glacier_dynamic.db_calculated_area AS db_area,
    glacier_dynamic.primary_classification AS primeclass,
    glacier_dynamic.primary_classification2 AS primclass2,
    glacier_dynamic.form,
    glacier_dynamic.frontal_characteristics AS front_char,
    glacier_dynamic.frontal_characteristics2 AS front_char2,
    glacier_dynamic.longitudinal_characteristics AS long_char,
    glacier_dynamic.dominant_mass_source AS mass_src,
    glacier_dynamic.tongue_activity AS tong_act,
    glacier_dynamic.tongue_activity2 AS tong_act2,
    glacier_dynamic.moraine_code1 AS moraine1,
    glacier_dynamic.moraine_code2 AS moraine2,
    glacier_dynamic.debris_cover AS debriscov,
    glacier_dynamic.min_elev,
    glacier_dynamic.mean_elev,
    glacier_dynamic.median_elev AS med_elev,
    glacier_dynamic.max_elev,
    glacier_dynamic.snowline_elev AS snwln_elev,
    glacier_dynamic.ela,
    glacier_dynamic.ela_desc,
    glacier_dynamic.three_d_desc AS threeddesc,
    glacier_dynamic.orientation AS aspect,
    glacier_dynamic.orientation_ablat AS abl_aspect,
    glacier_dynamic.orientation_accum AS acc_aspect,
    glacier_dynamic.avg_slope,
    glacier_dynamic.thickness_m AS thick_m,
    glacier_dynamic.basin_code,
    glacier_dynamic.num_basins,
    glacier_dynamic.source_timestamp AS src_date,
    glacier_dynamic.src_time_end AS src_dt_end,
    glacier_dynamic.rgiid,
    glacier_dynamic.rgi_glactype AS rgi_gl_typ,
    glacier_dynamic.rgi_join_count AS rgi_join_n,
    glacier_dynamic.rgi_maxlength_m AS rgi_max_l,
    glacier_dynamic.gtng_o1region AS gtng_o1reg,
    glacier_dynamic.gtng_o2region AS gtng_o2reg,
    glacier_dynamic.rgiflag,
    glacier_dynamic.record_status AS rec_status,
    glacier_dynamic.icesheet_conn_level AS conn_lvl,
    glacier_dynamic.surge_type,
    glacier_dynamic.term_type,
    glacier_static.glacier_name AS glac_name,
    glacier_static.wgms_id,
    glacier_static.local_glacier_id AS local_id,
    glacier_static.glacier_status AS glac_stat,
    submission_info.submission_id AS subm_id,
    submission_info.release_okay_date AS release_dt,
    submission_info.process_description AS proc_desc,
    submission_submitter.surname AS submit_surn,
    submission_submitter.givennames AS submit_givn,
    submission_submitter.affiliation AS submit_affl,
    submission_submitter.url_primary AS submit_url,
    submission_submitter.country_code AS submit_ccode,
    submission_anlst_names.surname AS anlst_surn,
    submission_anlst_names.givennames AS anlst_givn,
    submission_anlst_names.affiliation AS anlst_affl,
    submission_anlst_names.url_primary AS anlst_url,
    submission_anlst_names.country_code AS anlst_ccode,
    submission_rc_info.chief_surn,
    submission_rc_info.chief_givn,
    submission_rc_info.chief_affl,
    submission_rc_info.url_primary AS rc_url,
    submission_rc_info.country_code AS rc_ccode,
    submission_info.rc_id,
    submission_rc_info.geog_area
   FROM public.glacier_polygons,
    public.glacier_dynamic,
    public.glacier_static,
    public.submission_info,
    public.submission_submitter,
    public.submission_anlst_names,
    public.submission_rc_info
  WHERE ((glacier_polygons.analysis_id = glacier_dynamic.analysis_id) AND ((glacier_dynamic.glacier_id)::text = (glacier_static.glacier_id)::text) AND (glacier_dynamic.submission_id = submission_info.submission_id) AND (submission_info.submission_id = submission_submitter.submission_id) AND (submission_info.submission_id = submission_anlst_names.submission_id) AND (submission_info.submission_id = submission_rc_info.submission_id) AND ((glacier_dynamic.record_status)::text = 'okay'::text));


ALTER TABLE public.glacier_query_full3_v3 OWNER TO braup;

--
-- Name: glacier_query_no_people; Type: VIEW; Schema: public; Owner: braup
--

CREATE VIEW public.glacier_query_no_people AS
 SELECT glacier_polygons.glacier_polys AS glac_polys,
    glacier_polygons.line_type,
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
   FROM public.glacier_polygons,
    public.glacier_dynamic,
    public.glacier_static,
    public.submission_info,
    public.submission_rc_info
  WHERE ((glacier_polygons.analysis_id = glacier_dynamic.analysis_id) AND ((glacier_dynamic.glacier_id)::text = (glacier_static.glacier_id)::text) AND (glacier_dynamic.submission_id = submission_info.submission_id) AND (submission_info.submission_id = submission_rc_info.submission_id) AND ((glacier_dynamic.record_status)::text = 'okay'::text));


ALTER TABLE public.glacier_query_no_people OWNER TO braup;

--
-- Name: glacier_query_no_people_v2; Type: VIEW; Schema: public; Owner: braup
--

CREATE VIEW public.glacier_query_no_people_v2 AS
 SELECT glacier_polygons.glacier_polys AS glac_polys,
    glacier_polygons.line_type,
    glacier_dynamic.analysis_id AS anlys_id,
    glacier_dynamic.glacier_id AS glac_id,
    glacier_dynamic.analysis_timestamp AS anlys_time,
    glacier_dynamic.width,
    glacier_dynamic.length,
    glacier_dynamic.area,
    glacier_dynamic.abzone_area AS abzon_area,
    glacier_dynamic.speed,
    glacier_dynamic.db_calculated_area AS db_area,
    glacier_dynamic.primary_classification AS primeclass,
    glacier_dynamic.primary_classification2 AS primclass2,
    glacier_dynamic.form,
    glacier_dynamic.frontal_characteristics AS front_char,
    glacier_dynamic.frontal_characteristics2 AS front_char2,
    glacier_dynamic.longitudinal_characteristics AS long_char,
    glacier_dynamic.dominant_mass_source AS mass_src,
    glacier_dynamic.tongue_activity AS tong_act,
    glacier_dynamic.tongue_activity2 AS tong_act2,
    glacier_dynamic.moraine_code1 AS moraine1,
    glacier_dynamic.moraine_code2 AS moraine2,
    glacier_dynamic.debris_cover AS debriscov,
    glacier_dynamic.min_elev,
    glacier_dynamic.mean_elev,
    glacier_dynamic.median_elev AS med_elev,
    glacier_dynamic.max_elev,
    glacier_dynamic.snowline_elev AS snwln_elev,
    glacier_dynamic.ela,
    glacier_dynamic.ela_desc,
    glacier_dynamic.three_d_desc AS threeddesc,
    glacier_dynamic.orientation AS aspect,
    glacier_dynamic.orientation_accum AS acc_aspect,
    glacier_dynamic.orientation_ablat AS abl_aspect,
    glacier_dynamic.avg_slope,
    glacier_dynamic.thickness_m AS thick_m,
    glacier_dynamic.basin_code,
    glacier_dynamic.num_basins,
    glacier_dynamic.source_timestamp AS src_date,
    glacier_dynamic.src_time_end AS src_dt_end,
    glacier_dynamic.rgiid,
    glacier_dynamic.rgi_glactype AS rgi_gl_typ,
    glacier_dynamic.rgi_join_count AS rgi_join_n,
    glacier_dynamic.rgi_maxlength_m AS rgi_max_l,
    glacier_dynamic.gtng_o1region AS gtng_o1reg,
    glacier_dynamic.gtng_o2region AS gtng_o2reg,
    glacier_dynamic.rgiflag,
    glacier_dynamic.record_status AS rec_status,
    glacier_dynamic.icesheet_conn_level AS conn_lvl,
    glacier_dynamic.surge_type,
    glacier_dynamic.term_type,
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
   FROM public.glacier_polygons,
    public.glacier_dynamic,
    public.glacier_static,
    public.submission_info,
    public.submission_rc_info
  WHERE ((glacier_polygons.analysis_id = glacier_dynamic.analysis_id) AND ((glacier_dynamic.glacier_id)::text = (glacier_static.glacier_id)::text) AND (glacier_dynamic.submission_id = submission_info.submission_id) AND (submission_info.submission_id = submission_rc_info.submission_id) AND ((glacier_dynamic.record_status)::text = 'okay'::text));


ALTER TABLE public.glacier_query_no_people_v2 OWNER TO braup;

--
-- Name: glacier_query_no_people_v3; Type: VIEW; Schema: public; Owner: braup
--

CREATE VIEW public.glacier_query_no_people_v3 AS
 SELECT glacier_polygons.glacier_polys AS glac_polys,
    glacier_polygons.line_type,
    glacier_dynamic.analysis_id AS anlys_id,
    glacier_dynamic.glacier_id AS glac_id,
    glacier_dynamic.analysis_timestamp AS anlys_time,
    glacier_dynamic.width,
    glacier_dynamic.length,
    glacier_dynamic.area,
    glacier_dynamic.abzone_area AS abzon_area,
    glacier_dynamic.speed,
    glacier_dynamic.db_calculated_area AS db_area,
    glacier_dynamic.primary_classification AS primeclass,
    glacier_dynamic.primary_classification2 AS primclass2,
    glacier_dynamic.form,
    glacier_dynamic.frontal_characteristics AS front_char,
    glacier_dynamic.frontal_characteristics2 AS front_char2,
    glacier_dynamic.longitudinal_characteristics AS long_char,
    glacier_dynamic.dominant_mass_source AS mass_src,
    glacier_dynamic.tongue_activity AS tong_act,
    glacier_dynamic.tongue_activity2 AS tong_act2,
    glacier_dynamic.moraine_code1 AS moraine1,
    glacier_dynamic.moraine_code2 AS moraine2,
    glacier_dynamic.debris_cover AS debriscov,
    glacier_dynamic.min_elev,
    glacier_dynamic.mean_elev,
    glacier_dynamic.median_elev AS med_elev,
    glacier_dynamic.max_elev,
    glacier_dynamic.snowline_elev AS snwln_elev,
    glacier_dynamic.ela,
    glacier_dynamic.ela_desc,
    glacier_dynamic.three_d_desc AS threeddesc,
    glacier_dynamic.orientation AS aspect,
    glacier_dynamic.orientation_accum AS acc_aspect,
    glacier_dynamic.orientation_ablat AS abl_aspect,
    glacier_dynamic.avg_slope,
    glacier_dynamic.thickness_m AS thick_m,
    glacier_dynamic.basin_code,
    glacier_dynamic.num_basins,
    glacier_dynamic.source_timestamp AS src_date,
    glacier_dynamic.src_time_end AS src_dt_end,
    glacier_dynamic.rgiid,
    glacier_dynamic.rgi_glactype AS rgi_gl_typ,
    glacier_dynamic.rgi_join_count AS rgi_join_n,
    glacier_dynamic.rgi_maxlength_m AS rgi_max_l,
    glacier_dynamic.gtng_o1region AS gtng_o1reg,
    glacier_dynamic.gtng_o2region AS gtng_o2reg,
    glacier_dynamic.rgiflag,
    glacier_dynamic.record_status AS rec_status,
    glacier_dynamic.icesheet_conn_level AS conn_lvl,
    glacier_dynamic.surge_type,
    glacier_dynamic.term_type,
    glacier_static.glacier_name AS glac_name,
    glacier_static.wgms_id,
    glacier_static.local_glacier_id AS local_id,
    glacier_static.glacier_status AS glac_stat,
    glacier_static.est_disappear_date AS gone_date,
    glacier_static.est_disappear_unc AS gone_dt_e,
    submission_info.submission_id AS subm_id,
    submission_info.release_okay_date AS release_dt,
    submission_info.process_description AS proc_desc,
    submission_info.rc_id,
    submission_rc_info.geog_area,
    submission_rc_info.chief_affl,
    glacier_static.parent_icemass_id AS parent_id
   FROM public.glacier_polygons,
    public.glacier_dynamic,
    public.glacier_static,
    public.submission_info,
    public.submission_rc_info
  WHERE ((glacier_polygons.analysis_id = glacier_dynamic.analysis_id) AND ((glacier_dynamic.glacier_id)::text = (glacier_static.glacier_id)::text) AND (glacier_dynamic.submission_id = submission_info.submission_id) AND (submission_info.submission_id = submission_rc_info.submission_id) AND ((glacier_dynamic.record_status)::text = 'okay'::text));


ALTER TABLE public.glacier_query_no_people_v3 OWNER TO braup;

--
-- Name: glacier_reference; Type: TABLE; Schema: public; Owner: braup
--

CREATE TABLE public.glacier_reference (
    glacier_id character varying(20) NOT NULL,
    reference_doc_id integer NOT NULL
);


ALTER TABLE public.glacier_reference OWNER TO braup;

--
-- Name: glacier_static_id_num_seq; Type: SEQUENCE; Schema: public; Owner: braup
--

CREATE SEQUENCE public.glacier_static_id_num_seq
    START WITH 141688
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.glacier_static_id_num_seq OWNER TO braup;

--
-- Name: glacier_static_id_num_seq1; Type: SEQUENCE; Schema: public; Owner: braup
--

CREATE SEQUENCE public.glacier_static_id_num_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.glacier_static_id_num_seq1 OWNER TO braup;

--
-- Name: glacier_static_id_num_seq1; Type: SEQUENCE OWNED BY; Schema: public; Owner: braup
--

ALTER SEQUENCE public.glacier_static_id_num_seq1 OWNED BY public.glacier_static.id_num;


--
-- Name: glims_aster_footprints; Type: TABLE; Schema: public; Owner: braup
--

CREATE TABLE public.glims_aster_footprints (
    aster_id integer NOT NULL,
    granule_id character varying(50) NOT NULL,
    edc_id integer NOT NULL,
    insert_time timestamp without time zone NOT NULL,
    browse_id character varying(100),
    short_name character varying(10),
    version_id integer,
    size_mb character varying(30),
    day_or_night character varying(10),
    production_date timestamp without time zone,
    capture_time time without time zone,
    capture_date date,
    missing_data integer,
    out_of_bounds integer,
    interpolated integer,
    cloud_cover integer,
    band12 character varying(30),
    band8 character varying(30),
    azimuth_angle character varying,
    processing_center character varying(10),
    aster_gains character varying(100),
    band9 character varying(30),
    band1 character varying(30),
    radiometricdbversion character varying(30),
    lr_cloud_cover integer,
    band2 character varying(30),
    band5 character varying(30),
    ll_cloud_cover integer,
    band10 character varying(30),
    vnir2_ob_mode character varying(5),
    band13 character varying(30),
    cloud_coverage integer,
    band6 character varying(30),
    resampling character varying(30),
    swir_observationmode character varying(5),
    generation_date character varying(30),
    band3b character varying(30),
    receiving_center character varying(30),
    band11 character varying(30),
    band14 character varying(30),
    band4 character varying(30),
    ul_cloud_cov integer,
    band7 character varying(30),
    ur_cloud_cov integer,
    elevation_angle character varying(50),
    tir_observationmode character varying(5),
    band3n character varying(30),
    dar_id character varying(80),
    map_projection character varying(50),
    geometric_dbversion character varying(50),
    vnir1_ob_mode character varying(5),
    swir_angle character varying(30),
    vnir_angle character varying(30),
    scene_orient_angle character varying(30),
    tir_angle character varying(50),
    glims_footprints public.geometry,
    edc_browse_url character varying(120),
    browse_retrieved boolean,
    CONSTRAINT enforce_dims_glims_footprints CHECK ((public.st_ndims(glims_footprints) = 2)),
    CONSTRAINT enforce_geotype_glims_footprints CHECK (((public.geometrytype(glims_footprints) = 'POLYGON'::text) OR (glims_footprints IS NULL))),
    CONSTRAINT enforce_srid_glims_footprints CHECK ((public.st_srid(glims_footprints) = 4326))
);


ALTER TABLE public.glims_aster_footprints OWNER TO braup;

--
-- Name: glims_field_dictionary; Type: TABLE; Schema: public; Owner: braup
--

CREATE TABLE public.glims_field_dictionary (
    field_name character varying(100) NOT NULL,
    short_name character varying(100),
    display_name character varying(100),
    description text,
    shapefile character varying(50),
    sort_order integer
);


ALTER TABLE public.glims_field_dictionary OWNER TO braup;

--
-- Name: glims_table_fields; Type: TABLE; Schema: public; Owner: braup
--

CREATE TABLE public.glims_table_fields (
    table_name character varying(100) NOT NULL,
    field_name character varying(100) NOT NULL
);


ALTER TABLE public.glims_table_fields OWNER TO braup;

--
-- Name: group_state_dates; Type: TABLE; Schema: public; Owner: braup
--

CREATE TABLE public.group_state_dates (
    group_id integer,
    state_id integer NOT NULL,
    rep_date timestamp without time zone
);


ALTER TABLE public.group_state_dates OWNER TO braup;

--
-- Name: groups; Type: TABLE; Schema: public; Owner: braup
--

CREATE TABLE public.groups (
    group_id integer NOT NULL,
    group_poly public.geometry NOT NULL,
    CONSTRAINT enforce_dims_group_poly CHECK ((public.st_ndims(group_poly) = 2)),
    CONSTRAINT enforce_srid_group_poly CHECK ((public.st_srid(group_poly) = 4326))
);


ALTER TABLE public.groups OWNER TO braup;

--
-- Name: gtng_order1regions; Type: TABLE; Schema: public; Owner: braup
--

CREATE TABLE public.gtng_order1regions (
    gid integer NOT NULL,
    full_name character varying(80),
    rgi_code integer,
    wgms_code character varying(80),
    geom public.geometry(MultiPolygon,4326)
);


ALTER TABLE public.gtng_order1regions OWNER TO braup;

--
-- Name: gtng_order1regions_gid_seq; Type: SEQUENCE; Schema: public; Owner: braup
--

CREATE SEQUENCE public.gtng_order1regions_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.gtng_order1regions_gid_seq OWNER TO braup;

--
-- Name: gtng_order1regions_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: braup
--

ALTER SEQUENCE public.gtng_order1regions_gid_seq OWNED BY public.gtng_order1regions.gid;


--
-- Name: gtng_order2regions; Type: TABLE; Schema: public; Owner: braup
--

CREATE TABLE public.gtng_order2regions (
    gid integer NOT NULL,
    full_name character varying(80),
    rgi_code character varying(80),
    wgms_code character varying(80),
    geom public.geometry(MultiPolygon,4326)
);


ALTER TABLE public.gtng_order2regions OWNER TO braup;

--
-- Name: gtng_order2regions_gid_seq; Type: SEQUENCE; Schema: public; Owner: braup
--

CREATE SEQUENCE public.gtng_order2regions_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.gtng_order2regions_gid_seq OWNER TO braup;

--
-- Name: gtng_order2regions_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: braup
--

ALTER SEQUENCE public.gtng_order2regions_gid_seq OWNED BY public.gtng_order2regions.gid;


--
-- Name: himalayan_dar_2007; Type: TABLE; Schema: public; Owner: braup
--

CREATE TABLE public.himalayan_dar_2007 (
    gid integer NOT NULL,
    id integer,
    area_km__2 double precision,
    the_geom public.geometry,
    CONSTRAINT enforce_dims_the_geom CHECK ((public.st_ndims(the_geom) = 2)),
    CONSTRAINT enforce_geotype_the_geom CHECK (((public.geometrytype(the_geom) = 'MULTIPOLYGON'::text) OR (the_geom IS NULL))),
    CONSTRAINT enforce_srid_the_geom CHECK ((public.st_srid(the_geom) = 4326))
);


ALTER TABLE public.himalayan_dar_2007 OWNER TO braup;

--
-- Name: himalayan_dar_2007_gid_seq; Type: SEQUENCE; Schema: public; Owner: braup
--

CREATE SEQUENCE public.himalayan_dar_2007_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.himalayan_dar_2007_gid_seq OWNER TO braup;

--
-- Name: himalayan_dar_2007_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: braup
--

ALTER SEQUENCE public.himalayan_dar_2007_gid_seq OWNED BY public.himalayan_dar_2007.gid;


--
-- Name: image; Type: TABLE; Schema: public; Owner: braup
--

CREATE TABLE public.image (
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
    image_center_loc public.geometry,
    comment text,
    CONSTRAINT enforce_dims_image_center_loc CHECK ((public.st_ndims(image_center_loc) = 3)),
    CONSTRAINT enforce_geotype_image_center_loc CHECK (((public.geometrytype(image_center_loc) = 'POINT'::text) OR (image_center_loc IS NULL))),
    CONSTRAINT enforce_srid_image_center_loc CHECK ((public.st_srid(image_center_loc) = 4326))
);


ALTER TABLE public.image OWNER TO braup;

--
-- Name: image_band; Type: TABLE; Schema: public; Owner: braup
--

CREATE TABLE public.image_band (
    band_id integer NOT NULL,
    image_id integer NOT NULL
);


ALTER TABLE public.image_band OWNER TO braup;

--
-- Name: instrument; Type: TABLE; Schema: public; Owner: braup
--

CREATE TABLE public.instrument (
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


ALTER TABLE public.instrument OWNER TO braup;

--
-- Name: image_info_view; Type: VIEW; Schema: public; Owner: braup
--

CREATE VIEW public.image_info_view AS
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
    public.st_astext(image.image_center_loc) AS image_center_loc,
    image.comment
   FROM public.image,
    public.instrument
  WHERE (image.instrument_id = instrument.instrument_id);


ALTER TABLE public.image_info_view OWNER TO braup;

--
-- Name: lon_char_valids; Type: TABLE; Schema: public; Owner: braup
--

CREATE TABLE public.lon_char_valids (
    longitudinal_characteristics integer NOT NULL,
    description text
);


ALTER TABLE public.lon_char_valids OWNER TO braup;

--
-- Name: map_metadata; Type: TABLE; Schema: public; Owner: braup
--

CREATE TABLE public.map_metadata (
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


ALTER TABLE public.map_metadata OWNER TO braup;

--
-- Name: mytestview; Type: VIEW; Schema: public; Owner: braup
--

CREATE VIEW public.mytestview AS
 SELECT gs.glacier_id AS gid,
    gd.analysis_id AS aid,
    gs.glacier_name AS gname
   FROM public.glacier_static gs,
    public.glacier_dynamic gd
  WHERE ((gs.glacier_id)::text = (gd.glacier_id)::text);


ALTER TABLE public.mytestview OWNER TO braup;

--
-- Name: point_measurement; Type: TABLE; Schema: public; Owner: braup
--

CREATE TABLE public.point_measurement (
    pnt_meas_id integer NOT NULL,
    glacier_id character varying(20) NOT NULL,
    pnt_timestamp timestamp without time zone NOT NULL,
    pnt_elev real,
    pnt_label character varying(20),
    pnt_value real,
    pnt_lon_unc real,
    pnt_lat_unc real,
    pnt_elev_unc real,
    pnt_value_unc real,
    pnt_unit character varying(10),
    comment text,
    record_status character varying(20),
    pnt_loc public.geometry,
    submission_id integer,
    CONSTRAINT enforce_dims_pnt_loc CHECK ((public.st_ndims(pnt_loc) = 2)),
    CONSTRAINT enforce_geotype_pnt_loc CHECK (((public.geometrytype(pnt_loc) = 'POINT'::text) OR (pnt_loc IS NULL))),
    CONSTRAINT enforce_srid_pnt_loc CHECK ((public.st_srid(pnt_loc) = 4326))
);


ALTER TABLE public.point_measurement OWNER TO braup;

--
-- Name: primary_classification_valids; Type: TABLE; Schema: public; Owner: braup
--

CREATE TABLE public.primary_classification_valids (
    primary_classification integer NOT NULL,
    description character varying(30)
);


ALTER TABLE public.primary_classification_valids OWNER TO braup;

--
-- Name: rc_people; Type: TABLE; Schema: public; Owner: braup
--

CREATE TABLE public.rc_people (
    rc_id integer,
    contact_id integer,
    status integer
);


ALTER TABLE public.rc_people OWNER TO braup;

--
-- Name: rc_people_nocoords; Type: VIEW; Schema: public; Owner: braup
--

CREATE VIEW public.rc_people_nocoords AS
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
    public.st_astext(people.affiliation_points) AS affiliation_points,
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
   FROM ((public.rc_people
     JOIN public.people ON ((rc_people.contact_id = people.contact_id)))
     JOIN public.regional_centers ON ((regional_centers.rc_id = rc_people.rc_id)));


ALTER TABLE public.rc_people_nocoords OWNER TO braup;

--
-- Name: rc_people_view; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.rc_people_view AS
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
   FROM ((public.rc_people
     JOIN public.people ON ((rc_people.contact_id = people.contact_id)))
     JOIN public.regional_centers ON ((regional_centers.rc_id = rc_people.rc_id)));


ALTER TABLE public.rc_people_view OWNER TO postgres;

--
-- Name: reference_document; Type: TABLE; Schema: public; Owner: braup
--

CREATE TABLE public.reference_document (
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


ALTER TABLE public.reference_document OWNER TO braup;

--
-- Name: ref_doc_id_seq; Type: SEQUENCE; Schema: public; Owner: braup
--

CREATE SEQUENCE public.ref_doc_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ref_doc_id_seq OWNER TO braup;

--
-- Name: ref_doc_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: braup
--

ALTER SEQUENCE public.ref_doc_id_seq OWNED BY public.reference_document.reference_doc_id;


--
-- Name: reference_point; Type: TABLE; Schema: public; Owner: braup
--

CREATE TABLE public.reference_point (
    ref_pnt_id character varying(20) NOT NULL,
    ref_pnt_name character varying(50),
    ref_pnt_desc text NOT NULL,
    ref_pnt_lat_unc real,
    ref_pnt_lon_unc real,
    ref_pnt_elev real,
    ref_pnt_elev_unc real,
    ref_pnt_chip_location text,
    ref_pnt_chip_src integer,
    ref_pnt_chip_num_bands integer,
    ref_pnt_chip_bands character varying(30),
    ref_pnt_img_line integer,
    ref_pnt_img_samp integer,
    ref_pnt_chip_line double precision,
    ref_pnt_chip_samp double precision,
    reference_doc_id integer,
    ref_pnt_loc public.geometry,
    CONSTRAINT enforce_dims_ref_pnt_loc CHECK ((public.st_ndims(ref_pnt_loc) = 2)),
    CONSTRAINT enforce_geotype_ref_pnt_loc CHECK (((public.geometrytype(ref_pnt_loc) = 'POINT'::text) OR (ref_pnt_loc IS NULL))),
    CONSTRAINT enforce_srid_ref_pnt_loc CHECK ((public.st_srid(ref_pnt_loc) = 4326))
);


ALTER TABLE public.reference_point OWNER TO braup;

--
-- Name: rgi_users; Type: TABLE; Schema: public; Owner: braup
--

CREATE TABLE public.rgi_users (
    id integer NOT NULL,
    surname character varying(50),
    givenname character varying(50),
    institution character varying(80),
    email character varying(40),
    intendeduse text,
    use_time timestamp with time zone
);


ALTER TABLE public.rgi_users OWNER TO braup;

--
-- Name: rgi_users_id_seq; Type: SEQUENCE; Schema: public; Owner: braup
--

CREATE SEQUENCE public.rgi_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.rgi_users_id_seq OWNER TO braup;

--
-- Name: rgi_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: braup
--

ALTER SEQUENCE public.rgi_users_id_seq OWNED BY public.rgi_users.id;


--
-- Name: starpolys; Type: TABLE; Schema: public; Owner: braup
--

CREATE TABLE public.starpolys (
    gid integer NOT NULL,
    area double precision,
    perimeter double precision,
    ice_buff2_ bigint,
    ice_buff2___3 bigint,
    begindoy integer,
    enddoy integer,
    title character varying,
    maxsunangl double precision,
    maxcloudfr integer,
    g1 integer,
    g2 integer,
    g3 integer,
    g4 integer,
    g5 integer,
    g6 integer,
    g7 integer,
    g8 integer,
    g9 integer,
    fragflag integer,
    instmode integer,
    urgentf integer,
    minlookang double precision,
    the_geom public.geometry,
    CONSTRAINT enforce_dims_the_geom CHECK ((public.st_ndims(the_geom) = 2)),
    CONSTRAINT enforce_geotype_the_geom CHECK (((public.geometrytype(the_geom) = 'MULTIPOLYGON'::text) OR (the_geom IS NULL))),
    CONSTRAINT enforce_srid_the_geom CHECK ((public.st_srid(the_geom) = 4326))
);


ALTER TABLE public.starpolys OWNER TO braup;

--
-- Name: starpolys_gid_seq; Type: SEQUENCE; Schema: public; Owner: braup
--

CREATE SEQUENCE public.starpolys_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.starpolys_gid_seq OWNER TO braup;

--
-- Name: starpolys_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: braup
--

ALTER SEQUENCE public.starpolys_gid_seq OWNED BY public.starpolys.gid;


--
-- Name: status_def; Type: TABLE; Schema: public; Owner: braup
--

CREATE TABLE public.status_def (
    id integer,
    status_defn character(20),
    comment character varying
);


ALTER TABLE public.status_def OWNER TO braup;

--
-- Name: testtable; Type: TABLE; Schema: public; Owner: braup
--

CREATE TABLE public.testtable (
    name text,
    nums integer[],
    matrix integer[]
);


ALTER TABLE public.testtable OWNER TO braup;

--
-- Name: tiepoint_region; Type: TABLE; Schema: public; Owner: braup
--

CREATE TABLE public.tiepoint_region (
    tiepoint_region_id integer NOT NULL,
    rc_id integer,
    tiepoint_region_timestamp timestamp without time zone,
    comment text,
    tiepoint_outline public.geometry,
    CONSTRAINT enforce_dims_tiepoint_outline CHECK ((public.st_ndims(tiepoint_outline) = 2)),
    CONSTRAINT enforce_geotype_tiepoint_outline CHECK (((public.geometrytype(tiepoint_outline) = 'POLYGON'::text) OR (tiepoint_outline IS NULL))),
    CONSTRAINT enforce_srid_tiepoint_outline CHECK ((public.st_srid(tiepoint_outline) = 4326))
);


ALTER TABLE public.tiepoint_region OWNER TO braup;

--
-- Name: tongue_activity_valids; Type: TABLE; Schema: public; Owner: braup
--

CREATE TABLE public.tongue_activity_valids (
    tongue_activity integer NOT NULL,
    description character varying(30)
);


ALTER TABLE public.tongue_activity_valids OWNER TO braup;

--
-- Name: vector; Type: TABLE; Schema: public; Owner: braup
--

CREATE TABLE public.vector (
    vel_set_id integer NOT NULL,
    first_pnt_loc public.geometry,
    second_pnt_loc public.geometry,
    CONSTRAINT enforce_dims_first_pnt_loc CHECK ((public.st_ndims(first_pnt_loc) = 3)),
    CONSTRAINT enforce_dims_second_pnt_loc CHECK ((public.st_ndims(second_pnt_loc) = 3)),
    CONSTRAINT enforce_geotype_first_pnt_loc CHECK (((public.geometrytype(first_pnt_loc) = 'POINT'::text) OR (first_pnt_loc IS NULL))),
    CONSTRAINT enforce_geotype_second_pnt_loc CHECK (((public.geometrytype(second_pnt_loc) = 'POINT'::text) OR (second_pnt_loc IS NULL))),
    CONSTRAINT enforce_srid_first_pnt_loc CHECK ((public.st_srid(first_pnt_loc) = 4326)),
    CONSTRAINT enforce_srid_second_pnt_loc CHECK ((public.st_srid(second_pnt_loc) = 4326))
);


ALTER TABLE public.vector OWNER TO braup;

--
-- Name: vector_set; Type: TABLE; Schema: public; Owner: braup
--

CREATE TABLE public.vector_set (
    vel_set_id integer NOT NULL,
    analysis_id1 integer NOT NULL,
    analysis_id2 integer NOT NULL,
    num_vecs integer,
    loc_unc_first_lon real,
    loc_unc_first_lat real,
    glob_unc_first_lon real,
    glob_unc_first_lat real,
    loc_unc_second_lon real,
    loc_unc_second_lat real,
    glob_unc_second_lon real,
    glob_unc_second_lat real,
    record_status character varying(20),
    submission_id integer
);


ALTER TABLE public.vector_set OWNER TO braup;

--
-- Name: country gid; Type: DEFAULT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.country ALTER COLUMN gid SET DEFAULT nextval('public.country_gid_seq'::regclass);


--
-- Name: glacier_static id_num; Type: DEFAULT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.glacier_static ALTER COLUMN id_num SET DEFAULT nextval('public.glacier_static_id_num_seq1'::regclass);


--
-- Name: gtng_order1regions gid; Type: DEFAULT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.gtng_order1regions ALTER COLUMN gid SET DEFAULT nextval('public.gtng_order1regions_gid_seq'::regclass);


--
-- Name: gtng_order2regions gid; Type: DEFAULT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.gtng_order2regions ALTER COLUMN gid SET DEFAULT nextval('public.gtng_order2regions_gid_seq'::regclass);


--
-- Name: himalayan_dar_2007 gid; Type: DEFAULT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.himalayan_dar_2007 ALTER COLUMN gid SET DEFAULT nextval('public.himalayan_dar_2007_gid_seq'::regclass);


--
-- Name: reference_document reference_doc_id; Type: DEFAULT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.reference_document ALTER COLUMN reference_doc_id SET DEFAULT nextval('public.ref_doc_id_seq'::regclass);


--
-- Name: rgi_users id; Type: DEFAULT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.rgi_users ALTER COLUMN id SET DEFAULT nextval('public.rgi_users_id_seq'::regclass);


--
-- Name: starpolys gid; Type: DEFAULT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.starpolys ALTER COLUMN gid SET DEFAULT nextval('public.starpolys_gid_seq'::regclass);


--
-- Name: ancillary_data ancillary_data_pkey; Type: CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.ancillary_data
    ADD CONSTRAINT ancillary_data_pkey PRIMARY KEY (anc_data_id);


--
-- Name: area_histogram area_histogram_pkey; Type: CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.area_histogram
    ADD CONSTRAINT area_histogram_pkey PRIMARY KEY (area_histogram_id);


--
-- Name: aster_footprints aster_footprints_pkey; Type: CONSTRAINT; Schema: public; Owner: aster_metadata
--

ALTER TABLE ONLY public.aster_footprints
    ADD CONSTRAINT aster_footprints_pkey PRIMARY KEY (aster_id);


--
-- Name: band band_pkey; Type: CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.band
    ADD CONSTRAINT band_pkey PRIMARY KEY (band_id);


--
-- Name: country country_gid_key; Type: CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.country
    ADD CONSTRAINT country_gid_key UNIQUE (gid);


--
-- Name: country country_pkey; Type: CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.country
    ADD CONSTRAINT country_pkey PRIMARY KEY (country_code2);


--
-- Name: debris_cover_valids debris_cover_valids_pkey; Type: CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.debris_cover_valids
    ADD CONSTRAINT debris_cover_valids_pkey PRIMARY KEY (debris_cover);


--
-- Name: debris_distribution_valids debris_distribution_valids_pkey; Type: CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.debris_distribution_valids
    ADD CONSTRAINT debris_distribution_valids_pkey PRIMARY KEY (debris_distribution);


--
-- Name: dominant_mass_source_valids dominant_mass_source_valids_pkey; Type: CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.dominant_mass_source_valids
    ADD CONSTRAINT dominant_mass_source_valids_pkey PRIMARY KEY (dominant_mass_source);


--
-- Name: form_valids form_valids_pkey; Type: CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.form_valids
    ADD CONSTRAINT form_valids_pkey PRIMARY KEY (form);


--
-- Name: frontal_characteristics_valids frontal_characteristics_valids_pkey; Type: CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.frontal_characteristics_valids
    ADD CONSTRAINT frontal_characteristics_valids_pkey PRIMARY KEY (frontal_characteristics);


--
-- Name: glacier_countries glacier_countries_pkey; Type: CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.glacier_countries
    ADD CONSTRAINT glacier_countries_pkey PRIMARY KEY (glacier_id, country_id);


--
-- Name: glacier_dynamic glacier_dynamic_pkey; Type: CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.glacier_dynamic
    ADD CONSTRAINT glacier_dynamic_pkey PRIMARY KEY (analysis_id);


--
-- Name: glacier_static glacier_static_pkey; Type: CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.glacier_static
    ADD CONSTRAINT glacier_static_pkey PRIMARY KEY (glacier_id);


--
-- Name: glims_aster_footprints glims_aster_footprints_pkey; Type: CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.glims_aster_footprints
    ADD CONSTRAINT glims_aster_footprints_pkey PRIMARY KEY (aster_id);


--
-- Name: groups groups_pkey; Type: CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (group_id);


--
-- Name: gtng_order1regions gtng_order1regions_pkey; Type: CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.gtng_order1regions
    ADD CONSTRAINT gtng_order1regions_pkey PRIMARY KEY (gid);


--
-- Name: gtng_order2regions gtng_order2regions_pkey; Type: CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.gtng_order2regions
    ADD CONSTRAINT gtng_order2regions_pkey PRIMARY KEY (gid);


--
-- Name: himalayan_dar_2007 himalayan_dar_2007_pkey; Type: CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.himalayan_dar_2007
    ADD CONSTRAINT himalayan_dar_2007_pkey PRIMARY KEY (gid);


--
-- Name: image image_pkey; Type: CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.image
    ADD CONSTRAINT image_pkey PRIMARY KEY (image_id);


--
-- Name: instrument instrument_pkey; Type: CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.instrument
    ADD CONSTRAINT instrument_pkey PRIMARY KEY (instrument_id);


--
-- Name: lon_char_valids lon_char_valids_pkey; Type: CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.lon_char_valids
    ADD CONSTRAINT lon_char_valids_pkey PRIMARY KEY (longitudinal_characteristics);


--
-- Name: map_metadata map_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.map_metadata
    ADD CONSTRAINT map_metadata_pkey PRIMARY KEY (map_id);


--
-- Name: people people_pkey; Type: CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.people
    ADD CONSTRAINT people_pkey PRIMARY KEY (contact_id);


--
-- Name: point_measurement point_measurement_pkey; Type: CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.point_measurement
    ADD CONSTRAINT point_measurement_pkey PRIMARY KEY (pnt_meas_id);


--
-- Name: primary_classification_valids primary_classification_valids_pkey; Type: CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.primary_classification_valids
    ADD CONSTRAINT primary_classification_valids_pkey PRIMARY KEY (primary_classification);


--
-- Name: reference_document reference_document_pkey; Type: CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.reference_document
    ADD CONSTRAINT reference_document_pkey PRIMARY KEY (reference_doc_id);


--
-- Name: reference_point reference_point_pkey; Type: CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.reference_point
    ADD CONSTRAINT reference_point_pkey PRIMARY KEY (ref_pnt_id);


--
-- Name: regional_centers regional_centers_pkey; Type: CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.regional_centers
    ADD CONSTRAINT regional_centers_pkey PRIMARY KEY (rc_id);


--
-- Name: segment segment_pkey; Type: CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.segment
    ADD CONSTRAINT segment_pkey PRIMARY KEY (segment_id);


--
-- Name: starpolys starpolys_pkey; Type: CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.starpolys
    ADD CONSTRAINT starpolys_pkey PRIMARY KEY (gid);


--
-- Name: submission_info submission_info_pkey; Type: CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.submission_info
    ADD CONSTRAINT submission_info_pkey PRIMARY KEY (submission_id);


--
-- Name: tiepoint_region tiepoint_region_pkey; Type: CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.tiepoint_region
    ADD CONSTRAINT tiepoint_region_pkey PRIMARY KEY (tiepoint_region_id);


--
-- Name: tongue_activity_valids tongue_activity_valids_pkey; Type: CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.tongue_activity_valids
    ADD CONSTRAINT tongue_activity_valids_pkey PRIMARY KEY (tongue_activity);


--
-- Name: vector_set vector_set_pkey; Type: CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.vector_set
    ADD CONSTRAINT vector_set_pkey PRIMARY KEY (vel_set_id);


--
-- Name: analyses_groups_analysis_id_index; Type: INDEX; Schema: public; Owner: braup
--

CREATE INDEX analyses_groups_analysis_id_index ON public.analyses_groups USING btree (analysis_id);


--
-- Name: analyses_groups_group_id_index; Type: INDEX; Schema: public; Owner: braup
--

CREATE INDEX analyses_groups_group_id_index ON public.analyses_groups USING btree (group_id);


--
-- Name: analyses_groups_state_id_index; Type: INDEX; Schema: public; Owner: braup
--

CREATE INDEX analyses_groups_state_id_index ON public.analyses_groups USING btree (state_id);


--
-- Name: analysis_id_index; Type: INDEX; Schema: public; Owner: braup
--

CREATE INDEX analysis_id_index ON public.glacier_line USING btree (analysis_id);


--
-- Name: cntry_name_index; Type: INDEX; Schema: public; Owner: braup
--

CREATE INDEX cntry_name_index ON public.country USING btree (cntry_name);


--
-- Name: country_index; Type: INDEX; Schema: public; Owner: braup
--

CREATE INDEX country_index ON public.country USING gist (borders);


--
-- Name: glac_dyn_submission_id_index; Type: INDEX; Schema: public; Owner: braup
--

CREATE INDEX glac_dyn_submission_id_index ON public.glacier_dynamic USING btree (submission_id);


--
-- Name: glacier_dynamic_glacier_id; Type: INDEX; Schema: public; Owner: braup
--

CREATE INDEX glacier_dynamic_glacier_id ON public.glacier_dynamic USING btree (glacier_id);


--
-- Name: glacier_dynamic_record_status; Type: INDEX; Schema: public; Owner: braup
--

CREATE INDEX glacier_dynamic_record_status ON public.glacier_dynamic USING btree (record_status);


--
-- Name: glacier_dynamic_source_timestamp; Type: INDEX; Schema: public; Owner: braup
--

CREATE INDEX glacier_dynamic_source_timestamp ON public.glacier_dynamic USING btree (source_timestamp);


--
-- Name: glacier_poly_index; Type: INDEX; Schema: public; Owner: braup
--

CREATE INDEX glacier_poly_index ON public.glacier_polygons USING gist (glacier_polys);

ALTER TABLE public.glacier_polygons CLUSTER ON glacier_poly_index;


--
-- Name: glacier_polygons_anal_id_index; Type: INDEX; Schema: public; Owner: braup
--

CREATE INDEX glacier_polygons_anal_id_index ON public.glacier_polygons USING btree (analysis_id);


--
-- Name: glacier_static_point_index; Type: INDEX; Schema: public; Owner: braup
--

CREATE INDEX glacier_static_point_index ON public.glacier_static USING gist (glac_static_points);


--
-- Name: glims_aster_ftprnts_index; Type: INDEX; Schema: public; Owner: braup
--

CREATE INDEX glims_aster_ftprnts_index ON public.glims_aster_footprints USING gist (glims_footprints);


--
-- Name: group_poly_index; Type: INDEX; Schema: public; Owner: braup
--

CREATE INDEX group_poly_index ON public.groups USING gist (group_poly);

ALTER TABLE public.groups CLUSTER ON group_poly_index;


--
-- Name: group_state_dates_group_id_index; Type: INDEX; Schema: public; Owner: braup
--

CREATE INDEX group_state_dates_group_id_index ON public.group_state_dates USING btree (group_id);


--
-- Name: group_state_dates_state_id_index; Type: INDEX; Schema: public; Owner: braup
--

CREATE INDEX group_state_dates_state_id_index ON public.group_state_dates USING btree (state_id);


--
-- Name: groups_group_id_index; Type: INDEX; Schema: public; Owner: braup
--

CREATE INDEX groups_group_id_index ON public.groups USING btree (group_id);


--
-- Name: gtng_order1regions_geom_idx; Type: INDEX; Schema: public; Owner: braup
--

CREATE INDEX gtng_order1regions_geom_idx ON public.gtng_order1regions USING gist (geom);


--
-- Name: gtng_order2regions_geom_idx; Type: INDEX; Schema: public; Owner: braup
--

CREATE INDEX gtng_order2regions_geom_idx ON public.gtng_order2regions USING gist (geom);


--
-- Name: id_num_idx; Type: INDEX; Schema: public; Owner: braup
--

CREATE INDEX id_num_idx ON public.glacier_static USING btree (id_num);


--
-- Name: people_affiliation_index; Type: INDEX; Schema: public; Owner: braup
--

CREATE INDEX people_affiliation_index ON public.people USING btree (affiliation);


--
-- Name: people_ccode_index; Type: INDEX; Schema: public; Owner: braup
--

CREATE INDEX people_ccode_index ON public.people USING btree (country_code);


--
-- Name: people_givennames_index; Type: INDEX; Schema: public; Owner: braup
--

CREATE INDEX people_givennames_index ON public.people USING btree (givennames);


--
-- Name: people_points_index; Type: INDEX; Schema: public; Owner: braup
--

CREATE INDEX people_points_index ON public.people USING gist (affiliation_points);


--
-- Name: people_surname_index; Type: INDEX; Schema: public; Owner: braup
--

CREATE INDEX people_surname_index ON public.people USING btree (surname);


--
-- Name: people_url_primary_index; Type: INDEX; Schema: public; Owner: braup
--

CREATE INDEX people_url_primary_index ON public.people USING btree (url_primary);


--
-- Name: rc_poly_index; Type: INDEX; Schema: public; Owner: braup
--

CREATE INDEX rc_poly_index ON public.regional_centers USING gist (regional_center_polys);


--
-- Name: segment_id_index; Type: INDEX; Schema: public; Owner: braup
--

CREATE INDEX segment_id_index ON public.glacier_line USING btree (segment_id);


--
-- Name: segment_index; Type: INDEX; Schema: public; Owner: braup
--

CREATE INDEX segment_index ON public.segment USING gist (segment_lines);


--
-- Name: starpoly_index; Type: INDEX; Schema: public; Owner: braup
--

CREATE INDEX starpoly_index ON public.starpolys USING gist (the_geom);


--
-- Name: submission_info_rc_id_index; Type: INDEX; Schema: public; Owner: braup
--

CREATE INDEX submission_info_rc_id_index ON public.submission_info USING btree (rc_id);


--
-- Name: submission_info_rel_okay_date_index; Type: INDEX; Schema: public; Owner: braup
--

CREATE INDEX submission_info_rel_okay_date_index ON public.submission_info USING btree (release_okay_date);


--
-- Name: submission_info_submitter_id_index; Type: INDEX; Schema: public; Owner: braup
--

CREATE INDEX submission_info_submitter_id_index ON public.submission_info USING btree (submitter_id);


--
-- Name: analyses_groups analyses_groups_analysis_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.analyses_groups
    ADD CONSTRAINT analyses_groups_analysis_id_fkey FOREIGN KEY (analysis_id) REFERENCES public.glacier_dynamic(analysis_id);


--
-- Name: analyses_groups analyses_groups_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.analyses_groups
    ADD CONSTRAINT analyses_groups_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.groups(group_id);


--
-- Name: area_histogram area_histogram_analysis_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.area_histogram
    ADD CONSTRAINT area_histogram_analysis_id_fkey FOREIGN KEY (analysis_id) REFERENCES public.glacier_dynamic(analysis_id);


--
-- Name: area_histogram_data area_histogram_data_area_histogram_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.area_histogram_data
    ADD CONSTRAINT area_histogram_data_area_histogram_id_fkey FOREIGN KEY (area_histogram_id) REFERENCES public.area_histogram(area_histogram_id);


--
-- Name: band band_instrument_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.band
    ADD CONSTRAINT band_instrument_id_fkey FOREIGN KEY (instrument_id) REFERENCES public.instrument(instrument_id);


--
-- Name: glacier_ancillary_info glacier_ancillary_info_analysis_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.glacier_ancillary_info
    ADD CONSTRAINT glacier_ancillary_info_analysis_id_fkey FOREIGN KEY (analysis_id) REFERENCES public.glacier_dynamic(analysis_id);


--
-- Name: glacier_ancillary_info glacier_ancillary_info_data_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.glacier_ancillary_info
    ADD CONSTRAINT glacier_ancillary_info_data_id_fkey FOREIGN KEY (anc_data_id) REFERENCES public.ancillary_data(anc_data_id);


--
-- Name: glacier_countries glacier_countries_country_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.glacier_countries
    ADD CONSTRAINT glacier_countries_country_id_fkey FOREIGN KEY (country_id) REFERENCES public.country(gid);


--
-- Name: glacier_countries glacier_countries_glacier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.glacier_countries
    ADD CONSTRAINT glacier_countries_glacier_id_fkey FOREIGN KEY (glacier_id) REFERENCES public.glacier_static(glacier_id);


--
-- Name: glacier_dynamic glacier_dynamic_contact_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.glacier_dynamic
    ADD CONSTRAINT glacier_dynamic_contact_id_fkey FOREIGN KEY (contact_id) REFERENCES public.people(contact_id);


--
-- Name: glacier_dynamic glacier_dynamic_glacier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.glacier_dynamic
    ADD CONSTRAINT glacier_dynamic_glacier_id_fkey FOREIGN KEY (glacier_id) REFERENCES public.glacier_static(glacier_id);


--
-- Name: glacier_dynamic glacier_dynamic_rc_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.glacier_dynamic
    ADD CONSTRAINT glacier_dynamic_rc_id_fkey FOREIGN KEY (rc_id) REFERENCES public.regional_centers(rc_id);


--
-- Name: glacier_dynamic glacier_dynamic_submission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.glacier_dynamic
    ADD CONSTRAINT glacier_dynamic_submission_id_fkey FOREIGN KEY (submission_id) REFERENCES public.submission_info(submission_id);


--
-- Name: glacier_image_info glacier_image_info_analysis_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.glacier_image_info
    ADD CONSTRAINT glacier_image_info_analysis_id_fkey FOREIGN KEY (analysis_id) REFERENCES public.glacier_dynamic(analysis_id);


--
-- Name: glacier_image_info glacier_image_info_image_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.glacier_image_info
    ADD CONSTRAINT glacier_image_info_image_id_fkey FOREIGN KEY (image_id) REFERENCES public.image(image_id);


--
-- Name: glacier_line glacier_line_analysis_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.glacier_line
    ADD CONSTRAINT glacier_line_analysis_id_fkey FOREIGN KEY (analysis_id) REFERENCES public.glacier_dynamic(analysis_id);


--
-- Name: glacier_line glacier_line_segment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.glacier_line
    ADD CONSTRAINT glacier_line_segment_id_fkey FOREIGN KEY (segment_id) REFERENCES public.segment(segment_id);


--
-- Name: glacier_map_info glacier_map_info_analysis_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.glacier_map_info
    ADD CONSTRAINT glacier_map_info_analysis_id_fkey FOREIGN KEY (analysis_id) REFERENCES public.glacier_dynamic(analysis_id);


--
-- Name: glacier_map_info glacier_map_info_mad_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.glacier_map_info
    ADD CONSTRAINT glacier_map_info_mad_id_fkey FOREIGN KEY (map_id) REFERENCES public.map_metadata(map_id);


--
-- Name: glacier_polygons glacier_polygons_analysis_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.glacier_polygons
    ADD CONSTRAINT glacier_polygons_analysis_id_fkey FOREIGN KEY (analysis_id) REFERENCES public.glacier_dynamic(analysis_id);


--
-- Name: glacier_reference glacier_reference_glacier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.glacier_reference
    ADD CONSTRAINT glacier_reference_glacier_id_fkey FOREIGN KEY (glacier_id) REFERENCES public.glacier_static(glacier_id);


--
-- Name: glacier_reference glacier_reference_reference_doc_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.glacier_reference
    ADD CONSTRAINT glacier_reference_reference_doc_id_fkey FOREIGN KEY (reference_doc_id) REFERENCES public.reference_document(reference_doc_id);


--
-- Name: glacier_static glacier_static_submission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.glacier_static
    ADD CONSTRAINT glacier_static_submission_id_fkey FOREIGN KEY (submission_id) REFERENCES public.submission_info(submission_id);


--
-- Name: group_state_dates group_state_dates_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.group_state_dates
    ADD CONSTRAINT group_state_dates_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.groups(group_id);


--
-- Name: image_band image_band_band_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.image_band
    ADD CONSTRAINT image_band_band_id_fkey FOREIGN KEY (band_id) REFERENCES public.band(band_id);


--
-- Name: image_band image_band_image_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.image_band
    ADD CONSTRAINT image_band_image_id_fkey FOREIGN KEY (image_id) REFERENCES public.image(image_id);


--
-- Name: image image_instrument_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.image
    ADD CONSTRAINT image_instrument_id_fkey FOREIGN KEY (instrument_id) REFERENCES public.instrument(instrument_id);


--
-- Name: image image_mosaic_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.image
    ADD CONSTRAINT image_mosaic_id_fkey FOREIGN KEY (mosaic_id) REFERENCES public.image(image_id);


--
-- Name: people people_country_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.people
    ADD CONSTRAINT people_country_code_fkey FOREIGN KEY (country_code) REFERENCES public.country(country_code2);


--
-- Name: point_measurement point_measurement_glacier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.point_measurement
    ADD CONSTRAINT point_measurement_glacier_id_fkey FOREIGN KEY (glacier_id) REFERENCES public.glacier_static(glacier_id);


--
-- Name: point_measurement point_measurement_submission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.point_measurement
    ADD CONSTRAINT point_measurement_submission_id_fkey FOREIGN KEY (submission_id) REFERENCES public.submission_info(submission_id);


--
-- Name: rc_people rc_people_contact_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.rc_people
    ADD CONSTRAINT rc_people_contact_id_fkey FOREIGN KEY (contact_id) REFERENCES public.people(contact_id);


--
-- Name: rc_people rc_people_rc_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.rc_people
    ADD CONSTRAINT rc_people_rc_id_fkey FOREIGN KEY (rc_id) REFERENCES public.regional_centers(rc_id);


--
-- Name: reference_point reference_point_ref_pnt_chip_src_fkey; Type: FK CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.reference_point
    ADD CONSTRAINT reference_point_ref_pnt_chip_src_fkey FOREIGN KEY (ref_pnt_chip_src) REFERENCES public.instrument(instrument_id);


--
-- Name: reference_point reference_point_reference_doc_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.reference_point
    ADD CONSTRAINT reference_point_reference_doc_id_fkey FOREIGN KEY (reference_doc_id) REFERENCES public.reference_document(reference_doc_id);


--
-- Name: regional_centers regional_centers_chief_fkey; Type: FK CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.regional_centers
    ADD CONSTRAINT regional_centers_chief_fkey FOREIGN KEY (chief) REFERENCES public.people(contact_id);


--
-- Name: regional_centers regional_centers_main_contact_fkey; Type: FK CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.regional_centers
    ADD CONSTRAINT regional_centers_main_contact_fkey FOREIGN KEY (main_contact) REFERENCES public.people(contact_id);


--
-- Name: regional_centers regional_centers_parent_rc_fkey; Type: FK CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.regional_centers
    ADD CONSTRAINT regional_centers_parent_rc_fkey FOREIGN KEY (parent_rc) REFERENCES public.regional_centers(rc_id);


--
-- Name: submission_analyst submission_analyst_analyst_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.submission_analyst
    ADD CONSTRAINT submission_analyst_analyst_id_fkey FOREIGN KEY (analyst_id) REFERENCES public.people(contact_id);


--
-- Name: submission_analyst submission_analyst_submission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.submission_analyst
    ADD CONSTRAINT submission_analyst_submission_id_fkey FOREIGN KEY (submission_id) REFERENCES public.submission_info(submission_id);


--
-- Name: submission_info submission_info_rc_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.submission_info
    ADD CONSTRAINT submission_info_rc_id_fkey FOREIGN KEY (rc_id) REFERENCES public.regional_centers(rc_id);


--
-- Name: submission_info submission_info_submitter_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.submission_info
    ADD CONSTRAINT submission_info_submitter_id_fkey FOREIGN KEY (submitter_id) REFERENCES public.people(contact_id);


--
-- Name: tiepoint_region tiepoint_region_rc_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.tiepoint_region
    ADD CONSTRAINT tiepoint_region_rc_id_fkey FOREIGN KEY (rc_id) REFERENCES public.regional_centers(rc_id);


--
-- Name: vector_set vector_set_submission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.vector_set
    ADD CONSTRAINT vector_set_submission_id_fkey FOREIGN KEY (submission_id) REFERENCES public.submission_info(submission_id);


--
-- Name: vector vector_vel_set_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: braup
--

ALTER TABLE ONLY public.vector
    ADD CONSTRAINT vector_vel_set_id_fkey FOREIGN KEY (vel_set_id) REFERENCES public.vector_set(vel_set_id);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO braup;
GRANT USAGE ON SCHEMA public TO glims_rc;
GRANT USAGE ON SCHEMA public TO aster_metadata;
GRANT USAGE ON SCHEMA public TO glims_ro;
GRANT ALL ON SCHEMA public TO glims_rw;
GRANT USAGE ON SCHEMA public TO glu;
GRANT USAGE ON SCHEMA public TO rgi_role;


--
-- Name: TABLE analyses_groups; Type: ACL; Schema: public; Owner: braup
--

GRANT SELECT ON TABLE public.analyses_groups TO glims_ro;
GRANT ALL ON TABLE public.analyses_groups TO glims_rw;
GRANT SELECT ON TABLE public.analyses_groups TO glims_rc;
GRANT SELECT ON TABLE public.analyses_groups TO glu;
GRANT SELECT ON TABLE public.analyses_groups TO rgi_role;


--
-- Name: TABLE ancillary_data; Type: ACL; Schema: public; Owner: braup
--

GRANT ALL ON TABLE public.ancillary_data TO glims_rw;
GRANT SELECT ON TABLE public.ancillary_data TO glims_rc;
GRANT SELECT ON TABLE public.ancillary_data TO glims_ro;
GRANT SELECT ON TABLE public.ancillary_data TO aster_metadata;
GRANT SELECT ON TABLE public.ancillary_data TO glu;
GRANT SELECT ON TABLE public.ancillary_data TO rgi_role;


--
-- Name: TABLE area_histogram; Type: ACL; Schema: public; Owner: braup
--

GRANT ALL ON TABLE public.area_histogram TO glims_rw;
GRANT SELECT ON TABLE public.area_histogram TO glims_rc;
GRANT SELECT ON TABLE public.area_histogram TO glims_ro;
GRANT SELECT ON TABLE public.area_histogram TO aster_metadata;
GRANT SELECT ON TABLE public.area_histogram TO glu;
GRANT SELECT ON TABLE public.area_histogram TO rgi_role;


--
-- Name: TABLE area_histogram_data; Type: ACL; Schema: public; Owner: braup
--

GRANT ALL ON TABLE public.area_histogram_data TO glims_rw;
GRANT SELECT ON TABLE public.area_histogram_data TO glims_rc;
GRANT SELECT ON TABLE public.area_histogram_data TO glims_ro;
GRANT SELECT ON TABLE public.area_histogram_data TO aster_metadata;
GRANT SELECT ON TABLE public.area_histogram_data TO glu;
GRANT SELECT ON TABLE public.area_histogram_data TO rgi_role;


--
-- Name: TABLE aster_footprints; Type: ACL; Schema: public; Owner: aster_metadata
--

GRANT SELECT ON TABLE public.aster_footprints TO glims_ro;
GRANT ALL ON TABLE public.aster_footprints TO braup;
GRANT SELECT ON TABLE public.aster_footprints TO glu;
GRANT SELECT ON TABLE public.aster_footprints TO rgi_role;
GRANT SELECT ON TABLE public.aster_footprints TO glims_rc;
GRANT ALL ON TABLE public.aster_footprints TO glims_rw;


--
-- Name: TABLE band; Type: ACL; Schema: public; Owner: braup
--

GRANT ALL ON TABLE public.band TO glims_rw;
GRANT SELECT ON TABLE public.band TO glims_rc;
GRANT SELECT ON TABLE public.band TO glims_ro;
GRANT SELECT ON TABLE public.band TO aster_metadata;
GRANT SELECT ON TABLE public.band TO glu;
GRANT SELECT ON TABLE public.band TO rgi_role;


--
-- Name: TABLE country; Type: ACL; Schema: public; Owner: braup
--

GRANT ALL ON TABLE public.country TO glims_rw;
GRANT SELECT ON TABLE public.country TO glims_rc;
GRANT SELECT ON TABLE public.country TO glims_ro;
GRANT SELECT ON TABLE public.country TO aster_metadata;
GRANT SELECT ON TABLE public.country TO glu;
GRANT SELECT ON TABLE public.country TO rgi_role;


--
-- Name: SEQUENCE country_gid_seq; Type: ACL; Schema: public; Owner: braup
--

GRANT ALL ON SEQUENCE public.country_gid_seq TO glims_rw;
GRANT SELECT ON SEQUENCE public.country_gid_seq TO glims_ro;


--
-- Name: TABLE debris_cover_valids; Type: ACL; Schema: public; Owner: braup
--

GRANT ALL ON TABLE public.debris_cover_valids TO glims_rw;
GRANT SELECT ON TABLE public.debris_cover_valids TO glims_rc;
GRANT SELECT ON TABLE public.debris_cover_valids TO glims_ro;
GRANT SELECT ON TABLE public.debris_cover_valids TO aster_metadata;
GRANT SELECT ON TABLE public.debris_cover_valids TO glu;
GRANT SELECT ON TABLE public.debris_cover_valids TO rgi_role;


--
-- Name: TABLE debris_distribution_valids; Type: ACL; Schema: public; Owner: braup
--

GRANT ALL ON TABLE public.debris_distribution_valids TO glims_rw;
GRANT SELECT ON TABLE public.debris_distribution_valids TO glims_rc;
GRANT SELECT ON TABLE public.debris_distribution_valids TO glims_ro;
GRANT SELECT ON TABLE public.debris_distribution_valids TO aster_metadata;
GRANT SELECT ON TABLE public.debris_distribution_valids TO glu;
GRANT SELECT ON TABLE public.debris_distribution_valids TO rgi_role;


--
-- Name: TABLE dominant_mass_source_valids; Type: ACL; Schema: public; Owner: braup
--

GRANT ALL ON TABLE public.dominant_mass_source_valids TO glims_rw;
GRANT SELECT ON TABLE public.dominant_mass_source_valids TO glims_rc;
GRANT SELECT ON TABLE public.dominant_mass_source_valids TO glims_ro;
GRANT SELECT ON TABLE public.dominant_mass_source_valids TO aster_metadata;
GRANT SELECT ON TABLE public.dominant_mass_source_valids TO glu;
GRANT SELECT ON TABLE public.dominant_mass_source_valids TO rgi_role;


--
-- Name: TABLE glacier_static; Type: ACL; Schema: public; Owner: braup
--

GRANT ALL ON TABLE public.glacier_static TO glims_rw;
GRANT SELECT ON TABLE public.glacier_static TO glims_rc;
GRANT SELECT ON TABLE public.glacier_static TO glims_ro;
GRANT SELECT ON TABLE public.glacier_static TO aster_metadata;
GRANT SELECT ON TABLE public.glacier_static TO glu;
GRANT SELECT ON TABLE public.glacier_static TO rgi_role;


--
-- Name: TABLE extinct_glaciers_view; Type: ACL; Schema: public; Owner: braup
--

GRANT SELECT ON TABLE public.extinct_glaciers_view TO glims_ro;


--
-- Name: TABLE form_valids; Type: ACL; Schema: public; Owner: braup
--

GRANT ALL ON TABLE public.form_valids TO glims_rw;
GRANT SELECT ON TABLE public.form_valids TO glims_rc;
GRANT SELECT ON TABLE public.form_valids TO glims_ro;
GRANT SELECT ON TABLE public.form_valids TO aster_metadata;
GRANT SELECT ON TABLE public.form_valids TO glu;
GRANT SELECT ON TABLE public.form_valids TO rgi_role;


--
-- Name: TABLE frontal_characteristics_valids; Type: ACL; Schema: public; Owner: braup
--

GRANT ALL ON TABLE public.frontal_characteristics_valids TO glims_rw;
GRANT SELECT ON TABLE public.frontal_characteristics_valids TO glims_rc;
GRANT SELECT ON TABLE public.frontal_characteristics_valids TO glims_ro;
GRANT SELECT ON TABLE public.frontal_characteristics_valids TO aster_metadata;
GRANT SELECT ON TABLE public.frontal_characteristics_valids TO glu;
GRANT SELECT ON TABLE public.frontal_characteristics_valids TO rgi_role;


--
-- Name: TABLE glacier_ancillary_info; Type: ACL; Schema: public; Owner: braup
--

GRANT ALL ON TABLE public.glacier_ancillary_info TO glims_rw;
GRANT SELECT ON TABLE public.glacier_ancillary_info TO glims_rc;
GRANT SELECT ON TABLE public.glacier_ancillary_info TO glims_ro;
GRANT SELECT ON TABLE public.glacier_ancillary_info TO aster_metadata;
GRANT SELECT ON TABLE public.glacier_ancillary_info TO glu;
GRANT SELECT ON TABLE public.glacier_ancillary_info TO rgi_role;


--
-- Name: TABLE glacier_countries; Type: ACL; Schema: public; Owner: braup
--

GRANT SELECT ON TABLE public.glacier_countries TO glims_ro;
GRANT SELECT,INSERT,UPDATE ON TABLE public.glacier_countries TO glims_rw;


--
-- Name: TABLE glacier_dynamic; Type: ACL; Schema: public; Owner: braup
--

GRANT ALL ON TABLE public.glacier_dynamic TO glims_rw;
GRANT SELECT ON TABLE public.glacier_dynamic TO glims_rc;
GRANT SELECT ON TABLE public.glacier_dynamic TO glims_ro;
GRANT SELECT ON TABLE public.glacier_dynamic TO aster_metadata;
GRANT SELECT ON TABLE public.glacier_dynamic TO glu;
GRANT SELECT ON TABLE public.glacier_dynamic TO rgi_role;


--
-- Name: TABLE glacier_image_info; Type: ACL; Schema: public; Owner: braup
--

GRANT ALL ON TABLE public.glacier_image_info TO glims_rw;
GRANT SELECT ON TABLE public.glacier_image_info TO glims_rc;
GRANT SELECT ON TABLE public.glacier_image_info TO glims_ro;
GRANT SELECT ON TABLE public.glacier_image_info TO aster_metadata;
GRANT SELECT ON TABLE public.glacier_image_info TO glu;
GRANT SELECT ON TABLE public.glacier_image_info TO rgi_role;


--
-- Name: TABLE glacier_line; Type: ACL; Schema: public; Owner: braup
--

GRANT ALL ON TABLE public.glacier_line TO glims_rw;
GRANT SELECT ON TABLE public.glacier_line TO glims_rc;
GRANT SELECT ON TABLE public.glacier_line TO glims_ro;
GRANT SELECT ON TABLE public.glacier_line TO aster_metadata;
GRANT SELECT ON TABLE public.glacier_line TO glu;
GRANT SELECT ON TABLE public.glacier_line TO rgi_role;


--
-- Name: TABLE people; Type: ACL; Schema: public; Owner: braup
--

GRANT ALL ON TABLE public.people TO glims_rw;
GRANT SELECT ON TABLE public.people TO glims_ro;
GRANT SELECT ON TABLE public.people TO aster_metadata;
GRANT SELECT ON TABLE public.people TO glu;
GRANT SELECT ON TABLE public.people TO rgi_role;
GRANT SELECT,UPDATE ON TABLE public.people TO glims_rc;


--
-- Name: TABLE regional_centers; Type: ACL; Schema: public; Owner: braup
--

GRANT ALL ON TABLE public.regional_centers TO glims_rw;
GRANT SELECT ON TABLE public.regional_centers TO glims_rc;
GRANT SELECT ON TABLE public.regional_centers TO glims_ro;
GRANT SELECT ON TABLE public.regional_centers TO aster_metadata;
GRANT SELECT ON TABLE public.regional_centers TO glu;
GRANT SELECT ON TABLE public.regional_centers TO rgi_role;


--
-- Name: TABLE segment; Type: ACL; Schema: public; Owner: braup
--

GRANT ALL ON TABLE public.segment TO glims_rw;
GRANT SELECT ON TABLE public.segment TO glims_rc;
GRANT SELECT ON TABLE public.segment TO glims_ro;
GRANT SELECT ON TABLE public.segment TO aster_metadata;
GRANT SELECT ON TABLE public.segment TO glu;
GRANT SELECT ON TABLE public.segment TO rgi_role;


--
-- Name: TABLE submission_info; Type: ACL; Schema: public; Owner: braup
--

GRANT ALL ON TABLE public.submission_info TO glims_rw;
GRANT SELECT ON TABLE public.submission_info TO glims_rc;
GRANT SELECT ON TABLE public.submission_info TO glims_ro;
GRANT SELECT ON TABLE public.submission_info TO aster_metadata;
GRANT SELECT ON TABLE public.submission_info TO glu;
GRANT SELECT ON TABLE public.submission_info TO rgi_role;


--
-- Name: TABLE submission_rc_info; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.submission_rc_info TO glu;
GRANT SELECT ON TABLE public.submission_rc_info TO rgi_role;
GRANT ALL ON TABLE public.submission_rc_info TO glims_rw;
GRANT SELECT ON TABLE public.submission_rc_info TO glims_rc;
GRANT SELECT ON TABLE public.submission_rc_info TO glims_ro;
GRANT ALL ON TABLE public.submission_rc_info TO braup;
GRANT SELECT ON TABLE public.submission_rc_info TO aster_metadata;


--
-- Name: TABLE glacier_line_query_no_people; Type: ACL; Schema: public; Owner: braup
--

GRANT SELECT ON TABLE public.glacier_line_query_no_people TO glims_ro;
GRANT ALL ON TABLE public.glacier_line_query_no_people TO glims_rw;
GRANT SELECT ON TABLE public.glacier_line_query_no_people TO aster_metadata;
GRANT SELECT ON TABLE public.glacier_line_query_no_people TO glims_rc;
GRANT SELECT ON TABLE public.glacier_line_query_no_people TO glu;
GRANT SELECT ON TABLE public.glacier_line_query_no_people TO rgi_role;


--
-- Name: TABLE glacier_line_query_no_people_v3; Type: ACL; Schema: public; Owner: braup
--

GRANT SELECT ON TABLE public.glacier_line_query_no_people_v3 TO glims_ro;


--
-- Name: TABLE glacier_polygons; Type: ACL; Schema: public; Owner: braup
--

GRANT ALL ON TABLE public.glacier_polygons TO glims_rw;
GRANT SELECT ON TABLE public.glacier_polygons TO glims_rc;
GRANT SELECT ON TABLE public.glacier_polygons TO glims_ro;
GRANT SELECT ON TABLE public.glacier_polygons TO aster_metadata;
GRANT SELECT ON TABLE public.glacier_polygons TO glu;
GRANT SELECT ON TABLE public.glacier_polygons TO rgi_role;


--
-- Name: TABLE glacier_lines_disp; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.glacier_lines_disp TO glu;
GRANT SELECT ON TABLE public.glacier_lines_disp TO rgi_role;
GRANT ALL ON TABLE public.glacier_lines_disp TO glims_rw;
GRANT SELECT ON TABLE public.glacier_lines_disp TO glims_rc;
GRANT SELECT ON TABLE public.glacier_lines_disp TO glims_ro;
GRANT ALL ON TABLE public.glacier_lines_disp TO braup;
GRANT SELECT ON TABLE public.glacier_lines_disp TO aster_metadata;


--
-- Name: TABLE glacier_map_info; Type: ACL; Schema: public; Owner: braup
--

GRANT ALL ON TABLE public.glacier_map_info TO glims_rw;
GRANT SELECT ON TABLE public.glacier_map_info TO glims_rc;
GRANT SELECT ON TABLE public.glacier_map_info TO glims_ro;
GRANT SELECT ON TABLE public.glacier_map_info TO aster_metadata;
GRANT SELECT ON TABLE public.glacier_map_info TO glu;
GRANT SELECT ON TABLE public.glacier_map_info TO rgi_role;


--
-- Name: TABLE submission_analyst; Type: ACL; Schema: public; Owner: braup
--

GRANT ALL ON TABLE public.submission_analyst TO glims_rw;
GRANT SELECT ON TABLE public.submission_analyst TO glims_rc;
GRANT SELECT ON TABLE public.submission_analyst TO glims_ro;
GRANT SELECT ON TABLE public.submission_analyst TO aster_metadata;
GRANT SELECT ON TABLE public.submission_analyst TO glu;
GRANT SELECT ON TABLE public.submission_analyst TO rgi_role;


--
-- Name: TABLE submission_anlst_names; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.submission_anlst_names TO glu;
GRANT SELECT ON TABLE public.submission_anlst_names TO rgi_role;
GRANT ALL ON TABLE public.submission_anlst_names TO glims_rw;
GRANT SELECT ON TABLE public.submission_anlst_names TO glims_rc;
GRANT SELECT ON TABLE public.submission_anlst_names TO glims_ro;
GRANT ALL ON TABLE public.submission_anlst_names TO braup;
GRANT SELECT ON TABLE public.submission_anlst_names TO aster_metadata;


--
-- Name: TABLE submission_submitter; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.submission_submitter TO glu;
GRANT SELECT ON TABLE public.submission_submitter TO rgi_role;
GRANT ALL ON TABLE public.submission_submitter TO glims_rw;
GRANT SELECT ON TABLE public.submission_submitter TO glims_rc;
GRANT SELECT ON TABLE public.submission_submitter TO glims_ro;
GRANT ALL ON TABLE public.submission_submitter TO braup;
GRANT SELECT ON TABLE public.submission_submitter TO aster_metadata;


--
-- Name: TABLE glacier_query_full3; Type: ACL; Schema: public; Owner: braup
--

GRANT SELECT ON TABLE public.glacier_query_full3 TO glims_ro;


--
-- Name: TABLE glacier_query_full3_v2; Type: ACL; Schema: public; Owner: braup
--

GRANT SELECT ON TABLE public.glacier_query_full3_v2 TO glims_ro;


--
-- Name: TABLE glacier_query_full3_v3; Type: ACL; Schema: public; Owner: braup
--

GRANT SELECT ON TABLE public.glacier_query_full3_v3 TO glims_ro;


--
-- Name: TABLE glacier_query_no_people; Type: ACL; Schema: public; Owner: braup
--

GRANT SELECT ON TABLE public.glacier_query_no_people TO glims_ro;


--
-- Name: TABLE glacier_query_no_people_v2; Type: ACL; Schema: public; Owner: braup
--

GRANT SELECT ON TABLE public.glacier_query_no_people_v2 TO glims_ro;


--
-- Name: TABLE glacier_query_no_people_v3; Type: ACL; Schema: public; Owner: braup
--

GRANT SELECT ON TABLE public.glacier_query_no_people_v3 TO glims_ro;


--
-- Name: TABLE glacier_reference; Type: ACL; Schema: public; Owner: braup
--

GRANT ALL ON TABLE public.glacier_reference TO glims_rw;
GRANT SELECT ON TABLE public.glacier_reference TO glims_rc;
GRANT SELECT ON TABLE public.glacier_reference TO glims_ro;
GRANT SELECT ON TABLE public.glacier_reference TO aster_metadata;
GRANT SELECT ON TABLE public.glacier_reference TO glu;
GRANT SELECT ON TABLE public.glacier_reference TO rgi_role;


--
-- Name: SEQUENCE glacier_static_id_num_seq1; Type: ACL; Schema: public; Owner: braup
--

GRANT SELECT,UPDATE ON SEQUENCE public.glacier_static_id_num_seq1 TO glims_rw;


--
-- Name: TABLE glims_aster_footprints; Type: ACL; Schema: public; Owner: braup
--

GRANT ALL ON TABLE public.glims_aster_footprints TO glims_rw;
GRANT SELECT ON TABLE public.glims_aster_footprints TO glims_rc;
GRANT SELECT ON TABLE public.glims_aster_footprints TO aster_metadata;
GRANT SELECT,INSERT ON TABLE public.glims_aster_footprints TO glims_ro;
GRANT SELECT ON TABLE public.glims_aster_footprints TO glu;
GRANT SELECT ON TABLE public.glims_aster_footprints TO rgi_role;


--
-- Name: TABLE glims_field_dictionary; Type: ACL; Schema: public; Owner: braup
--

GRANT ALL ON TABLE public.glims_field_dictionary TO glims_rw;
GRANT SELECT ON TABLE public.glims_field_dictionary TO glims_rc;
GRANT SELECT ON TABLE public.glims_field_dictionary TO glims_ro;
GRANT SELECT ON TABLE public.glims_field_dictionary TO aster_metadata;
GRANT SELECT ON TABLE public.glims_field_dictionary TO glu;
GRANT SELECT ON TABLE public.glims_field_dictionary TO rgi_role;


--
-- Name: TABLE glims_table_fields; Type: ACL; Schema: public; Owner: braup
--

GRANT ALL ON TABLE public.glims_table_fields TO glims_rw;
GRANT SELECT ON TABLE public.glims_table_fields TO glims_rc;
GRANT SELECT ON TABLE public.glims_table_fields TO glims_ro;
GRANT SELECT ON TABLE public.glims_table_fields TO aster_metadata;
GRANT SELECT ON TABLE public.glims_table_fields TO glu;
GRANT SELECT ON TABLE public.glims_table_fields TO rgi_role;


--
-- Name: TABLE group_state_dates; Type: ACL; Schema: public; Owner: braup
--

GRANT SELECT ON TABLE public.group_state_dates TO glims_ro;
GRANT ALL ON TABLE public.group_state_dates TO glims_rw;
GRANT SELECT ON TABLE public.group_state_dates TO glims_rc;
GRANT SELECT ON TABLE public.group_state_dates TO glu;
GRANT SELECT ON TABLE public.group_state_dates TO rgi_role;


--
-- Name: TABLE groups; Type: ACL; Schema: public; Owner: braup
--

GRANT SELECT ON TABLE public.groups TO glims_ro;
GRANT ALL ON TABLE public.groups TO glims_rw;
GRANT SELECT ON TABLE public.groups TO glims_rc;
GRANT SELECT ON TABLE public.groups TO glu;
GRANT SELECT ON TABLE public.groups TO rgi_role;


--
-- Name: TABLE gtng_order1regions; Type: ACL; Schema: public; Owner: braup
--

GRANT SELECT ON TABLE public.gtng_order1regions TO glims_ro;
GRANT SELECT,INSERT,UPDATE ON TABLE public.gtng_order1regions TO glims_rw;


--
-- Name: SEQUENCE gtng_order1regions_gid_seq; Type: ACL; Schema: public; Owner: braup
--

GRANT SELECT ON SEQUENCE public.gtng_order1regions_gid_seq TO glims_ro;


--
-- Name: TABLE gtng_order2regions; Type: ACL; Schema: public; Owner: braup
--

GRANT SELECT ON TABLE public.gtng_order2regions TO glims_ro;
GRANT SELECT,INSERT,UPDATE ON TABLE public.gtng_order2regions TO glims_rw;


--
-- Name: SEQUENCE gtng_order2regions_gid_seq; Type: ACL; Schema: public; Owner: braup
--

GRANT SELECT ON SEQUENCE public.gtng_order2regions_gid_seq TO glims_ro;


--
-- Name: TABLE himalayan_dar_2007; Type: ACL; Schema: public; Owner: braup
--

GRANT ALL ON TABLE public.himalayan_dar_2007 TO glims_rw;
GRANT SELECT ON TABLE public.himalayan_dar_2007 TO glims_rc;
GRANT SELECT ON TABLE public.himalayan_dar_2007 TO glims_ro;
GRANT SELECT ON TABLE public.himalayan_dar_2007 TO aster_metadata;
GRANT SELECT ON TABLE public.himalayan_dar_2007 TO glu;
GRANT SELECT ON TABLE public.himalayan_dar_2007 TO rgi_role;


--
-- Name: SEQUENCE himalayan_dar_2007_gid_seq; Type: ACL; Schema: public; Owner: braup
--

GRANT ALL ON SEQUENCE public.himalayan_dar_2007_gid_seq TO glims_rw;
GRANT SELECT ON SEQUENCE public.himalayan_dar_2007_gid_seq TO glims_ro;


--
-- Name: TABLE image; Type: ACL; Schema: public; Owner: braup
--

GRANT ALL ON TABLE public.image TO glims_rw;
GRANT SELECT ON TABLE public.image TO glims_rc;
GRANT SELECT ON TABLE public.image TO glims_ro;
GRANT SELECT ON TABLE public.image TO aster_metadata;
GRANT SELECT ON TABLE public.image TO glu;
GRANT SELECT ON TABLE public.image TO rgi_role;


--
-- Name: TABLE image_band; Type: ACL; Schema: public; Owner: braup
--

GRANT ALL ON TABLE public.image_band TO glims_rw;
GRANT SELECT ON TABLE public.image_band TO glims_rc;
GRANT SELECT ON TABLE public.image_band TO glims_ro;
GRANT SELECT ON TABLE public.image_band TO aster_metadata;
GRANT SELECT ON TABLE public.image_band TO glu;
GRANT SELECT ON TABLE public.image_band TO rgi_role;


--
-- Name: TABLE instrument; Type: ACL; Schema: public; Owner: braup
--

GRANT ALL ON TABLE public.instrument TO glims_rw;
GRANT SELECT ON TABLE public.instrument TO glims_rc;
GRANT SELECT ON TABLE public.instrument TO glims_ro;
GRANT SELECT ON TABLE public.instrument TO aster_metadata;
GRANT SELECT ON TABLE public.instrument TO glu;
GRANT SELECT ON TABLE public.instrument TO rgi_role;


--
-- Name: TABLE image_info_view; Type: ACL; Schema: public; Owner: braup
--

GRANT SELECT ON TABLE public.image_info_view TO glims_ro;
GRANT ALL ON TABLE public.image_info_view TO glims_rw;
GRANT SELECT ON TABLE public.image_info_view TO aster_metadata;
GRANT SELECT ON TABLE public.image_info_view TO glims_rc;
GRANT SELECT ON TABLE public.image_info_view TO glu;
GRANT SELECT ON TABLE public.image_info_view TO rgi_role;


--
-- Name: TABLE lon_char_valids; Type: ACL; Schema: public; Owner: braup
--

GRANT ALL ON TABLE public.lon_char_valids TO glims_rw;
GRANT SELECT ON TABLE public.lon_char_valids TO glims_rc;
GRANT SELECT ON TABLE public.lon_char_valids TO glims_ro;
GRANT SELECT ON TABLE public.lon_char_valids TO aster_metadata;
GRANT SELECT ON TABLE public.lon_char_valids TO glu;
GRANT SELECT ON TABLE public.lon_char_valids TO rgi_role;


--
-- Name: TABLE map_metadata; Type: ACL; Schema: public; Owner: braup
--

GRANT ALL ON TABLE public.map_metadata TO glims_rw;
GRANT SELECT ON TABLE public.map_metadata TO glims_rc;
GRANT SELECT ON TABLE public.map_metadata TO glims_ro;
GRANT SELECT ON TABLE public.map_metadata TO aster_metadata;
GRANT SELECT ON TABLE public.map_metadata TO glu;
GRANT SELECT ON TABLE public.map_metadata TO rgi_role;


--
-- Name: TABLE mytestview; Type: ACL; Schema: public; Owner: braup
--

GRANT ALL ON TABLE public.mytestview TO glims_rw;
GRANT SELECT ON TABLE public.mytestview TO glims_rc;
GRANT SELECT ON TABLE public.mytestview TO aster_metadata;
GRANT SELECT ON TABLE public.mytestview TO glims_ro;
GRANT SELECT ON TABLE public.mytestview TO glu;
GRANT SELECT ON TABLE public.mytestview TO rgi_role;


--
-- Name: TABLE point_measurement; Type: ACL; Schema: public; Owner: braup
--

GRANT ALL ON TABLE public.point_measurement TO glims_rw;
GRANT SELECT ON TABLE public.point_measurement TO glims_rc;
GRANT SELECT ON TABLE public.point_measurement TO glims_ro;
GRANT SELECT ON TABLE public.point_measurement TO aster_metadata;
GRANT SELECT ON TABLE public.point_measurement TO glu;
GRANT SELECT ON TABLE public.point_measurement TO rgi_role;


--
-- Name: TABLE primary_classification_valids; Type: ACL; Schema: public; Owner: braup
--

GRANT ALL ON TABLE public.primary_classification_valids TO glims_rw;
GRANT SELECT ON TABLE public.primary_classification_valids TO glims_rc;
GRANT SELECT ON TABLE public.primary_classification_valids TO glims_ro;
GRANT SELECT ON TABLE public.primary_classification_valids TO aster_metadata;
GRANT SELECT ON TABLE public.primary_classification_valids TO glu;
GRANT SELECT ON TABLE public.primary_classification_valids TO rgi_role;


--
-- Name: TABLE rc_people; Type: ACL; Schema: public; Owner: braup
--

GRANT ALL ON TABLE public.rc_people TO glims_rw;
GRANT SELECT ON TABLE public.rc_people TO glims_rc;
GRANT SELECT ON TABLE public.rc_people TO glims_ro;
GRANT SELECT ON TABLE public.rc_people TO aster_metadata;
GRANT SELECT ON TABLE public.rc_people TO glu;
GRANT SELECT ON TABLE public.rc_people TO rgi_role;


--
-- Name: TABLE rc_people_nocoords; Type: ACL; Schema: public; Owner: braup
--

GRANT ALL ON TABLE public.rc_people_nocoords TO glims_rw;
GRANT SELECT ON TABLE public.rc_people_nocoords TO glims_rc;
GRANT SELECT ON TABLE public.rc_people_nocoords TO glims_ro;
GRANT SELECT ON TABLE public.rc_people_nocoords TO aster_metadata;
GRANT SELECT ON TABLE public.rc_people_nocoords TO glu;
GRANT SELECT ON TABLE public.rc_people_nocoords TO rgi_role;


--
-- Name: TABLE rc_people_view; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.rc_people_view TO glu;
GRANT SELECT ON TABLE public.rc_people_view TO rgi_role;
GRANT ALL ON TABLE public.rc_people_view TO glims_rw;
GRANT SELECT ON TABLE public.rc_people_view TO glims_rc;
GRANT SELECT ON TABLE public.rc_people_view TO glims_ro;
GRANT ALL ON TABLE public.rc_people_view TO braup;
GRANT SELECT ON TABLE public.rc_people_view TO aster_metadata;


--
-- Name: TABLE reference_document; Type: ACL; Schema: public; Owner: braup
--

GRANT ALL ON TABLE public.reference_document TO glims_rw;
GRANT SELECT ON TABLE public.reference_document TO glims_rc;
GRANT SELECT ON TABLE public.reference_document TO glims_ro;
GRANT SELECT ON TABLE public.reference_document TO aster_metadata;
GRANT SELECT ON TABLE public.reference_document TO glu;
GRANT SELECT ON TABLE public.reference_document TO rgi_role;


--
-- Name: TABLE reference_point; Type: ACL; Schema: public; Owner: braup
--

GRANT ALL ON TABLE public.reference_point TO glims_rw;
GRANT SELECT ON TABLE public.reference_point TO glims_rc;
GRANT SELECT ON TABLE public.reference_point TO glims_ro;
GRANT SELECT ON TABLE public.reference_point TO aster_metadata;
GRANT SELECT ON TABLE public.reference_point TO glu;
GRANT SELECT ON TABLE public.reference_point TO rgi_role;


--
-- Name: TABLE rgi_users; Type: ACL; Schema: public; Owner: braup
--

GRANT ALL ON TABLE public.rgi_users TO glims_rw;
GRANT SELECT ON TABLE public.rgi_users TO glims_rc;
GRANT SELECT ON TABLE public.rgi_users TO glims_ro;
GRANT SELECT ON TABLE public.rgi_users TO aster_metadata;
GRANT SELECT ON TABLE public.rgi_users TO glu;
GRANT SELECT,INSERT ON TABLE public.rgi_users TO rgi_role;


--
-- Name: SEQUENCE rgi_users_id_seq; Type: ACL; Schema: public; Owner: braup
--

GRANT ALL ON SEQUENCE public.rgi_users_id_seq TO glims_rw;
GRANT SELECT,UPDATE ON SEQUENCE public.rgi_users_id_seq TO rgi_role;


--
-- Name: TABLE starpolys; Type: ACL; Schema: public; Owner: braup
--

GRANT ALL ON TABLE public.starpolys TO glims_rw;
GRANT SELECT ON TABLE public.starpolys TO glims_rc;
GRANT SELECT ON TABLE public.starpolys TO glims_ro;
GRANT SELECT ON TABLE public.starpolys TO aster_metadata;
GRANT SELECT ON TABLE public.starpolys TO glu;
GRANT SELECT ON TABLE public.starpolys TO rgi_role;


--
-- Name: SEQUENCE starpolys_gid_seq; Type: ACL; Schema: public; Owner: braup
--

GRANT ALL ON SEQUENCE public.starpolys_gid_seq TO glims_rw;
GRANT SELECT ON SEQUENCE public.starpolys_gid_seq TO glims_ro;


--
-- Name: TABLE status_def; Type: ACL; Schema: public; Owner: braup
--

GRANT ALL ON TABLE public.status_def TO glims_rw;
GRANT SELECT ON TABLE public.status_def TO glims_rc;
GRANT SELECT ON TABLE public.status_def TO glims_ro;
GRANT SELECT ON TABLE public.status_def TO aster_metadata;
GRANT SELECT ON TABLE public.status_def TO glu;
GRANT SELECT ON TABLE public.status_def TO rgi_role;


--
-- Name: TABLE tiepoint_region; Type: ACL; Schema: public; Owner: braup
--

GRANT ALL ON TABLE public.tiepoint_region TO glims_rw;
GRANT SELECT ON TABLE public.tiepoint_region TO glims_rc;
GRANT SELECT ON TABLE public.tiepoint_region TO glims_ro;
GRANT SELECT ON TABLE public.tiepoint_region TO aster_metadata;
GRANT SELECT ON TABLE public.tiepoint_region TO glu;
GRANT SELECT ON TABLE public.tiepoint_region TO rgi_role;


--
-- Name: TABLE tongue_activity_valids; Type: ACL; Schema: public; Owner: braup
--

GRANT ALL ON TABLE public.tongue_activity_valids TO glims_rw;
GRANT SELECT ON TABLE public.tongue_activity_valids TO glims_rc;
GRANT SELECT ON TABLE public.tongue_activity_valids TO glims_ro;
GRANT SELECT ON TABLE public.tongue_activity_valids TO aster_metadata;
GRANT SELECT ON TABLE public.tongue_activity_valids TO glu;
GRANT SELECT ON TABLE public.tongue_activity_valids TO rgi_role;


--
-- Name: TABLE vector; Type: ACL; Schema: public; Owner: braup
--

GRANT ALL ON TABLE public.vector TO glims_rw;
GRANT SELECT ON TABLE public.vector TO glims_rc;
GRANT SELECT ON TABLE public.vector TO glims_ro;
GRANT SELECT ON TABLE public.vector TO aster_metadata;
GRANT SELECT ON TABLE public.vector TO glu;
GRANT SELECT ON TABLE public.vector TO rgi_role;


--
-- Name: TABLE vector_set; Type: ACL; Schema: public; Owner: braup
--

GRANT ALL ON TABLE public.vector_set TO glims_rw;
GRANT SELECT ON TABLE public.vector_set TO glims_rc;
GRANT SELECT ON TABLE public.vector_set TO glims_ro;
GRANT SELECT ON TABLE public.vector_set TO aster_metadata;
GRANT SELECT ON TABLE public.vector_set TO glu;
GRANT SELECT ON TABLE public.vector_set TO rgi_role;


--
-- PostgreSQL database dump complete
--

