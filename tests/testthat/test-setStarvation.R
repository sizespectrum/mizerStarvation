test_that("Starvation mortality is correctly set and unset", {
    params <- setStarvation(NS_params)
    expect_identical(params@other_mort$starvation, "getStarvMort")
    expect_identical(params@species_params$starv_coef, rep(10, 12))
    # test that extension field in metadata is set
    expect_equal(getMetadata(params)$extensions[["mizerStarvation"]],
                 "sizespectrum/mizerStarvation")
    # Error if starv_coef has wrong length
    expect_error(setStarvation(NS_params, starv_coef = c(1,2)),
                 "`starv_coef` must be a single number or")
    # Now unset
    params <- setStarvation(params, starv_coef = 0)
    expect_equal(params@other_mort, list(), check.attributes = FALSE)
    expect_null(params@species_params$starv_coef)
    expect_false("mizerStarvation" %in% names(params@extensions))
})
