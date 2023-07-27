library(FLR4MFCL)
library(tools)  # file_path_sans_ext

template <- "14a_Five_Regions"
species <- "yft"

mix <- 2
size <- c(10, 20, 40)
age <- c(0.5, 0.75, 1.0)
steep <- c(0.65, 0.8, 0.95)

top.dir <- "../grid/m2"
model.prefix <- "14a_"

age.length.file <- paste0(species, ".age_length")
frq.file <- paste0(species, ".frq")
tag.file <- paste0("mix", mix, "/", species, ".tag")
common.files <- c("condor.sub", "condor_run.sh", "labels.tmp", "mfcl.cfg",
                  "mfclo64", age.length.file, frq.file, tag.file)
common.files <- file.path("../common", common.files)

LLfisheries <-
  c(1, 2, 4, 7, 8, 9, 11, 12, 29, 33, 34, 35, 36, 37, 38, 39, 40, 41)

################################################################################

i <- j <- k <- 1
a.label <- formatC(100*age, width=3, flag="0")
h.label <- formatC(100*steep, width=2, flag="0")

for(i in 1:length(size))
{
  for(j in 1:length(age))
  {
    for(k in 1:length(steep))
    {
      # Construct model name
      model <- paste0(model.prefix, "m", mix, "_s", size[i],
                      "_a", a.label[j], "_h", h.label[k])
      cat(model, fill=TRUE)

      # Create directory for grid member
      model.dir <- file.path(top.dir, model)
      if(dir.exists(model.dir))
        unlink(model.dir, recursive=TRUE)
      dir.create(model.dir, recursive=TRUE)
      file.copy(common.files, model.dir, copy.date=TRUE)

      # Read in template par file
      template.dir <- file.path("../template", template)
      template.parfile <- finalPar(template.dir)
      txt <- readLines(template.parfile)
      first.year <- as.integer(txt[which(txt=="# First year in model")+1])
      par <- read.MFCLPar(template.parfile, first.yr=first.year)

      # Modify par object
      # steepness
      steepness(par) <- steep[k]
      # size comp data weighting
      flagval(par, -(1:41), 49:50) <- size[i]
      flagval(par, -LLfisheries, 49:50) <- 2*size[i]

      # Write new par file
      new.parfile <- file.path(model.dir, basename(template.parfile))
      write(par, new.parfile)

      # Temporary workaround to solve version conflict between MFCL and FLR4MFCL
      # => This block of code can be removed when FLR4MFCL is updated (Oct 2023)
      # Manually edit the grid parfile, following MFCL 2.2.2.0 format (vsn 1066)
      # We insert two lines of text (first year) into the middle of the parfile
      # But only do this if the first year is not already in the parfile
      txt <- readLines(new.parfile)
      if(!any(txt == "# First year in model"))
      {
        pos2 <- grep("# The grouped_catch_dev_coffs flag", txt, fixed=TRUE)
        pos1 <- pos2 - 1
        n <- length(txt)
        txt <- c(txt[1:pos1], "# First year in model", first.year, txt[pos2:n])
        writeLines(txt, new.parfile)
      }

      # Set age data weighting
      txt <- readLines(file.path(model.dir, age.length.file))
      pos <- grep("# num age length records", txt, fixed=TRUE) + 1
      n <- as.integer(txt[pos])
      pos <- grep("# effective sample size", txt, fixed=TRUE) + 1
      txt[pos] <- paste(rep(age[j], n), collapse=" ")
      writeLines(txt, file.path(model.dir, age.length.file))

      # Write doitall
      start.par <- basename(new.parfile)
      end.par <- paste0(as.integer(file_path_sans_ext(start.par)) + 1, ".par")
      doitall <- c("#!/bin/sh", "",
                   paste("mfclo64", frq.file, start.par, end.par,
                         "-switch 2 1 1 10000 1 50 -5"))
      writeLines(doitall, file.path(model.dir, "doitall.sh"))
    }
  }
}
