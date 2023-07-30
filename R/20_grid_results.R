library(openxlsx)
source("utilities.R")

folders <- dir("c:/x/yft/mix2", full=TRUE)

grid.list <- lapply(folders, grid_results)
grid.tab <- do.call(rbind, grid.list)

################################################################################

write.xlsx(grid.tab, "../grid_results.xlsx")
cat("\nWrote grid_results.xlsx\n")
