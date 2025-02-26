from shapely.wkt import loads
from shapely.validation import make_valid

class Glacier_entity(object):
    def __init__(self, tup):
        '''
        Input:  a 4-tuple:  (gid, aid, line_type, poly_EWKT)
        '''
        self.gid = tup[0]
        self.aid = tup[1]
        self.line_type = tup[2]
        self.srid = tup[3].split(';')[0]  # e.g. 'SRID=4326'
        #self.poly_ewkt = tup[3]
        self.sgeom = loads(tup[3].split(';')[1])

        self.from_multi = False
        self.old_gid = None
        self.old_aid = None
        self.from_aid = None

    def as_tuple(self):
        rtn = (self.gid, self.aid, self.line_type, self.as_ewkt_with_srid())
        return rtn

    def as_ewkt_with_srid(self):
        ''' Ouput as something like

        'SRID=4326;POLYGON ((0 0, 0 2, 2 2, 2 0, 0 0))'

        '''
        if self.sgeom is not None:
            rtn = ';'.join([self.srid, self.sgeom.wkt])
        else:
            rtn = 'None_geom'
        return rtn

    def contains(self, o):
        ''' input:  another Glacier_entity object '''
        return self.sgeom.contains(o.sgeom)

    def touches(self, o):
        ''' input:  another Glacier_entity object '''
        return self.sgeom.touches(o.sgeom)

    def intersects(self, o):
        return self.sgeom.intersects(o.sgeom)

    def max_overlap_frac(self, o):
        self_area = self.sgeom.area
        o_area = o.sgeom.area
        intersect_area = self.sgeom.intersection(o.sgeom).area
        return max(intersect_area/self_area, intersect_area/o_area)

    def make_valid(self):
        ''' Use shapely's make_valid to make valid geometries, but it creates
            multi-polygons, so return a list of objects with valid geometries.
        '''
        self.sgeom = make_valid(self.sgeom)
        if self.sgeom.geom_type.lower().startswith('multi'):
            return list(self)  # Calls __iter__ below
        else:
            return self

    def __repr__(self):
        return f"({self.gid}, {self.aid}, {self.line_type})"

    def __iter__(self):
        # This allows a call like: list(gl_obj) where the sgeom is
        # a multipolygon that gets expanded into multiple parts
        return (Glacier_entity((self.gid, self.aid, self.line_type, f'SRID=4326;{e.wkt}')) for e in list(self.sgeom.geoms))
