<p align="center">
  <img alt="NSIDC logo" src="https://nsidc.org/themes/custom/nsidc/logo.svg" width="150" />
</p>

# glims-db-refactor : Simplifying the GLIMS Glacier Database implementation

The original design of the GLIMS Glacier Database included many features that
have not been used in practice.  The data model is also not well aligned
with actual use of GLIMS data.  For example, nunataks (rock outcrops or
mountains that are internal to a glacier) are currently represented as
separate polygons, linked to the glacier through the GLIMS glacier ID, and
attributed as `intrnl_rock` (rather than `glac_bound`, as are glacier
boundary polygons).  By contrast, the Randolph Glacier Inventory (RGI),
which is derived from GLIMS, uses "holes" (interior rings) in the glacier
boundary polygons to represent nunataks.  This refactoring will simplify
the design of the GLIMS Glacier Database and better align it with actual
modern use.

The main changes to the GLIMS Glacier Database will be:

* Nunataks will be represented as holes in the boundary polygon (requested
  by numerous users, including the maintainers of the RGI);
* Formerly 3-D polygons ("POLYGON Z") will be 2-D ("POLYGON") (requested
  occasionally by users);
* Many topological errors (self-intersections) in polygons will be fixed,
  hour-glass type self-intersections in particular. Some errors in
  non-multi-polygons, e.g. two parts of a polygon meeting at a point but
  not intersecting, are not seen as errors in some software, and will pass
  through unchanged.  Fixing the self-intersections is an item that has
  been raised in a DAAC User Working Group meeting.
* Multi-polygons, GeometryCollection objects, and glacier\_id-sharing
  multiple polygons will be split out into single polygons, with the
  correct IDs, or new IDs, assigned as necessary (RGI request).

These changes will necessitate updating the inputs (ingest workflow and
code) and outputs (download and query services) of the GLIMS Glacier
Database.  But the new system will be easier to maintain and modify.

# Environment

This work is being done on Bruce Raup's desktop machine, nsidc-braup, in
a conda virtual environment called `glims_ingest`.  A listing of the
environment components is in the `package_list.txt` file.  (It could also
be done on a virtual machine.)

# Testing

## Unit Tests

At least one of the unit tests requires a connection to the database, so
the test suite should be run as, for example,

    GLIMS_DB_RO=<pw1> GLIMS_DB_RW=<pw2> nosetests

or

    GLIMS_DB_RO=<pw1> GLIMS_DB_RW=<pw2> pytest

## Evaluation of processed data

In addition to producing SQL (or, optionally, writing directly to the new
database), the "move" script (`Scripts/mv_glims_to_new_db.py`) creates
a shapefile of all the geometries that would be put into the SQL or
database.  This shapefile includes some useful attributes:

* `gid`   -- the GLIMS glacier ID (should be the same for all entities
  related to one glacier);
* `aid`   -- the GLIMS analysis ID (unique for each outline);
* `from_aid` -- if the gid came from matching another entity, the aid of that
  entity;
* `from_multi` -- boolean, True if the entity was created from splitting
  a multi-polygon, GeometryCollection, etc.
* `line_type` -- type of entity; can be glac_bound, debris_cov, pro_lake,
  etc.;
* `old_gid` -- the glacier ID of the multi-polygon from which this entity
  came;
* `old_aid` -- the glacier ID of the multi-polygon from which this entity
  came.

QGIS can be used to color entities according to `line_type` or `from_multi`
to ensure the script is doing the right thing.

When new data are put in the new database, the `new_db` branch of the
`glims-web`, `glims-services`, and `glims-geoserver` projects can be used
to do a full end-to-end test of the new system.

## Level of Support

If you discover any problems or bugs, please submit an Issue. If you would
like to contribute to this repository, you may fork the repository and
submit a pull request.  We will do our best to incorporate your ideas.  You
may also contact people on the [GLIMS Core
Team](https://www.glims.org/About/glims_core_team.html).


## Credit

This work is supported by the National Snow and Ice Data Center with
funding from the NASA NSIDC DAAC.
