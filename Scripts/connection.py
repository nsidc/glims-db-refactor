import os

ropw = os.environ.get('GLIMS_DB_RO', None)
rwpw = os.environ.get('GLIMS_DB_RW', None)

CONN = ('host=db.production.glims.apps.int.nsidc.org'
        ' dbname=glims user=glims_ro password={}'.format(ropw))

# Old version of PostgreSQL/PostGIS
CONN_OLDV2 = ('host=db.development.glims.apps.int.nsidc.org'
        ' dbname=glims_v2 user=glims_rw password={}'.format(rwpw))

# glims_v2 on production
CONN_NEWV2 = ('host=db.production.glims.apps.int.nsidc.org'
        ' dbname=glims_v2 user=glims_rw password={}'.format(rwpw))

SCHEMA = 'data'
