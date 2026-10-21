#' landform: Topographic Position Index-Based Landform Classification
#'
#' Classifies a landscape into slope-position or landform classes on the basis
#' of the Topographic Position Index (TPI) and slope (Weiss 2001; Jenness 2006).
#'
#' Main functions:
#' \itemize{
#'   \item \code{\link{landform}}: Slope Position and Landform
#'     classifications, returned as an object with \code{print},
#'     \code{summary} and \code{plot} methods;
#'   \item \code{\link{tpi}}: the TPI surface itself, raw or standardised;
#'   \item \code{\link{class_layers}}: one presence/absence layer per class;
#'   \item \code{\link{malta_dtm}}: a sample digital terrain model.
#' }
#'
#' @keywords internal
#' @importFrom terra rast
"_PACKAGE"
