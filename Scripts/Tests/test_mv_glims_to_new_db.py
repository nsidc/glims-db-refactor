import sys

import shapely
from shapely.geometry import Polygon, shape
#from shapely.wkt import loads as sloads
import psycopg2

import mv_glims_to_new_db as mv
from db_objs import Glacier_entity


def _make_test_data():
    '''
    Test data is in the format of a database query result:  a list of tuples:
    [(glacier_id, analysis_id, line_type, glacier_polys),
    ...]

 X: 0     1      2    3      4     5     6      7     8      9
Y
0   --------------    --------------            --------------
    | G1         |    | G1 --> G4  |            | G2         |
1   |   ----     |    |   ----     |            |  ----      |
    |   |1a|     |    |   |4a|     |            |  |2a|      |
    |   ----     |    |   ----     |            |  ----      |
2   --------------    --------------            --------------

3           --------------
            | G3         |
4           |   ------   |      -------
            |   |lake|   |      | 3a? |
            |   ------   |      -------
5           --------------

    - Glacier "G1" has two glac_bound polygons that must be given separate
      identities (hence G1 --> G4).

    - Internal rock polygons 1a, 2a, and 4a should be converted to holes in
      glac_bound polys G1, G2, and G4.

    - Internal rock polygon 3a? is outside glac_bound polygon 3.  What is best action?

        - Warn about it but drop it?

        - Warn about it but convert it to glac_bound polygon and assign it
          a new GLIMS glacier ID?

Combined geoms should look something like this:

'SRID=4326;POLYGON ((0 0, 2 0, 2 2, 0 2, 0 0), (0.8 1, 0.8 1.8, 1.2 1.8, 1.2 1, 0.8 1))',
'SRID=4326;POLYGON ((3 0, 5 0, 5 2, 3 2, 3 0), (3.8 1, 3.8 1.8, 4.2 1.8, 4.2 1, 3.8 1))',
'SRID=4326;POLYGON ((7 0, 7 2, 9 2, 9 0, 7 0), (7.8 1, 7.8 1.8, 8.199999999999999 1.8, 8.199999999999999 1, 7.8 1))',
'SRID=4326;POLYGON ((1 3, 1 5, 3 5, 3 3, 1 3))']

    '''
    entity_list = [
        ('G1', 1, 'glac_bound',  'SRID=4326;POLYGON ((0 0, 0 2, 2 2, 2 0, 0 0))'),
        ('G1', 1, 'intrnl_rock', 'SRID=4326;POLYGON ((0.8 1, 0.8 1.8, 1.2 1.8, 1.2 1, 0.8 1))'),
        ('G1', 1, 'glac_bound',  'SRID=4326;POLYGON ((3 0, 3 2, 5 2, 5 0, 3 0))'),
        ('G1', 1, 'intrnl_rock', 'SRID=4326;POLYGON ((3.8 1, 3.8 1.8, 4.2 1.8, 4.2 1, 3.8 1))'),

        ('G2', 2, 'glac_bound',  'SRID=4326;POLYGON ((7 0, 7 2, 9 2, 9 0, 7 0))'),
        ('G2', 2, 'intrnl_rock', 'SRID=4326;POLYGON ((7.8 1, 7.8 1.8, 8.2 1.8, 8.2 1, 7.8 1))'),

        ('G3', 3, 'glac_bound',  'SRID=4326;POLYGON ((1 3, 1 5, 3 5, 3 3, 1 3))'),

        ('G3', 3, 'intrnl_rock', 'SRID=4326;POLYGON ((4.8 4, 4.8 4.8, 5.2 4.8, 5.2 4, 4.8 4))'),

        ('G1', 1, 'pro_lake',    'SRID=4326;POLYGON ((0 2, 0 3, 1 3, 1 2, 0 2))'),
        ('B1', 1, 'basin_bound', 'SRID=4326;POLYGON ((-1 -1, -1 7, 10 7, 10 -1, -1 -1))'),

        ('G3', 3, 'supra_lake',  'SRID=4326;POLYGON ((1.5 4, 2.5 4, 2.5 4.5, 1.5 4.5, 1.5 4))'),
        ('G1', 1, 'supra_lake',  'SRID=4326;POLYGON ((3.8 1, 3.8 1.8, 4.2 1.8, 4.2 1, 3.8 1))'),
    ]

    return entity_list


def _make_multipolygon_2_simple():
    # See https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry for format
    obj = ('G1_multi', 1, 'glac_bound',
            'SRID=4326;MULTIPOLYGON (((30 20, 45 40, 10 40, 30 20)), ((15 5, 40 10, 10 20, 5 10, 15 5)))')
    return obj


def _make_multipolygon_2_1_w_hole():
    # See https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry for format
    obj = ('G1_multi_h', 2, 'glac_bound',
            'SRID=4326;MULTIPOLYGON (((40 40, 20 45, 45 30, 40 40)), ((20 35, 10 30, 10 10, 30 5, 45 20, 20 35), (30 20, 20 15, 20 25, 30 20)))')
    return obj


def _make_Glacier_entity_object():

    gid = 'G123456E12345N'
    aid = 42
    line_type = 'glac_bound'
    geom = 'SRID=4326;POLYGON ((0 0, 0 2, 2 2, 2 0, 0 0))'

    sim_row = (gid, aid, line_type, geom)
    gl_obj = Glacier_entity(sim_row)
    return gl_obj


def test_fix_quotes():
    teststring = '"This is X"avier\'s book"'
    expect = 'This is X\"avierQQs book'
    got = mv.fix_quotes(teststring)
    print('   got = ', got)
    print('expect = ', expect)
    assert(got == expect)


def test_fix_quotes_real():
    teststring = '"Global Land Ice Measurements from Space (GLIMS): Remote Sensing and GIS Investigations of the Earth\'s Cryosphere"'
    expect     = 'Global Land Ice Measurements from Space (GLIMS): Remote Sensing and GIS Investigations of the EarthQQs Cryosphere'
    got = mv.fix_quotes(teststring)
    print('   got = ', got)
    print('expect = ', expect)
    assert(got == expect)

def test_fix_quotes_real2():
    teststring = '"Kilimanjaro\'s Secrets Revealed"'
    expect     = 'KilimanjaroQQs Secrets Revealed'
    got = mv.fix_quotes(teststring)
    print('   got = ', got)
    print('expect = ', expect)
    assert(got == expect)


def test_as_tuple():
    testdata = _make_test_data()
    in_tuple = testdata[0]
    g1 = Glacier_entity(in_tuple)
    got = g1.as_tuple()
    print('in_tuple = ', in_tuple)
    print('     got = ', got)
    assert(got == in_tuple)


def test_srid():
    testdata = _make_test_data()
    g1 = Glacier_entity(testdata[0])
    got = g1.srid
    expect = 'SRID=4326'
    assert(got == expect)


def test_as_ewkt_with_srid():
    testdata = _make_test_data()
    g1 = Glacier_entity(testdata[0])
    got = g1.as_ewkt_with_srid()
    expect = 'SRID=4326;POLYGON ((0 0, 0 2, 2 2, 2 0, 0 0))'
    print('   got = ', got)
    print('expect = ', expect)
    assert(got == expect)


def test_insert_row_as_simple_copy1():
    T = 'the_table'
    row = (1, 2, None, 'abcde')
    expect = "INSERT INTO data.the_table VALUES (1, 2, NULL, 'abcde');"
    got = mv.insert_row_as_simple_copy(T, row)
    print('   got = ', got)
    print('expect = ', expect)
    assert(expect == got)


def test_insert_row_as_simple_copy2():
    T = 'the_table'
    row = (1, 2, None, '"abcde"')
    expect = "INSERT INTO data.the_table VALUES (1, 2, NULL, 'abcde');"
    got = mv.insert_row_as_simple_copy(T, row)
    print('   got = ', got)
    print('expect = ', expect)
    assert(expect == got)


def test_testdata_1():
    '''
    Test that the coordinates lead to the expected overlaps
    '''
    testdata = _make_test_data()
    g1 = Glacier_entity(testdata[0])
    g1a = Glacier_entity(testdata[1])
    assert(g1.contains(g1a))


def test_testdata_2():
    '''
    Test that the coordinates lead to the expected overlaps
    '''
    testdata = _make_test_data()
    g1 = Glacier_entity(testdata[2])
    g1a = Glacier_entity(testdata[3])
    assert(g1.contains(g1a))


def test_testdata_3():
    '''
    Test that the coordinates lead to the expected overlaps
    '''
    testdata = _make_test_data()
    g2 = Glacier_entity(testdata[4])
    g2a = Glacier_entity(testdata[5])
    assert(g2.contains(g2a))


def test_testdata_4():
    '''
    Test that the coordinates lead to the expected overlaps
    '''
    testdata = _make_test_data()
    g3 = Glacier_entity(testdata[6])
    g3a = Glacier_entity(testdata[7])
    assert(not g3.contains(g3a))


def test_testdata_5():
    '''
    Test that the coordinates lead to the expected overlaps
    '''
    testdata = _make_test_data()
    bbound = Glacier_entity(testdata[9])
    g3 = Glacier_entity(testdata[6])
    assert(bbound.contains(g3))


def test_testdata_5a():
    '''
    Test that the coordinates lead to the expected overlaps
    '''
    testdata = _make_test_data()
    g3 = Glacier_entity(testdata[6])
    g3_lake = Glacier_entity(testdata[10])
    assert(g3.contains(g3_lake))


def test_testdata_6():
    '''
    Test of converting to holey polygon
    '''
    testdata = _make_test_data()
    g1 = Glacier_entity(testdata[0])
    g1a = Glacier_entity(testdata[1])

    g1_area = g1.sgeom.area
    g1a_area = g1a.sgeom.area

    holey = Polygon(g1.sgeom.exterior, holes=[g1a.sgeom.exterior])
    combined_area = holey.area

    print("g1_area: ", g1_area, "; g1a_area = ", g1a_area, ";  combined_area = ", combined_area)

    assert(g1_area == 4.0 and combined_area == 3.68)


def test_testdata_multiple_holes():
    '''
    Test of converting to multi-holey polygon
    '''
    testdata = _make_test_data()
    outer = Glacier_entity(testdata[9])
    inner1 = Glacier_entity(testdata[0])
    inner2 = Glacier_entity(testdata[2])
    inner3 = Glacier_entity(testdata[4])

    outer_area = outer.sgeom.area
    inners = inner1.sgeom.area + inner2.sgeom.area + inner3.sgeom.area

    holey = Polygon(outer.sgeom.exterior, [inner1.sgeom.exterior, inner2.sgeom.exterior, inner3.sgeom.exterior])
    combined_area = holey.area

    print("outer_area: ", outer_area, "; inners = ", inners, ";  combined_area = ", combined_area)
    print("holey: ", holey)

    print("After buffer:  holey: ", holey.buffer(0.0))

    assert(outer_area == 88.0 and combined_area == 76.0)


def test_connect_to_db_old_by_default():
    old_cur = mv.connect_to_db()
    assert(type(old_cur) is psycopg2.extensions.cursor)


def test_connect_to_db_old_by_arg():
    old_cur = mv.connect_to_db(db='src')
    assert(type(old_cur) is psycopg2.extensions.cursor)


def test_connect_to_db_new_by_arg():
    new_cur = mv.connect_to_db(db='dst')
    assert(type(new_cur) is psycopg2.extensions.cursor)


def test_connect_to_db_new_ENV_by_arg():
    new_cur = mv.connect_to_db(db='dst', dsthost='new')
    assert(type(new_cur) is psycopg2.extensions.cursor)


def test_get_new_aid_generator():
    get_new_aid = mv.next_aid_generator()
    aid_a = next(get_new_aid)
    aid_b = next(get_new_aid)
    assert(aid_b - aid_a == 1)


def test_make_new_gid_new():
    glac_bound_obj = _make_Glacier_entity_object()
    g1 = _make_Glacier_entity_object()
    g2 = _make_Glacier_entity_object()
    g1.gid = 'G123456E12345N'
    g2.gid = 'G123456E12345S'
    fake_existing_polys = [g1, g2]
    new_gid = mv.make_new_gid(glac_bound_obj, fake_existing_polys)
    print('new_gid = ', new_gid)
    assert(new_gid == 'G001000E01000N')


def test_make_new_gid_dupe_in_dict():
    glac_bound_obj = _make_Glacier_entity_object()
    g1 = _make_Glacier_entity_object()
    g2 = _make_Glacier_entity_object()
    g1.gid = 'G001000E01000N'
    g2.gid = 'G123456E12345S'
    fake_existing_polys = [g1, g2]
    neighbors = ['G000999E00999N', 'G001000E00999N', 'G001001E00999N', 'G000999E01000N', 'G001001E01000N', 'G000999E01001N', 'G001000E01001N', 'G001001E01001N']

    new_gid = mv.make_new_gid(glac_bound_obj, fake_existing_polys)
    print('new_gid = ', new_gid)
    assert(new_gid in neighbors)


def test_Glacier_entity_multi_to_poly():
    glac_obj_tuple = _make_multipolygon_2_simple()
    gl_obj = Glacier_entity(glac_obj_tuple)
    gl_list = list(gl_obj)
    print("test_Glacier_entity_multi_to_poly: gl_list=", gl_list, file=sys.stderr)
    print("test_Glacier_entity_multi_to_poly: gl_list[0]=", gl_list[0].as_tuple(), file=sys.stderr)
    assert(len(gl_list) == 2 and type(gl_list[0]) is Glacier_entity)


def test_Glacier_entity_multi_to_poly_hole():
    glac_obj_tuple = _make_multipolygon_2_1_w_hole()
    gl_obj = Glacier_entity(glac_obj_tuple)
    gl_list = list(gl_obj)
    print("test_Glacier_entity_multi_to_poly_hole: gl_list=", gl_list, file=sys.stderr)
    print("test_Glacier_entity_multi_to_poly_hole: gl_list[0]=", gl_list[0].as_tuple(), file=sys.stderr)
    assert(len(gl_list) == 2 and type(gl_list[0]) is Glacier_entity)


def test_explode_multipolygons_list_of_singles():
    g1 = _make_Glacier_entity_object()
    g2 = _make_Glacier_entity_object()
    glist = [g1, g2]
    parts = mv.explode_multipolygons(glist)
    assert(len(parts) == 2 and type(parts[0]) is Glacier_entity and type(parts[1]) is Glacier_entity)


def test_explode_multipolygons_one_multi():
    glac_obj_tuple = _make_multipolygon_2_simple()
    gl_obj = Glacier_entity(glac_obj_tuple)
    parts = mv.explode_multipolygons(gl_obj)
    print("test_explode_multipolygons_one_multi: parts=", parts, file=sys.stderr)
    print("test_explode_multipolygons_one_multi: parts[0]=", parts[0].as_tuple(), file=sys.stderr)
    assert(len(parts) == 2 and type(parts[0]) is Glacier_entity)


def test_explode_multipolygons_list_of_multi():
    glac_obj_tuple = _make_multipolygon_2_simple()
    gl_obj_1 = Glacier_entity(glac_obj_tuple)

    glac_obj_tuple = _make_multipolygon_2_1_w_hole()
    gl_obj_2 = Glacier_entity(glac_obj_tuple)

    glist = [gl_obj_1, gl_obj_2]
    parts = mv.explode_multipolygons(glist)
    print("test_explode_multipolygons_list_of_multi: glist=", parts, file=sys.stderr)
    print("test_explode_multipolygons_list_of_multi: parts[0]=", parts[0].as_tuple(), file=sys.stderr)
    assert(len(parts) == 4 and type(parts[0]) is Glacier_entity)


def test_write_glac_ent_to_file():
    tuple_data = _make_test_data()
    obj_data = [Glacier_entity(e) for e in tuple_data]  # Now have list of Glacier_entity objects
    mv.write_glac_ent_to_file(obj_data, 'test_data_as_shapefile.shp')
    assert(True)

