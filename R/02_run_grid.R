library(condor)

session <- ssh_connect("NOUOFPCALC02")

grid.dir <- "m2"

model.dirs <- dir(file.path("../grid", grid.dir), full=TRUE)

for(i in seq_along(model.dirs))
  try(condor_submit(model.dirs[i]))
