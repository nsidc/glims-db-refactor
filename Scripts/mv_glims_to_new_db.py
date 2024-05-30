#!/usr/bin/env python3
"""

Read data from the existing GLIMS database, transform to the new data model,
and write to the new database.

"""

import os
import sys
import datetime
import argparse
from collections import OrderedDict
from collections import defaultdict

import psycopg2
from shapely.geometry import Polygon
from shapely.wkt import loads as sloads

from connection import CONN, CONN_V2
from db_objs import Glacier_entity


def print_arg_summary(args):
    """Print summary of command-line arguments."""
    print("Arguments object:", file=sys.stderr)
    print(args, file=sys.stderr)


def setup_argument_parser():
    """Set up command line options.  -h or --help for help is automatic"""
    b_help = 'Bounding box to define region for move. Format: --bbox=W,E,S,N'

    p = argparse.ArgumentParser()

    p.add_argument('-b', '--bbox', default='all',  help=b_help)
    p.add_argument('-d', '--debug', action='store_true',  help='Run in debugging mode')
    p.add_argument('-q', '--quiet',   action='store_true', default=False, help="Quiet mode.  Don't print status messages")

    return(p)


def connect_to_db():
    try:
        conn = psycopg2.connect(CONN)
    except:
        print(f"Unable to connect to the {dbname} database at {srv}", file=sys.stderr)
        sys.exit(1)

    dbh  = conn.cursor()
    return dbh


def get_tables_list(debug=False):
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
        #rtndict = {'image': ()}  # to fix the datetime.datetime issue
        #rtndict = {'glacier_polygons': ()}  # for meat of the data transform
        #rtndict = {'country': ()}  # for case with a geometry column
        rtndict = {'reference_document': ()}  # for simple scalar case
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



def connect_to_db():
    try:
        db_old = psycopg2.connect(CONN)
    except:
        print(f"Unable to connect to the old database.", file=sys.stderr)
        sys.exit(1)

    dbh_old  = db_old.cursor()

    # Until we have the new database, just return old and None
    #return (dbh_old, None)

    try:
        db_new = psycopg2.connect(CONN_V2)
    except:
        print(f"Unable to connect to the new database.", file=sys.stderr)
        sys.exit(1)

    dbh_new  = db_new.cursor()

    return (dbh_old, dbh_new)


def process_glacier_entities(T, dbh_old, dbh_new, args):
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
        W, E, S, N = args.bbox.split(',')
        region = f"ST_GeomFromEWKT('SRID=4326;POLYGON(({W} {S}, {E} {S}, {E} {N}, {W} {N}, {W} {S}))')"
        sql = base_query + f' AND {region} && {T}.glacier_polys'

    dbh_old.execute(sql)
    query_results = dbh_old.fetchall()      # list of tuples

    if not args.quiet:
        print(f"Selected {len(query_results)} records from table {T}", file=sys.stderr)

    move_sql = old_to_new_data_model(query_results, args)

    if not args.quiet:
        print(f"Printing {len(move_sql)} SQL statements...", file=sys.stderr)

    for m in move_sql:
        print(m)


def old_to_new_data_model(query_results, args):
    ''' old_to_new_data_model - translate all query results from old to new data model

    Input:  query_results, a list of tuples
    Output: SQL on stdout, or execute it on new DB

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

    Here are the needed actions by line_type:

    - pro_lake, supra_lake, basin_bound, debris_cov:  Simply copy as-is to the
      new "glacier_entities" table.

    - glac_bound and intrnl_rock:

        1) need to check that there aren't multiple glac_bound polygons for
           a given glacier.  In that case, we need to:

            a) break out into separate glac_polygons and assign new glacier IDs
            b) figure out which intrnl_rock polygons go with which glac_bound polygons
                - For each intrnl_rock polygon, check each glac_bound poly with
                  matching glac_id to see if it contains,

                - If none found, check all records.

        2) need to be combined so that intrnl_rock polygons become "holes" in the associated glac_bound polygon;

        This routine is detached from data source to enable application to test data.
    '''

    bounds_by_glac_id = defaultdict(list)
    rocks_by_glac_id = defaultdict(list)
    orphan_rocks_by_glac_id = defaultdict(list)
    new_glac_rec_by_glac_id = defaultdict(list)
    move_sql = []  # List of SQL statements to insert into the new DB

    # Copy non-glacier-bounds entities directly, or collect
    # glacier-bounds/intrnl_rock entities for further processing.

    for row in query_results:
        gl_obj = Glacier_entity(row)
        if gl_obj.line_type in ('pro_lake', 'supra_lake', 'basin_bound', 'debris_cov'):
            move_sql.append(insert_row_as_simple_copy(T, row))
        elif gl_obj.line_type == 'glac_bound':
            bounds_by_glac_id[gl_obj.gid].append(gl_obj)
        elif gl_obj.line_type == 'intrnl_rock':
            rocks_by_glac_id[gl_obj.gid].append(gl_obj)
        else:
            print("Warning: found unknown line_type: ", line_type, file=sys.stderr)

    # Now assemble glac_bound polys with holes
    if not args.quiet:
        print('Looping through glac_bound objects', file=sys.stderr)

    for gid, gl_obj_list in bounds_by_glac_id.items():

        if not args.quiet:
            print(f'{gid}:  Got {len(gl_obj_list)} piece(s)', file=sys.stderr)

        if len(gl_obj_list) > 1:
            # multiple glac_bound polys for this glacier
            print(f"Warning: Just found multiple glac_bound outlines for {gid}", file=sys.stderr)
            pass
        else:
            # Single glac_bound polygon. Find any intrnl_rock polys
            bound_obj = gl_obj_list[0]
            if gid in rocks_by_glac_id:
                rock_objs = rocks_by_glac_id[gid]  # list of "row" tuples
                # Check for containment...
                int_rocks = []
                for r in rock_objs:
                    if not bound_obj.contains(r):
                        orphan_rocks_by_glac_id[gid].append(r)
                    else:
                        int_rocks.append(r)

                # Assemble holey polygon
                holey_geom = Polygon(bound_obj.sgeom.exterior, [e.sgeom.exterior for e in int_rocks])
                bound_obj.sgeom = holey_geom

            # Prepare SQL
            # geom_part will look something like this:

            # ST_GeomFromEWKT('SRID=4326;POLYGON((-18.225858 79.933083 0,
            #     -18.225269 79.932970 0, -18.225888 79.932975 0, -18.225858 79.933083 0))'));

            geom_part = f"ST_GeomFromEWKT('{bound_obj.as_ewkt_with_srid()}')"
            sql = f'INSERT INTO glacier_entities (analysis_id, line_type, entity_geom) VALUES ' \
                  + f"({bound_obj.aid}, '{bound_obj.line_type}', {geom_part});"
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

    row_fixed = [e.isoformat() if type(e) is datetime.datetime else e for e in row]
    row_fixed = [fix_quotes(e) for e in row_fixed]
    row_fixed = tuple(['NULL' if e is None else e for e in row_fixed])
    sql_out = f'INSERT INTO {T} VALUES {row_fixed};'
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


def do_db_move(args):
    """
    Do major steps to move the database.
    """

    tables = get_tables_list(debug=args.debug)

    if tables is not None:
        print("Got table list:", file=sys.stderr)
        print(list(tables.keys()), file=sys.stderr)
    else:
        print("Something is wrong with table definition", file=sys.stderr)

    # Open connections to both databases
    dbh_old, dbh_new = connect_to_db()

    # Start transaction for all SQL
    print('BEGIN;')

    for T in tables.keys():
        # Default is a simple copy to the new db
        if T in ('glacier_polygons'):
            if not args.quiet:
                print("Processing 'glacier_polygons' table ...", file=sys.stderr)
            process_glacier_entities(T, dbh_old, dbh_new, args)
        else:
            # Simple copy
            # Can pg_dump/pg_restore be part of this? Nah...
            # Select *, then do a COPY command?

            if not args.quiet:
                print(f"Processing '{T}' table ...", file=sys.stderr)

            sql = f'SELECT * from {T};'
            dbh_old.execute(sql)
            for row in dbh_old.fetchall():
                print(insert_row_as_simple_copy(T, row))


def main():
    """

    Main entry point of the program.

    Steps to moving database:

    - Start a transaction.

    - Read from physical tables, in order of dependencies, transforming data
      when necessary.

    - Write directly to database, or SQL to stdout.


    """
    p = setup_argument_parser()

    # Parse command-line.
    args = p.parse_args()

    today_string = datetime.date.today().isoformat()

    # Get environment
    user = os.environ['USER']
    print('User:', user, file=sys.stderr)

    if not args.quiet:
        print_arg_summary(args)

    do_db_move(args)

    # End of main


if __name__ == '__main__':
    main()
