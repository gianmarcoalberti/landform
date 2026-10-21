## Submission summary

This is an update (0.3.0) of the existing CRAN package 'landform'.

It fixes the error reported by Robert J. Hijmans when the package is checked
against the development version of 'terra': the argument 'pad' (which belongs
to raster::focal()) is no longer passed to terra::focal().

The update also revises the package substantially (see NEWS.md): the TPI
standardisation now follows the original method by default (the previous one
remains available as an option), neighbourhoods can be circular or annular
and sized in map units, results are returned as an object with print, summary
and plot methods, and a vignette, tests and a small sample DTM (GeoTIFF, about
0.6 MB, in inst/extdata) have been added.

## Test environments

* local: macOS, R 4.2.2
* win-builder: R-devel, R-release, R-oldrelease

## R CMD check results

0 errors | 0 warnings | 0 notes

## Reverse dependencies

There are no reverse dependencies.
