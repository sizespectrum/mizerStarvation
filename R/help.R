#' mizerStarvation: Starvation mortality in mizer
#'
#' This is an extension package for the mizer package
#' (https://sizespectrum.org/mizer/) to implement starvation mortality.
#'
#' @import mizer assertthat
#' @importFrom utils packageVersion
#' @name mizerStarvation
#' @aliases mizerStarvation-package
#' @md
#' @keywords internal
"_PACKAGE"

.onLoad <- function(libname, pkgname) {
    mizer::registerExtension(pkgname, requirement = "sizespectrum/mizerStarvation")
}
