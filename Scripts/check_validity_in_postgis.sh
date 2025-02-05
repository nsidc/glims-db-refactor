#!/bin/bash

psql -h db.development.glims.apps.int.nsidc.org -U braup glims_v2 -c 'SELECT ST_IsValid(entity_geom), ST_IsValidReason(entity_geom) from glacier_entities' | sort | uniq -c
