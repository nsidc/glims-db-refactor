# General steps

## Changes (table names are in italic font):

1.  Edit tables:

    1.  Rename *glacier\_polygons* to *glac\_entities* (multi-format
        geometries; i.e. polylines, polygons, etc are in geometry field).

    2.  Move uncertainty fields from *segment* to *glac\_entities.*

    3.  Retain *glacier\_dynamic* and *glacier\_static* tables as they are.

    4.  Revisit the issue of multiple (local language, English
        spellings, etc.) glacier names?

2.  Remove tables (i.e. don’t duplicate):

    1.  segments

    2.  glacier\_line

    3.  ancillary\_data

    4.  glacier\_ancillary\_info

    5.  tiepoint\_region

    6.  glims\_aster\_footprints

    7.  aster\_footprints

    8.  starpolys

3.  Topology changes:

    1.  Merge all “intrnl\_rock” polygons with their glac\_bound
        polygons and store in new glac\_outlines table

        1.  How to do this? Download service can convert intrnl\_rock
            polygons to holes, so need to adapt this code to

            1.  Download data (region by region?)

            2.  Convert to polygons with holes

            3.  Ingest directly, or write SQL for later ingest

        2.  Note that the download service doesn’t provide **all** the
            attributes that are stored in the database.

    2.  Convert all multi-part polygons to single ones, assigning new
        GLIMS Glacier IDs, and analysis IDs, to the new parts.

## Simpler Data Transfer Format

We need one data format and submission procedure that all contributors
can adhere to.  A follow-on project will be to define a simpler, and stricter,
data transfer format.

## Considerations

1.  One submission contains data for one timestamp only, or one season.
    Each glacier should have only one glac\_bound outline.

    1.  Either all outlines in glaciers.shp should have the same as-of
        date, or there should be at least one “image\_idN” column in
        the glaciers.shp file, and the images.shp file should be a
        list of images and have, in addition to the image IDs, the
        corresponding dates. Note that while different dates are
        allowed, they shouldn’t be too different from each other (e.g.
        from one season).

2.  No multi-polygons are allowed.

3.  The existing session.shp and metadata.txt files will be replaced by
    an online form that will get the session metadata from the
    submitter. Note that it would be good to have user accounts so that
    we can pre-populate many of the known fields.

    1.  Names of analysts

    2.  Description of analysis method(s)

    3.  Analysis date

    4.  We should have a file upload option. Format could be text file
        with key=value format.

4.  The existing “segments.shp” file will no longer be needed.

## Potential Special Cases To Plan For

1.  Outlines have spread of as-of dates that are not precisely known.
2.  Outlines are from a mix of images and maps.

## Ingest Software

The ingest software will have to be modified -- mostly simplified -- to
write to the new (smaller) set of tables. Items to keep in mind:

1.  Use only “line\_type”. Replace all instances of “category” with
    “line\_type”.
