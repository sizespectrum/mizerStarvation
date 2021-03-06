% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/setStarvation.R
\name{setStarvation}
\alias{setStarvation}
\title{Set starvation mortality.}
\usage{
setStarvation(params, starv_coef = 10)
}
\arguments{
\item{params}{A MizerParams object}

\item{starv_coef}{Proportionality constant for starvation mortality. the
default is \code{starv_coef = 10}, which has the effect that the instantaneous
starvation mortality (1/year) is 1 when the energy deficit is 10\% of body
weight. When \code{starv_coef = 0} there is no starvation mortality. You can
set a different value for each species by providing a vector with length
equal to the number of species in the model.}
}
\value{
A MizerParams object with starvation mortality
}
\description{
Initially, a MizerParams object set up with the mizer setup functions will
have no starvation mortality. This function returns a MizerParams object
with starvation mortality enabled, unless you set \code{starv_coef = 0}, which
will disable starvation mortality again. For the details of how starvation
mortality is modelled see \code{getStarvMort()}.
}
