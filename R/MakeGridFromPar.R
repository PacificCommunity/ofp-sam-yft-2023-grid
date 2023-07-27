library(condor)
library(FLR4MFCL)

execute = TRUE
if(execute)
#  session <- ssh_connect("NOUOFPCALC02")
  session <- ssh_connect("SUVOFPSUBMIT")

# Directories
proj.dir <-".."
model <- "Jitter_14dM1F0C0_50_42"
jobs.group <- "grid_m1"

dir.input <- file.path(proj.dir, model)              # doitall.sh *.frq, *.ini, *.tag, *.age_length
condor.input <- file.path(proj.dir, "condor")        # condor.sub, condor_run.sh, mfcl.cfg, mfclo64
dir.output <- file.path(proj.dir, "Mix1GridModels")  # [place to put grid models]

frq_file <- "bet.frq"
ini_file <- "bet.ini"
tag_file <- "bet.tag"
age_length_file <- "bet.age_length"
LLfisheries <- c(1, 2, 4, 7, 8, 9, 11, 12, 29, 33, 34, 35, 36, 37, 38, 39, 40, 41)

size <- c(10,20,40)
age <- c(0.5,0.75,1.0)
steep <- c(0.65,0.8,0.95)

write_doitall <- TRUE

#######################################################################################

# Create grid model directories and run if 'executable' is TRUE
for(i in 1:length(size))
{ 
  for(j in 1:length(age))
  {
    for(k in 1:length(steep))
    {
      cat("i=", i, ", j=", j, ", k=", k, "\n", sep="")
      a.label <- formatC(100*age, width=3, flag="0")
      h.label <- formatC(100*steep, width=3, flag="0")
      runname <- paste0(jobs.group, "_s", size[i], "_a", a.label[j], "_h", h.label[k])
      model.run.dir <- file.path(dir.output, jobs.group, runname)

      # create directory for model run
      if (! dir.exists(model.run.dir)) dir.create(model.run.dir, recursive = TRUE)
      file.copy(file.path(dir.input, c(frq_file, tag_file, age_length_file, "doitall.sh")), 
                model.run.dir, overwrite=TRUE)
      file.copy(file.path(condor.input, c("condor.sub", "condor_run.sh", "mfcl.cfg", "mfclo64")),
                model.run.dir, overwrite=TRUE)
      
      # Read in par file
      final_par <- finalPar(dir.input)
      txt <- readLines(final_par)
      first_year <- as.integer(txt[which(txt=="# First year in model")+1])
      par <- read.MFCLPar(final_par, first.yr=first_year)
      # steepness
      steepness(par) <- steep[k]
      # comp data weighting
      flagval(par, -(1:41), 49:50) <- size[i]
      flagval(par, -LLfisheries, 49:50) <- 2*size[i]
      
      # final_par_out <- file.path(model.run.dir, final_par)
      final_par_out <- file.path(model.run.dir, "12.par")
      write(par, final_par_out)
      
      # Temporary workaround to solve version conflict between MFCL and FLR4MFCL
      # => This block of code can be removed when FLR4MFCL is updated (~ Oct 2023)
      # Manually edit the grid parfile, following MFCL 2.2.2.0 format (vsn 1066)
      # We insert two lines of text (first year) into the middle of the parfile
      # But only do this if the first year is not already in the parfile
      txt <- readLines(final_par_out)
      if(!any(txt=="# First year in model"))
      {
        part2 <- grep("# The grouped_catch_dev_coffs flag", txt, fixed=TRUE)
        part1 <- part2 - 1
        n <- length(txt)
        txt <- c(txt[1:part1], "# First year in model", first_year, txt[part2:n])
        writeLines(txt, final_par_out)
      }

      # .age_length: age weighting
      age_l <- readLines(file.path(model.run.dir, age_length_file))
      pointer.0 <- grep("# num age length records", age_l, fixed = TRUE)
      num_age_length_records <- as.integer(age_l[pointer.0+1])
      pointer.1 <- grep("# effective sample size", age_l, fixed = TRUE)
      pointer.2 <- grep("# Year   Month   Fishery   Species", age_l, fixed = TRUE)
      pointer.3 <- pointer.2[1]
      age_l[(pointer.1+1):(pointer.3-1)] <- paste(rep(age[j], times=num_age_length_records), collapse=" ")
      writeLines(age_l, file.path(model.run.dir, age_length_file))
      
      if (write_doitall)
      {
        doitall <- c("#!/bin/sh",
                                "MFCL=./mfclo64",
                                "# -------------------------------",
                                "#  PHASE 13 - total mortality 1.0",
                                "# -------------------------------",
                                "if [ ! -f 13.par ]; then",
                                paste("  $MFCL", frq_file, "12.par 13.par -switch 3 1 1 500 1 50 -2 2 116 100"),
                                "fi",
                                "# -------------------------------",
                                "#  PHASE 14 - total mortality 3.0",
                                "# -------------------------------",                     
                                "if [ ! -f 14.par ]; then",
                                paste("  $MFCL", frq_file, "13.par 14.par -switch 3 1 1 10000 1 50 -5 2 116 300"),
                                "fi",
                                "# ------------------------",
                                "# PHASE 15 - Hessian Calcs",
                                "# ------------------------",
                                paste("  $MFCL", frq_file, "14.par junk -switch 1 1 145 1"),
                                paste("  $MFCL", frq_file, "14.par junk -switch 2 1 37 1 1 145 2"),
                                paste("  $MFCL", frq_file, "14.par junk -switch 1 1 145 4"),
                                paste("  $MFCL", frq_file, "14.par junk -switch 1 1 145 5"))
                                
        writeLines(doitall, file.path(model.run.dir, "doitall.sh"))
      }
          
      # Execute on condor
      if(execute)
        condor_submit(model.run.dir)
    }
  }
}