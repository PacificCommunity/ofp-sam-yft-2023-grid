td <- function(model, seed)
{
  root.dir <- "c:/x/yft/mix2"
  jitter.model <- paste0("Jitter_14c_m2_", model)
  seed.string <- formatC(seed, width=2, flag="0")
  jitter.model.seed <- paste0(jitter.model, "_", seed.string)
  file.path(root.dir, jitter.model, jitter.model.seed)  # template.dir
}

template.dir <- td("s10_a050_h80", 10); source("11a_grid_low_high_steepness.R")
template.dir <- td("s10_a075_h80", 10); source("11a_grid_low_high_steepness.R")
template.dir <- td("s10_a100_h80", 10); source("11a_grid_low_high_steepness.R")
template.dir <- td("s20_a050_h80", 10); source("11a_grid_low_high_steepness.R")
template.dir <- td("s20_a075_h80", 10); source("11a_grid_low_high_steepness.R")
template.dir <- td("s20_a100_h80", 03); source("11a_grid_low_high_steepness.R")
template.dir <- td("s40_a050_h80", 03); source("11a_grid_low_high_steepness.R")
template.dir <- td("s40_a075_h80", 18); source("11a_grid_low_high_steepness.R")
template.dir <- td("s40_a100_h80", 18); source("11a_grid_low_high_steepness.R")
