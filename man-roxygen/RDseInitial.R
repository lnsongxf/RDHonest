#' @param se.initial Method for estimating initial variance (ignored if
#'     \code{hp} and \code{hm} are provided, or if data already contains
#'     estimate of variance.
#'
#' \describe{
#'
#'   \item{"IK"}{Based on residuals from a local linear regression using IK
#'               bandwidth}
#'
#'    \item{"Silverman"}{Based on Silverman's pilot bandwidth, as in Equatio
#'    (14) in IK}
#'
#' }