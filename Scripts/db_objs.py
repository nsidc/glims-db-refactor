from shapely.wkt import loads

class Glacier_entity(object):
    def __init__(self, tup):
        '''
        Input:  a 4-tuple:  (gid, aid, line_type, poly_EWKT)
        '''
        self.gid = tup[0]
        self.aid = tup[1]
        self.line_type = tup[2]
        self.poly_ewkt = tup[3]

    def as_tuple(self):
        rtn = (self.gid, self.aid, self.line_type, self.poly_ewkt)
        return rtn

    def get_srid(self):
        return self.poly_ewkt.split(';')[0]  # e.g. 'SRID=4326'

    def get_poly_nosrid(self):
        return self.poly_ewkt.split(';')[1]

    def get_poly_shapely(self):
        self.poly_shapely = loads(self.get_poly_nosrid())

    def set_poly_from_shapely(self, p):
        ''' Input:  shapely polygon '''
        self.poly_ewkt = ';'.join([self.get_srid(), p.to_wkt()])

    def contains(self, o):
        ''' input:  another Glacier_entity object '''
        return self.get_poly_shapely().contains(o.get_poly_shapely())
