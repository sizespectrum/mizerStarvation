#' Get starvation mortality
#'
#' Calculates starvation mortality based on the equation in the original mizer
#' vignette. Starvation mortality is proportional to the energy deficiency and
#' is inversely proportional to body weight (and therefore also lipid reserves).
#' \eqn{\mu_s(w)} The weight proportionality constant is currently set to 0.1,
#' but could be a separate parameter. The 0.1 constant means that the
#' instantaneous starvation mortality is 1 when energy deficit is equal
#' individual's body mass.
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
#' @note   The default value of starv_coef is 10, which scales how energy intake
#'   deficit (e) translates to starvation mortality. When instantaneous energy
#'   intake rate deficit per year is 10% of body weight it will give
#'   instantaneous starvation mortality rate of 1/year, i.e. an average
#'   individual can survive for about a year. If starv_coef = 0, there is no
#'   starvation mortality and negative intake just gets converted to 0 (there is
#'   no cost to having negative energy intake, which is unrealistic!). If
#'   starv_coef = 20, the cost of negative intake increases, and 10% energy
#'   deficit will lead to instantaneous starvation mortality of 2/year.
#' @export
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
