suppressMessages(library(FLR4MFCL))
library(tools)  # file_path_sans_ext

template <- "14c_M_Growth_Phase_Eleven"
model.prefix <- "14c_"
species <- "yft"

mix <- 2
size <- c(10, 20, 40)
age <- c(0.5, 0.75, 1.0)
steep <- c(0.65, 0.8, 0.95)

top.dir <- "../grid/m2"

age.length.file <- paste0(species, ".age_length")
frq.file <- paste0(species, ".frq")
tag.file <- paste0("mix", mix, "/", species, ".tag")
common.files <- c("condor.sub", "condor_run.sh", "labels.tmp", "mfcl.cfg",
                  "mfclo64", age.length.file, frq.file, tag.file)
common.files <- file.path("../common", common.files)

LLfisheries <-
  c(1, 2, 4, 7, 8, 9, 11, 12, 29, 33, 34, 35, 36, 37, 38, 39, 40, 41)

################################################################################

i <- j <- k <- 1  # to quickly step through the code
for(i in 1:length(size))
{
  for(j in 1:length(age))
  {
    for(k in 1:length(steep))
    {
      # Construct model name
      a.label <- formatC(100*age, width=3, flag="0")
      h.label <- formatC(100*steep, width=3, flag="0")
      runname <- paste0(jobs.group, "_s", size[i], "_a", a.label[j], "_h", h.label[k])
      model.run.dir <- file.path(dir.output, jobs.group, runname)

      # create directory for model run
      if (! dir.exists(model.run.dir)) dir.create(model.run.dir, recursive = TRUE)
      file.copy(file.path(dir.input, c(frq_file, ini_file, tag_file, age_length_file, "doitall.sh")),
                model.run.dir, overwrite=TRUE)
      file.copy(file.path(dir.input, c("condor.sub", "condor_run.sh", "mfcl.cfg", "mfclo64")),
                model.run.dir, overwrite=TRUE)

      # doitall.sh: size weight, age weight, Hessian
      doitall <- readLines(file.path(model.run.dir, "doitall.sh"), warn = FALSE)
      pointer <- grep(" -999 49 20", doitall, fixed = TRUE)
      doitall[pointer] <- paste(" -999 49", size[i],"      # divide LF sample sizes by 20 (default=10)")
      pointer <- grep(" -999 50 20", doitall, fixed = TRUE)
      doitall[pointer] <- paste(" -999 50", size[i],"      # divide WF sample sizes by 20 (default=10)")
      # divide LF & WF samples in 2 again for LL + index
      pointer <- grep(" 49 40", doitall, fixed = TRUE)
      doitall[pointer] <- gsub(" 49 40", paste(" 49", 2*size[i]), doitall[pointer])
      pointer <- grep(" 50 40", doitall, fixed = TRUE)
      doitall[pointer] <- gsub(" 50 40", paste(" 50", 2*size[i]), doitall[pointer])

      # .age_length: age weighting
      age_l <- readLines(file.path(model.run.dir, age_length_file))
      pointer.0 <- grep("# num age length records", age_l, fixed = TRUE)
      num_age_length_records <- as.integer(age_l[pointer.0+1])
      pointer.1 <- grep("# effective sample size", age_l, fixed = TRUE)
      pointer.2 <- grep("# Year   Month   Fishery   Species", age_l, fixed = TRUE)
      pointer.3 <- pointer.2[1]
      age_l[(pointer.1+1):(pointer.3-1)] <- paste(rep(age[j], times=num_age_length_records), collapse=" ")
      writeLines(age_l, file.path(model.run.dir, age_length_file))

      # ini: steepness
      ini <- readLines(file.path(model.run.dir, ini_file))
      pointer.h1 <- grep("# sv(29)", ini, fixed = TRUE)
      pointer.h2 <- grep("# Generic SD of length at age", ini, fixed = TRUE)
      ini[(pointer.h1+1):(pointer.h2-1)] <- steep[k]
      writeLines(ini, file.path(model.run.dir, ini_file))
    }
  }
}
