#!/bin/bash

# This generates the row counts of the tables in the old database to compare
# with the counts from the mv_glims_to_new_db.py script.  That output is
# commented below and in the file Output_tests/transfer_table_counts.txt.

for T in reference_document         \
    dominant_mass_source_valids     \
    form_valids     \
    frontal_characteristics_valids      \
    lon_char_valids     \
    primary_classification_valids       \
    tongue_activity_valids      \
    glims_table_fields      \
    gtng_order1regions      \
    gtng_order2regions      \
    glims_field_dictionary      \
    instrument      \
    country     \
    status_def      \
    map_metadata        \
    image       \
    people      \
    regional_centers        \
    rc_people       \
    submission_info     \
    submission_analyst      \
    glacier_static      \
    glacier_reference       \
    glacier_dynamic     \
    glacier_image_info     \
    area_histogram      \
    area_histogram_data     \
    glacier_polygons        \
    glacier_countries       \
    glacier_map_info ; do

        psql -h db.production.glims.apps.int.nsidc.org -U braup -c "select count(*) from $T;" glims |   \
            grep -v row |   \
            grep -v count | \
            grep -Po '\d+' |    \
            xargs echo -n

        echo " $T"

done


#      82 data.reference_document
#       4 data.dominant_mass_source_valids
#      10 data.form_valids
#      13 data.frontal_characteristics_valids
#       6 data.lon_char_valids
#      11 data.primary_classification_valids
#      10 data.tongue_activity_valids
#     407 data.glims_table_fields
#      21 data.gtng_order1regions
#      93 data.gtng_order2regions
#     393 data.glims_field_dictionary
#      75 data.instrument
#     251 data.country
#       6 data.status_def
#     558 data.map_metadata
#    5279 data.image
#     369 data.people
#     127 data.regional_centers
#     387 data.rc_people
#     835 data.submission_info
#    3363 data.submission_analyst
#  434241 data.glacier_static
#   76638 data.glacier_reference
# 1075399 data.glacier_dynamic
# 61775879 data.glacier_image_info
#  179073 data.area_histogram
# 22501329 data.area_histogram_data
#       6 data.glacier_entities
#  425573 data.glacier_countries
#  541026 data.glacier_map_info
