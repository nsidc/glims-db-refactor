#!/bin/bash

# Create an SQL file that represents the existing schema that will be replaced.

pg_dump --schema-only --create -h db.production.glims.apps.int.nsidc.org -U braup glims > before_schema.sql
