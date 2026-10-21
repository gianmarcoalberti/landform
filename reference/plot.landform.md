# Plot a landform classification

Plots the map of the classes, a bar plot of the area of each class, or
the standardised TPI surface(s), from an object returned by
[`landform`](landform.md).

## Usage

``` r
# S3 method for class 'landform'
plot(
  x,
  what = c("classes", "area", "tpi"),
  hillshade = FALSE,
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

- hillshade:

  Logical. For `what = "classes"`, draw the classes semi-transparently
  over a hillshade of the elevation raster. Default `FALSE`.

- alpha:

  Opacity of the classes relative to the hillshade drawn over them (0 to
  1; the hillshade is drawn with opacity `1 - alpha`). Default `0.6`.

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

## Examples

``` r
dem <- malta_dtm()
sp <- landform(dem, scale = 9, plot = FALSE)
plot(sp)
plot(sp, hillshade = TRUE)

plot(sp, what = "area")

plot(sp, what = "tpi")

```
