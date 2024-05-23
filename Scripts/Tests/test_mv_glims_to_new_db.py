import shapely
from shapely.geometry import Polygon
from shapely.wkt import loads as sloads

import mv_glims_to_new_db as mv


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
        ('G1', 1, 'glac_bound',  'SRID=4326;POLYGON((0 0, 0 2, 2 2, 2 0, 0 0))'),
        ('G1', 1, 'intrnl_rock', 'SRID=4326;POLYGON((0.8 1, 0.8 1.8, 1.2 1.8, 1.2 1, 0.8 1))'),
        ('G1', 1, 'glac_bound',  'SRID=4326;POLYGON((3 0, 3 2, 5 2, 5 0, 3 0))'),
        ('G1', 1, 'intrnl_rock', 'SRID=4326;POLYGON((3.8 1, 3.8 1.8, 4.2 1.8, 4.2 1, 3.8 1))'),

        ('G2', 2, 'glac_bound',  'SRID=4326;POLYGON((7 0, 7 2, 9 2, 9 0, 7 0))'),
        ('G2', 2, 'intrnl_rock', 'SRID=4326;POLYGON((7.8 1, 7.8 1.8, 8.2 1.8, 8.2 1, 7.8 1))'),

        ('G3', 3, 'glac_bound',  'SRID=4326;POLYGON((1 3, 1 5, 3 5, 3 3, 1 3))'),

        ('G3', 3, 'intrnl_rock', 'SRID=4326;POLYGON((4.8 4, 4.8 4.8, 5.2 4.8, 5.2 4, 4.8 4))'),

        ('G1', 1, 'pro_lake',    'SRID=4326;POLYGON((0 2, 0 3, 1 3, 1 2, 0 2))'),
        ('B1', 1, 'basin__bound','SRID=4326;POLYGON((0 0, 0 6, 9 6, 9 0, 0 0))'),
    ]

    return entity_list


def test_extract_poly_only():
    poly_ewkt = 'SRID=4326;POLYGON((4.8 4, 4.8 4.8, 5.2 4.8, 5.2 4, 4.8 4))'
    poly_only =           'POLYGON((4.8 4, 4.8 4.8, 5.2 4.8, 5.2 4, 4.8 4))'
    got = mv.extract_poly_only(poly_ewkt)
    print('got = ', got)
    print('poly_only = ', poly_only)
    assert(got == sloads(poly_only))


def test_add_srid_to_poly():
    poly_ewkt = 'SRID=4326;POLYGON((4.8 4, 4.8 4.8, 5.2 4.8, 5.2 4, 4.8 4))'
    poly_only = 'POLYGON((4.8 4, 4.8 4.8, 5.2 4.8, 5.2 4, 4.8 4))'
    got = mv.add_srid_to_poly(poly_only)
    assert(got == poly_ewkt)


def test_insert_row_as_simple_copy():
    T = 'the_table'
    row = (1, 2, None, 'abcde')
    expect = "INSERT INTO the_table VALUES (1, 2, NULL, 'abcde');"
    got = mv.insert_row_as_simple_copy(T, row)
    assert(expect == got)


def test_testdata_1():
    '''
    Test that the coordinates lead to the expected overlaps
    '''
    testdata = _make_test_data()
    g1_geom = mv.extract_poly_only(testdata[0][3])
    g1a_geom = mv.extract_poly_only(testdata[1][3])
    assert(g1_geom.contains(g1a_geom))


def test_testdata_2():
    '''
    Test that the coordinates lead to the expected overlaps
    '''
    testdata = _make_test_data()
    g1_geom = mv.extract_poly_only(testdata[2][3])
    g1a_geom = mv.extract_poly_only(testdata[3][3])
    assert(g1_geom.contains(g1a_geom))


def test_testdata_3():
    '''
    Test that the coordinates lead to the expected overlaps
    '''
    testdata = _make_test_data()
    g1_geom = mv.extract_poly_only(testdata[4][3])
    g1a_geom = mv.extract_poly_only(testdata[5][3])
    assert(g1_geom.contains(g1a_geom))


def test_testdata_4():
    '''
    Test that the coordinates lead to the expected overlaps
    '''
    testdata = _make_test_data()
    g1_geom = mv.extract_poly_only(testdata[6][3])
    g1a_geom = mv.extract_poly_only(testdata[7][3])
    assert(not g1_geom.contains(g1a_geom))


def test_testdata_5():
    '''
    Test that the coordinates lead to the expected overlaps
    '''
    testdata = _make_test_data()
    g1_geom = mv.extract_poly_only(testdata[9][3])
    g1a_geom = mv.extract_poly_only(testdata[6][3])
    assert(g1_geom.contains(g1a_geom))


def test_testdata_6():
    '''
    Test of converting to holey polygon
    '''
    testdata = _make_test_data()
    g1_geom = mv.extract_poly_only(testdata[0][3])
    g1a_geom = mv.extract_poly_only(testdata[1][3])

    g1_area = g1_geom.area
    g1a_area = g1a_geom.area

    holey = Polygon(g1_geom.exterior, [g1a_geom.exterior])
    combined_area = holey.area

    print("g1_area: ", g1_area, "; g1a_area = ", g1a_area, ";  combined_area = ", combined_area)

    assert(g1_area == 4.0 and combined_area == 3.68)


def test_testdata_multiple_holes():
    '''
    Test of converting to multi-holey polygon
    '''
    testdata = _make_test_data()
    outer = mv.extract_poly_only(testdata[9][3])
    inner1 = mv.extract_poly_only(testdata[0][3])
    inner2 = mv.extract_poly_only(testdata[2][3])
    inner3 = mv.extract_poly_only(testdata[4][3])

    outer_area = outer.area
    inners = inner1.area + inner2.area + inner3.area

    holey = Polygon(outer.exterior, [inner1.exterior, inner2.exterior, inner3.exterior])
    combined_area = holey.area

    print("outer_area: ", outer_area, "; inners = ", inners, ";  combined_area = ", combined_area)

    assert(outer_area == 54.0 and combined_area == 42.0)


def test_old_to_new_data_model():
    '''
    Test full representation of test data in new data model
    '''
    testdata = _make_test_data()
