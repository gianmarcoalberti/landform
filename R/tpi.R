#' Topographic Position Index
#'
#' Calculates the Topographic Position Index (TPI), that is the difference
#' between the elevation of each cell and the mean elevation of its
#' neighbourhood (Guisan et al. 1999; Weiss 2001), optionally standardised.
#' This is the quantity on which \code{\link{landform}} bases its
#' classifications; it is exported so that the TPI surfaces can be inspected,
#' mapped, or used in other analyses.
#'
#' @param x A single-layer \code{SpatRaster} (or a \code{RasterLayer}, which is
#'   converted internally) representing elevation.
#' @param scale Size of the neighbourhood. If \code{units = "cells"} (default),
#'   the width of the moving window in cells (an odd integer >= 3; e.g.
#'   \code{3} gives a 3 x 3 window). If \code{units = "map"}, the radius of the
#'   neighbourhood (or the half-width of the window, for \code{shape =
#'   "square"}) in map units; for longitude/latitude rasters, map units are
#'   metres.
#' @param units Either \code{"cells"} (default) or \code{"map"}; see
#'   \code{scale}.
#' @param shape Shape of the neighbourhood: \code{"square"} (default),
#'   \code{"circle"}, or \code{"annulus"} (a ring; requires \code{inner}).
#' @param inner Inner radius of the annulus, in the same units as \code{scale}
#'   (for \code{units = "cells"}, a radius in cells). Ignored unless
#'   \code{shape = "annulus"}.
#' @param centre Logical. Should the focal cell be included when computing the
#'   neighbourhood mean (and standard deviation)? Default \code{FALSE}, in line
#'   with the definition of TPI as the difference between a cell and its
#'   surroundings. See Details.
#' @param std Standardisation: \code{"global"} (default), \code{"local"}, or
#'   \code{"none"}. See Details.
#'
#' @details
#' \strong{Standardisation}. With \code{std = "global"} the TPI is converted to
#' z-scores using the mean and standard deviation of the TPI over the whole
#' raster, so that values express the number of standard deviations from the
#' grid mean. This is the standardisation used by Weiss (2001) and in Jenness's
#' TPI extension (Jenness 2006), to which the classification thresholds in
#' \code{\link{landform}} refer.\cr
#' With \code{std = "local"} the TPI of each cell is divided by the standard
#' deviation of elevation within its own neighbourhood. This is the
#' "deviation from mean elevation" (DEV) of Wilson and Gallant (2000), which
#' De Reu et al. (2013) found preferable in landscapes whose relief varies
#' strongly from place to place. Be aware that, in nearly flat areas, the local
#' standard deviation is very small, so that minimal elevation noise is
#' magnified into large standardised values; on perfectly flat areas the
#' local standardisation is undefined (\code{NA}). This was the (only)
#' standardisation used by \pkg{landform} up to version 0.2.\cr
#' With \code{std = "none"} the raw TPI (in elevation units) is returned.
#'
#' \strong{Focal cell}. With \code{std = "global"}, including or excluding
#' the focal cell rescales every TPI value by the same constant (n-1)/n, which
#' cancels out in the z-scores; the choice therefore only affects cells close
#' to the raster edges or to \code{NA} cells, where the neighbourhood is
#' incomplete. It matters with \code{std = "local"} and \code{std = "none"}.
#'
#' \strong{Edges}. Cells beyond the raster boundary, and \code{NA} cells, are
#' ignored when averaging; TPI near edges is therefore computed from an
#' incomplete neighbourhood.
#'
#' \strong{Map units for longitude/latitude rasters}. Cell sizes in metres
#' are approximated at the latitude of the centre of the raster; over large
#' latitudinal extents the neighbourhood is therefore only approximately
#' constant in ground size.
#'
#' @return A single-layer \code{SpatRaster} with the (standardised) TPI.
#'
#' @references
#' De Reu, J., Bourgeois, J., Bats, M., Zwertvaegher, A., Gelorini, V.,
#' De Smedt, P., Chu, W., Antrop, M., De Maeyer, P., Finke, P., Van Meirvenne,
#' M., Verniers, J. and Crombé, P. (2013). Application of the topographic
#' position index to heterogeneous landscapes. Geomorphology, 186, 39-49.
#'
#' Guisan, A., Weiss, S. B. and Weiss, A. D. (1999). GLM versus CCA spatial
#' modeling of plant species distribution. Plant Ecology, 143, 107-122.
#'
#' Jenness, J. (2006). Topographic Position Index (tpi_jen.avx) extension for
#' ArcView 3.x, v. 1.2. Jenness Enterprises.
#'
#' Weiss, A. (2001). Topographic Position and Landforms Analysis. Poster
#' presentation, ESRI User Conference, San Diego, CA.
#'
#' Wilson, J. P. and Gallant, J. C. (eds) (2000). Terrain Analysis: Principles
#' and Applications. Wiley, New York.
#'
#' @seealso \code{\link{landform}}, \code{\link[terra]{focal}}
#'
#' @examples
#' dem <- malta_dtm()
#'
#' # standardised TPI, 9 x 9 cell window (360 m at 40 m resolution)
#' t9 <- tpi(dem, scale = 9)
#' terra::plot(t9, main = "Standardised TPI (9 x 9 cells)")
#'
#' # raw TPI over a 500 m circular neighbourhood
#' t500 <- tpi(dem, scale = 500, units = "map", shape = "circle", std = "none")
#' terra::plot(t500, main = "TPI (m), 500 m radius")
#'
#' @export
tpi <- function(x, scale = 3, units = c("cells", "map"),
                shape = c("square", "circle", "annulus"), inner = NULL,
                centre = FALSE, std = c("global", "local", "none")) {
  units <- match.arg(units)
  shape <- match.arg(shape)
  std <- match.arg(std)
  x <- .lf_check_raster(x)
  w <- .lf_window(x, scale, units, shape, inner, centre, what = "scale")
  .lf_tpi(x, w, std)$tpi
}

# ---------------------------------------------------------------------------
# Internal helpers
# ---------------------------------------------------------------------------

# Validate the input raster and convert a RasterLayer to a SpatRaster
.lf_check_raster <- function(x) {
  if (inherits(x, "RasterLayer")) x <- terra::rast(x)
  if (!inherits(x, "SpatRaster")) {
    stop("'x' must be a SpatRaster (or a RasterLayer).", call. = FALSE)
  }
  if (terra::nlyr(x) != 1) {
    stop("'x' must have a single layer (elevation); it has ", terra::nlyr(x),
         " layers.", call. = FALSE)
  }
  x
}

# Cell size (x, y) in map units; for lon/lat rasters, metres approximated at
# the latitude of the centre of the raster
.lf_cellsize <- function(x) {
  r <- terra::res(x)
  if (terra::crs(x) != "" && isTRUE(terra::is.lonlat(x))) {
    lat <- mean(as.vector(terra::ext(x))[3:4]) * pi / 180
    r <- c(r[1] * 111320 * cos(lat), r[2] * 110574)
  }
  r
}

# Build the focal weight matrix: 1 for cells in the neighbourhood, NA otherwise
.lf_window <- function(x, size, units, shape, inner, centre, what) {
  if (!is.numeric(size) || length(size) != 1 || !is.finite(size) || size <= 0) {
    stop("'", what, "' must be a single positive number.", call. = FALSE)
  }
  if (units == "cells") {
    if (size < 3 || size %% 2 != 1) {
      stop("With units = \"cells\", '", what, "' must be an odd integer >= 3 ",
           "(the window width in cells); got ", size, ".", call. = FALSE)
    }
    cs <- c(1, 1)
    radius <- (size - 1) / 2
  } else {
    cs <- .lf_cellsize(x)
    radius <- size
  }
  # half-width of the window in cells, along x (columns) and y (rows)
  hx <- floor(radius / cs[1] + 1e-9)
  hy <- floor(radius / cs[2] + 1e-9)
  if (hx < 1 || hy < 1) {
    stop("'", what, "' (", size, ") is smaller than the cell size (",
         paste(signif(cs, 4), collapse = " x "), "); the neighbourhood would ",
         "contain no cells other than the focal one.", call. = FALSE)
  }
  # distance of each cell of the window from the focal cell, in map units
  # (or in cells)
  dx <- outer(rep(1, 2 * hy + 1), (-hx:hx) * cs[1])
  dy <- outer((-hy:hy) * cs[2], rep(1, 2 * hx + 1))
  d <- sqrt(dx^2 + dy^2)
  keep <- switch(shape,
    square = matrix(TRUE, nrow(d), ncol(d)),
    circle = d <= radius + 1e-9,
    annulus = {
      if (is.null(inner) || !is.numeric(inner) || length(inner) != 1 ||
          inner < 0 || inner >= radius) {
        stop("With shape = \"annulus\", 'inner' must be a single number ",
             ">= 0 and smaller than the outer radius.", call. = FALSE)
      }
      d <= radius + 1e-9 & d > inner + 1e-9
    }
  )
  w <- ifelse(keep, 1, NA_real_)
  w[hy + 1, hx + 1] <- if (centre && shape != "annulus") 1 else NA_real_
  if (sum(!is.na(w)) < 2) {
    stop("The neighbourhood defined by '", what, "' contains fewer than two ",
         "cells; increase it.", call. = FALSE)
  }
  w
}

# Raw and standardised TPI for a given weight matrix
.lf_tpi <- function(x, w, std) {
  m <- terra::focal(x, w, fun = "mean", na.rm = TRUE)
  raw <- x - m
  out <- switch(std,
    none = raw,
    global = {
      # one statistic per call: older versions of terra do not accept
      # several functions in global()
      g_mean <- terra::global(raw, "mean", na.rm = TRUE)[1, 1]
      g_sd <- terra::global(raw, "sd", na.rm = TRUE)[1, 1]
      if (!is.finite(g_sd) || g_sd == 0) {
        warning("The TPI has zero variance over the raster (flat surface?); ",
                "standardised values are undefined.", call. = FALSE)
      }
      (raw - g_mean) / g_sd
    },
    local = {
      s <- terra::focal(x, w, fun = "sd", na.rm = TRUE)
      z <- raw / s
      # zero local variability (flat neighbourhood): undefined, set to NA
      terra::ifel(is.finite(z), z, NA)
    }
  )
  names(raw) <- "tpi"
  names(out) <- "tpi"
  list(raw = raw, tpi = out)
}
