#!/usr/bin/env python3
"""

Read data from the existing GLIMS database, transform to the new data model,
and write to the new database.

"""

import os
import sys
import datetime as dt
import argparse
from collections import OrderedDict
from pprint import pprint

import psycopg2

from connection import CONN, CONN_V2


def print_arg_summary(args):
    """Print summary of command-line arguments."""
    print("Arguments object:", file=sys.stderr)
    print(args, file=sys.stderr)


def setup_argument_parser():
    """Set up command line options.  -h or --help for help is automatic"""
    b_help = 'Bounding box to define region for move. Format: --bbox=W,E,S,N'

    p = argparse.ArgumentParser()

    p.add_argument('-o', '--outfile', default='mv_glims_db.sql',  help='File name for SQL output')
    p.add_argument('-b', '--bbox', default='all',  help=b_help)
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
        rtndict = {'country': ()}  # for case with a geometry column
        #rtndict = {'reference_document': ()}  # for simple scalar case
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

    if check_dependencies(tables):
        return tables
    else:
        return None


def check_dependencies(tables):
    '''
    check_dependencies: check that the tables are in a correct order to satisfy dependencies
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
    return (dbh_old, None)

    try:
        db_new = psycopg2.connect(CONN_V2)
    except:
        print(f"Unable to connect to the new database.", file=sys.stderr)
        sys.exit(1)

    dbh_new  = db_new.cursor()

    return (dbh_old, dbh_new)


def process_glacier_entities(T, dbh_old, dbh_new, args):
    '''
    process_glacier_entities -- Move glacier_polygons to glacier_entities

    - Read all records within region (args.bbox), group by glacier_id, and
      convert all intrnl_rock polygons to holes in the associated glac_bound
      polygon

      TODO:  Need to select also from glacier_dynamic so that I get the glacier_id

    '''
    if args.bbox == 'all':
        sql = f'SELECT gd.glacier_id, gd.analysis_id, {T}.* FROM {T}, glacier_dynamic gd WHERE {T}.analysis_id=gd.analysis_id'
    else:
        W, E, S, N = args.bbox.split(',')
        region = f"ST_MakePolygon(ST_GeomFromText('LINESTRING({W} {S}, {E} {S}, {E} {N}, {W} {N}, {W} {S})'))"
        sql = f'SELECT gd.glacier_id, gd.analysis_id, {T}.* FROM {T}, glacier_dynamic gd WHERE {T}.analysis_id=gd.analysis_id AND ST_Overlaps(region, {T}.glacier_polys)'

    dbh_old.execute(sql)

    ents_by_glac_id = {}
    for row in dbh_old.fetchall():
        aid, line_type, glac_polys, 


def do_db_move(args):
    """
    Do major steps to move the database.
    """
    
    tables = get_tables_list(debug=True)

    if tables is not None:
        print("Got table list:", file=sys.stderr)
        print(list(tables.keys()), file=sys.stderr)
        #pprint(list(tables.keys()), file=sys.stderr)
    else:
        print("Something is wrong with table definition", file=sys.stderr)

    # Open connections to both databases
    dbh_old, dbh_new = connect_to_db()

    for T in tables.keys():
        # Default is a simple copy to the new db
        if T in ('glacier_polygons'):
            process_glacier_entities(T, dbh_old, dbh_new, args)
        else:
            # Simple copy
            # Can pg_dump/pg_restore be part of this? Nah...
            # Select *, then do a COPY command?
            sql = f'SELECT * from {T};'
            dbh_old.execute(sql)
            for row in dbh_old.fetchall():
                row_fixed = tuple(['NULL' if e is None else e for e in row])
                sql_out = f'INSERT INTO {T} VALUES {row_fixed};'
                sql_out = sql_out.replace("'NULL'", 'NULL')
                print(sql_out)


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

    today_string = dt.date.today().isoformat()

    # Get environment
    user = os.environ['USER']
    print('User:', user, file=sys.stderr)

    if not args.quiet:
        print_arg_summary(args)

    do_db_move(args)

    # End of main


if __name__ == '__main__':
    main()
