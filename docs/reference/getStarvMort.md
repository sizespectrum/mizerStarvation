# Get starvation mortality

There is no starvation mortality as long as the energy income rate
\\E_r\\ is positive. For details of this rate see
[`mizer::getEReproAndGrowth()`](https://sizespectrum.org/mizer/reference/getEReproAndGrowth.html).
Once this rate is negative, the per-capita mortality is proportional to
this rate and inversely proportional to body weight (and therefore also
lipid reserves): \$\$\mu_s(w) = \frac{-E_r(w)}{w} {\tt starv\\coeff}
\$\$ The proportionality constant `starv_coeff` is set with
[`setStarvation()`](https://sizespectrum.org/mizerStarvation/reference/setStarvation.md).

## Usage

``` r
getStarvMort(
  params,
  n = params@initial_n,
  n_pp = params@initial_n_pp,
  n_other = params@initial_n_other,
  ...
)

starvMort(params, n, n_pp, n_other, ...)
```

## Arguments

- params:

  A
  [MizerParams](https://sizespectrum.org/mizer/reference/MizerParams-class.html)
  object

- n:

  A matrix of species abundances (species x size).

- n_pp:

  A vector of the plankton abundance by size

- n_other:

  A list of abundances for other dynamical components of the ecosystem

- ...:

  Unused

## Value

A two dimensional array of instantaneous starvation mortality (species x
size).
