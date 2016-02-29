#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Script File: BD4Cancer_ReadPMCdataset.R  
# Date of creation: 18 Feb 2016
# Date of last modification: 20 Feb 2016
# Author: Seraya Maouche <seraya.maouche@iscb.org>
# Project: Epidemium BD4Cancer (http://www.epidemium.cc)
# Short Description: This script provides functionalities to read and all
#                    PMC dataset provided by Epidemium 
#                    The script will generates a summary file and create a 
#                    corpus from all XML files
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

library(R.utils)
requiredPackages <- c("XML","tm","SnowballC","RColorBrewer","ggplot2","NLP",
                      "wordcloud","biclust","cluster","igraph","fpc")
                      
#install.packages(requiredPackages,repos="http://cran.r-project.org", dependencies=TRUE)

################ Load required packages
lapply(requiredPackages, require, character.only=TRUE)


DataDir <- "/home/s_maouche/BD4Cancer/data/PMC"
ResDir <- "/home/s_maouche/BD4Cancer/results/"
setwd(DataDir)
Files <- c(dir(DataDir))
length(Files)
summary(Files)

# Generate a summary file with number of file in each of the 3602 directories
FileSummary <- data.frame()
for (i in 1:length(Files)) {
    Files[i]
    path <- paste(DataDir, Files[i], sep="/") 
    setwd(path)
    NumberOfFiles <- length(c(dir(path)))
    tmp <- cbind(Journal= Files[i],NumberOfFiles)
    FileSummary <- rbind(FileSummary,tmp)
}

head(FileSummary)
setwd(ResDir)
write.table(FileSummary, file="PMCdatasetSummary.txt", sep="\t")
png(file = "plot.png", bg = "transparent")
hist(as.numeric(FileSummary$NumberOfFiles))
sumFiles <- sum(as.numeric(FileSummary$NumberOfFiles))
dev.off()

# Create a corpus from all XML files
PMCcorpus <- list()
for (i in 1:length(Files)) {
    path <- paste(DataDir, Files[i], sep="/")
    setwd(path)
    lengthDir <- length(dir(path)) 
    fname   <- file.path(path)
    dir(fname)
    docs <- Corpus(DirSource(fname))
    PMCcorpus <- mergeLists(PMCcorpus, docs)
}
setwd(ResDir)
save(PMCcorpus, "PMCcorpus.RData")






