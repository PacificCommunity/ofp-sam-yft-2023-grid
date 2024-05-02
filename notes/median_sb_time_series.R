# Tabulate median biomass
# History: 2024-05-02 arnim created, responding to WCPFC request

library(TAF)
library(FLR4MFCL)

if(!dir.exists("../grid"))
{
  stop("../grid results not found, please download from\n",
       "https://github.com/PacificCommunity/ofp-sam-yft-2023-grid")
}

# Grid models
model.dirs <- dir("../grid", full=TRUE)
models <- basename(model.dirs)
repfiles <- file.path(model.dirs, "plot-final.par.rep")

# Read results
message("Reading rep files:")
rep <- sb <- list()
for(i in seq_along(repfiles))
{
  rep[i] <- sapply(repfiles[i], read.MFCLRep)
  sb[i] <- SB(rep[i])
  message(i)
}
message("done")
names(rep) <- names(sb) <- models

# Calculate SB median
sb.matrix <- sapply(sb, drop)
sb.median <- apply(sb.matrix, 1, median)
median.sb.time.series <-
  data.frame(Year=as.integer(names(sb.median)), SB=sb.median)

# Write table
write.taf(median.sb.time.series)

plot(median.sb.time.series$Year, median.sb.time.series$SB/1e3,
     ylim=lim(median.sb.time.series/1e3), type="l", xlab="Year", ylab="SB",
     panel.first=grid())
