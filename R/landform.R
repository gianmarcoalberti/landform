#' Landform Classification
#'
#' Classifies a landscape into slope-position or landform classes on the basis
#' of the Topographic Position Index (TPI; see \code{\link{tpi}}) and slope,
#' following Weiss (2001) and Jenness (2006). Two classifications are
#' available: the six-class Slope Position Classification, based on one TPI
#' scale, and the ten-class Landform Classification, based on a small and a
#' large TPI scale.
#'
#' @param x A single-layer \code{SpatRaster} (or a \code{RasterLayer}, which is
#'   converted internally) representing elevation. A projected coordinate
#'   system with the same horizontal and vertical units (e.g. metres) is
#'   recommended, since slope (and hence the slope threshold) depends on it.
#' @param scale Neighbourhood size for the Slope Position Classification. With
#'   \code{units = "cells"} (default), the width of the moving window in cells
#'   (odd integer >= 3); with \code{units = "map"}, the radius (half-width for
#'   square windows) in map units (metres for longitude/latitude rasters).
#'   Default \code{3}.
#' @param sn,ln Small and large neighbourhood sizes for the Landform
#'   Classification, in the same units as \code{scale}. Defaults \code{3} and
#'   \code{7}; \code{ln} must be larger than \code{sn}.
#' @param class.type Either \code{"slope.position"} (default) or
#'   \code{"landform.classification"}.
#' @param descriptive Logical. If \code{TRUE}, a bar plot of the area of each
#'   class is drawn in addition to the map (default \code{FALSE}). The
#'   descriptive statistics are always computed and stored in the returned
#'   object (see Value).
#' @param leg.pos Position of the legend of the map, as a keyword accepted by
#'   \code{\link[graphics]{legend}} (e.g. \code{"topright"}). The default,
#'   \code{NULL}, places the legend outside the map, to its right, so that no
#'   data are hidden.
#' @param leg.cex Magnification of the legend text. Default \code{0.8}.
#' @param units Either \code{"cells"} (default) or \code{"map"}; see
#'   \code{scale}.
#' @param shape Neighbourhood shape: \code{"square"} (default),
#'   \code{"circle"}, or \code{"annulus"}. See \code{\link{tpi}}.
#' @param inner Inner radius (or radii) of the annulus, in the same units as
#'   \code{scale}: one value for the Slope Position Classification, two values
#'   (for \code{sn} and \code{ln}) for the Landform Classification. Ignored
#'   unless \code{shape = "annulus"}.
#' @param centre Logical. Include the focal cell in the neighbourhood mean?
#'   Default \code{FALSE}. See \code{\link{tpi}}.
#' @param std TPI standardisation: \code{"global"} (default; Weiss 2001,
#'   Jenness 2006) or \code{"local"} (as in \pkg{landform} <= 0.2). See
#'   \code{\link{tpi}} for the difference, which can be substantial.
#' @param tpi.thr Two increasing positive thresholds (in standard deviation
#'   units) used by the Slope Position Classification. Default
#'   \code{c(0.5, 1)} (Weiss 2001).
#' @param lf.thr Threshold (in standard deviation units) separating low, mid
#'   and high TPI in the Landform Classification. Default \code{1} (Weiss
#'   2001).
#' @param slope.thr Slope threshold, in degrees, separating flat from sloping
#'   terrain. Default \code{5} (Weiss 2001).
#' @param plot Logical. Draw the map of the classes? Default \code{TRUE}.
#' @param hillshade Logical. Draw the classes semi-transparently over a
#'   hillshade? Default \code{FALSE}.
#' @param col Optional vector of colours, one per class. By default the
#'   Slope Position Classification uses an ordinal blue-to-brown palette
#'   (valley to ridge) that remains readable with the common forms of colour
#'   blindness; the Landform Classification groups hues by landform family
#'   (drainages and valleys in blues, plains and slopes in yellows and greens,
#'   ridges and tops in oranges, reds and purple). With ten classes no palette
#'   is fully colour-blind safe; supply your own if needed.
#'
#' @details
#' \strong{Slope Position Classification} (Weiss 2001). With \eqn{z} the
#' standardised TPI, \eqn{t_1 < t_2} the values of \code{tpi.thr}, and
#' \eqn{s} the slope in degrees:
#' \tabular{ll}{
#'   1 Valley \tab \eqn{z \le -t_2}\cr
#'   2 Lower Slope \tab \eqn{-t_2 < z \le -t_1}\cr
#'   3 Flat Slope \tab \eqn{-t_1 < z < t_1} and \eqn{s \le} \code{slope.thr}\cr
#'   4 Middle Slope \tab \eqn{-t_1 < z < t_1} and \eqn{s >} \code{slope.thr}\cr
#'   5 Upper Slope \tab \eqn{t_1 \le z \le t_2}\cr
#'   6 Ridge \tab \eqn{z > t_2}
#' }
#'
#' \strong{Landform Classification} (Weiss 2001; Jenness 2006). With
#' \eqn{SN} and \eqn{LN} the standardised TPI at the small and large scales,
#' and \eqn{t} the value of \code{lf.thr}:
#' \tabular{ll}{
#'   1 Canyons, Deeply Incised Streams \tab \eqn{SN \le -t}, \eqn{LN \le -t}\cr
#'   2 Midslope Drainages, Shallow Valleys \tab \eqn{SN \le -t}, \eqn{-t < LN < t}\cr
#'   3 Upland Drainages, Headwaters \tab \eqn{SN \le -t}, \eqn{LN \ge t}\cr
#'   4 U-shaped Valleys \tab \eqn{-t < SN < t}, \eqn{LN \le -t}\cr
#'   5 Plains \tab \eqn{-t < SN < t}, \eqn{-t < LN < t}, \eqn{s \le} \code{slope.thr}\cr
#'   6 Open Slopes \tab \eqn{-t < SN < t}, \eqn{-t < LN < t}, \eqn{s >} \code{slope.thr}\cr
#'   7 Upper Slopes, Mesas \tab \eqn{-t < SN < t}, \eqn{LN \ge t}\cr
#'   8 Local Ridges, Hills in Valleys \tab \eqn{SN \ge t}, \eqn{LN \le -t}\cr
#'   9 Midslope Ridges, Small Hills in Plains \tab \eqn{SN \ge t}, \eqn{-t < LN < t}\cr
#'   10 Mountain Tops, High Ridges \tab \eqn{SN \ge t}, \eqn{LN \ge t}
#' }
#' Both sets of rules assign every cell to exactly one class.
#'
#' \strong{Edges and NA cells}. Slope cannot be computed for the outermost
#' cells of the raster and for cells adjacent to \code{NA} cells; these cells
#' are left unclassified (\code{NA}) for every class, so that the class
#' frequencies are not biased by edge effects.
#'
#' \strong{Area}. Class areas are computed with \code{\link[terra]{cellSize}},
#' and are therefore correct also for longitude/latitude rasters; for
#' projected rasters they are ground areas, which may differ slightly from
#' the nominal cell area (resolution squared) because of the scale distortion
#' of the projection. If the
#' raster has no coordinate reference system, map units are assumed to be
#' metres.
#'
#' \strong{Reproducing results of landform <= 0.2}. Use
#' \code{std = "local", centre = TRUE} (with the default square window in
#' cells). Cells whose standardised TPI equalled exactly \eqn{t_1} were left
#' unclassified by earlier versions and are now classified as Upper Slope; edge
#' cells are now consistently \code{NA}.
#'
#' @return An object of class \code{"landform"}: a list with elements
#' \describe{
#'   \item{\code{classes}}{a categorical \code{SpatRaster} of the classes
#'     (integer codes with class names as levels and a colour table);
#'     per-class layers can be obtained with \code{\link{class_layers}};}
#'   \item{\code{tpi}}{a \code{SpatRaster} with the raw (elevation units) and
#'     standardised TPI layers used in the classification;}
#'   \item{\code{slope}}{a \code{SpatRaster} of slope (degrees);}
#'   \item{\code{stats}}{a data frame with, for every class, the number of
#'     cells, the area (km\eqn{^2}), the percentage of the classified area,
#'     and the mean elevation and slope;}
#'   \item{\code{dem}}{the input elevation raster;}
#'   \item{\code{params}}{a list of the settings used.}
#' }
#' The object has \code{print}, \code{summary} and \code{plot} methods (see
#' \code{\link{plot.landform}}). The map (and, with \code{descriptive = TRUE},
#' the bar plot of class areas) is drawn as a side effect when
#' \code{plot = TRUE}; the object is returned invisibly in that case.
#'
#' @references
#' Jenness, J. (2006). Topographic Position Index (tpi_jen.avx) extension for
#' ArcView 3.x, v. 1.2. Jenness Enterprises.
#'
#' Weiss, A. (2001). Topographic Position and Landforms Analysis. Poster
#' presentation, ESRI User Conference, San Diego, CA.
#'
#' See \code{\link{tpi}} for references on the TPI and its standardisation.
#'
#' @seealso \code{\link{tpi}}, \code{\link{plot.landform}},
#'   \code{\link{class_layers}}, \code{\link{malta_dtm}},
#'   \code{\link[terra]{terrain}}
#'
#' @examples
#' dem <- malta_dtm()
#'
#' # Slope Position Classification, 9 x 9 cell window
#' sp <- landform(dem, scale = 9)
#' sp
#' summary(sp)
#'
#' # Landform Classification, circular neighbourhoods of 120 m and 480 m
#' lf <- landform(dem, class.type = "landform.classification",
#'                sn = 120, ln = 480, units = "map", shape = "circle")
#'
#' \donttest{
#' # the standardisation used by landform <= 0.2, for comparison
#' sp_local <- landform(dem, scale = 9, std = "local", centre = TRUE)
#' }
#'
#' # the same, over a hillshade, with the bar plot of class areas
#' plot(lf, hillshade = TRUE)
#' plot(lf, what = "area")
#'
#' # one layer per class
#' layers <- class_layers(lf)
#'
#' @export
landform <- function(x, scale = 3, sn = 3, ln = 7,
                     class.type = c("slope.position", "landform.classification"),
                     descriptive = FALSE, leg.pos = NULL, leg.cex = 0.8,
                     units = c("cells", "map"),
                     shape = c("square", "circle", "annulus"), inner = NULL,
                     centre = FALSE, std = c("global", "local"),
                     tpi.thr = c(0.5, 1), lf.thr = 1, slope.thr = 5,
                     plot = TRUE, hillshade = FALSE, col = NULL) {

  # --- check the arguments ---------------------------------------------------
  class.type <- match.arg(class.type)
  units <- match.arg(units)
  shape <- match.arg(shape)
  std <- match.arg(std)
  x <- .lf_check_raster(x)
  if (!is.numeric(tpi.thr) || length(tpi.thr) != 2 || any(tpi.thr <= 0) ||
      tpi.thr[1] >= tpi.thr[2]) {
    stop("'tpi.thr' must be two increasing positive numbers.", call. = FALSE)
  }
  if (!is.numeric(lf.thr) || length(lf.thr) != 1 || lf.thr <= 0) {
    stop("'lf.thr' must be a single positive number.", call. = FALSE)
  }
  if (!is.numeric(slope.thr) || length(slope.thr) != 1 || slope.thr < 0 ||
      slope.thr >= 90) {
    stop("'slope.thr' must be a single number between 0 and 90 (degrees).",
         call. = FALSE)
  }
  if (class.type == "landform.classification") {
    if (!is.numeric(sn) || !is.numeric(ln) || ln <= sn) {
      stop("'ln' must be larger than 'sn'.", call. = FALSE)
    }
    if (shape == "annulus" && length(inner) != 2) {
      stop("With shape = \"annulus\", 'inner' must give two inner radii, ",
           "one for 'sn' and one for 'ln'.", call. = FALSE)
    }
  }

  # --- slope (degrees); NA on the outer rim and next to NA cells ------------
  slp <- terra::terrain(x, v = "slope", unit = "degrees", neighbors = 8)
  # older versions of terra may return a slope for NA elevation cells
  slp <- terra::mask(slp, x)
  names(slp) <- "slope"

  # --- TPI and classification ------------------------------------------------
  if (class.type == "slope.position") {
    w <- .lf_window(x, scale, units, shape, inner[1], centre, what = "scale")
    tp <- .lf_tpi(x, w, std)
    z <- tp$tpi
    t1 <- tpi.thr[1]
    t2 <- tpi.thr[2]
    cls <- terra::ifel(z <= -t2, 1,
           terra::ifel(z <= -t1, 2,
           terra::ifel(z < t1, terra::ifel(slp <= slope.thr, 3, 4),
           terra::ifel(z <= t2, 5, 6))))
    tpi_layers <- c(tp$raw, tp$tpi)
    names(tpi_layers) <- c("tpi_raw", "tpi_std")
  } else {
    w_s <- .lf_window(x, sn, units, shape, inner[1], centre, what = "sn")
    w_l <- .lf_window(x, ln, units, shape, inner[2], centre, what = "ln")
    tp_s <- .lf_tpi(x, w_s, std)
    tp_l <- .lf_tpi(x, w_l, std)
    t <- lf.thr
    # position of each TPI in the low (1), mid (2), high (3) band
    bs <- 1 + (tp_s$tpi > -t) + (tp_s$tpi >= t)
    bl <- 1 + (tp_l$tpi > -t) + (tp_l$tpi >= t)
    b <- (bs - 1) * 3 + bl                     # 1 to 9
    # codes 1-4 unchanged, 5 split by slope into 5-6, codes 6-9 become 7-10
    cls <- terra::ifel(b <= 4, b,
           terra::ifel(b == 5, terra::ifel(slp <= slope.thr, 5, 6), b + 1))
    tpi_layers <- c(tp_s$raw, tp_s$tpi, tp_l$raw, tp_l$tpi)
    names(tpi_layers) <- c("sn_tpi_raw", "sn_tpi_std", "ln_tpi_raw",
                           "ln_tpi_std")
  }

  # leave cells without slope or without TPI unclassified (consistent edge
  # handling); masking explicitly also guards against older versions of terra,
  # in which ifel() does not propagate NA conditions
  cls <- terra::mask(cls, slp)
  for (i in seq_len(terra::nlyr(tpi_layers))) {
    cls <- terra::mask(cls, tpi_layers[[i]])
  }
  defs <- .lf_classes(class.type)
  cls <- .lf_as_categorical(cls, defs, col)
  names(cls) <- "class"

  out <- list(
    classes = cls,
    tpi = tpi_layers,
    slope = slp,
    stats = .lf_stats(cls, x, slp, defs),
    dem = x,
    params = list(class.type = class.type, scale = scale, sn = sn, ln = ln,
                  units = units, shape = shape, inner = inner,
                  centre = centre, std = std, tpi.thr = tpi.thr,
                  lf.thr = lf.thr, slope.thr = slope.thr,
                  col = if (is.null(col)) defs$col else col)
  )
  class(out) <- "landform"

  if (plot) {
    plot.landform(out, what = "classes", hillshade = hillshade,
                  leg.pos = leg.pos, leg.cex = leg.cex)
    if (descriptive) plot.landform(out, what = "area")
    return(invisible(out))
  }
  out
}

# ---------------------------------------------------------------------------
# Class definitions and palettes
# ---------------------------------------------------------------------------
.lf_classes <- function(class.type) {
  if (class.type == "slope.position") {
    data.frame(
      value = 1:6,
      class = c("Valley", "Lower Slope", "Flat Slope", "Middle Slope",
                "Upper Slope", "Ridge"),
      # ordinal, diverging (blue = low, brown = high); colour-blind safe
      col = c("#2166AC", "#92C5DE", "#DDDDDD", "#A6A67E", "#DFA365",
              "#8C510A"),
      stringsAsFactors = FALSE
    )
  } else {
    data.frame(
      value = 1:10,
      class = c("Canyons, Deeply Incised Streams",
                "Midslope Drainages, Shallow Valleys",
                "Upland Drainages, Headwaters",
                "U-shaped Valleys",
                "Plains",
                "Open Slopes",
                "Upper Slopes, Mesas",
                "Local Ridges, Hills in Valleys",
                "Midslope Ridges, Small Hills in Plains",
                "Mountain Tops, High Ridges"),
      # drainages/valleys in blues, flat and sloping terrain in yellows and
      # greens, ridges and tops in oranges, reds and purple
      col = c("#08306B", "#2171B5", "#6BAED6", "#9ECAE1",
              "#FFF7BC", "#B8CE80", "#E6AB02",
              "#FB9A99", "#E31A1C", "#6A3D9A"),
      stringsAsFactors = FALSE
    )
  }
}

# Turn an integer raster into a categorical raster with levels and colours
.lf_as_categorical <- function(r, defs, col = NULL) {
  if (!is.null(col)) {
    if (length(col) != nrow(defs)) {
      stop("'col' must contain ", nrow(defs), " colours, one per class.",
           call. = FALSE)
    }
    defs$col <- col
  }
  r <- terra::as.int(r)
  levels(r) <- defs[, c("value", "class")]
  terra::coltab(r) <- data.frame(value = defs$value, col = defs$col)
  r
}

# Descriptive statistics for every class
.lf_stats <- function(cls, dem, slp, defs) {
  codes <- terra::values(cls, mat = FALSE)
  ok <- !is.na(codes)
  if (terra::crs(dem) == "") {
    # no CRS: assume map units are metres (as in landform <= 0.2)
    area <- rep(prod(terra::res(dem)) / 1e6, terra::ncell(dem))
  } else {
    area <- terra::values(terra::cellSize(dem, unit = "km"), mat = FALSE)
  }
  elev <- terra::values(dem, mat = FALSE)
  slope <- terra::values(slp, mat = FALSE)
  f <- factor(codes[ok], levels = defs$value)
  n <- as.vector(table(f))
  a <- as.vector(tapply(area[ok], f, sum))
  a[is.na(a)] <- 0
  me <- as.vector(tapply(elev[ok], f, mean, na.rm = TRUE))
  ms <- as.vector(tapply(slope[ok], f, mean, na.rm = TRUE))
  data.frame(
    code = defs$value,
    class = defs$class,
    cells = n,
    area_km2 = a,
    percent = if (sum(a) > 0) 100 * a / sum(a) else rep(NA_real_, length(a)),
    mean_elev = me,
    mean_slope = ms,
    stringsAsFactors = FALSE
  )
}

# ---------------------------------------------------------------------------
# Methods
# ---------------------------------------------------------------------------

#' @export
print.landform <- function(x, ...) {
  p <- x$params
  type <- if (p$class.type == "slope.position") {
    "Slope Position Classification (Weiss 2001)"
  } else {
    "Landform Classification (Weiss 2001; Jenness 2006)"
  }
  u <- if (p$units == "cells") "cells (window width)" else "map units (radius)"
  size <- if (p$class.type == "slope.position") {
    paste0("scale = ", p$scale)
  } else {
    paste0("sn = ", p$sn, ", ln = ", p$ln)
  }
  cat("<landform>", type, "\n")
  cat("  neighbourhood :", size, "in", u, "-", p$shape,
      if (p$centre) "(focal cell included)" else "(focal cell excluded)",
      "\n")
  cat("  TPI standard. :", p$std, "\n")
  cat("  classified    :", sum(x$stats$cells), "cells,",
      format(round(sum(x$stats$area_km2), 3), nsmall = 3), "km2\n\n")
  s <- x$stats[, c("code", "class", "area_km2", "percent")]
  s$area_km2 <- round(s$area_km2, 3)
  s$percent <- round(s$percent, 1)
  print(s, row.names = FALSE)
  invisible(x)
}

#' @export
summary.landform <- function(object, ...) {
  object$stats
}

#' Plot a landform classification
#'
#' Plots the map of the classes, a bar plot of the area of each class, or the
#' standardised TPI surface(s), from an object returned by
#' \code{\link{landform}}.
#'
#' @param x An object of class \code{"landform"}.
#' @param what What to plot: \code{"classes"} (default), \code{"area"}, or
#'   \code{"tpi"}.
#' @param hillshade Logical. For \code{what = "classes"}, draw the classes
#'   semi-transparently over a hillshade of the elevation raster. Default
#'   \code{FALSE}.
#' @param alpha Opacity of the classes relative to the hillshade drawn over
#'   them (0 to 1; the hillshade is drawn with opacity \code{1 - alpha}).
#'   Default \code{0.6}.
#' @param leg.pos Legend position for the map (a \code{\link[graphics]{legend}}
#'   keyword); \code{NULL} (default) places it outside the map, to its right.
#' @param leg.cex Magnification of the legend text. Default \code{0.8}.
#' @param main Plot title; a sensible default is used if \code{NULL}.
#' @param ... Further arguments passed to \code{\link[terra]{plot}} (for maps)
#'   or \code{\link[graphics]{barplot}} (for \code{what = "area"}).
#'
#' @return \code{x}, invisibly.
#'
#' @examples
#' dem <- malta_dtm()
#' sp <- landform(dem, scale = 9, plot = FALSE)
#' plot(sp)
#' plot(sp, hillshade = TRUE)
#' plot(sp, what = "area")
#' plot(sp, what = "tpi")
#'
#' @importFrom graphics barplot par
#' @export
plot.landform <- function(x, what = c("classes", "area", "tpi"),
                          hillshade = FALSE, alpha = 0.6, leg.pos = NULL,
                          leg.cex = 0.8, main = NULL, ...) {
  what <- match.arg(what)
  p <- x$params
  title <- if (p$class.type == "slope.position") {
    "Slope Position (Weiss 2001)"
  } else {
    "Landform Classification (Weiss 2001; Jenness 2006)"
  }

  if (what == "classes") {
    if (is.null(main)) main <- title
    # right margin wide enough for the longest class name in the legend
    mar <- c(3.1, 3.1, 2.1, 3 + 0.45 * leg.cex * max(nchar(x$stats$class)))
    plg <- list(cex = leg.cex)
    if (!is.null(leg.pos)) plg$x <- leg.pos
    if (hillshade) {
      # classes first (opaque, with their legend), then a semi-transparent
      # hillshade on top; this avoids colour-table transparency, which older
      # versions of terra do not support
      terra::plot(x$classes, main = main, plg = plg,
                  mar = mar, ...)
      sl <- terra::terrain(x$dem, v = "slope", unit = "radians")
      as <- terra::terrain(x$dem, v = "aspect", unit = "radians")
      hs <- terra::shade(sl, as, angle = 45, direction = 315)
      terra::plot(hs, col = grDevices::grey(0:100 / 100), legend = FALSE,
                  alpha = 1 - alpha, add = TRUE)
    } else {
      terra::plot(x$classes, main = main, plg = plg,
                  mar = mar, ...)
    }
  }

  if (what == "area") {
    s <- x$stats
    cols <- x$params$col
    if (is.null(main)) main <- title
    op <- par(mar = c(4.1, 15, 2.1, 1), no.readonly = TRUE)
    on.exit(par(op))
    # horizontal bars, first class at the top
    barplot(rev(s$area_km2), names.arg = rev(s$class), horiz = TRUE,
            las = 1, col = rev(cols), border = "grey40",
            xlab = expression("Area (km"^2*")"), main = main, cex.names = 0.7,
            cex.main = 0.9, cex.axis = 0.8, ...)
  }

  if (what == "tpi") {
    z <- x$tpi[[grep("_std$", names(x$tpi))]]
    # colour scale symmetric around zero and capped at +/- 3 SD, so that a few
    # extreme values do not wash out the map; more extreme cells are drawn in
    # the end colours
    m <- 3
    z <- terra::clamp(z, -m, m)
    lab <- if (p$class.type == "slope.position") {
      "Standardised TPI"
    } else {
      c("Standardised TPI, small scale (SN)", "Standardised TPI, large scale (LN)")
    }
    terra::plot(z, col = grDevices::hcl.colors(101, "Blue-Red 3"),
                range = c(-m, m), main = if (is.null(main)) lab else main,
                ...)
  }
  invisible(x)
}

#' One layer per class
#'
#' Splits the classified raster of a \code{"landform"} object into one
#' presence/absence layer per class, named after the classes. This replaces the
#' list of per-class rasters returned by \pkg{landform} <= 0.2.
#'
#' @param x An object of class \code{"landform"}.
#' @param absent Value given to cells not belonging to the class: \code{0}
#'   (default) or \code{NA}.
#'
#' @return A multi-layer \code{SpatRaster} with one layer for each class
#'   present in the classification (1 = cell belongs to the class); cells left
#'   unclassified are \code{NA} in every layer.
#'
#' @examples
#' dem <- malta_dtm()
#' sp <- landform(dem, scale = 9, plot = FALSE)
#' layers <- class_layers(sp)
#' names(layers)
#' terra::plot(layers[["Ridge"]], main = "Ridge")
#'
#' @export
class_layers <- function(x, absent = 0) {
  if (!inherits(x, "landform")) {
    stop("'x' must be an object returned by landform().", call. = FALSE)
  }
  r <- terra::segregate(x$classes, other = absent)
  codes <- as.integer(names(r))
  names(r) <- x$stats$class[match(codes, x$stats$code)]
  # keep cells that were left unclassified as NA in every layer
  terra::mask(r, x$classes)
}
