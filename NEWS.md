# mizerStarvation 0.2.0

- Replaced obsolete session extension registration (`registerExtension()`) with mizer's simpler S3 extension mechanism. `setStarvation()` now records the extension requirement and version directly with `recordExtension()`, and the `.onLoad()` hook has been removed.
- `setStarvation()` sets and withdraws the `starv_coef` column via `species_params<-()`.
- `starvMort()` and `getStarvMort()` gained an explicit `t` argument, passed on to `getEReproAndGrowth()`.
- Bug fix: `getStarvMort()` now uses the abundances passed to it rather than always using initial values.
