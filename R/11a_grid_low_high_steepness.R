suppressMessages(library(FLR4MFCL))
library(tools)  # file_path_sans_ext

# template.dir <- "c:/x/yft/mix2/Jitter_14c_m2_s10_a050_h80/Jitter_14c_m2_s10_a050_h80_10"

species <- "yft"
mix <- as.integer(gsub(".*_m([0-9])_.*", "\\1", template.dir))
steep <- c(0.65, 0.95)
memory <- "small"

top.dir <- paste0("../grid/steepness")

age.length.file <- paste0(species, ".age_length")  # from template, not common
frq.file <- paste0(species, ".frq")
tag.file <- paste0("mix", mix, "/", species, ".tag")
mfcl.cfg <- file.path(paste0("memory_", memory), "mfcl.cfg")
condor.sub <- file.path(paste0("memory_", memory), "condor.sub")
common.files <- c(condor.sub, "condor_run.sh", "labels.tmp", mfcl.cfg,
                  "mfclo64", frq.file, tag.file)
common.files <- file.path("../common", common.files)

# Specify 41 fisheries, so script can be used for BET and YFT
# The flagval() function only modifies existing flags,
# so non-existing fishery numbers are harmless
fisheries <- 1:41
LLfisheries <-
  c(1, 2, 4, 7, 8, 9, 11, 12, 29, 33, 34, 35, 36, 37, 38, 39, 40, 41)

################################################################################

# Read in template par file
template.parfile <- finalPar(template.dir)
txt <- readLines(template.parfile)
first.year <- as.integer(txt[grep("# First year in model", txt) + 1])
cat("* Studying template", template.parfile, "... ")
par <- read.MFCLPar(template.parfile, first.yr=first.year)
cat("done\n")

for(k in 1:length(steep))
{
  # Construct model name
  h.label <- formatC(100*steep, width=2, flag="0")
  model <- gsub("_h80", paste0("_h", h.label[k]), template.dir)
  model <- basename(model)
  cat(model, fill=TRUE)

  # Create directory for grid member
  model.dir <- file.path(top.dir, model)
  if(dir.exists(model.dir))
    unlink(model.dir, recursive=TRUE)
  dir.create(model.dir, recursive=TRUE)
  file.copy(common.files, model.dir, copy.date=TRUE)

  # Modify par object
  # steepness
  steepness(par) <- steep[k]
  # write new par file
  new.parfile <- file.path(model.dir, basename(template.parfile))
  write(par, new.parfile)

  # Repair new par file
  # Temporary workaround to solve version conflict between MFCL and FLR4MFCL
  # => This block of code can be removed when FLR4MFCL is updated (Oct 2023)
  # Manually edit the grid parfile, following MFCL 2.2.2.0 format (vsn 1066)
  # We insert two lines of text (first year) into the middle of the parfile
  # But only do this if the first year is not already in the parfile
  txt <- readLines(new.parfile)
  if(!any(grepl("# First year in model", txt)))
  {
    pos2 <- grep("# The grouped_catch_dev_coffs flag", txt)
    pos1 <- pos2 - 1
    n <- length(txt)
    txt <- c(txt[1:pos1], "# First year in model", first.year, txt[pos2:n])
    writeLines(txt, new.parfile)
  }

  # Use same age data weighting as template model
  file.copy(file.path(template.dir, age.length.file),
            file.path(model.dir, age.length.file), copy.date=TRUE)

  # Create generic doitall
  start.par <- basename(new.parfile)
  end.par <- paste0(as.integer(file_path_sans_ext(start.par)) + 1, ".par")
  doitall <- c("#!/bin/sh", "",
               paste("mfclo64", frq.file, start.par, end.par,
                     "-switch 2 1 1 10000 1 50 -5"))
  writeLines(doitall, file.path(model.dir, "doitall.sh"))
}
