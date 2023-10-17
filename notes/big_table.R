library(FLR4MFCL)

get_shiny <- function(folder)
{
  load(file.path(folder, "ll_tab_data.RData"))
  like <- as.data.frame(ll_tab_dat)
  like <- like[c("Model", "ObjFun", "Gradient")]

  load(file.path(folder, "other_data.RData"))
  dep <- as.data.frame(status_tab_dat)
  dep <- dep[c("Model", "Final SB/SBF0recent")]
  names(dep)[2] <- "Depletion"

  out <- merge(like, dep)
  out
}

read <- function(x) scan(x, integer(), n=1, quiet=TRUE)

# Read results from Shiny apps
shiny1 <- "z:/yft/2023/model_runs/grid/round_3_m1_final/shiny/app/data"
shiny2 <- "z:/yft/2023/model_runs/grid/round_3_m2_final/shiny/app/data"
tab <- rbind(get_shiny(shiny1), get_shiny(shiny2))

# Read results from Hessian dirs
grid <- "z:/yft/2023/model_runs/grid/full_hessian"
neg <- dir(grid, full=TRUE)
neg <- neg[dir.exists(neg)]
neg <- file.path(neg, "neigenvalues")
neigen <- unname(sapply(neg, read))
tab$Neigen <- neigen
tab$PDH <- ifelse(neigen == 0, "Yes", "")

# Format table
x <- tab
x$ObjFun <- formatC(x$Obj, format="f", digits=2)
x$Gradient <- formatC(x$Gradient, format="f", digits=5)
x$Depletion <- formatC(x$Depletion, format="f", digits=3)

# Write table
write.table(x, "big_table.dat", quote=FALSE, row.names=FALSE)
