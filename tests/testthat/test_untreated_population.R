library(comprehenr)


describe(" The function est_beta_params", {
  it("Return right answer", {
    expected <- list(alpha = NaN, beta = NaN)
    obtained <- est_beta_params(mu = 0, var = 1)
    expect_equal(expected, obtained)
  })
  it("Return right answer", {
    expected <- list(alpha = -1, beta = 0)
    obtained <- est_beta_params(mu = 1, var = 1)
    expect_equal(expected, obtained)
  })
  it("Return right answer", {
    expected <- list(alpha = -6.6, beta = 4.4)
    obtained <- est_beta_params(mu = 3, var = 5)
    expect_equal(expected, obtained)
  })
})

describe("get_stochastic_fertility", {
  it("limits are correts", {
    fertility <- c(3, 4)
    sd_fertility <- c(0.1, 0.2)
    obtained_stochastic_fertility <- get_stochastic_fertility(fertility, sd_fertility)
    all_less_than_five <- all(obtained_stochastic_fertility < 5)
    expect_true(all_less_than_five)
    all_greater_than_two <- all(obtained_stochastic_fertility > 2)
    expect_true(all_greater_than_two)
  })
})

describe("The class Survival_Fertility", {
  it("The method get_fertility works", {
    fertility <- seq(1, 4)
    survival_probability <- rbeta(3, 1, 1)
    survival <- Survival_Fertility$new(fertility, survival_probability)
    expect_equal(fertility, survival$get_fertility())
    expect_equal(survival_probability, survival$get_survival())
  })
})

describe("The class Stochastic_Survival_Fertility", {
  fertility <- seq(1, 4)
  survival_probability <- c(0.46, 0.46, 0.7)
  survival <- Stochastic_Survival_Fertility$new(fertility, survival_probability)
  std_fertility <- rbeta(4, 1, 1)
  std_survival_probability <- c(0.1150, 0.1150, 0.0575)
  survival$set_standard_desviations(std_fertility, std_survival_probability)
  it("The method get_fertility works", {
    new_fertility <- survival$get_fertility()
    are_all_different <- all(fertility != new_fertility)
    expect_true(are_all_different)
    bootstraped_mean <- to_vec(for (x in seq(1, 200)) mean(survival$get_fertility()))
    expect_equal(mean(bootstraped_mean), mean(fertility), tolerance = 1e-1)
  })
  it("The method get_survival works", {
    new_survival <- survival$get_survival()
    are_all_different <- all(survival_probability != new_survival)
    expect_true(are_all_different)
    bootstraped_mean <- to_vec(for (x in seq(1, 200)) mean(survival$get_survival()))
    expect_equal(mean(bootstraped_mean), mean(survival_probability), tolerance = 1e-2)
  })
})

get_fertlity_by_n_months <- function(n_months) {
  return(c(rep((0.745 / 3) / 12, 12), rep(2.52 / 12, n_months), rep(1.98 / 12, 12)))
}

get_survival_by_n_months <- function(n_months) {
  return(c(rep((0.46)^(1 / 12), 12), rep(0.7^(1 / 12), n_months)))
}

describe("The class Monthly_Survival_Fertility", {
  fertility <- c((0.745 / 3), 2.52, 1.98)
  survival_probability <- c(0.46, 0.7)
  survival <- Monthly_Survival_Fertility$new(fertility, survival_probability)
  it("Fertility for tree classes of age", {
    expected_monthly_fertility <- get_fertlity_by_n_months(12)
    obtained_monthly_fertility <- survival$get_fertility()
    expect_equal(expected_monthly_fertility, obtained_monthly_fertility)
  })
  it("Survival for tree classes of age", {
    expected_monthly_survival <- get_survival_by_n_months(23)
    obtained_monthly_survival <- survival$get_survival()
    expect_equal(expected_monthly_survival, obtained_monthly_survival)
  })
  fertility <- c((0.745 / 3), 2.52, 2.52, 1.98)
  survival_probability <- c(0.46, 0.7, 0.7)
  survival <- Monthly_Survival_Fertility$new(fertility, survival_probability)
  it("Fertility for four classes of age", {
    expected_monthly_fertility <- get_fertlity_by_n_months(24)
    obtained_monthly_fertility <- survival$get_fertility()
    expect_equal(expected_monthly_fertility, obtained_monthly_fertility)
  })
  it("Survival for four classes of age", {
    expected_monthly_survival <- get_survival_by_n_months(35)
    obtained_monthly_survival <- survival$get_survival()
    expect_equal(expected_monthly_survival, obtained_monthly_survival)
  })
})

get_second_comparation <- function(survival_fertility, n_times, p_value = 0.05) {
  a <- survival_fertility$get_fertility()
  for (index in seq(1, n_times)) {
    survival_fertility$get_fertility()
  }
  b <- survival_fertility$get_fertility()
  test_case_2 <- t.test(a, b)
  return(test_case_2$p.value > p_value)
}

get_first_comparation <- function(survival_fertility, p_value = 0.05) {
  a <- survival_fertility$get_fertility()
  b <- survival_fertility$get_fertility()
  test_case_1 <- t.test(a, b)
  return(test_case_1$p.value > p_value)
}

assess_are_equal <- function(survival, std_fertility, std_survival_probability) {
  survival$set_standard_desviations(std_fertility, std_survival_probability)
  is_the_same_distribution <- get_first_comparation(survival)
  expect_true(is_the_same_distribution)
}

describe("The class Kathryn_Survival_Fertility", {
  set.seed(4705)
  fertility <- rep(1, 20)
  survival_probability <- rep(0.46, 20)
  std_fertility <- rbeta(20, 1, 1)
  std_survival_probability <- rep(0.1150, 19)
  it("Compare fertility from distribution on Stochastic_Survival_Fertility", {
    survival <- Stochastic_Survival_Fertility$new(fertility, survival_probability)
    assess_are_equal(survival, std_fertility, std_survival_probability)
    is_the_same_distribution <- get_second_comparation(survival, 200)
    expect_true(is_the_same_distribution)
  })
  it("Verify that fertility change from distribution on kathryn_Survival_Fertility", {
    kathryn <- kathryn_Survival_Fertility$new(fertility, survival_probability)
    assess_are_equal(kathryn, std_fertility, std_survival_probability)
    is_the_same_distribution <- get_second_comparation(kathryn, 200)
    expect_false(is_the_same_distribution)
  })
})
