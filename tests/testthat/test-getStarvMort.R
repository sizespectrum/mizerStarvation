test_that("getStarvMort works", {
    # NS model steady state has no starvation
    params <- setStarvation(NS_params)
    zero_mort <- params@initial_n
    zero_mort[] <- 0
    expect_identical(getStarvMort(params), zero_mort)
    # We get starvation by setting high metabolism at single w
    params@metab[1, 30] <- 10
    sm <- getStarvMort(params)
    expect_gt(sm[1, 30], 0)
    # but only at this single w
    sm[1, 30] <- 0
    expect_identical(sm, zero_mort)
})
