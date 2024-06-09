#!/bin/bash

#GLIMS_DB_RO=hyouga GLIMS_DB_RW=kakeru ./mv_glims_to_new_db.py -b ' -25,63,-13,67' --transaction --write_to_db > iceland.sql
GLIMS_DB_RO=hyouga GLIMS_DB_RW=kakeru ./mv_glims_to_new_db.py -b ' -25,63,-13,67' --write_to_db > iceland.sql
