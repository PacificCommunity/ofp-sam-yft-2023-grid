suppressMessages(library(FLR4MFCL))
library(tools)  # file_path_sans_ext

template <- "14a_Five_Regions"
model.prefix <- "14a_ini_"
species <- "yft"

mix <- 2
size <- c(10, 20, 40)
age <- c(0.5, 0.75, 1.0)
steep <- c(0.65, 0.8, 0.95)

top.dir <- "../grid/m2_ini"

age.length.file <- paste0(species, ".age_length")
frq.file <- paste0(species, ".frq")
ini.file <- paste0(species, ".ini")
tag.file <- paste0("mix", mix, "/", species, ".tag")
common.files <- c("condor.sub", "condor_run.sh", "labels.tmp", "mfcl.cfg",
                  "mfclo64", age.length.file, frq.file, tag.file)
common.files <- file.path("../common", common.files)

# Specify 41 fisheries, so script can be used for BET and YFT
# The flagval() function only modifies existing flags,
# so non-existing fishery numbers are harmless
fisheries <- 1:41
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
      h.label <- formatC(100*steep, width=2, flag="0")
      model <- paste0(model.prefix, "m", mix, "_s", size[i],
                      "_a", a.label[j], "_h", h.label[k])
      cat(model, fill=TRUE)

      # Create directory for grid member
      model.dir <- file.path(top.dir, model)
      if(dir.exists(model.dir))
        unlink(model.dir, recursive=TRUE)
      dir.create(model.dir, recursive=TRUE)
      file.copy(common.files, model.dir, copy.date=TRUE)

      # Modify size and age data weighting
      doitall <- readLines(file.path("../template", template, "doitall.sh"))
      pos <- grep(" -999 49 20", doitall)
      doitall[pos] <- paste(" -999 49", size[i])
      pos <- grep(" -999 50 20", doitall)
      doitall[pos] <- paste(" -999 50", size[i])
      # divide LF & WF samples in 2 again for LL + index
      pos <- grep(" 49 40.* 50 40", doitall)
      doitall[pos] <- gsub(" 49 40", paste(" 49", 2*size[i]), doitall[pos])
      doitall[pos] <- gsub(" 50 40", paste(" 50", 2*size[i]), doitall[pos])
      writeLines(doitall, file.path(model.dir, "doitall.sh"))

      # Modify age data weighting
      txt <- readLines(file.path(model.dir, age.length.file))
      pos <- grep("# num age length records", txt) + 1
      n <- as.integer(txt[pos])
      pos <- grep("# effective sample size", txt) + 1
      txt[pos] <- paste(rep(age[j], n), collapse=" ")
      writeLines(txt, file.path(model.dir, age.length.file))

      # Modify steepness
      ini <- readLines(file.path("../template", template, ini.file))
      pos <- grep("# sv(29)", ini, fixed=TRUE) + 1
      ini[pos] <- steep[k]
      writeLines(ini, file.path(model.dir, ini.file))
    }
  }
}
