# Set starvation mortality.

Initially, a MizerParams object set up with the mizer setup functions
will have no starvation mortality. This function returns a MizerParams
object with starvation mortality enabled, unless you set
`starv_coef = 0`, which will disable starvation mortality again. For the
details of how starvation mortality is modelled see
[`getStarvMort()`](https://sizespectrum.org/mizerStarvation/reference/getStarvMort.md).

## Usage

``` r
setStarvation(params, starv_coef = 10)
```

## Arguments

- params:

  A MizerParams object

- starv_coef:

  Proportionality constant for starvation mortality. the default is
  `starv_coef = 10`, which has the effect that the instantaneous
  starvation mortality (1/year) is 1 when the energy deficit is 10% of
  body weight. When `starv_coef = 0` there is no starvation mortality.
  You can set a different value for each species by providing a vector
  with length equal to the number of species in the model.

## Value

A MizerParams object with starvation mortality
