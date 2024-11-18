from shapely.wkt import loads

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

    def as_tuple(self):
        rtn = (self.gid, self.aid, self.line_type, self.as_ewkt_with_srid())
        return rtn

    def as_ewkt_with_srid(self):
        ''' Ouput as something like

        'SRID=4326;POLYGON ((0 0, 0 2, 2 2, 2 0, 0 0))'

        '''
        rtn = ';'.join([self.srid, self.sgeom.wkt])
        return rtn

    def contains(self, o):
        ''' input:  another Glacier_entity object '''
        return self.sgeom.contains(o.sgeom)

    def touches(self, o):
        ''' input:  another Glacier_entity object '''
        return self.sgeom.touches(o.sgeom)

    def __repr__(self):
        return f"({self.gid}, {self.aid}, {self.line_type})"

    def __iter__(self):
        # This allows a call like: list(gl_obj) where the sgeom is
        # a multipolygon that gets expanded into multiple parts
        return (Glacier_entity((self.gid, self.aid, self.line_type, f'SRID=4326;{e.wkt}')) for e in list(self.sgeom))
