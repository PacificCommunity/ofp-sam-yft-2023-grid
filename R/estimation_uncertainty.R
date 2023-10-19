# Calculate and write out estimation_uncertainty.csv table
# History: 2023-08-11 thomast created, including plots for assessment report
#          2023-10-19 arnim streamlined to produce just the table

library(FLR4MFCL)

species <- "yft"
n <- 1000
set.seed(1134)

if(!dir.exists("../grid"))
{
  stop("../grid results not found, please download from\n",
       "https://github.com/PacificCommunity/ofp-sam-yft-2023-grid")
}

# Grid models
model.dirs <- dir("../grid", full=TRUE)
models <- basename(model.dirs)

# Reference point estimates and standard errors
est <- sapply(file.path(model.dirs, paste0(species, ".var")), read.MFCLVar)
est <- as.data.frame(t(est))
row.names(est) <- NULL

# Apply estimation uncertainty
refarray <- array(NA_real_, dim=c(n, nrow(est), 3),
                  dimnames=list(NULL, NULL, c("depletion", "ffmsy", "sbsbmsy")))
for(i in 1:length(models))
{
  refarray[,i,"depletion"] <- rnorm(n=n, mean=est$log.sbsbfo[i],
                                    sd=est$log.sbsbfo.se[i])
  refarray[,i,"ffmsy"] <- rnorm(n=n, mean=est$ffmsy[i],
                                sd=est$ffmsy.se[i])
  refarray[,i,"sbsbmsy"] <- rnorm(n=n, mean=est$sbsbmsy[i],
                                  sd=est$sbsbmsy.se[i])
}
depletion <- exp(refarray[,,"depletion"])
ffmsy <- refarray[,,"ffmsy"]
sbsbmsy <- refarray[,,"sbsbmsy"]

# Mean and quantiles
probs <- c(0.5, 0.0, 0.1, 0.9, 1.0)
uncertainty <- data.frame(
  depletion=c(mean(depletion), quantile(depletion, probs)),
  ffmsy=c(mean(ffmsy), quantile(ffmsy, probs)),
  sbsbmsy=c(mean(sbsbmsy), quantile(sbsbmsy, probs)))
row.names(uncertainty) <- c("Mean", "Median", "Min", "10%ile", "90%ile", "Max")
uncertainty <- data.frame(Refpt=names(uncertainty), t(uncertainty),
                          row.names=NULL, check.names=FALSE)
write.csv(uncertainty, "estimation_uncertainty.csv", row.names=FALSE)
