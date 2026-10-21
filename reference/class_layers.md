# One layer per class

Splits the classified raster of a `"landform"` object into one
presence/absence layer per class, named after the classes. This replaces
the list of per-class rasters returned by landform \<= 0.2.

## Usage

``` r
class_layers(x, absent = 0)
```

## Arguments

- x:

  An object of class `"landform"`.

- absent:

  Value given to cells not belonging to the class: `0` (default) or
  `NA`.

## Value

A multi-layer `SpatRaster` with one layer for each class present in the
classification (1 = cell belongs to the class); cells left unclassified
are `NA` in every layer.

## Examples

``` r
dem <- malta_dtm()
sp <- landform(dem, scale = 9, plot = FALSE)
layers <- class_layers(sp)
names(layers)
#> [1] "Valley"       "Lower Slope"  "Flat Slope"   "Middle Slope" "Upper Slope" 
#> [6] "Ridge"       
terra::plot(layers[["Ridge"]], main = "Ridge")

```
