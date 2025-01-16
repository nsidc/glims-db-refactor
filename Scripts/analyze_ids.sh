#!/bin/bash

# The SQL resulting from the script mv_glims_to_new_db.py is in the file
# iceland_exp_rocks_id_tracking.sql.  This script analyzes the glacier IDs to
# be inserted into glacier_static in that file, to make sure they are unique.

# Extract all the INSERT statements for the glacier_static table
grep 'INSERT INTO data.glacier_static' iceland_exp_rocks_id_tracking.sql > glstatic_inserts.sql

# Extract the actual IDs to be inserted into the glacier_static.glacier_id
# field, which is done in one of two ways:  From the bulk copy of the table
# ("VALUES ('G..."), and from inserting new records for split-up multi-polygons
# ("SELECT 'G...").  Two extra characters are grabbed because there are many
# retired IDs in the old GLIMS database, which end in _R.

grep -o                                 \
        -e "SELECT 'G......E........'"    \
        -e "VALUES ('G......E........"    \
        glstatic_inserts.sql > gids_plus_cruft.txt

# Get rid of the retired IDs and then pull out the remaining IDs, getting rid
# of the cruft.

grep -v _R gids_plus_cruft.txt | grep -o 'G......E......' > gids_only.txt

# The remaining list of IDs to be inserted *should* be unique.  Check that.

echo -n "Number of duplicated IDs going into glacier_static:  "
sort gids_only.txt | uniq -dc | wc -l

#read -n 1 -s -r -p "Press any key to see the list."
#sort gids_only.txt | uniq -dc | less
