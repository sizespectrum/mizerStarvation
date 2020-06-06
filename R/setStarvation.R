#' Set starvation mortality.
#'
#' Initially, a MizerParams object set up with the mizer setup functions will
#' have no starvation mortality. This function returns a MizerParams object
#' with starvation mortality enabled, unless you set `starv_coef = 0`, which
#' will disable starvation mortality again. For the details of how starvation
#' mortality is modelled see `getStarvMort()`.
#'
#' @param params A MizerParams object
#' @param starv_coef Proportionality constant for starvation mortality. the
#'   default is `starv_coef = 10`, which has the effect that the instantaneous
#'   starvation mortality (1/year) is 1 when the energy deficit is 10% of body
#'   weight. When `starv_coef = 0` there is no starvation mortality. You can
#'   set a different value for each species by providing a vector with length
#'   equal to the number of species in the model.
#' @return A MizerParams object with starvation mortality
#' @md
#' @export
setStarvation <- function(params,
                          starv_coef = 10) {
    validObject(params)
    if (length(starv_coef) != 1 &&
        length(starv_coef) != nrow(params@species_params)) {
        stop("`starv_coef` must be a single number or a vector with one entry for each species.")
    }

    # Disable starvation mortality if starv_coef = 0
    if (all(starv_coef == 0)) {
        params@other_mort[["starvation"]] <- NULL
        params@species_params[["starv_coef"]] <- NULL
        return(params)
    }

    # Set starvation mortality rate
    params@species_params[["starv_coef"]] <- starv_coef

    # Hook into mizer
    params@other_mort[["starvation"]] <- "getStarvMort"

    return(params)
}
