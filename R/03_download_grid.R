library(condor)
options(width=160)

session <- ssh_connect("NOUOFPCALC02")

# Select Condor models that are finished
(jobs <- condor_dir(sort="dir"))
models <- jobs$dir[jobs$status=="finished"]

# Destination folders, will be created by full_download() below
folders <- file.path("//penguin/assessments/yft/2023/model_runs/stepwise",
                     models)

# Download results
for(i in seq_along(folders))
  try(condor_download(folders[i]))
