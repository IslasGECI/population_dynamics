#' @export
est_beta_params <- function(mu, var) {
  alpha <- ((1 - mu) / var - 1 / mu) * mu^2
  beta <- alpha * (1 / mu - 1)
  return(params = list(alpha = alpha, beta = beta))
}

get_stochastic_fertility <- function(fertility, sd_fertility) {
  fert.stch <- rnorm(length(fertility), fertility, sd_fertility)
  fert.stoch <- ifelse(fert.stch < 0, 0, fert.stch)
  return(fert.stoch)
}

get_stochastic_survival <- function(survival, sd_survival) {
  parameter <- est_beta_params(survival, sd_survival^2)
  s.stoch <- rbeta(length(survival), parameter[["alpha"]], parameter[["beta"]])
  return(s.stoch)
}

#' @export
Survival_Fertility <- R6::R6Class("Survival_Fertility",
  public = list(
    initialize = function(fertility, survival_probability) {
      private$survival <- survival_probability
      private$fertility <- fertility
    },
    get_fertility = function() {
      return(private$fertility)
    },
    get_survival = function() {
      return(private$survival)
    }
  ),
  private = list(
    fertility = NULL,
    survival = NULL
  )
)

#' @export
Stochastic_Survival_Fertility <- R6::R6Class("Stochastic_Survival_Fertility",
  inherit = Survival_Fertility,
  public = list(
    set_standard_desviations = function(std_fertility, std_survival) {
      private$std_fertility <- std_fertility
      private$std_survival <- std_survival
    },
    get_fertility = function() {
      fertility <- get_stochastic_fertility(private$fertility, private$std_fertility)
      return(fertility)
    },
    get_survival = function() {
      survival <- get_stochastic_survival(private$survival, private$std_survival)
      return(survival)
    }
  ),
  private = list(
    std_fertility = NULL,
    std_survival = NULL
  )
)

#' @export
Monthly_Survival_Fertility <- R6::R6Class("Monthly_Survival_Fertility",
  inherit = Survival_Fertility,
  public = list(
    get_fertility = function() {
      fertility <- comprehenr::to_vec(for (f in private$fertility) rep(f / 12, 12))
      return(fertility)
    },
    get_survival = function() {
      survival <- comprehenr::to_vec(for (s in private$survival) rep(s^(1 / 12), 12))
      survival <- append(survival, rep(survival[length(survival)], 11))
      return(survival)
    }
  ),
  private = list()
)

kathryn_Survival_Fertility <- R6::R6Class("kathryn_Survival_Fertility",
  inherit = Stochastic_Survival_Fertility,
  public = list(
    get_fertility = function() {
      private$fertility <- get_stochastic_fertility(private$fertility, private$std_fertility)
      return(private$fertility)
    }
  ),
  private = list()
)
