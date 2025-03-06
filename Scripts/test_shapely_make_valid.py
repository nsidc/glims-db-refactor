#!/usr/bin/env python3

import shapely
from shapely.geometry import Polygon
from shapely.validation import make_valid

p_v = Polygon(((0,0),(1,0),(1,1),(0,1), (0,0)))
p_i = Polygon(((0,0),(1,1),(1,0),(0,1), (0,0)))

print("p_i: ", p_i)

print("Printing 'make_valid(p_i)'")
print(make_valid(p_i))
print("Printing 'p_i.buffer(0.0)'")
print(p_i.buffer(0.0))

p_i = Polygon(((0,0),(10,0),(10,10),(0,10),(1,-1),(0,0)))

print("p_i is now: ", p_i)

print("Printing 'make_valid(p_i)'")
print(make_valid(p_i))
print("Printing 'p_i.buffer(0.0)'")
print(p_i.buffer(0.0))


import db_objs as d
import Tests.test_mv_glims_to_new_db as tm


glac_obj_tuple = tm._make_multipolygon_2_simple()
g1 = d.Glacier_entity(glac_obj_tuple)

glac_obj_tuple = tm._make_multipolygon_2_1_w_hole()
g2 = d.Glacier_entity(glac_obj_tuple)

g1.sgeom = p_v
g2.sgeom = p_i

L = [g1, g2]

valid_pieces = []
for e in L:
    print("Geom type", e.sgeom.geom_type)
    v = e.make_valid()
    if type(v) is d.Glacier_entity:
        valid_pieces.append(v)
    else:
        valid_pieces.extend(v)

    print("       e: ", e)
    print("Post-val: ", e.make_valid())

filtered = [e for e in valid_pieces if len(e.sgeom.exterior.coords) > 3]

print("filtered:  ", filtered)

for e in filtered:
    print(f"Post-filter: type of {e} is", e.sgeom.geom_type)

