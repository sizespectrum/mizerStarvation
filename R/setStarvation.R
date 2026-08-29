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
    params <- validParams(params)
    if (length(starv_coef) != 1 &&
        length(starv_coef) != nrow(params@species_params)) {
        stop("`starv_coef` must be a single number or a vector with one entry for each species.")
    }

    # Disable starvation mortality if starv_coef = 0
    if (all(starv_coef == 0)) {
        other_mort(params)[["starvation"]] <- NULL
        # Drop the column entirely
        species_params(params)$starv_coef <- NULL
        if (length(params$extensions) > 0 && "mizerStarvation" %in% names(params$extensions)) {
            params$extensions[["mizerStarvation"]] <- NULL
        }
        return(params)
    }

    # Set starvation mortality parameter.
    species_params(params)$starv_coef <- starv_coef

    # Hook into mizer's mortality pipeline. `other_mort()` is the accessor for
    # the extra mortality contributions that carry no state of their own, so
    # there is no need for a component with its own dynamics.
    other_mort(params)[["starvation"]] <- "starvMort"

    # Record that this extension has been applied to the object. The installed
    # package version is stamped only when the component is first created; on
    # later calls the existing stamp is preserved.
    extensions <- getMetadata(params)$extensions
    version <- if ("mizerStarvation" %in% names(extensions)) {
        NULL
    } else {
        as.character(utils::packageVersion("mizerStarvation"))
    }
    params <- mizer::recordExtension(
        params, "mizerStarvation",
        version = version,
        requirement = "sizespectrum/mizerStarvation"
    )

    params
}
