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
#' @param params A \linkS4class{MizerParams} object
#' @param n A matrix of species abundances (species x size).
#' @param n_pp A vector of the plankton abundance by size
#' @param n_other A list of abundances for other dynamical components of the
#'   ecosystem
#' @param ... Unused
#'
#' @return A two dimensional array of instantaneous starvation mortality
#'   (species x size).
#' @export
#' @md
#' @family rate functions
#'
getStarvMort <- function(params, n = params@initial_n,
                         n_pp = params@initial_n_pp,
                         n_other = params@initial_n_other,
                         ...) {

    e <- getEReproAndGrowth(params, n = n, n_pp = n_pp, n_other)
    # apply the mortality formula to the whole matrix
    mu_s <- -t(t(e * params@species_params$starv_coef) / params@w)
    mu_s[e > 0] <- 0  # No mortality when e > 0

    return(mu_s)
}
