# Small synthetic DEMs used across the tests

# random surface, 60 x 60 cells, no CRS (as in the landform <= 0.2 examples)
rand_dem <- function(n = 60, seed = 123) {
  set.seed(seed)
  terra::rast(matrix(stats::runif(n * n), n, n))
}

# a hill and a valley on a flat plain with 5 cm noise; 10 m cells, UTM
hill_dem <- function(n = 120, seed = 1) {
  set.seed(seed)
  xy <- expand.grid(x = 1:n, y = 1:n)
  z <- 100 * exp(-((xy$x - 35)^2 + (xy$y - 35)^2) / (2 * 12^2)) -
    40 * exp(-((xy$x - 95)^2) / (2 * 5^2)) + stats::rnorm(n * n, 0, 0.05)
  terra::rast(matrix(z, n, n, byrow = TRUE),
              extent = terra::ext(0, n * 10, 0, n * 10), crs = "EPSG:32633")
}

# the TPI and classification code of landform 0.2 (with 'pad' removed),
# kept to check that std = "local", centre = TRUE reproduces old results
legacy_tp <- function(x, k) {
  w <- matrix(1, k, k)
  (x - terra::focal(x, w, fun = mean, na.rm = TRUE)) /
    terra::focal(x, w, fun = stats::sd, na.rm = TRUE)
}
legacy_sp <- function(x, scale) {
  tp <- legacy_tp(x, scale)
  slp <- terra::terrain(x, v = "slope", unit = "degrees", neighbors = 8)
  (tp <= -1) * 1 + (tp > -1 & tp <= -0.5) * 2 +
    ((tp > -0.5 & tp < 0.5) & (slp <= 5)) * 3 +
    ((tp > -0.5 & tp < 0.5) & (slp > 5)) * 4 +
    (tp > 0.5 & tp <= 1) * 5 + (tp > 1) * 6
}
legacy_lf <- function(x, sn, ln) {
  slp <- terra::terrain(x, v = "slope", unit = "degrees", neighbors = 8)
  sn <- legacy_tp(x, sn)
  ln <- legacy_tp(x, ln)
  ((sn <= -1) & (ln <= -1)) * 1 + ((sn <= -1) & (ln > -1 & ln < 1)) * 2 +
    ((sn <= -1) & (ln >= 1)) * 3 + ((sn > -1 & sn < 1) & (ln <= -1)) * 4 +
    ((sn > -1 & sn < 1) & (ln > -1 & ln < 1) & (slp <= 5)) * 5 +
    ((sn > -1 & sn < 1) & (ln > -1 & ln < 1) & (slp > 5)) * 6 +
    ((sn > -1 & sn < 1) & (ln >= 1)) * 7 + ((sn >= 1) & (ln <= -1)) * 8 +
    ((sn >= 1) & (ln > -1 & ln < 1)) * 9 + ((sn >= 1) & (ln >= 1)) * 10
}
