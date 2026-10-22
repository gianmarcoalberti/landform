# Changelog

## landform 0.3.0

A thorough revision of the package. Please read the first two points:
with the default settings, results differ from those of earlier
versions.

### Changes that affect results

- The TPI is now standardised, by default, over the whole raster
  (z-scores of the TPI), as in Weiss (2001) and Jenness (2006), to which
  the classification thresholds refer (`std = "global"`). Earlier
  versions divided the TPI of each cell by the standard deviation of
  elevation in its own neighbourhood; this is still available with
  `std = "local"`. In nearly flat areas the local standardisation turns
  small irregularities of the DTM into large standardised values, so
  that plains may be classified as a mosaic of valleys and ridges; on
  perfectly flat areas it is undefined.
- By default the focal cell is now excluded from the neighbourhood mean
  (`centre = FALSE`), in line with the definition of TPI as the
  difference between a cell and its surroundings. With global
  standardisation this has no effect away from the edges.
- Results of version 0.2 are reproduced exactly with
  `std = "local", centre = TRUE`, apart from the two fixes below.
- Fixed: cells with a standardised TPI exactly equal to 0.5 fell into no
  class (and were coded 0); they are now classified as Upper Slope, so
  that every cell gets exactly one class.
- Fixed: cells on the outer rim of the raster (and next to `NA` cells),
  where slope cannot be computed, were left unclassified only when their
  TPI was close to zero, which biased the class frequencies. They are
  now consistently left unclassified.
- Class areas are now computed with
  [`terra::cellSize()`](https://rspatial.github.io/terra/reference/cellSize.html),
  and are therefore correct also for longitude/latitude rasters.

### Fixes

- Removed the argument `pad` from the internal calls to
  [`terra::focal()`](https://rspatial.github.io/terra/reference/focal.html);
  it belongs to `raster::focal()` and is rejected by recent versions of
  terra (reported by Robert J. Hijmans).
- Fixed the map colours not matching the legend when some classes were
  absent.
- An invalid `class.type` now gives an error instead of returning
  `NULL`.

### New features

- Neighbourhoods can be square, circular or annular (`shape`, `inner`),
  and sized in cells or in map units (`units`; metres for
  longitude/latitude).
- Thresholds can be changed: `tpi.thr`, `lf.thr`, `slope.thr`.
- New function
  [`tpi()`](https://gianmarcoalberti.github.io/landform/reference/tpi.md),
  returning the raw or standardised TPI surface.
- New function
  [`class_layers()`](https://gianmarcoalberti.github.io/landform/reference/class_layers.md),
  returning one presence/absence layer per class.
- New sample dataset,
  [`malta_dtm()`](https://gianmarcoalberti.github.io/landform/reference/malta_dtm.md).
- Input checks with informative error messages (window sizes, `ln > sn`,
  single-layer input, thresholds, colours).

### Changes to the returned value

- [`landform()`](https://gianmarcoalberti.github.io/landform/reference/landform.md)
  now returns an object of class `"landform"` with
  [`print()`](https://rdrr.io/r/base/print.html),
  [`summary()`](https://rspatial.github.io/terra/reference/summary.html)
  and [`plot()`](https://rspatial.github.io/terra/reference/plot.html)
  methods, holding the classes as a single categorical `SpatRaster`
  (`classes`, with class names and colours), the TPI and slope layers,
  the descriptive statistics (always computed; now also with mean
  elevation and slope per class), the input DTM and the settings. The
  list of per-class rasters returned by earlier versions (`result$all`,
  `result$Valley`, …) is replaced by `result$classes` and
  `class_layers(result)`; `result[["Descriptive Statistics"]]` is
  replaced by `result$stats` (or `summary(result)`).
- Class names now follow Jenness (2006) (e.g. “Midslope Ridges, Small
  Hills in Plains” instead of “Midslopes Ridges-Small Hills in Plains”).

### Plots

- New colour palettes: an ordinal blue-to-brown palette for the Slope
  Position Classification, and hues grouped by landform family for the
  Landform Classification (both replace
  [`rainbow()`](https://rdrr.io/r/grDevices/palettes.html)). Custom
  colours via `col`.
- The legend is placed outside the map by default, so that no data are
  hidden (`leg.pos` still accepts the usual keywords).
- Optional relief shading underneath the classes or the TPI: a
  slopeshade (`shade = "slope"`, slope in grey levels from white for
  flat terrain to black for the steepest slopes) or a hillshade
  (`shade = "hill"`), with the overlying layer drawn semi-transparently
  (`alpha`).
- The bar plot of class areas is horizontal and labelled with class
  names.
- `plot(x, what = "tpi")` maps the standardised TPI surface(s).
- `plot = FALSE` suppresses plotting.

### Documentation

- New vignette, also available on the package website.

## landform 0.2

CRAN release: 2023-10-04

- minor fixes and optimisations;
- spatialEco removed from Suggests.

## landform 0.1

CRAN release: 2023-08-28

- first release to CRAN.
