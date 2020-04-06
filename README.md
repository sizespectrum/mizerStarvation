
<!-- README.md is generated from README.Rmd. Please edit that file -->

# mizerStarvation

<!-- badges: start -->

<!-- badges: end -->

This is an extension package for the mizer package
(<https://sizespectrum.org/mizer/>) to implement starvation mortality.

## Installation

<!--
You can install the released version of mizerStarvation from [CRAN](https://CRAN.R-project.org) with: 

``` r 
install.packages("mizerStarvation") 
```
-->

You can install the development version of mizerStarvation from GitHub
with

``` r
devtools::install_github("sizespectrum/mizerStarvation")
```

## Example

This is an artificial example just to illustrate usage. We start with
the North Sea model that comes with the mizer package.

``` r
library(mizer)
library(mizerStarvation)
library(tidyverse)
library(ggplot2)
params <- NS_params
plotSpectra(params, power = 2)
```

<img src="man/figures/README-unnamed-chunk-2-1.png" width="100%" />

We add starvation mortality

``` r
params <- setStarvation(NS_params, 10)
```

We decrease plankton availability to create some starvation

``` r
params@cc_pp[params@w_full > 0.1] <- 0
params@initial_n_pp[params@w_full > 0.1] <- 0
```

We can calculate the starvation mortality for each species as a function
of size with `getStarvMort()`:

``` r
starv_mort <- getStarvMort(params)
```

This returns a matrix. For plotting we turn this into a data frame with
`melt()` and send it to ggplot:

``` r
ggplot(melt(starv_mort)) +
    geom_line(aes(x = w, y = value, colour = sp, linetype = sp), size = 1) +
    scale_x_log10() +
    xlab("Size [g]") +
    ylab("Starvation mortality [1/year]") +
    scale_colour_manual(values = params@linecolour) +
    scale_linetype_manual(values = params@linetype)
```

<img src="man/figures/README-unnamed-chunk-6-1.png" width="100%" />

Of course now Saithe will go extinct, not only because of the starvation
mortality but also because it stops growing before maturity.

``` r
sim <- project(params, t_max = 30)
plotBiomass(sim)
```

<img src="man/figures/README-unnamed-chunk-7-1.png" width="100%" />
