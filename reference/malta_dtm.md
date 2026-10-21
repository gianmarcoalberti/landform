# Sample digital terrain model of Malta

Returns a digital terrain model (DTM) of the island of Malta (Maltese
archipelago), bundled with the package as a GeoTIFF file and read on
demand. The sea is coded as `NA`, which makes the dataset suitable for
showing how [`landform`](landform.md) handles irregular study areas.

## Usage

``` r
malta_dtm()
```

## Format

A single-layer `SpatRaster`: 535 rows by 580 columns, 40 m resolution,
elevation in metres, coordinate reference system ED50 / UTM zone 33N
(EPSG:23033).

## Source

The same DTM is distributed with the movecost package by the same author
(`movecost::mc_malta_dtm()`).

## Value

A `SpatRaster`.

## Examples

``` r
dem <- malta_dtm()
terra::plot(dem, main = "Malta DTM (m)")

```
