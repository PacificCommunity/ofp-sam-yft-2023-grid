grid_results <- function(jitter.dir, round=TRUE)
{
  # Load Shiny results
  data.dir <- file.path(jitter.dir, "shiny/app/data")
  load(file.path(data.dir, "ll_tab_data.RData"))  # ll_tab_data
  load(file.path(data.dir, "other_data.RData"))   # status_tab_dat

  # Extract results of interest
  run <- ll_tab_dat$Model[1]
  b <- which.min(ll_tab_dat$ObjFun)
  best.seed <- substring(ll_tab_dat$Model[b], nchar(ll_tab_dat$Model[b])-1)
  best.seed <- with(ll_tab_dat, substring(Model[b], nchar(Model[b])-1))
  objfun.orig <- ll_tab_dat$ObjFun[1]
  objfun.best <- ll_tab_dat$ObjFun[b]
  grad.orig <- ll_tab_dat$Gradient[1]
  grad.best <- ll_tab_dat$Gradient[b]
  instant.orig <- status_tab_dat$"Final SB/SBF0instant"[1]
  instant.best <- status_tab_dat$"Final SB/SBF0instant"[b]
  recent.orig <- status_tab_dat$"Final SB/SBF0recent"[1]
  recent.best <- status_tab_dat$"Final SB/SBF0recent"[b]
  n.improved <- sum(ll_tab_dat$ObjFun[-1] - ll_tab_dat$ObjFun[1] < 0)
  objfun.diff <- objfun.best - objfun.orig
  recent.diff <- recent.best - recent.orig

  if(round)
  {
    objfun.orig <- round(objfun.orig, 0)
    objfun.best <- round(objfun.best, 0)
    grad.orig <- round(grad.orig, 5)
    grad.best <- round(grad.best, 5)
    instant.orig <- round(instant.orig, 3)
    instant.best <- round(instant.best, 3)
    recent.orig <- round(recent.orig, 3)
    recent.best <- round(recent.best, 3)
    objfun.diff <- round(objfun.diff, 0)
    recent.diff <- round(recent.diff, 5)
  }

  # Prepare output
  out <- data.frame(run, best.seed, objfun.orig, objfun.best, grad.orig,
                    grad.best, instant.orig, instant.best, recent.orig,
                    recent.best, n.improved, objfun.diff, recent.diff)

  out
}
