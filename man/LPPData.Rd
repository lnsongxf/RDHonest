% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{LPPData}
\alias{LPPData}
\title{Class Constructor for \code{"LPPData"}}
\usage{
LPPData(d, point)
}
\arguments{
\item{d}{data frame with first column corresponding to outcome variable,
second column corresponding to independent variable and optionally a column
called \code{"(sigma2)"} that corresponds to the conditional variance of
the outcome (or an estimate of the conditional variance)}

\item{point}{specifies the point at which to calculate conditional mean}
}
\value{
An object of class \code{"LPPData"}, which is a list containing the
    following components:

    \describe{

    \item{Y}{Outcome vector}

    \item{X}{Independent variable}

    \item{sigma2}{Conditional variance of outcome}

    \item{orig.point}{Original point}

    item{var.names}{Names of outcome and independent variable in supplied data frame}

    }
}
\description{
Convert data to standardized format for use with low-level functions. If the
point for which to do inference is non-zero, shift the independent variable so
that it is at zero.
}
\examples{

## Transform Lee data
d <- RDData(lee08[lee08$margin>0, ], cutoff=0)
}
