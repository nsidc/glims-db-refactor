#!/bin/bash

# The SQL resulting from the script mv_glims_to_new_db.py is in the file
# iceland_exp_rocks_id_tracking.sql.  This script analyzes the glacier IDs to
# be inserted into glacier_static in that file, to make sure they are unique.

if [ "$1" = "" ] ; then
    echo "Usage:  $0 <sql_filename>"
    exit 1
fi

infile=$1
inserts='glstatic_inserts.sql'
gid_plus_file='gids_plus_cruft.txt'
gid_file='gids_only.txt'

# Extract all the INSERT statements for the glacier_static table
echo "Extracting glacier_static INSERT statements from $infile ..."
grep 'INSERT INTO data.glacier_static' $infile > $inserts

# Extract the actual IDs to be inserted into the glacier_static.glacier_id
# field, which is done in one of two ways:  From the bulk copy of the table
# ("VALUES ('G..."), and from inserting new records for split-up multi-polygons
# ("SELECT 'G...").  Two extra characters are grabbed because there are many
# retired IDs in the old GLIMS database, which end in _R.

echo "Extracting glacier IDs ..."
grep -o                                 \
        -e "SELECT 'G......E........'"    \
        -e "VALUES ('G......E........"    \
        $inserts > $gid_plus_file

# Get rid of the retired IDs and then pull out the remaining IDs, getting rid
# of the cruft.

grep -v _R $gid_plus_file | grep -o 'G......E......' > $gid_file

# The remaining list of IDs to be inserted *should* be unique.  Check that.

echo -n "Number of duplicated IDs going into glacier_static:  "
sort $gid_file | uniq -dc | wc -l

# Clean up temp files
rm $inserts $gid_plus_file $gid_file
