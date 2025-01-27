library(tidyverse)
library(testthat)
library(vdiffr)
library(ggplot2)


fertility <- c((0.745 / 3), 0.745, 2.52, 2.52, 2.52, 2.52, 1.98)
survival_probability <- c(0.46, 0.46, 0.7, 0.7, 0.7, 0.7)
initial_population <- 1629

# Project
yr_now <- 2020 # update if more data available post-2010
yr_end <- 2030 # set projection end date
interval_time <- Interval_Time$new(initial_year = yr_now, final_year = yr_end)
survival <- Survival_Fertility$new(fertility, survival_probability)
population_with_cc <- Population$new(survival)
simulator <- Runner_Population$new(population_with_cc)
simulator$run_generations(interval_time, initial_population = initial_population)

test_that("Population anualy from 2020 to 2030", {
  plotter <- Plotter_Population$new()
  p <- plotter$plot(simulator)
  expect_doppelganger("Population anualy", p)
})

interval_time <- Monthly_Interval_Time$new(initial_year = yr_now, final_year = yr_end)
survival <- Monthly_Survival_Fertility$new(fertility, survival_probability)
population <- Population$new(survival)
simulator <- Runner_Population$new(population)
simulator$run_generations(interval_time, initial_population = initial_population)

test_that("Population monthly from 2020 to 2030", {
  plotter <- Plotter_Population$new()
  p <- plotter$plot(simulator)
  expect_doppelganger("Population monthly", p)
})

capacity <- Carry_Capacity$new()
coefficients <- capacity$coefficients_model(half_capacity = initial_population)
population_with_cc <- Population$new(survival)
simulator <- Runner_Population_With_CC$new(population_with_cc, coefficients)
simulator$run_generations(interval_time, initial_population = initial_population)

test_that("Population anualy with carring capacity from 2020 to 2030", {
  plotter <- Plotter_Population$new()
  p <- plotter$plot(simulator)
  expect_doppelganger("Population anualy with carring capacity", p)
})

population_with_cc <- Population$new(survival)
harv.prop <- Annualy_Harvest$new(0.1)
simulator <- Runner_Population_With_CC_harvest$new(population_with_cc, coefficients, harv.prop)
simulator$run_generations(interval_time, initial_population = initial_population)

test_that("Population anualy with carring capacity and harvest from 2020 to 2030", {
  plotter <- Plotter_Population$new()
  p <- plotter$plot(simulator)
  expect_doppelganger("Population anualy with carring capacity and harvest", p)
})
