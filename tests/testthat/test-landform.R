test_that("the result object has the documented structure", {
  r <- landform(hill_dem(), 7, plot = FALSE)
  expect_s3_class(r, "landform")
  expect_named(r, c("classes", "tpi", "slope", "stats", "dem", "params"))
  expect_true(terra::is.factor(r$classes))
  expect_equal(names(r$tpi), c("tpi_raw", "tpi_std"))
  expect_equal(nrow(r$stats), 6)
  r <- landform(hill_dem(), sn = 5, ln = 15, plot = FALSE,
                class.type = "landform.classification")
  expect_equal(nrow(r$stats), 10)
  expect_equal(terra::nlyr(r$tpi), 4)
})

test_that("every cell with a slope gets exactly one valid class", {
  d <- hill_dem()
  for (ct in c("slope.position", "landform.classification")) {
    r <- landform(d, 5, sn = 5, ln = 15, class.type = ct, plot = FALSE)
    v <- terra::values(r$classes, mat = FALSE)
    s <- terra::values(r$slope, mat = FALSE)
    expect_true(all(is.na(v) == is.na(s)))
    expect_true(all(v[!is.na(v)] %in% r$stats$code))
    expect_equal(sum(r$stats$cells), sum(!is.na(v)))
  }
})

test_that("cells exactly on the inner threshold are classified", {
  # standardised TPI exactly 0.5 was left unclassified by landform <= 0.2
  z <- terra::rast(matrix(c(-2, -1, -0.5, 0, 0.5, 1, 2, 0.25, -0.75), 3, 3))
  cls <- terra::ifel(z <= -1, 1, terra::ifel(z <= -0.5, 2,
         terra::ifel(z < 0.5, 3, terra::ifel(z <= 1, 5, 6))))
  expect_false(anyNA(terra::values(cls)))
})

test_that("std = 'local', centre = TRUE reproduces landform 0.2", {
  d <- rand_dem()
  new <- landform(d, 3, std = "local", centre = TRUE, plot = FALSE)
  old <- legacy_sp(d, 3)
  v_new <- terra::values(new$classes, mat = FALSE)
  v_old <- terra::values(old, mat = FALSE)
  ok <- !is.na(v_new)
  expect_equal(v_new[ok], v_old[ok])

  new <- landform(d, sn = 3, ln = 11, std = "local", centre = TRUE,
                  class.type = "landform.classification", plot = FALSE)
  old <- legacy_lf(d, 3, 11)
  v_new <- terra::values(new$classes, mat = FALSE)
  v_old <- terra::values(old, mat = FALSE)
  ok <- !is.na(v_new)
  expect_equal(v_new[ok], v_old[ok])
})

test_that("a noisy plain is flat with global, but not with local, standardisation", {
  d <- hill_dem()
  # plain: far from the hill (35, 35) and the valley (x = 95)
  xy <- expand.grid(x = 1:120, y = 1:120)
  plain <- sqrt((xy$x - 35)^2 + (xy$y - 35)^2) > 45 & abs(xy$x - 95) > 20 &
    xy$x > 5 & xy$x < 116 & xy$y > 5 & xy$y < 116
  plain <- as.vector(t(matrix(plain, 120, 120, byrow = TRUE)))
  g <- terra::values(landform(d, 7, plot = FALSE)$classes, mat = FALSE)
  l <- terra::values(landform(d, 7, std = "local", plot = FALSE)$classes,
                     mat = FALSE)
  expect_gt(mean(g[plain] == 3, na.rm = TRUE), 0.99)   # Flat Slope
  expect_lt(mean(l[plain] == 3, na.rm = TRUE), 0.6)
})

test_that("areas use the cell size, also for longitude/latitude rasters", {
  d <- rand_dem()                         # no CRS: nominal area, metres
  terra::ext(d) <- c(0, 600, 0, 600)      # 10 m cells
  r <- landform(d, 5, plot = FALSE)
  expect_equal(sum(r$stats$area_km2), sum(r$stats$cells) * 1e-4)
  expect_equal(sum(r$stats$percent), 100)
  lux <- terra::rast(system.file("ex/elev.tif", package = "terra"))
  r <- landform(lux, 5, plot = FALSE)
  a <- terra::cellSize(lux, unit = "km")
  a <- terra::global(terra::mask(a, r$classes), "sum", na.rm = TRUE)$sum
  expect_equal(sum(r$stats$area_km2), a)
})

test_that("arguments are validated", {
  d <- rand_dem(20)
  expect_error(landform(d, class.type = "foo", plot = FALSE))
  expect_error(landform(d, sn = 7, ln = 5, plot = FALSE,
                        class.type = "landform.classification"), "larger")
  expect_error(landform(d, 3, tpi.thr = c(1, 0.5), plot = FALSE), "increasing")
  expect_error(landform(d, 3, slope.thr = 95, plot = FALSE), "between 0")
  expect_error(landform(d, 3, col = "red", plot = FALSE), "6 colours")
  expect_error(landform(d, sn = 3, ln = 7, shape = "annulus", inner = 1,
                        class.type = "landform.classification",
                        plot = FALSE), "two inner")
})

test_that("print, summary and plot methods run", {
  r <- landform(hill_dem(), sn = 5, ln = 15, plot = FALSE,
                class.type = "landform.classification")
  expect_output(print(r), "Landform Classification")
  expect_s3_class(summary(r), "data.frame")
  grDevices::pdf(NULL)
  on.exit(grDevices::dev.off())
  expect_invisible(plot(r))
  expect_invisible(plot(r, shade = "slope"))
  expect_invisible(plot(r, shade = "hill", alpha = 0.4))
  expect_invisible(plot(r, what = "tpi", shade = "slope"))
  expect_error(plot(r, shade = "slope", alpha = 2), "between 0 and 1")
  expect_invisible(plot(r, what = "area"))
  expect_invisible(plot(r, what = "tpi"))
  expect_invisible(landform(hill_dem(), 5, descriptive = TRUE,
                            leg.pos = "topright"))
})

test_that("class_layers() returns named presence/absence layers", {
  r <- landform(hill_dem(), 7, plot = FALSE)
  l <- class_layers(r)
  present <- r$stats$class[r$stats$cells > 0]
  expect_equal(names(l), present)
  s <- terra::values(sum(l), mat = FALSE)
  expect_true(all(s[!is.na(s)] == 1))           # exactly one class per cell
  expect_true(all(is.na(s) == is.na(terra::values(r$classes, mat = FALSE))))
  expect_error(class_layers(1), "landform")
})

test_that("cells with NA elevation are never classified", {
  d <- hill_dem()
  d[1000:1600] <- NA                       # a block of NA cells (e.g. sea)
  for (ct in c("slope.position", "landform.classification")) {
    r <- landform(d, 5, sn = 5, ln = 15, class.type = ct, plot = FALSE)
    v <- terra::values(r$classes, mat = FALSE)
    e <- terra::values(d, mat = FALSE)
    expect_true(all(is.na(v[is.na(e)])))
    # areas are complete for every class with cells
    expect_false(anyNA(r$stats$area_km2))
    expect_true(all(r$stats$area_km2[r$stats$cells > 0] > 0))
  }
})
