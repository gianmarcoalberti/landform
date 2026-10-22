# Plot a landform classification

Plots the map of the classes, a bar plot of the area of each class, or
the standardised TPI surface(s), from an object returned by
[`landform`](https://gianmarcoalberti.github.io/landform/reference/landform.md).

## Usage

``` r
# S3 method for class 'landform'
plot(
  x,
  what = c("classes", "area", "tpi"),
  shade = c("none", "slope", "hill"),
  alpha = 0.6,
  leg.pos = NULL,
  leg.cex = 0.8,
  main = NULL,
  ...
)
```

## Arguments

- x:

  An object of class `"landform"`.

- what:

  What to plot: `"classes"` (default), `"area"`, or `"tpi"`.

- shade:

  Relief shading drawn underneath the classes or the TPI: `"none"`
  (default), `"slope"` (a slopeshade, that is the slope in grey levels
  from white for flat terrain to black for the steepest slopes), or
  `"hill"` (a hillshade, lit from the north-west at 45 degrees). See
  Details.

- alpha:

  Opacity (0 to 1) of the classes or TPI drawn over the shading. Default
  `0.6`. Ignored when `shade = "none"`.

- leg.pos:

  Legend position for the map (a
  [`legend`](https://rdrr.io/r/graphics/legend.html) keyword); `NULL`
  (default) places it outside the map, to its right.

- leg.cex:

  Magnification of the legend text. Default `0.8`.

- main:

  Plot title; a sensible default is used if `NULL`.

- ...:

  Further arguments passed to
  [`plot`](https://rspatial.github.io/terra/reference/plot.html) (for
  maps) or [`barplot`](https://rdrr.io/r/graphics/barplot.html) (for
  `what = "area"`).

## Value

`x`, invisibly.

## Details

A slopeshade conveys relief without the directional bias of a hillshade:
features facing away from the light are not darkened, and steepness is
shown in the same way whatever the aspect. The grey scale is stretched
between 0 degrees and the 99th percentile of slope, so that a few very
steep cells do not flatten the contrast elsewhere.

## Examples

``` r
dem <- malta_dtm()
sp <- landform(dem, scale = 9, plot = FALSE)
plot(sp)

plot(sp, shade = "slope")

plot(sp, what = "area")

plot(sp, what = "tpi", shade = "slope", alpha = 0.5)

```
