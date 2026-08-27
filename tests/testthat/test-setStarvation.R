test_that("Starvation mortality is correctly set and unset", {
    params <- setStarvation(NS_params)
    expect_identical(other_mort(params)$starvation, "starvMort")
    # `$` on a species parameter table returns a vector named by species
    expect_equal(unname(species_params(params)$starv_coef), rep(10, 12))
    # `starv_coef` is recorded as user input, not as something mizer calculated
    expect_true("starv_coef" %in% names(given_species_params(params)))
    # test that extension field in metadata is set
    ext <- getMetadata(params)$extensions[["mizerStarvation"]]
    expect_identical(ext[["requirement"]], "sizespectrum/mizerStarvation")
    expect_identical(ext[["version"]],
                     as.character(utils::packageVersion("mizerStarvation")))
    # Error if starv_coef has wrong length
    expect_error(setStarvation(NS_params, starv_coef = c(1,2)),
                 "`starv_coef` must be a single number or")
    # A different coefficient for each species
    params2 <- setStarvation(NS_params, starv_coef = 1:12)
    expect_equal(unname(species_params(params2)$starv_coef), 1:12)
    # Re-applying preserves the version stamp
    params3 <- setStarvation(params, starv_coef = 5)
    expect_identical(getMetadata(params3)$extensions[["mizerStarvation"]], ext)
    # Now unset
    params <- setStarvation(params, starv_coef = 0)
    expect_equal(other_mort(params), list(), check.attributes = FALSE)
    expect_null(species_params(params)$starv_coef)
    expect_false("starv_coef" %in% names(given_species_params(params)))
    expect_false("mizerStarvation" %in% names(params@extensions))
})
