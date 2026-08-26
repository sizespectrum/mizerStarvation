# Changelog

## mizerStarvation 0.2.0

Updated to the conventions of mizer 3.3.0, which is now the minimum
required version.

- [`setStarvation()`](https://sizespectrum.org/mizerStarvation/reference/setStarvation.md)
  now records the extension on the params object with
  [`mizer::recordExtension()`](https://sizespectrum.org/mizer/reference/recordExtension.html)
  instead of copying the whole session-wide chain returned by
  [`getRegisteredExtensions()`](https://sizespectrum.org/mizer/reference/getRegisteredExtensions.html)
  into the `extensions` slot. The slot therefore lists only the
  extensions actually applied to the model, and each entry carries both
  the installation requirement and the version of mizerStarvation that
  the model conforms to. Code reading
  `params@extensions[["mizerStarvation"]]` now gets a named character
  vector with `requirement` and `version` entries rather than a bare
  requirement string.
- [`setStarvation()`](https://sizespectrum.org/mizerStarvation/reference/setStarvation.md)
  writes `starv_coef` with `given_species_params<-()` so that it is
  recorded as user input, and validates and upgrades its argument with
  [`validParams()`](https://sizespectrum.org/mizer/reference/validParams.html)
  rather than only calling
  [`validObject()`](https://rdrr.io/r/methods/validObject.html).
- [`starvMort()`](https://sizespectrum.org/mizerStarvation/reference/getStarvMort.md)
  and
  [`getStarvMort()`](https://sizespectrum.org/mizerStarvation/reference/getStarvMort.md)
  gained an explicit `t` argument, which is passed on to
  [`getEReproAndGrowth()`](https://sizespectrum.org/mizer/reference/getEReproAndGrowth.html).
  Previously the time was silently dropped, so starvation mortality was
  evaluated at `t = 0` in models with time-dependent rates.
- Bug fix:
  [`getStarvMort()`](https://sizespectrum.org/mizerStarvation/reference/getStarvMort.md)
  ignored the `n`, `n_pp` and `n_other` arguments it was given and
  always used the initial values stored in the params object. It now
  uses the abundances passed to it. Calls that relied on the defaults
  are unaffected.
