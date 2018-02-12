################################################################################
## PREPROCESSING SCRIPT FOR LCRPILOT
## read in data files and consolidate them
##
## ey mcf 1/14
## mod bll 6/16
################################################################################


library(ggplot2)
library(lme4)
library(stringr)
library(reshape2)
library(plyr)

## PRELIMINARIES
rm(list = ls())

source("/Users/brialong/Documents/GitHub/label-cats/analyses/HelperCode/useful.R")
source("/Users/brialong/Documents/GitHub/label-cats/analyses/HelperCode/et_helper_bll.R")

#raw.data.path <- "sanitycheck_data/"
#processed.data.filename <- "labelcats-pilot-sanity.csv"

raw.data.path <- "raw_data/all/"
processed.data.filename <- "labelcats-pilot-all.csv"

info.path <- "info/"
processed.data.path <- "processed_data/"

## LOOP TO READ IN FILES
all.data <- data.frame()
files <- dir(raw.data.path,pattern="*.txt")

for (file.name in files) {
  print(file.name)
  headerNum=34

  ## these are the two functions that are most meaningful
  d <- read.smi.idf(paste(raw.data.path,file.name,sep=""),header.rows=headerNum) #for idf converter version 3.20
  d <- preprocess.data(d)
  d$subid <- file.name
  
  ## now here's where data get bound together
  all.data <- rbind(all.data, d)
}

## WRITE DATA OUT TO CSV FOR EASY ACCESS
write.csv(all.data,paste(processed.data.path,
                         processed.data.filename,sep=""),
          row.names=FALSE) 

