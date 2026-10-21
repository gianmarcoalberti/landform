#' Sample digital terrain model of Malta
#'
#' Returns a digital terrain model (DTM) of the island of Malta (Maltese
#' archipelago), bundled with the package as a GeoTIFF file and read on demand. The
#' sea is coded as \code{NA}, which makes the dataset suitable for showing how
#' \code{\link{landform}} handles irregular study areas.
#'
#' @format A single-layer \code{SpatRaster}: 535 rows by 580 columns, 40 m
#'   resolution, elevation in metres, coordinate reference system ED50 / UTM
#'   zone 33N (EPSG:23033).
#'
#' @source The same DTM is distributed with the \pkg{movecost} package by the
#'   same author (\code{movecost::mc_malta_dtm()}).
#'
#' @return A \code{SpatRaster}.
#'
#' @examples
#' dem <- malta_dtm()
#' terra::plot(dem, main = "Malta DTM (m)")
#'
#' @export
malta_dtm <- function() {
  f <- system.file("extdata", "malta_dtm_40.tif", package = "landform")
  if (f == "") {
    stop("malta_dtm_40.tif not found; reinstall the package.", call. = FALSE)
  }
  r <- terra::rast(f)
  names(r) <- "elevation"
  r
}
