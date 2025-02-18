#!/usr/bin/env python3
"""

Read data from the existing GLIMS database, transform to the new data model,
and write to the new database.

"""

import os
import sys
import datetime as dt
import decimal
import argparse
from collections import OrderedDict
from collections import defaultdict
import urllib.request
import json

import psycopg2
import shapely.geometry as shg
from shapely.geometry import Polygon
from shapely.wkt import loads as sloads

from connection import CONN, CONN_V2, SCHEMA
from db_objs import Glacier_entity

# For handling GLIMS IDs
sys.path.insert(1, '/projects/GLIMS/GLIMS_Ingest/ID_assignment')
import GLIMS_ID


def print_arg_summary(args):
    """Print summary of command-line arguments."""
    print("Arguments object:", file=sys.stderr)
    print(args, file=sys.stderr)


def setup_argument_parser():
    """Set up command line options.  -h or --help for help is automatic"""
    b_help = 'Bounding box to define region for move. Format: --bbox=W,S,E,N'
    F_help = 'Copy all tables from "glacier_entities" on. Previous tables should be in the new DB already.'
    T_help = 'Copy all tables up to, but not including, "glacier_entities".'

    p = argparse.ArgumentParser()

    g1 = p.add_mutually_exclusive_group()
    g1.add_argument('-b', '--bbox', default='all',  help=b_help)
    g1.add_argument('-s', '--subm_id', help=b_help)

    g2 = p.add_mutually_exclusive_group()
    g2.add_argument('-F', '--From_glacier_entities', action='store_true', help=F_help)
    g2.add_argument('-T', '--To_glacier_entities', action='store_true',  help=T_help)

    p.add_argument('-d', '--debug', action='store_true',  help='Run in debugging mode.')
    p.add_argument('-L', '--list_tables', action='store_true',  help='Show table list and exit')
    p.add_argument('-q', '--quiet',   action='store_true', default=False, help="Quiet mode.  Don't print status messages.")
    p.add_argument('-w', '--write_to_db', action='store_true',  help='Run SQL directly on database rather than print it.')

    return(p)


def get_tables_list(debug=False, from_glacents=False, to_glacents=False):
    '''
    get_tables_list -- Return a list of tables in order of dependency

    Here is the list of tables and their dependencies (those in ALL CAPS to be deleted):

    reference_document
    dominant_mass_source_valids
    form_valids
    frontal_characteristics_valids
    lon_char_valids
    primary_classification_valids
    tongue_activity_valids
    glims_table_fields
    gtng_order1regions
    gtng_order2regions
    glims_field_dictionary
    instrument
    country
    status_def
    map_metadata
    image (-> instrument)
    people (-> country)
    regional_centers (-> people)
    rc_people (-> regional_centers, people)
    submission_info (-> people, regional_centers)
    submission_analyst (-> submission_info, people)
    glacier_static (-> SUBMISSION_INFO)
    glacier_reference (-> glacier_static, reference_document)
    glacier_dynamic (-> glacier_static, people, submission_info, regional_centers)
    glacier_image_info (-> glacier_dynamic, image)
    area_histogram (-> glacier_dynamic)
    area_histogram_data (-> area_histogram)
    glacier_entities (-> glacier_dynamic)
    glacier_countries (-> glacier_static, country)
    glacier_map_info (-> map_metadata, glacier_dynamic)

    '''

    if debug:
        #rtndict = {'image': ()}  # to fix the dt.datetime issue
        #rtndict = {'glacier_polygons': ()}  # for meat of the data transform
        #rtndict = {'country': ()}  # for case with a geometry column WORKS
        rtndict = {'reference_document': ()}  # for simple scalar case WORKS
        return rtndict

    if from_glacents:
        # All other tables should be in new DB already
        rtndict = OrderedDict(
                      [('glacier_polygons', ('glacier_dynamic',)),
                       ('glacier_countries', ('glacier_static', 'country')),
                       ('glacier_map_info', ('map_metadata', 'glacier_dynamic')),
                      ]
                 )
        return rtndict

    if to_glacents:
        # All other tables should be in new DB already
        rtndict = OrderedDict(
                    [
                        ('reference_document', ()),
                        ('dominant_mass_source_valids', ()),
                        ('form_valids', ()),
                        ('frontal_characteristics_valids', ()),
                        ('lon_char_valids', ()),
                        ('primary_classification_valids', ()),
                        ('tongue_activity_valids', ()),
                        ('glims_table_fields', ()),
                        ('gtng_order1regions', ()),
                        ('gtng_order2regions', ()),
                        ('glims_field_dictionary', ()),
                        ('instrument', ()),
                        ('country', ()),
                        ('status_def', ()),
                        ('map_metadata', ()),
                        ('image', ('instrument',)),
                        ('people', ('country',)),
                        ('regional_centers', ('people',)),
                        ('rc_people', ('regional_centers', 'people')),
                        ('submission_info', ('people', 'regional_centers')),
                        ('submission_analyst', ('submission_info', 'people')),
                        ('glacier_static', ('submission_info',)),
                        ('glacier_reference', ('glacier_static', 'reference_document')),
                        ('glacier_dynamic', ('glacier_static', 'people', 'submission_info', 'regional_centers')),
                        ('glacier_image_info', ('glacier_dynamic', 'image')),
                        ('area_histogram', ('glacier_dynamic',)),
                        ('area_histogram_data', ('area_histogram',)),
                    ]
                  )

        return rtndict

    tables = OrderedDict(
        [
            ('reference_document', ()),
            ('dominant_mass_source_valids', ()),
            ('form_valids', ()),
            ('frontal_characteristics_valids', ()),
            ('lon_char_valids', ()),
            ('primary_classification_valids', ()),
            ('tongue_activity_valids', ()),
            ('glims_table_fields', ()),
            ('gtng_order1regions', ()),
            ('gtng_order2regions', ()),
            ('glims_field_dictionary', ()),
            ('instrument', ()),
            ('country', ()),
            ('status_def', ()),
            ('map_metadata', ()),
            ('image', ('instrument',)),
            ('people', ('country',)),
            ('regional_centers', ('people',)),
            ('rc_people', ('regional_centers', 'people')),
            ('submission_info', ('people', 'regional_centers')),
            ('submission_analyst', ('submission_info', 'people')),
            ('glacier_static', ('submission_info',)),
            ('glacier_reference', ('glacier_static', 'reference_document')),
            ('glacier_dynamic', ('glacier_static', 'people', 'submission_info', 'regional_centers')),
            ('glacier_image_info', ('glacier_dynamic', 'image')),
            ('area_histogram', ('glacier_dynamic',)),
            ('area_histogram_data', ('area_histogram',)),
            ('glacier_polygons', ('glacier_dynamic',)),     # Named glacier_entities in new DB
            ('glacier_countries', ('glacier_static', 'country')),
            ('glacier_map_info', ('map_metadata', 'glacier_dynamic')),
        ]
    )

    if check_table_dependencies(tables):
        return tables
    else:
        return None


def check_table_dependencies(tables):
    '''
    check_table_dependencies: check that the tables are in a correct order to satisfy dependencies
    '''
    dep_t_seen = {}
    for t, dep_t in tables.items():
        # Check that dependent tables are already in tables as keys
        for dt in dep_t:
            if dt not in dep_t_seen:
                print('Dependent table', dt, "is not defined before use.\n", file=sys.stderr)
                return False
        dep_t_seen[t] = 1
    return True


def connect_to_db(db='old'):
    if db == 'old':
        try:
            db_old = psycopg2.connect(CONN)
        except:
            print(f"Unable to connect to the old database.", file=sys.stderr)
            sys.exit(1)

        return db_old.cursor()

    elif db == 'new':

        try:
            db_new = psycopg2.connect(CONN_V2)
        except psycopg2.Error as e:
            print(f"Unable to connect to the new database: {e}", file=sys.stderr)
            sys.exit(1)

        db_new.set_session(autocommit=True)

        return db_new.cursor()
    else:
        print(f"connect_to_db: unrecognized db: {db}", file=sys.stderr)
        sys.exit(1)


def issue_sql(sql, dbh_new_cur, args):
    '''
    Depending on command-line options, either print the SQL to stdout or run it on the database.
    '''

    if args.debug:
        print("issue_sql:  Input SQL:\n    ", sql, file=sys.stderr)

    if args.write_to_db:
        try:
            dbh_new_cur.execute(sql.rstrip(';'))
        except psycopg2.Error as e:
            print("Execution of the following SQL failed.  Stopping.", file=sys.stderr)
            print(f"Error message:  {e}.\n", file=sys.stderr)
            return None
    else:
        print(sql, file=sys.stdout)

    return True


def next_aid_generator():
    '''
    Get next available analysis ID, starting with the one from the next_ids service.
    '''
    # query service for next aid
    service_url = 'https://www.glims.org/services/next_ids'

    with urllib.request.urlopen(service_url) as response:
        json_return = response.read()

        next_ids = json.loads(json_return)
        next_aid = int(next_ids['analysis_id'])

    while True:
        yield next_aid
        next_aid += 1


def assign_correct_gid(p, processed_singles):
    '''
    assign_correct_gid -- assign a glacier ID to a new part, taking into
                        account overlap relationships with other glaciers

    Case 1:  New part overlaps with no other polygons in processed_singles

    Case 2:  Two overlapping multi-polygons, both of which should be broken up,
    but the overlapping pieces should get the same GLIMS glacier IDs.

    The overlap check needs to be done with all glaciers in the region, not
    just the glacier polygons sharing a glacier ID.  Therefore, this script
    needs to be run on a region at a time.  Otherwise, the run time will be
    prohibitive, O(N2) I think.

    '''
    best_overlap_frac = 0.0
    best_overlap_gid = ''
    for single in processed_singles:
        if single.intersects(p):
            ov_frac = single.max_overlap_frac(p)
            if ov_frac > best_overlap_frac:
                best_overlap_frac = ov_frac
                best_overlap_gid = single.gid

    if best_overlap_frac == 0.0:
        # Create new ID here
        new_gid = make_new_gid(p, processed_singles)
        return new_gid
    else:
        return best_overlap_gid


def make_new_gid(p, processed_singles):
    '''
    Calculate a new GLIMS glacier ID for this object, making sure it doesn't
    already exist in the list of glaciers in this run.  Make sure it's also not
    in the database already by querying the glacierinfo service.

    Input:
        - a glac_bound record (with outline)
        - dict? of all processed single outline objects, keyed by glacier ID??

    Output:
        the new GLIMS glacier ID
    '''

    #print("DEBUG: make_new_gid: input p is ", p, file=sys.stderr)

    try:
        ppoly = shg.polygon.orient(shg.shape(p.sgeom))
        center = ppoly.representative_point()
    except:
        #print("DEBUG: make_new_gid: shape or representative_point failed", file=sys.stderr)
        return None

    #print("DEBUG: make_new_gid: center = ", center, "type is ", type(center), file=sys.stderr)

    if center.is_empty:
        return None

    rep_point_id = GLIMS_ID.lonlat2glimsID(center.x, center.y)
    neighs = GLIMS_ID.neighbors(rep_point_id)

    for id_to_try in [rep_point_id] + neighs:
        if is_good_new_id(id_to_try, processed_singles):
            #print("   --> make_new_gid: returning ", id_to_try, file=sys.stderr)
            return id_to_try

    return 'no_candidates'


def is_good_new_id(gid, processed_singles):
    '''
    Check candiate glacier ID for uniqueness: mustn't be in
    processed_singles or in the database
    '''

    # Check bounds_by_glac_id and fail fast if not unique
    if gid in [e.gid for e in processed_singles]:
        return False

    # Check db
    url = f'https://www.glims.org/services/glacierinfo?glac_id={gid}'
    with urllib.request.urlopen(url) as response:
        json_return = response.read()
        rtn_object = json.loads(json_return)

    if 'message' in rtn_object and rtn_object['message'].startswith('No records found'):
        return True
    else:
        return False


def process_glacier_entities(T, dbh_old_cur, dbh_new_cur, args):
    '''
    process_glacier_entities -- Top-level routine for moving glacier_polygons to glacier_entities

    Read all records within region (args.bbox), group by glacier_id, and
    convert all intrnl_rock polygons to holes in the associated glac_bound
    polygon

    '''

    # Select all entities from database (or those within bounding box)

    # The ST_Force_2D function will convert the GLIMS DB to 2D, which is what people want.
    base_query = f'SELECT gd.glacier_id, gd.analysis_id, {T}.line_type, ST_AsEWKT(ST_Force_2D({T}.glacier_polys)) ' \
                + f'FROM {T}, glacier_dynamic gd WHERE {T}.analysis_id=gd.analysis_id'

    if args.bbox == 'all':
        sql = base_query
    else:
        W, S, E, N = args.bbox.split(',')
        region = f"ST_GeomFromEWKT('SRID=4326;POLYGON(({W} {S}, {E} {S}, {E} {N}, {W} {N}, {W} {S}))')"
        sql = base_query + f' AND {region} && {T}.glacier_polys'

    dbh_old_cur.execute(sql)

    # Change this to fetchmany, in a while True loop?  No, since all results
    # are required to guarantee that all intrnl_rock parts are processed
    # properly.

    query_results = dbh_old_cur.fetchall()      # list of tuples

    if not args.quiet:
        print(f"Selected {len(query_results)} records from table {T}", file=sys.stderr)

    all_entities = old_to_new_data_model(query_results, dbh_new_cur, args)

    #print("DEBUG: calling glac_objs_to_sql_inserts(glac_bound_objs)", file=sys.stderr)
    move_sql =      glac_objs_to_sql_inserts(all_entities)

    if not args.quiet:
        print(f"Issuing {len(move_sql)} SQL statements...", file=sys.stderr)

    for m in move_sql:
        rtn_code = issue_sql(m, dbh_new_cur, args)


def close_ring(ring):
    if ring[0] != ring[-1]:
        ring = ring + [ring[0]]
    return ring


def make_valid_poly_if_possible(poly):
    '''
    Use shapely to check validity of a Polygon geometry, and fix if possible.

    Return:
        Valid Polygon geometry        if input poly is already valid, or fixed with buffering
        None                          if input poly is invalid even after buffering
    '''
    if poly.is_valid:
        return poly

    #buffed_poly  = shg.polygon.orient(poly.buffer(0.0))
    buffed_poly  = poly.buffer(0.0)
    if buffed_poly.to_wkt().strip().lower().startswith('multi'):
        # Likely complicated (and spurious) rocks; just skip.
        return None
    if buffed_poly.is_valid:
        return buffed_poly
    else:
        print("Invalid poly:", poly, file=sys.stderr)
        return None


def make_valid_if_possible(gl_obj):
    ''' Like above make_valid_poly_if_possible, but operate on Glacier_entity object
    '''
    if type(gl_obj) is Glacier_entity:
        fixed_geom = make_valid_poly_if_possible(gl_obj.sgeom)
        gl_obj.sgeom = fixed_geom
        return gl_obj
    elif type(gl_obj) is Polygon:
        return make_valid_poly_if_possible(gl_obj)
    else:
        print("Warning: make_valid_if_possible wants a Glacier_entity object: ", file=sys.stderr)
        sys.exit(1)


def explode_multipolygons(gl_obj_list):
    ''' Input:  list of glacier objects, each of which might be
        a multi-polygon, or possibly a list of glacier objects, or a mixed list of
        single and multi-polygons.

        Output:  a list (parts) with all the parts exploded (flattened) into
        a one-level list, possibly recursively.

        Glacier_entity objects could be POLYGON or "POLYGON Z", hence the
        "startswith" below.

    '''

    parts = []

    for o in gl_obj_list:
        if type(o) is Glacier_entity and o.sgeom is not None:
            if o.sgeom.geom_type.lower() == 'multipolygon':
                #print('   ===>', o.sgeom, file=sys.stderr)
                temp = list(o)
                done = False
                while not done:
                    done = True
                    for i, e in enumerate(temp):
                        if e.sgeom.geom_type.lower().startswith('multi'):
                            print(' ### Nested multi: ', e.sgeom, file=sys.stderr)
                            temp[i:i+1] = list(e)
                            done = False
                parts.extend(temp)
            elif o.sgeom.geom_type.lower().startswith('polygon'):
                parts.append(o)
        elif type(o) is list:
            parts.extend(explode_multipolygons(o))

    return parts


def old_to_new_data_model(query_results, dbh_new_cur, args):
    ''' old_to_new_data_model - translate all query results from old to new data model

    Input:  query_results, a list of tuples from the glacier_polygons table
    Output: two lists of objects: glacier objects and misc. objects

    For reference, as of 2024-05-20, here are the line types in the glacier_polygons table:

    # select line_type, count(line_type) from glacier_polygons group by line_type order by count desc;
          line_type  | count
        -------------+--------
         glac_bound  | 792212
         intrnl_rock | 467402
         debris_cov  |  14872
         pro_lake    |    291
         supra_lake  |     18
         basin_bound |      9
        (6 rows)

    Here are the needed actions:

    All single polygons (for a given region but including all as-of times) must
    be done first, before any multipolygons. Thus, I must do the move region by
    region, including all outlines (for all times) in each region.

    0. intrnl_rock polygons and glac_bound polygons that belong together share
       an analysis_id.  Therefore, I should first combine them into holey
       polygons before splitting up multi-polygons.  Does that do the right
       thing? (I don't think so ... ??)

       What about retired records?  Just copy those to new DB.

    1. Process all single (non-multipolygon) glac_bounds first.  Store list of
       these --> "processed_singles".  Don't change their IDs at all.  Convert
       intrnl_rock polygons with the same ANALYSIS IDs to holes.

    2. Process all multipolygon glac_bounds next.  When breaking them apart,
       must assign new glacier IDs to the pieces.  Do this by:

        A. Does the piece overlap any single polygon in processed_singles?  If
           so, assign ID from that single, or from the single with the most
           overlap.

        B. If no overlap, assign new ID from centroid, ensuring no collisions
           with IDs in processed_singles.

        C. Add record to glacier_static with the new glacier ID.

    3. Loop through all the non-glac_bound entities (debris_cov, lakes...) and
       assign IDs via steps 2A and 2B above (via overlap relationships).

    How will this work to run over different regions?  In theory, there will be
    no overlapping glacier outlines that are in different regions.  But do any
    multi-polygons span regions??  How to find out?

    The last two tables, after the glacier_entities, are the glacier_countries
    and glacier_map_info tables.  Will these have to be reconstructed?  And
    what about the glacier_image_info table?  A row-by-row copy of these will
    not pick up the new glacier IDs from the multi-polygons.

    I think I need a mapping of old_glacier_id --> new_glacier_id_list (from
    exploding multi-polygons), and then assign the same images and maps to the
    new as were connected to the old.

    '''

    bounds_by_aid = defaultdict(list)
    rocks_by_aid = defaultdict(list)
    orphan_rocks_by_aid = defaultdict(list)
    misc_entities_by_aid = defaultdict(list)

    # Bin the query results by entity type
    for row in query_results:

        gl_obj = Glacier_entity(row)

        if gl_obj.line_type in ('pro_lake', 'supra_lake', 'basin_bound', 'debris_cov'):
            try:
                # Case:  geom is multipolygon
                temp_objs = []
                for e in list(gl_obj):
                    e = make_valid_if_possible(e)
                    if e is not None:
                        temp_objs.append(e)
                misc_entities_by_aid[gl_obj.aid].extend(temp_objs)
            except:
                misc_entities_by_aid[gl_obj.aid].append(gl_obj)
        elif gl_obj.line_type == 'glac_bound':
            bounds_by_aid[gl_obj.aid].append(gl_obj)
        elif gl_obj.line_type == 'intrnl_rock':
            rocks_by_aid[gl_obj.aid].append(gl_obj)
        else:
            print("Warning: found unknown line_type: ", gl_obj.line_type, file=sys.stderr)

    if not args.quiet:
        print("Num entities of type (glac_bound, intrnl_rock, misc):",
               len(bounds_by_aid), len(rocks_by_aid), len(misc_entities_by_aid), file=sys.stderr)

    # Assemble glac_bound polys with holes
    if not args.quiet:
        print('Looping through glac_bound objects', file=sys.stderr)

    # Separate glac_bound entities into singles and non-singles

    singles = defaultdict(list)
    non_singles = defaultdict(list)

    for aid, gl_obj_list in bounds_by_aid.items():
        if len(gl_obj_list) > 1 or gl_obj_list[0].sgeom.geom_type.lower() == 'multipolygon':
            print(f"Warning: Found ({len(gl_obj_list)}) glac_bound outlines for {aid} (or is multipolygon)", file=sys.stderr)
            non_singles[aid].append(gl_obj_list)
        else:
            singles[aid].extend(gl_obj_list)

    # Process the single polygons.  This routine returns a structure of all the
    # already-processed single polygon objects. Dictionary keyed by
    # analysis_id?  glacier_id?  Singles created from exploding multi-polygons
    # will be added to this structure.

    processed_singles = process_single_entities(singles, rocks_by_aid)

    # Create single polygons from multi-polygons and add them to the list of
    # single objects.

    processed_singles = process_nonsingle_entities(non_singles, processed_singles, rocks_by_aid, dbh_new_cur, args)

    # Adjust the IDs of the miscellaneous entities as necessary.  "Necessary"
    # means that they share an analysis ID with a multipolygon that was broken
    # up.

    all_entities = process_others(misc_entities_by_aid, processed_singles)

    # return list of all objects for SQL creation
    return all_entities


def process_others(misc_entities_by_aid, processed_singles):
    ''' process_others -- Adjust IDs of misc entities contained by changed
        glac_bound entities, and append to the growing list of processed entities.
    '''

    # Go once through whole list of processed singles and look up misc entities by aid
    for p in processed_singles:
        if p.aid in misc_entities_by_aid:
            for m in misc_entities_by_aid[p.aid]:
                if not m.sgeom.is_valid:
                    print(f"misc poly {m.as_tuple} is not valid", file=sys.stderr)
                    continue
                if p.touches(m) or p.contains(m):
                    m.gid = p.gid
                    m.aid = p.aid
                    processed_singles.append(m)

    return processed_singles


def process_nonsingle_entities(non_singles, processed_singles, rocks_by_aid, dbh_new_cur, args):
    '''
    process_nonsingle_entities -- assign correct or create new glacier ID to
    these multi-part polygon parts, and convert nunutak polys to holes....
    '''

    get_new_aid = next_aid_generator()

    for aid, gl_obj_list in non_singles.items():

        # Break all boundary parts into a list of single polygons.

        parts = explode_multipolygons(gl_obj_list)

        # If a part overlaps a single outline in processed_singles, it should
        # be given that glacier ID.

        # Otherwise, give the part a new identity (gid, aid, etc).
        
        # Either way, put nunataks in boundary polygon as holes.

        for p in parts:

            p.from_multi = True

            if not p.sgeom.is_valid:
                p = make_valid_if_possible(p)
                if p.sgeom is None:
                    print(f"glac_bound poly {p.as_tuple} is not valid. Skipping.", file=sys.stderr)
                    continue

            p.old_gid = p.gid
            new_gid = assign_correct_gid(p, processed_singles)
            #print("In parts loop: new_gid = ", new_gid, file=sys.stderr)

            if new_gid is None:
                print(f"Topology seems wrong for glac_bound poly: {p}. Skipping.", file=sys.stderr)
                continue
            if new_gid == 'no_candidates':
                print(f"No candidate IDs were found for glac_bound poly: {p}. Exiting.", file=sys.stderr)
                sys.exit(1)

            p.gid = new_gid
            p.old_aid = p.aid
            p.aid = next(get_new_aid)
            #print("In parts loop: new_aid = ", new_aid, file=sys.stderr)

            rtn_code = write_new_to_glacier_static(p, dbh_new_cur, args)
            # Do something with rtn_code?
            #del_from_glacier_static(gid)???  # Need to delete records from referencing tables too (first)

            rocks_to_add = []
            for n in explode_multipolygons([rocks_by_aid[p.old_aid]]):
                #print('DEBUG: n geom is', n.sgeom, file=sys.stderr)
                n_fixed = make_valid_if_possible(n)
                #print('   Post-make_valid: n_fixed geom is', n_fixed.sgeom, file=sys.stderr)
                if n_fixed.sgeom is None:
                    print("Found unfixable rock outline. Skipping.", file=sys.stderr)
                    continue
                if p.contains(n_fixed):
                    rocks_to_add.append(n_fixed)

            p_ext_coords = p.sgeom.exterior.coords
            new_p_geom = Polygon(close_ring(list(p_ext_coords)), holes=[close_ring(list(e.sgeom.exterior.coords)) for e in rocks_to_add])
            p.sgeom = make_valid_if_possible(new_p_geom)
            if p.sgeom is None:
                continue

            #print("In parts loop: appending ", p, file=sys.stderr)
            add_part_to_glacier_dynamic(p, dbh_new_cur, args)
            processed_singles.append(p)
        # Remove gid entry from bounds_by_glac_id ?
    return processed_singles


def process_single_entities(singles, rocks_by_aid):

    print("process_single_entities: singles is", singles, file=sys.stderr)

    bound_objs_to_ingest = []
    for aid, bound_obj_list in singles.items():
        if len(bound_obj_list) > 1:
            print("Multi-polygon found in singles list. Exiting.", file=sys.stderr)
            sys.exit(1)
        bound_obj = bound_obj_list[0]
        if aid in rocks_by_aid:
            rock_objs = explode_multipolygons([rocks_by_aid[aid]])
            # Check for containment...
            int_rocks = []
            for r in rock_objs:
                if type(r) is list:
                    print("Why is this rock obj a list??", r, file=sys.stderr)
                if type(bound_obj) is list:
                    print("Why is this bound_obj a list??", bound_obj, file=sys.stderr)
                # Skip rocks with different analysis_id values.
                if r.aid != bound_obj.aid:
                    continue

                if bound_obj.contains(r):
                    int_rocks.append(r)
                else:
                    orphan_rocks_by_glac_id[aid].append(r)

            # Assemble holey polygon
            if len(int_rocks) > 0:
                holey_geom = Polygon(close_ring(list(bound_obj.sgeom.exterior.coords)), holes=[close_ring(list(e.sgeom.exterior.coords)) for e in int_rocks])
                bound_obj.sgeom = holey_geom

        bound_objs_to_ingest.append(bound_obj)

    return (bound_objs_to_ingest)


def write_new_to_glacier_static(gl_obj, dbh_new_cur, args):
    all_glacier_static_fields = [
        'glacier_id',
        'glacier_name',
        'wgms_id',
        'local_glacier_id',
        'parent_icemass_id',
        'record_status',
        'glac_static_points',
        'glacier_status',
        'submission_id',
        'id_num',
        'est_disappear_date',
        'est_disappear_unc',
    ]

    # Replace analysis_id and glacier_id with the new ones
    fields_to_copy_from_old_rec = all_glacier_static_fields[1:]

    # Add table name to field names.
    fields_to_copy_with_table = ['gs.' + e for e in fields_to_copy_from_old_rec]

    sql = f"INSERT INTO data.glacier_static ( {','.join(all_glacier_static_fields)} ) SELECT '{gl_obj.gid}', {','.join(fields_to_copy_with_table)} FROM glacier_static gs WHERE gs.glacier_id='{gl_obj.old_gid}';"
    rtn_code = issue_sql(sql, dbh_new_cur, args)
    return rtn_code


def add_part_to_glacier_dynamic(gl_obj, dbh_new_cur, args):
    ''' When multipolygons are converted to multiple single polygons, they need
        new records in the glacier_dynamic table.
    '''

    # Make SQL to do insert by combining the new info with that already in
    # glacier_dynamic.  This is the INSERT INTO SELECT form.

    # All fields from glacier_dynamic except db_calculated_area, which will
    # need to be recalculated.

    all_glacier_dynamic_fields = [
         'analysis_id',
         'glacier_id',
         'analysis_timestamp',
         'rc_id',
         'contact_id',
         'three_d_desc',
         'width',
         'length',
         'area',
         'abzone_area',
         'speed',
         'snowline_elev',
         'ela',
         'ela_desc',
         'primary_classification',
         'primary_classification2',
         'form',
         'frontal_characteristics',
         'frontal_characteristics2',
         'longitudinal_characteristics',
         'dominant_mass_source',
         'tongue_activity',
         'tongue_activity2',
         'moraine_code1',
         'moraine_code2',
         'debris_cover',
         'record_status',
         'icesheet_conn_level',
         'source_timestamp',
         'min_elev',
         'mean_elev',
         'max_elev',
         'orientation_accum',
         'basin_code',
         'num_basins',
         'avg_slope',
         'submission_id',
         'orientation_ablat',
         'thickness_m',
         'orientation',
         'median_elev',
         'rgiid',
         'rgi_glactype',
         'rgi_join_count',
         'rgi_maxlength_m',
         'gtng_o1region',
         'gtng_o2region',
         'rgiflag',
         'src_time_end',
         'surge_type',
         'term_type',
    ]

    # Replace analysis_id and glacier_id with the new ones
    fields_to_copy_from_old_rec = all_glacier_dynamic_fields[2:]

    # Add table name to field names.
    fields_to_copy_with_table = ['gd.' + e for e in fields_to_copy_from_old_rec]

    sql = f"INSERT INTO data.glacier_dynamic ( {','.join(all_glacier_dynamic_fields)} ) SELECT {gl_obj.aid}, '{gl_obj.gid}', {','.join(fields_to_copy_with_table)} FROM glacier_dynamic gd WHERE gd.analysis_id={gl_obj.old_aid};"

    rtn_code = issue_sql(sql, dbh_new_cur, args)
    return rtn_code


def glac_objs_to_sql_inserts(obj_list):
    ''' glac_objs_to_sql_inserts -- create SQL INSERT statements for a list of glacier_entity
        objects

        Input:  list of Glacier_entity objects
        Output: List of INSERT statements

            # Prepare SQL
            # geom_part will look something like this:

            # ST_GeomFromEWKT('SRID=4326;POLYGON((-18.225858 79.933083 0,
            #     -18.225269 79.932970 0, -18.225888 79.932975 0, -18.225858 79.933083 0))'));

    '''
    move_sql = []
    for i, gl_obj in enumerate(obj_list):

        # DEBUG
        if type(gl_obj) is not Glacier_entity:
            print(f"Found non-Glacier_entity in object number {i}: ", gl_obj, file=sys.stderr)
            sys.exit(1)

        gid = gl_obj.gid
        #print("gl_obj: ", gl_obj, file=sys.stderr)  # DEBUG
        coords = gl_obj.as_ewkt_with_srid()
        geom_part = f"ST_GeomFromEWKT('{coords}')"
        sql = f'INSERT INTO {SCHEMA}.glacier_entities (analysis_id, line_type, entity_geom) VALUES ' \
              + f"({gl_obj.aid}, '{gl_obj.line_type}', {geom_part});"
        move_sql.append(sql)

    return move_sql


def insert_row_as_simple_copy(T, row):
    ''' insert_row_as_simple_copy -- print or do INSERT of unchanged row to unchanged table

        Because Postgresql expects strings with single quotes in them to look like this:

            'This is SQL''s single quote mechanism'

        and because Python interpolates strings with single quotes in them by putting double quotes around them as

            "This is SQL's single quote mechanism"

        I've used QQ as a stand-in for '', do the interpolation, then replace the QQ with '' after.  Ugh.
    '''

    row_fixed = [e.isoformat() if type(e) in (dt.date, dt.time, dt.datetime) else e for e in row]
    row_fixed = [int(e) if type(e) is decimal.Decimal else e for e in row_fixed]
    row_fixed = [fix_quotes(e) for e in row_fixed]
    row_fixed = tuple(['NULL' if e is None else e for e in row_fixed])
    sql_out = f'INSERT INTO {SCHEMA}.{T} VALUES {row_fixed};'
    sql_out = sql_out.replace("'NULL'", 'NULL')
    sql_out = sql_out.replace('QQ', "''")
    return sql_out


def fix_quotes(e):
    ''' fix_quotes -- Make double-single quoting conform to what Postgresql needs.

        Example:

            "This is X"avier's book"

        becomes

            'This is X"avierQQs book'

        which the function insert_row_as_simple_copy will change to

            'This is X"avier''s book'

    '''
    if type(e) is str:
        no_outer = e.strip('"\'')
        no_outer = no_outer.replace("'", 'QQ')
        final = f"{no_outer}"
    else:
        final = e

    return final


def count_recs(T, dbh_cur):
    '''
    Count number of records in table T, database handle dbh
    '''
    count_sql = f'SELECT COUNT(*) FROM {SCHEMA}.{T}'
    dbh_cur.execute(count_sql)
    cnt = int(dbh_cur.fetchone()[0])
    return cnt


def do_db_move(args):
    """
    Do major steps to move the database.
    """

    tables = get_tables_list(debug=args.debug, from_glacents=args.From_glacier_entities,
             to_glacents=args.To_glacier_entities)

    if tables is not None:
        print("Table list:", file=sys.stderr)
        print(list(tables.keys()), file=sys.stderr)
    else:
        print("Something is wrong with table definition", file=sys.stderr)
        sys.exit(1)

    if args.list_tables:
        sys.exit(2)

    # Open connections to both databases
    dbh_old_cur = connect_to_db('old')
    dbh_new_cur = connect_to_db('new')

    # Do sanity check if option From_glacier_entities is True
    if args.From_glacier_entities:
        if count_recs('reference_document', dbh_new_cur) == 0:
            print('From_glacier_entities flag specified but other tables are empty', file=sys.stderr)
            sys.exit(1)

    for T in tables.keys():
        # Default is a simple copy to the new db
        if T in ('glacier_polygons'):
            if not args.quiet:
                print("Processing 'glacier_polygons' table ...", file=sys.stderr)
            process_glacier_entities(T, dbh_old_cur, dbh_new_cur, args)
        else:
            # Simple copy
            # Can pg_dump/pg_restore be part of this? Nah...
            # Select *, then do a COPY command?

            if not args.quiet:
                print(f"Processing '{T}' table ...", file=sys.stderr)

            sort_orders = {'regional_centers': 'rc_id',
                          }

            if T in sort_orders:
                sort_by = f'ORDER BY {sort_orders[T]}'
            else:
                sort_by = ''

            sql = f'SELECT * from {T} {sort_by};'
            dbh_old_cur.execute(sql)
            for row in dbh_old_cur.fetchall():
                rtn_code = issue_sql(insert_row_as_simple_copy(T, row), dbh_new_cur, args)
                if rtn_code is None and not args.quiet:
                    print("Warning: SQL failed", file=sys.stderr)

    # psycopg2 uses transactions by default, which must be commited
    #issue_sql('COMMIT;', dbh_new_cur, args)


def main():
    """

    Main entry point of the program.

    Steps to moving database:

    - Read from physical tables, in order of dependencies, transforming data
      when necessary.

    - Write directly to database, or SQL to stdout.


    """
    p = setup_argument_parser()

    # Parse command-line.
    args = p.parse_args()

    today_string = dt.date.today().isoformat()

    # Get environment
    user = os.environ['USER']
    print('User:', user, file=sys.stderr)

    if not args.quiet:
        print_arg_summary(args)

    do_db_move(args)

    print("-- DONE")

    # End of main


if __name__ == '__main__':
    main()
