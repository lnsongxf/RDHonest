## ---- include=FALSE, cache=FALSE-----------------------------------------
library("knitr")
knitr::opts_knit$set(self.contained = FALSE)
knitr::opts_chunk$set(tidy = TRUE, collapse=TRUE, comment = "#>",
                      tidy.opts=list(blank=FALSE, width.cutoff=55))

## ------------------------------------------------------------------------
library("RDHonest")
## Assumes first column in the data frame corresponds to outcome,
## and second to running variable
dl <- RDData(lee08, cutoff = 0)

## Transform earnings to log earnings
do <- RDData(data.frame(logearn=log(cghs$earnings),
                        year14=cghs$yearat14), cutoff = 1947)

## ---- fig.width=4.5, fig.height=3.5, fig.cap="Lee (2008) data"-----------
## plot 25-bin averages in for observations 50 at most points away from the cutoff.
## See Figure 1
plot_RDscatter(dl, avg=25, window = 50, xlab="Margin of victory",
    ylab="Vote share in next election")

## ---- fig.width=4.5, fig.height=3.5, fig.cap="Oreopoulos (2006) data"----
## see Figure 2
f2 <- plot_RDscatter(do, avg=Inf, xlab="Year aged 14", ylab="Log earnings",
    propdotsize=TRUE)
## Adjust size of dots if they are too big
f2 + ggplot2::scale_size_area(max_size = 4)

## ------------------------------------------------------------------------
## Usual critical value
CVb(0, alpha=0.05) # returns a list
CVb(1/2, alpha=0.05)$cv # extract critical value

## Tabulate critical values for different significance levels
## when bias-sd ratio equals 1/4
knitr::kable(CVb(1/4, alpha=c(0.01, 0.05, 0.1)), caption="Critical values")

## ------------------------------------------------------------------------
RDHonest(voteshare ~ margin, data=lee08, kern="uniform", M=0.1, hp=10, sclass="T")
RDHonest(voteshare ~ margin, data=lee08, kern="uniform", M=0.1, hp=10, sclass="H")

## ------------------------------------------------------------------------
RDHonest(voteshare ~ margin, data=lee08, kern="triangular",
    M=0.1, opt.criterion="MSE", sclass="H")
## Choose bws optimal for length of CI, allowing for different bws
## on either side of cutoff
RDHonest(voteshare ~ margin, data=lee08, kern="triangular", M=0.1,
    opt.criterion="FLCI", sclass="H", bw.equal=FALSE)

## ------------------------------------------------------------------------
RDOptBW(voteshare ~ margin, data=lee08, kern="triangular",
    M=0.1, opt.criterion="MSE", sclass="H")

## ------------------------------------------------------------------------
## Replicate Table 2, column (10)
RDHonest(log(earnings) ~ yearat14, cutoff=1947,
    data=cghs, kern="uniform", M=0.04, opt.criterion="FLCI", sclass="H")
## Triangular kernel generally gives tigher CIs
RDHonest(log(earnings) ~ yearat14, cutoff=1947,
    data=cghs, kern="triangular", M=0.04, opt.criterion="FLCI", sclass="H")

## ------------------------------------------------------------------------
## Replicate Table 2, column (6), run local linear regression (order=1)
## with a uniform kernel (other kernels are not yet implemented)
RDHonestBME(log(earnings) ~ yearat14, cutoff=1947,
    data=cghs, hp=3, order=1)

## ------------------------------------------------------------------------
2*RDHonest(voteshare ~ margin, data=lee08, kern="optimal", M=0.1, opt.criterion="FLCI", se.initial="Silverman", se.method="nn")$hl

2*RDHonest(voteshare ~ margin, data=lee08, kern="triangular", M=0.1, opt.criterion="FLCI", se.initial="Silverman", se.method="nn", sclass="T")$hl


## ------------------------------------------------------------------------
## Add variance estimate to the lee data so that the RDSmoothnessBound
## function doesn't have to compute them each time
dl <- RDHonest::RDPrelimVar(dl, se.initial="NN")

### Only use three point-average for averages of a 100 points closest to cutoff,
### and report results separately for points above and below cutoff
RDSmoothnessBound(dl, s=100, separate=TRUE, multiple=FALSE, sclass="T")

### Pool estimates based on observations below and above cutoff, and
### use three-point averages over the entire support of the running variable
RDSmoothnessBound(dl, s=100, separate=FALSE, multiple=TRUE, sclass="H")

