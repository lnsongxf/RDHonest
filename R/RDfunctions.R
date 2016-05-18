#' Local polynomial regression at a point, normalized to 0
#'
#' Calculate estimate of a function at a point and its variance given a
#' bandwidth using local polynomial regression of order \code{order}.
#' @param Y,X Outcome variable and regressor
#' @param h Bandwidth
#' @param K Kernel function
#' @param order Order of local regression 1 for linear, 2 for quadratic, etc.
#' @param sigma2 Optionally, supply estimates of \eqn{\sigma^{2}_{i}}
#' @param se.method Vector with methods for estimating standard error of
#' estimate. If not specified or \code{NULL}, standard errors are not computed.
#' The elements of the vector can consist of the following method:
#' \describe{
#'     \item{"nn"}{Nearest neighbor method. Assumes data have been sorted so
#'                 that \code{X[i]<X[i+1]}}
#'     \item{"EHW"}{Eicker-Huber-White}
#'     \item{"demeaned"}{Only subtract intercept}
#'     \item{"supplied.sigma"}{Use EHW, but instead of computing residuals,
#'           use estimates of \eqn{sigma^2_i} supplied by \code{sigma2}}
#' }
#' @param J Number of nearest neighbors, if "nn" is specified in \code{se.method}
#' @keywords internal
LPReg <- function(X, Y, h, K, order=1, se.method=NULL, sigma2=NA, J=3) {
    R <- outer(X, 0:order, "^")
    W <- K(X/h)

    if (sum(W>0)<=order | h==0)
        return(list(theta=0, sigma2=NA, var=NA, w=function(u) 0, eff.obs=0))

    Gamma <- crossprod(R, W*R)
    beta <- drop(solve(Gamma, crossprod(R, W*Y)))
    hsigma2 <- drop(Y - R %*% beta)^2     # squared residuals

    ## weight function if we think of the estimator as linear estimator
    w <- function(x) solve(Gamma, t(outer(x, 0:order, "^")*K(x/h)))[1, ]

    EHW <- function(sigma2)
        (solve(Gamma, crossprod(sigma2*W*R, W*R)) %*% solve(Gamma))[1, 1]

    ## Robust variance-based formulae
    ehw <- if("EHW" %in% se.method) EHW(hsigma2) else NA
    sup <- if(!anyNA(sigma2)) EHW(sigma2) else NA

    if("demeaned" %in% se.method) {
        hsigma2 <- (Y-beta[1])^2
        dem <- EHW(hsigma2)
    } else  {
        dem <- NA
    }

    if("nn" %in% se.method) {
        hsigma2 <- sigmaNN(X, Y, J=J)
        nn <- EHW(hsigma2)
    } else  {
        nn <- NA
    }

    v <- c(sup, nn, ehw, dem)
    names(v) <- c("supplied.sigma", "nn", "EHW", "demeaned")

    eff.obs <- 1/sum(w(X)^2)
    list(theta=beta[1], sigma2=hsigma2, var=v, w=w, eff.obs=eff.obs)
}


#' Local polynomial regression in sharp RD
#'
#' Calculate sharp RD estimate and its variance given a bandwidth using local
#' polynomial regression of order \code{order}.
#'
#' @param d object of class \code{"RDData"}
#' @template RDBW
#' @template Kern
#' @param no.warning Don't warn about too few observations
#' @param se.method Vector with methods for estimating standard error of
#'     estimate. If not specified or \code{NULL}, standard errors are not
#'     computed. The elements of the vector can consist of the following method:
#'
#' \describe{
#'     \item{"nn"}{Nearest neighbor method}
#'     \item{"EHW"}{Eicker-Huber-White, with residuals from local regression.}
#'
#'     \item{"demeaned"}{Use EHW, but instead of using residuals, estimate
#'     \eqn{sigma^2_i} by only subtracting the estimated intercept from the
#'     outcome}
#'
#'     \item{"supplied.sigma"}{Use EHW, but instead of using residuals, use
#'     estimates of \eqn{sigma^2_i} supplied by \code{d}.}
#'     \item{"plugin"}{Plugin method.} }
#' @param J Number of nearest neighbors, if "nn" is specified in \code{se.method}.
#' @return list with elements:
#'
#' \describe{
#'     \item{estimate}{point estimate}
#'     \item{se}{Named vector of standard error estimates, as specified by \code{se.method}.}
#'     \item{wm,wp}{Implicit weight functions used}
#'     \item{sigma2m, sigma2p}{Estimates of \eqn{sigma^2(X)} for values of values
#'                    of \code{X} below (above) cutoff and receiving positive
#'                    kernel weight. By default, estimates are based on squared
#'                    regression residuals, as used in "EHW". If \code{"demeaned"}
#'                    or \code{"nn"} is specifed,  estimates are based on that method,
#'                    with \code{"nn"} method used if both are specified.}
#'     \item{eff.obs}{Number of effective observations}
#' }
#' @export
RDLPreg <- function(d, hp, kern="triangular", order=1, hm=h, se.method=NULL,
                    no.warning=FALSE, J=3) {

    ## Pre-sorting makes standard error computations faster
    if (is.unsorted(d$Xp) & ("nn" %in% se.method)) {
        s <- sort(d$Xp, index.return=TRUE)
        d$Yp <- d$Yp[s$ix]
        d$Xp <- s$x
        s <- sort(d$Xm, index.return=TRUE)
        d$Ym <- d$Ym[s$ix]
        d$Xm <- s$x
    }
    K <- if (!is.function(kern)) {
             lpKern::EqKern(kern, boundary=FALSE, order=0)
         } else {
             kern
         }
    Wm <- if (hm==0) 0*d$Xm else K(d$Xm/hm) # kernel weights
    Wp <- if (hp==0) 0*d$Xp else K(d$Xp/hp)

    ## variance calculations are faster if we only keep data with positive
    ## weights
    d$Xp <- d$Xp[Wp>0]
    d$Xm <- d$Xm[Wm>0]

    if ((length(d$Xm) < 3*order | length(d$Xp) < 3*order) & no.warning==FALSE) {
        warning("Too few observations to compute RD estimates.\nOnly ",
                length(d$Xm), " control and ", length(d$Xp),
                " treated units with positive weights")
    }

    rm <- LPReg(d$Xm, d$Ym[Wm>0], hm, K, order, se.method, d$sigma2m[Wm>0], J=J)
    rp <- LPReg(d$Xp, d$Yp[Wp>0], hp,  K, order, se.method, d$sigma2p[Wp>0], J=J)
    theta <- rp$theta-rm$theta

    ## Plug-in Asymptotic variance
    plugin <- NA
    if ("plugin" %in% se.method) {
        if (is.function(kern)) {
            ke <- lpKern::EqKern(kern, boundary=TRUE, order=order)
            nu0 <- lpKern::KernMoment(ke, moment=0, boundary=TRUE, "raw2")
        } else {
            tbl <- lpKern::kernC
            nu0 <- tbl[tbl$kernel==kern & tbl$order==order &
                           tbl$boundary==TRUE, "nu0"]
        }
        ## note we kept original outcomes, but only kept X's receiving positive
        ## weight
        N <- length(d$Yp) + length(d$Ym)
        f0 <- sum(length(d$Xp)+length(d$Xm)) / (N*(hp+hm))
        plugin <- nu0*(mean(rp$sigma2)/hp+mean(rm$sigma2)/hm) / (N*f0)
    }
    names(plugin) <- "plugin"
    se <- sqrt(c(rm$var+rp$var, plugin))

    list(estimate=theta, se=se, wm=rm$w, wp=rp$w, sigma2m=rm$sigma2,
         sigma2p=rp$sigma2, eff.obs=rm$eff.obs+rp$eff.obs)
}



#' method assumes X is sorted
#' @param J number of nearest neighbors
#' @keywords internal
sigmaNN <- function(X, Y, J=3) {
    n <- length(X)
    sigma2 <- vector(length=n)

    for (k in 1:n) {
        ## d is distance to Jth neighbor, exluding oneself
        s <- max(k-J, 1):k
        d <- sort(abs(c(X[s[-length(s)]], X[k:min(k+J, n)][-1])-X[k]))[J]
        ind <- (abs(X-X[k])<=d)
        ind[k] <- FALSE                 # exclude oneself
        Jk <- sum(ind)
        sigma2[k] <- Jk/(Jk+1)*(Y[k]-mean(Y[ind]))^2
    }
    sigma2
}