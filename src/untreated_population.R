library("ggplot2")
library(popdyn)
source("R/feral_cat.R")
source("src/parameters_of_fertility_and_survival.R")
####################################################
## iterations and quasi ext for each following model
####################################################
iter <- 10000 # final model run at 10 000
itdiv <- iter / 1000 # final model rate at iter/1000
################################################################################################################
## untreated population
###############################################################################################################
## stochatic projection with density feedback
## set storage matrices & vectors

initial_population <- 1629
capacity <- Carry_Capacity$new()
coefficients <- capacity$coefficients_model(half_capacity = initial_population)
yr_now <- 2020 # update if more data available post-2010
yr_end <- 2030 # set projection end date
interval_time <- Interval_Time$new(initial_year = yr_now, final_year = yr_end)
number_year <- yr_end - yr_now + 1
n_sums_mat <- matrix(data = 0, nrow = iter, ncol = number_year)
for (simulation in seq(1, iter)) {
  survival <- Stochastic_Survival_Fertility$new(fertility, survival_probability)
  survival$set_standard_desviations(std_fertility, std_survival_probability)
  population <- Population$new(survival)
  simulator <- Runner_Population_With_CC$new(population, coefficients)
  simulator$run_generations(interval_time, initial_population = initial_population)
  n_sums_mat[simulation, ] <- colSums(simulator$n_mat) / initial_population
}

yrs <- seq(yr_now, yr_end)
n_md <- apply(n_sums_mat, MARGIN = 2, median, na.rm = T) # mean over all iterations
n_up <- apply(n_sums_mat, MARGIN = 2, quantile, probs = 0.975, na.rm = T) # upper over all iterations
n_lo <- apply(n_sums_mat, MARGIN = 2, quantile, probs = 0.025, na.rm = T) # lower over all iterations
untreated <- data.frame(yrs, n_md, n_lo, n_up)

write_csv(untreated, "reports/tables/simulation.csv")
