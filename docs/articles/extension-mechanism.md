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

species_params(params)[["starv_coef"]]
```

Using `species_params` rather than
[`other_params()`](https://sizespectrum.org/mizer/reference/setRateFunction.html)
is appropriate here because `starv_coef` varies by species. It is also
the standard place mizer uses to keep per-species biological parameters,
so it is automatically saved and restored with the `MizerParams` object.

[`setStarvation()`](https://sizespectrum.org/mizerStarvation/reference/setStarvation.md)
writes the column with the
[`given_species_params()`](https://sizespectrum.org/mizer/reference/species_params.html)
replacement function rather than by assigning to the `species_params`
slot directly:

``` r

given_species_params(params)[["starv_coef"]] <- starv_coef
```

`starv_coef` is user input that mizer never calculates for itself, so
declaring it as a *given* species parameter records that provenance. It
then shows up in `given_species_params(params)` alongside the other
parameters the user supplied, rather than in
`calculated_species_params(params)`.

## Registering with mizer on load

When mizerStarvation is loaded, its `.onLoad` hook registers the package
with mizer:

``` r

.onLoad <- function(libname, pkgname) {
  mizer::registerExtension(pkgname, requirement = "sizespectrum/mizerStarvation")
}
```

This adds `mizerStarvation` to the session’s extension chain. The
`requirement` string is a `pak` installation spec, so mizer can install
the package automatically if it is missing. The call is idempotent:
reloading the package (e.g. via
[`devtools::load_all()`](https://devtools.r-lib.org/reference/load_all.html))
does not modify the chain a second time.

## Recording the extension in the params object

Registering the package in `.onLoad` only announces it to the *session*.
A `MizerParams` object additionally records which extensions were
actually applied to it, in its `extensions` slot:

``` r

params@extensions
#> $mizerStarvation
#>                    requirement                        version 
#> "sizespectrum/mizerStarvation"                        "0.2.0" 
```

[`setStarvation()`](https://sizespectrum.org/mizerStarvation/reference/setStarvation.md)
writes that entry with
[`mizer::recordExtension()`](https://sizespectrum.org/mizer/reference/recordExtension.html):

``` r

params <- recordExtension(params, "mizerStarvation", version = version)
```

[`recordExtension()`](https://sizespectrum.org/mizer/reference/recordExtension.html)
takes the installation requirement from the session’s registered chain,
preserves any entries other extensions have already made, and inserts
this one at the right position in the chain. This is deliberately
narrower than copying the whole of
[`getRegisteredExtensions()`](https://sizespectrum.org/mizer/reference/getRegisteredExtensions.html)
into the object: another extension package may well be loaded in the
session without having been applied to *this* model, and the slot is a
record of what was applied, not of what happened to be attached.

The `version` argument is the version of mizerStarvation whose object
layout the recorded component conforms to.
[`setStarvation()`](https://sizespectrum.org/mizerStarvation/reference/setStarvation.md)
stamps the installed version only when it first adds starvation
mortality to a model, and passes `version = NULL` on subsequent calls so
that an existing stamp is preserved. Re-stamping on an ordinary
modification would let an old object claim to be current and so skip a
migration it actually needs.

Storing this record lets mizer warn users who try to load a saved model
in a session where mizerStarvation is missing or out of date.

When starvation mortality is disabled by passing `starv_coef = 0`,
[`setStarvation()`](https://sizespectrum.org/mizerStarvation/reference/setStarvation.md)
removes the `"mizerStarvation"` entry from `params@extensions` again, so
the saved object no longer requires the package.

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

starvMort <- function(params, n, n_pp, n_other, t = 0, ...) {
    e <- getEReproAndGrowth(params, n = n, n_pp = n_pp, n_other = n_other,
                            t = t)
    starv_coef <- species_params(params)[["starv_coef"]]
    mu_s <- -t(t(e * starv_coef) / params@w)
    mu_s[e > 0] <- 0
    mu_s
}
```

[`getMort()`](https://sizespectrum.org/mizer/reference/getMort.html)
calls each `other_mort` function with `params`, `n`, `n_pp`, `n_other`,
`t` and the `component` name, so a rate function has to accept `...` to
absorb the arguments it does not use. Note that `t` is named explicitly
here and forwarded, so that starvation mortality is computed at the same
time as the rest of the mortality in models whose rates depend on time.

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
| `species_params(params)$starv_coef` | column in species parameters, written with `given_species_params<-()` | stores the per-species proportionality constant |
| `params@extensions` | named list written with [`recordExtension()`](https://sizespectrum.org/mizer/reference/recordExtension.html) | records that mizerStarvation set up this model, and under which version |

This package does not use
[`setRateFunction()`](https://sizespectrum.org/mizer/reference/setRateFunction.html),
[`setComponent()`](https://sizespectrum.org/mizer/reference/setComponent.html),
[`setExtMort()`](https://sizespectrum.org/mizer/reference/setExtMort.html),
or S4 subclassing, because those mechanisms are either designed for
replacing rather than augmenting existing rates, or add more
infrastructure than this simple additive mortality term requires.
