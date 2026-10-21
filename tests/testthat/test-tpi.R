test_that("neighbourhood windows have the expected cells", {
  r <- rand_dem(20)
  w <- landform:::.lf_window(r, 5, "cells", "square", NULL, FALSE, "scale")
  expect_equal(dim(w), c(5, 5))
  expect_equal(sum(!is.na(w)), 24)         # focal cell excluded
  w <- landform:::.lf_window(r, 5, "cells", "square", NULL, TRUE, "scale")
  expect_equal(sum(!is.na(w)), 25)
  w <- landform:::.lf_window(r, 5, "cells", "circle", NULL, TRUE, "scale")
  expect_equal(sum(!is.na(w)), 13)         # radius 2 cells
  w <- landform:::.lf_window(r, 2, "map", "annulus", 1, TRUE, "scale")
  expect_equal(sum(!is.na(w)), 8)          # 1 < d <= 2, centre always out
})

test_that("map units are converted with the cell size", {
  d <- hill_dem()                           # 10 m cells
  w <- landform:::.lf_window(d, 50, "map", "circle", NULL, FALSE, "scale")
  expect_equal(dim(w), c(11, 11))
})

test_that("invalid neighbourhoods are rejected", {
  r <- rand_dem(20)
  expect_error(tpi(r, scale = 4), "odd integer")
  expect_error(tpi(r, scale = 1), "odd integer")
  expect_error(tpi(r, scale = 0.5, units = "map"), "smaller than the cell")
  expect_error(tpi(r, scale = 5, shape = "annulus"), "inner")
  expect_error(tpi(c(r, r)), "single layer")
  expect_error(tpi(matrix(1, 3, 3)), "SpatRaster")
})

test_that("raw TPI is elevation minus the neighbourhood mean", {
  m <- matrix(0, 5, 5); m[3, 3] <- 8
  r <- terra::rast(m)
  t <- tpi(r, 3, std = "none")
  expect_equal(terra::values(t)[13], 8)         # 8 - mean of 8 zeros
  t <- tpi(r, 3, std = "none", centre = TRUE)
  expect_equal(terra::values(t)[13], 8 - 8 / 9)
})

test_that("global standardisation gives z-scores", {
  z <- tpi(hill_dem(), 7)
  expect_equal(terra::global(z, "mean", na.rm = TRUE)[1, 1], 0,
               tolerance = 1e-8)
  expect_equal(terra::global(z, "sd", na.rm = TRUE)[1, 1], 1,
               tolerance = 1e-8)
})

test_that("including the focal cell does not change global z-scores in the interior", {
  d <- hill_dem()
  a <- terra::values(tpi(d, 7, centre = FALSE), mat = FALSE)
  b <- terra::values(tpi(d, 7, centre = TRUE), mat = FALSE)
  inner <- matrix(FALSE, 120, 120); inner[4:117, 4:117] <- TRUE
  i <- which(t(inner))
  # equal up to a constant shift/rescale induced by edge cells only
  expect_gt(stats::cor(a[i], b[i]), 0.9999)
})

test_that("local standardisation of a flat surface is NA, global warns", {
  f <- terra::rast(matrix(10, 10, 10))
  expect_true(all(is.na(terra::values(tpi(f, 3, std = "local")))))
  expect_warning(tpi(f, 3, std = "global"), "zero variance")
})
