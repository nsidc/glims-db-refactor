import shapely
from shapely.geometry import Polygon
from shapely.wkt import loads as sloads

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
4           |            |      -------
            |            |      | 3a? |
            |            |      -------
5           --------------

    - Glacier "G1" has two glac_bound polygons that must be given separate
      identities (hence G1 --> G4).

    - Internal rock polygons 1a, 2a, and 4a should be converted to holes in
      glac_bound polys G1, G2, and G4.

    - Internal rock polygon 3a? is outside glac_bound polygon 3.  What is best action?

        - Warn about it but drop it?

        - Warn about it but convert it to glac_bound polygon and assign it
          a new GLIMS glacier ID?

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
        ('B1', 1, 'basin__bound','SRID=4326;POLYGON ((0 0, 0 6, 9 6, 9 0, 0 0))'),
    ]

    return entity_list


def test_fix_quotes():
    teststring = '"This is X"avier\'s book"'
    expect = "'This is X\"avier''s book'"
    got = mv.fix_quotes(teststring)
    print('   got = ', got)
    print('expect = ', expect)
    assert(got == expect)


def test_fix_quotes_real():
    teststring = '"Global Land Ice Measurements from Space (GLIMS): Remote Sensing and GIS Investigations of the Earth\'s Cryosphere"'
    expect     = "'Global Land Ice Measurements from Space (GLIMS): Remote Sensing and GIS Investigations of the Earth''s Cryosphere'"
    got = mv.fix_quotes(teststring)
    print('   got = ', got)
    print('expect = ', expect)
    assert(got == expect)

def test_fix_quotes_real2():
    teststring = '"Kilimanjaro\'s Secrets Revealed"'
    expect     = "'Kilimanjaro''s Secrets Revealed'"
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


def test_insert_row_as_simple_copy():
    T = 'the_table'
    row = (1, 2, None, 'abcde')
    expect = "INSERT INTO the_table VALUES (1, 2, NULL, 'abcde');"
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
    g1 = Glacier_entity(testdata[4])
    g1a = Glacier_entity(testdata[5])
    assert(g1.contains(g1a))


def test_testdata_4():
    '''
    Test that the coordinates lead to the expected overlaps
    '''
    testdata = _make_test_data()
    g1 = Glacier_entity(testdata[6])
    g1a = Glacier_entity(testdata[7])
    assert(not g1.contains(g1a))


def test_testdata_5():
    '''
    Test that the coordinates lead to the expected overlaps
    '''
    testdata = _make_test_data()
    g1 = Glacier_entity(testdata[9])
    g1a = Glacier_entity(testdata[6])
    assert(g1.contains(g1a))


def test_testdata_6():
    '''
    Test of converting to holey polygon
    '''
    testdata = _make_test_data()
    g1 = Glacier_entity(testdata[0])
    g1a = Glacier_entity(testdata[1])

    g1_area = g1.sgeom.area
    g1a_area = g1a.sgeom.area

    holey = Polygon(g1.sgeom.exterior, [g1a.sgeom.exterior])
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

    assert(outer_area == 54.0 and combined_area == 42.0)


def test_old_to_new_data_model():
    '''
    Test full representation of test data in new data model
    '''
    testdata = _make_test_data()
