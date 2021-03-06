% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/LPP_lp.R
\name{LPPHonest.fit}
\alias{LPPHonest.fit}
\title{Honest inference at a point}
\usage{
LPPHonest.fit(d, M, kern = "triangular", h, opt.criterion,
  alpha = 0.05, beta = 0.8, se.method = "nn", J = 3,
  sclass = "H", order = 1, se.initial = "ROTEHW")
}
\arguments{
\item{d}{object of class \code{"LPPData"}}

\item{M}{Bound on second derivative of the conditional mean function.}

\item{kern}{specifies kernel function used in the local regression. It can
either be a string equal to \code{"triangular"} (\eqn{k(u)=(1-|u|)_{+}}),
\code{"epanechnikov"} (\eqn{k(u)=(3/4)(1-u^2)_{+}}), or \code{"uniform"}
(\eqn{k(u)= (|u|<1)/2}), or else a kernel function.}

\item{h}{Bandwidth. If not supplied, optimal bandwidth is computed according
to criterion given by \code{opt.criterion}.}

\item{opt.criterion}{Optimality criterion that bandwidth is designed to
    optimize. It can either be based on exact finite-sample maximum bias and
    finite-sample estimate of variance, or asymptotic approximations to the
    bias and variance. The options are:

   \describe{

   \item{\code{"MSE"}}{Finite-sample maximum MSE}

   \item{\code{"FLCI"}}{Length of (fixed-length) two-sided
       confidence intervals.}

   \item{\code{"OCI"}}{Given quantile of excess length of one-sided
       confidence intervals}

    }

    The finite-sample methods use conditional variance given by
    \code{sigma2}, if supplied. Otherwise, for the purpose of estimating the
    optimal bandwidth, conditional variance is assumed homoscedastic, and
    estimated using a nearest neighbor estimator.}

\item{alpha}{determines confidence level, \code{1-alpha} for
constructing/optimizing confidence intervals.}

\item{beta}{Determines quantile of excess length to optimize, if bandwidth
optimizes given quantile of excess length of one-sided confidence
intervals.}

\item{se.method}{Vector with methods for estimating standard error of
estimate. If \code{NULL}, standard errors are not computed. The elements of
the vector can consist of the following methods:

\describe{
    \item{"nn"}{Nearest neighbor method}

    \item{"EHW"}{Eicker-Huber-White, with residuals from local regression
    (local polynomial estimators only).}

    \item{"demeaned"}{Use EHW, but instead of using residuals, estimate
        \eqn{sigma^2_i} by subtracting the estimated intercept from the
        outcome (and not subtracting the estimated slope). Local
        polynomial estimators only.}

   \item{"plugin"}{Plug-in estimate based on asymptotic variance. Local
        polynomial estimators in RD only.}

   \item{"supplied.var"}{Use conditional variance supplied by \code{sigma2} /
        \code{d} instead of computing residuals}

}}

\item{J}{Number of nearest neighbors, if "nn" is specified in
\code{se.method}.}

\item{sclass}{Smoothness class, either \code{"T"} for Taylor or
\code{"H"} for Hölder class.}

\item{order}{Order of local regression 1 for linear, 2 for quadratic.}

\item{se.initial}{Method for estimating initial variance for computing
    optimal bandwidth. Ignored if data already contains estimate of variance.

\describe{

\item{"ROTEHW"}{Based on residuals from a local linear regression using a
             triangular kernel and ROT bandwidth}

\item{"ROTdemeaned"}{Based on sum of squared deviations of outcome from
              estimate of intercept in local linear regression with
              triangular kernel and ROT bandwidth}
}}
}
\value{
Returns an object of class \code{"LPPResults"}, see description in
    \code{\link{LPPHonest}}
}
\description{
Basic computing engine called by \code{\link{LPPHonest}} to compute honest
confidence intervals for local polynomial estimators.
}
