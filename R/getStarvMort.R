#' Get starvation mortality
#'
#' There is no starvation mortality as long as the energy income rate
#' \eqn{E_r} is positive. For details of this rate see
#' `mizer::getEReproAndGrowth()`. Once this rate is negative, the per-capita
#' mortality is proportional to this rate and inversely proportional to body
#' weight (and therefore also lipid reserves):
#' \deqn{\mu_s(w) = \frac{-E_r(w)}{w} {\tt starv\_coeff} }{mu_s(w) = -E_r(w)/w * starv_coeff}
#' The proportionality constant `starv_coeff` is set with `setStarvation()`.
#'
#' @param params A [MizerParams] object
#' @param n A matrix of species abundances (species x size).
#' @param n_pp A vector of the plankton abundance by size
#' @param n_other A list of abundances for other dynamical components of the
#'   ecosystem
#' @param t The time for which to do the calculation. Defaults to 0.
#' @param ... Unused
#'
#' @return A two dimensional array of instantaneous starvation mortality
#'   (species x size).
#' @export
#' @md
#' @family rate functions
#'
getStarvMort <- function(params, n = initialN(params),
                         n_pp = initialNResource(params),
                         n_other = initialNOther(params),
                         t = 0,
                         ...) {
    params <- validParams(params)
    assert_that(is.array(n),
                is.numeric(n_pp),
                is.list(n_other),
                identical(dim(n), dim(params@initial_n)),
                identical(length(n_pp), length(params@initial_n_pp)),
                identical(length(n_other), length(params@initial_n_other))
    )
    starv_mort <- starvMort(params, n = n, n_pp = n_pp, n_other = n_other,
                            t = t)
    ArraySpeciesBySize(starv_mort, value_name = "Starvation mortality",
                       units = "1/year", params = params)
}

#' @rdname getStarvMort
#' @export
starvMort <- function(params, n, n_pp, n_other, t = 0, ...) {
    e <- getEReproAndGrowth(params, n = n, n_pp = n_pp, n_other = n_other,
                            t = t)
    # apply the mortality formula to the whole matrix
    starv_coef <- species_params(params)[["starv_coef"]]
    mu_s <- -t(t(e * starv_coef) / params@w)
    mu_s[e > 0] <- 0  # No mortality when e > 0

    mu_s
}
