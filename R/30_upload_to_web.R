# Copy selected model files to upload grid results to web

# yft-2023-grid.zip
#   [bin]
#     mfclo64
#   [grid]
#     m1_s10_a050_h65
#     ...

# GitHub ofp-sam-yft-2023-grid/releases/download/file/yft-2023-grid-results.zip

################################################################################

library(TAF)  # file utilities

# Source and destination paths
from <- "c:/spc/full"
from.hessian <- "c:/spc/full_hessian"
to <- "c:/spc/yft-2023-grid-results"
# unlink(to, recursive=TRUE)

# Create folders
models <- dir(from, pattern="m[12]")
mkdir(file.path(to, "bin"))
mkdir(file.path(to, "grid", models))

# Copy executable
cp(file.path(from, models[1], "mfclo64"), file.path(to, "bin"))

for(i in seq_along(models))
{
  # Copy model files, including all *.par
  model.files <- c("doitall.sh", "*.par", "mfcl.cfg", "plot-final.par.rep",
                   "test_plot_output", "yft.age_length", "yft.frq", "yft.tag")
  cp(file.path(from, models[i], model.files), file.path(to, "grid", models[i]))
  # Copy Hessian files
  hessian.files <- c("dohessian_standalone.sh", "neigenvalues", "xinit.rpt",
                     "yft.var", "yft_hess_inv_diag", "yft_pos_hess_cor")
  cp(file.path(from.hessian, models[i], hessian.files),
     file.path(to, "grid", models[i]))
}

# Then produce zip file in Linux, preserving executable bit for mfclo64 and *.sh
# $ chmod 755 bin/mfclo64 grid/*/*.sh
# $ zip -rX zipfile.zip bin grid
