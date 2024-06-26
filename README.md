<p align="center">
  <img alt="NSIDC logo" src="https://nsidc.org/themes/custom/nsidc/logo.svg" width="150" />
</p>

# glims-db-refactor : Simplifying the GLIMS Glacier Database implementation

The original design of the GLIMS Glacier Database included many features that
have not been used in practice.  The data model is also not well aligned
with actual use of GLIMS data.  For example, nunataks (rock outcrops or
mountains that are internal to a glacier) are currently represented as
separate polygons, linked to the glacier through the GLIMS glacier ID, and
attributed as "intrnl_rock" (rather than "glac_bound", as are glacier
boundary polygons).  By contrast, the Randolph Glacier Inventory (RGI),
which is derived from GLIMS, uses "holes" (interior rings) in the glacier
boundary polygons to represent nunataks.  This refactoring will simplify
the design of the GLIMS Glacier Database and better align it with actual
modern use.

The main changes to the GLIMS Glacier Database will be:

    * Nunataks will be represented as holes in the boundary polygon;
    * Formerly 3-D polygons ("POLYGON Z") will be 2-D ("POLYGON")

# Testing

At least one of the unit tests requires a connection to the database, so
the test suite should be run as, for example,

    GLIMS_DB_RO=<pw1> GLIMS_DB_RW=<pw2> nosetests

## Level of Support

If you discover any problems or bugs, please submit an Issue. If you would
like to contribute to this repository, you may fork the repository and
submit a pull request.  We will do our best to incorporate your ideas.  You
may also contact people on the [GLIMS Core
Team](https://www.glims.org/About/glims_core_team.html).


## Credit

This work is supported by the National Snow and Ice Data Center with
funding from the NASA NSIDC DAAC.
