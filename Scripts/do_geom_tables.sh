#!/bin/bash

GLIMS_DB_RO=hyouga GLIMS_DB_RW=kakeru ./mv_glims_to_new_db.py -b ' -25,63,-13,67' --from_Glacier_entities --write_to_db
