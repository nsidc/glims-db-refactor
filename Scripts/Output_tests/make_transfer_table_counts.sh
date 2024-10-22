#!/bin/bash

# This operates on the output of ../mv_glims_to_new_db.py to count the number
# of INSERT statements for each table.

awk '{print $3}' < out.sql | uniq -c > transfer_table_counts.txt
