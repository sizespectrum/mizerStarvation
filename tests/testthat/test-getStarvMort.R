test_that("getStarvMort works", {
    # NS model steady state has no starvation
    params <- setStarvation(NS_params)
    zero_mort <- params@initial_n
    zero_mort[] <- 0
    sm <- zero_mort
    sm[] <- getStarvMort(params)
    expect_identical(sm, zero_mort)
    # We get starvation by setting high metabolism at single w
    params@metab[1, 30] <- 10
    sm[] <- getStarvMort(params)
    expect_gt(sm[1, 30], 0)
    # but only at this single w
    sm[1, 30] <- 0
    expect_identical(sm, zero_mort)
})

test_that("starvation mortality reduces abundance after one time step", {
    # Force an energy deficit by setting high metabolism at a single size
    params_no_starv <- NS_params
    params_no_starv@metab[1, 30] <- 10
    params_starv <- setStarvation(params_no_starv)
    # Run one time step for both
    sim_no_starv <- project(params_no_starv, t_max = 1, t_save = 1)
    sim_starv <- project(params_starv, t_max = 1, t_save = 1)
    n_no_starv <- finalN(sim_no_starv)
    n_starv <- finalN(sim_starv)
    # Starvation mortality should lead to strictly lower abundance at the size
    # with the energy deficit
    expect_lt(n_starv[1, 30], n_no_starv[1, 30])
})

test_that("getStarvMort returns correct object", {
    params <- setStarvation(NS_params)
    sm <- getStarvMort(params)
    expect_identical(dimnames(sm), 
                     dimnames(params@initial_n))
    expect_true(is.ArraySpeciesBySize(sm))
})