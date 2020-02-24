#' Set starvation mortality
#'
#' @param params A MizerParams object
#' @param starv_coef Proportionality constant for starvation mortality. When
#'   `starv_coef` is equal to 10 the instantaneous starvation mortality (1/year)
#'   is 1 when energy deficit is 10% of body weight. When `starv_coef = 0` there
#'   is no starvation mortality
#' @return A MizerParams object with starvation mortality
#' @md
#' @export
setStarvation <- function(params,
                          starv_coef = 10) {
    validObject(params)

    # Set starvation mortality rate
    params@species_params[["starv_coef"]] <- starv_coef

    # Hook into mizer
    params@other_mort[["starvation"]] <- "getStarvMort"

    return(params)
}
