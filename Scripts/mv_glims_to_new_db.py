#!/usr/bin/env python3
"""

Read data from the existing GLIMS database, transform to the new data model,
and write to the new database.

"""

import os
import sys
import datetime
import decimal
import argparse
from collections import OrderedDict
from collections import defaultdict

import psycopg2
from shapely.geometry import Polygon
from shapely.wkt import loads as sloads

from connection import CONN, CONN_V2, SCHEMA
from db_objs import Glacier_entity


def print_arg_summary(args):
    """Print summary of command-line arguments."""
    print("Arguments object:", file=sys.stderr)
    print(args, file=sys.stderr)


def setup_argument_parser():
    """Set up command line options.  -h or --help for help is automatic"""
    b_help = 'Bounding box to define region for move. Format: --bbox=W,E,S,N'
    G_help = 'Copy all tables from "glacier_entities" on. Previous tables should be in the new DB already.'
    T_help = 'Copy all tables up to, but not including, "glacier_entities". All other tables should be in the new DB already.'

    p = argparse.ArgumentParser()

    p.add_argument('-b', '--bbox', default='all',  help=b_help)
    p.add_argument('-d', '--debug', action='store_true',  help='Run in debugging mode.')
    p.add_argument('-G', '--from_Glacier_entities', action='store_true',  help=G_help)
    p.add_argument('-L', '--list_tables', action='store_true',  help='Show table list and exit')
    p.add_argument('-q', '--quiet',   action='store_true', default=False, help="Quiet mode.  Don't print status messages.")
    p.add_argument('-T', '--To_glacier_entities', action='store_true',  help=T_help)
    p.add_argument('-t', '--transaction',   action='store_true', default=False, help="Execute SQL as single transaction.")
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
        #rtndict = {'image': ()}  # to fix the datetime.datetime issue
        rtndict = {'glacier_polygons': ()}  # for meat of the data transform
        #rtndict = {'country': ()}  # for case with a geometry column WORKS
        #rtndict = {'reference_document': ()}  # for simple scalar case WORKS
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


def connect_to_db():
    try:
        db_old = psycopg2.connect(CONN)
    except:
        print(f"Unable to connect to the old database.", file=sys.stderr)
        sys.exit(1)

    dbh_old_cur  = db_old.cursor()

    try:
        db_new = psycopg2.connect(CONN_V2)
    except:
        print(f"Unable to connect to the new database.", file=sys.stderr)
        sys.exit(1)

    dbh_new_cur  = db_new.cursor()

    return (dbh_old_cur, dbh_new_cur)


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
            sys.exit(1)
    else:
        print(sql, file=sys.stdout)


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
        W, E, S, N = args.bbox.split(',')
        region = f"ST_GeomFromEWKT('SRID=4326;POLYGON(({W} {S}, {E} {S}, {E} {N}, {W} {N}, {W} {S}))')"
        sql = base_query + f' AND {region} && {T}.glacier_polys'

    dbh_old_cur.execute(sql)
    query_results = dbh_old_cur.fetchall()      # list of tuples

    if not args.quiet:
        print(f"Selected {len(query_results)} records from table {T}", file=sys.stderr)

    move_sql = old_to_new_data_model(query_results, args)

    if not args.quiet:
        print(f"Issuing {len(move_sql)} SQL statements...", file=sys.stderr)

    for m in move_sql:
        issue_sql(m, dbh_new_cur, args)


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
            move_sql.append(insert_row_as_simple_copy('glacier_entities', row))
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

        if not args.quiet and len(gl_obj_list) > 1:
            print(f'{gid}:  Got {len(gl_obj_list)} piece', file=sys.stderr)

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
            sql = f'INSERT INTO {SCHEMA}.glacier_entities (analysis_id, line_type, entity_geom) VALUES ' \
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

    row_fixed = [e.isoformat() if type(e) in (datetime.date, datetime.time, datetime.datetime) else e for e in row]
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

    tables = get_tables_list(debug=args.debug, from_glacents=args.from_Glacier_entities,
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
    dbh_old_cur, dbh_new_cur = connect_to_db()

    # Do sanity check if option from_Glacier_entities is True
    if args.from_Glacier_entities:
        if count_recs('reference_document', dbh_new_cur) == 0:
            print('from_Glacier_entities flag specified but other tables are empty', file=sys.stderr)
            sys.exit(1)

    # Start transaction for all SQL
    if args.transaction:
        issue_sql('BEGIN;', dbh_new_cur, args)

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
                issue_sql(insert_row_as_simple_copy(T, row), dbh_new_cur, args)

    if args.transaction:
        issue_sql('COMMIT;', dbh_new_cur, args)


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
