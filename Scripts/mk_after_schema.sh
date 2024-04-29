#!/bin/bash

# Create an SQL file that represents a start at the new schema that will replace the old one.

pg_dump --schema-only --create                      \
        -h db.production.glims.apps.int.nsidc.org   \
        --table='glacier_static'                    \
        --table='glacier_dynamic'                   \
        --table='glacier_polygons'                  \
        --table='area_histogram'                    \
        --table='area_histogram_data'               \
        --table='country'                           \
        --table='dominant_mass_source_valids'       \
        --table='extinct_glaciers_view'             \
        --table='form_valids'                       \
        --table='frontal_characteristics_valids'    \
        --table='glacier_countries'                 \
        --table='glacier_image_info'                \
        --table='people'                            \
        --table='regional_centers'                  \
        --table='submission_info'                   \
        --table='submission_rc_info'                \
        --table='glacier_entities'                  \
        --table='glacier_lines_disp'                \
        --table='glacier_map_info'                  \
        --table='submission_analyst'                \
        --table='submission_anlst_names'            \
        --table='submission_submitter'              \
        --table='glacier_query_full'                \
        --table='glacier_query_no_people'           \
        --table='glacier_reference'                 \
        --table='glims_field_dictionary'            \
        --table='glims_table_fields'                \
        --table='gtng_order1regions'                \
        --table='gtng_order2regions'                \
        --table='image'                             \
        --table='instrument'                        \
        --table='image_info_view'                   \
        --table='lon_char_valids'                   \
        --table='map_metadata'                      \
        --table='primary_classification_valids'     \
        --table='rc_people'                         \
        --table='rc_people_nocoords'                \
        --table='rc_people_view'                    \
        --table='reference_document'                \
        --table='status_def'                        \
        --table='tongue_activity_valids'            \
        -U braup glims                              |
        sed 's/glacier_polygons/glacier_entities/g' |
        sed 's/glacier_polys/entity_geom/g'         |
        sed 's/line_type text/line_type smallint/'  |
        sed '/enforce_dims_entity_geom/d'           |
        sed '/enforce_geotype_entity_geom/d'        |
        sed 's/DATABASE glims/DATABASE glims_v2/'   |
        sed 's/Name: glims/Name: glims_v2/'         |
        sed 's/connect glims/connect glims_v2/'    \
        > new_schema.sql
