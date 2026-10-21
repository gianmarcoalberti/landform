# landform

Topographic Position Index (TPI) based landform classification for R.

`landform` classifies a digital terrain model into slope-position classes
(valley, lower slope, flat, middle slope, upper slope, ridge) or into ten
landform classes (from canyons to mountain tops), following Weiss (2001) and
Jenness (2006). The TPI can be computed over square, circular or annular
neighbourhoods, sized in cells or in map units, and standardised over the whole
grid (as in the original method) or locally.

## Installation

```r
install.packages("landform")
```

## Example

```r
library(landform)

dem <- malta_dtm()

# six-class Slope Position Classification, 9 x 9 cell window
sp <- landform(dem, scale = 9)
sp                  # class areas and percentages
plot(sp, hillshade = TRUE)

# ten-class Landform Classification, circular neighbourhoods of 200 m and 1 km
lf <- landform(dem, class.type = "landform.classification",
               sn = 200, ln = 1000, units = "map", shape = "circle")
plot(lf, what = "area")
```

See the vignette, `vignette("landform")`, for a full walk-through.

## References

Jenness, J. (2006). Topographic Position Index (tpi_jen.avx) extension for
ArcView 3.x, v. 1.2. Jenness Enterprises.

Weiss, A. (2001). Topographic Position and Landforms Analysis. Poster
presentation, ESRI User Conference, San Diego, CA.
