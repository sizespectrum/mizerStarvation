# Extension Mechanism

## Overview

The mizer package provides several routes for extending its behaviour
without editing the mizer source code. A full description of these
mechanisms is given in `vignette("extensions", package = "mizer")`. This
vignette explains which of those mechanisms mizerStarvation uses and
why.

The starvation mortality added by this package is an *additional*
mortality source that runs alongside the standard background, fishing,
and predation mortalities. It is not a replacement for any of them. This
calls for a mechanism that *adds* to the mortality rate pipeline rather
than replacing it.

## The `other_mort` mechanism

The `MizerParams` object carries a slot `other_mort`: a named list of
rate function names. During every time step,
[`getMort()`](https://sizespectrum.org/mizer/reference/getMort.html)
calls each function in this list and adds its return value to the total
per-capita mortality rate. This is the correct tool when:

- the extra mortality source is dynamical (it responds to the current
  community state at each time step), and
- it should be superimposed on the standard mortality terms rather than
  replacing them.

mizerStarvation registers its rate function into this list:

``` r
params@other_mort[["starvation"]]
#> [1] "starvMort"
```

The string `"starvMort"` is the name of the exported function
[`mizerStarvation::starvMort()`](https://sizespectrum.org/mizerStarvation/reference/getStarvMort.md).
mizer looks up this name in the package namespace at projection time, so
the function must remain exported as long as any saved model has
starvation mortality enabled.

## Storing parameters in `species_params`

The only parameter that governs starvation mortality is `starv_coef`,
one value per species. This is stored as a column of the
`species_params` data frame:

``` r
params@species_params[["starv_coef"]]
```

Using `species_params` rather than
[`other_params()`](https://sizespectrum.org/mizer/reference/setRateFunction.html)
is appropriate here because `starv_coef` varies by species. It is also
the standard place mizer uses to keep per-species biological parameters,
so it is automatically saved and restored with the `MizerParams` object.

## Recording the extension

[`setStarvation()`](https://sizespectrum.org/mizerStarvation/reference/setStarvation.md)
inserts an entry into the `params@extensions` named vector:

``` r
params@extensions[["mizerStarvation"]]
#> [1] "sizespectrum/mizerStarvation"
```

This records which extension package was used to set up the model. It
makes it possible for mizer to warn users when they try to use a saved
model in a session where mizerStarvation is not installed.

## How the pieces fit together

[`setStarvation()`](https://sizespectrum.org/mizerStarvation/reference/setStarvation.md)
sets up all three pieces in one call:

``` r
params <- setStarvation(params, starv_coef = 10)
```

Passing `starv_coef = 0` reverses the change: it removes the
`"starvation"` entry from `other_mort`, removes the `starv_coef` column
from `species_params`, and removes `"mizerStarvation"` from
`params@extensions`.

During a projection, at each time step and for each species and size
class, mizer calls
[`starvMort()`](https://sizespectrum.org/mizerStarvation/reference/getStarvMort.md):

``` r
starvMort <- function(params, n, n_pp, n_other, ...) {
    e <- getEReproAndGrowth(params, n = n, n_pp = n_pp, n_other)
    mu_s <- -t(t(e * params@species_params$starv_coef) / params@w)
    mu_s[e > 0] <- 0
    return(mu_s)
}
```

The function:

1.  Calls the standard mizer function
    [`getEReproAndGrowth()`](https://sizespectrum.org/mizer/reference/getEReproAndGrowth.html)
    to get the energy available for growth and reproduction, \\E_r(w)\\,
    at the current community state.
2.  Computes the starvation mortality rate \\\mu_s(w) =
    \frac{-E_r(w)}{w} \times \texttt{starv\\coef}\\ for size classes
    where the energy balance is negative (\\E_r \< 0\\).
3.  Sets mortality to zero for size classes with a positive energy
    balance.

The result is a species-by-size matrix with the same dimensions as
`initialN(params)`, which
[`getMort()`](https://sizespectrum.org/mizer/reference/getMort.html)
adds to the other mortality terms.

## Summary of extension points used

| Mechanism | Where | Purpose |
|----|----|----|
| `params@other_mort` | named list of rate function names | registers `starvMort` so [`getMort()`](https://sizespectrum.org/mizer/reference/getMort.html) calls it at each time step |
| `params@species_params$starv_coef` | column in species parameters | stores the per-species proportionality constant |
| `params@extensions` | named character vector | records that mizerStarvation set up this model |

This package does not use
[`setRateFunction()`](https://sizespectrum.org/mizer/reference/setRateFunction.html),
[`setComponent()`](https://sizespectrum.org/mizer/reference/setComponent.html),
[`setExtMort()`](https://sizespectrum.org/mizer/reference/setExtMort.html),
or S4 subclassing, because those mechanisms are either designed for
replacing rather than augmenting existing rates, or add more
infrastructure than this simple additive mortality term requires.
