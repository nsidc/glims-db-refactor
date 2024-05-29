import os

pw = os.environ.get('GLIMS_DB_PW', None)

CONN = ('host=db.production.glims.apps.int.nsidc.org'
        ' dbname=glims user=glims_ro password={}'.format(pw))

CONN_V2 = ('host=db.development.glims.apps.int.nsidc.org'
        ' dbname=glims_v2 user=glims_ro password={}'.format(pw))
