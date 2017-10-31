################################################################################
## IDF CONVERT
## read in data file from SMI tracker's IDF converter utility
## major issue is that new stimuli are marked as new "events" 
## need to be converted to their own column
##
## adapted from aen and dy
## edited by bll
################################################################################

read.smi.idf <- function (file.name, header.rows=35, suffix.len=4) {
  
  ## read the header from the file to paste back into the new file
  header <- scan(file.name, what = character(),
                 nlines=header.rows, sep="\n", quiet=TRUE)
  
  ## DATA CLEANING 
  # read in data and get rid of header rows
  all.d <- read.table(file.name, sep="\t", 
                      header=T, fill=T, comment.char="", skip=header.rows)
  
  ## split data into messages and data
  ## First get data:
  d <- subset(all.d, all.d$Type=="SMP")
  
  d$lx <- to.n(d$"L.POR.X..px.")
  d$rx <- to.n(d$"R.POR.X..px.")
  d$ly <- to.n(d$"L.POR.Y..px.")
  d$ry <- to.n(d$"R.POR.Y..px.")
  # added bll pupillometry
  d$pupL <- to.n(d$"L.Mapped.Diameter..mm.")
  d$pupR <- to.n(d$"R.Mapped.Diameter..mm.")
  d$confPup <- to.n(d$"Pupil.Confidence")
  d$LeyeValid <- to.n(d$"L.Validity")
  d$ReyeValid <- to.n(d$"R.Validity")
  
  #clean up d
  d <- d[,c("Time","lx","ly","rx", "ry","pupL","pupR","confPup","LeyeValid","ReyeValid")]
  names(d)[1] <- "t"
  
  ## Now get "messages" - about the stimulus that's being presented
  msgs <- subset(all.d,all.d$Type=="MSG")
  msgs <- msgs[,c("Time","L.Raw.X..px.")] ## edited BLL from L.Raw.X..px?
  names(msgs) <- c("Time","Message")
  msgs$Message <- as.character(msgs$Message)
  msgs$Stimulus <- gsub("# Message: ", "",msgs$Message)
  
  ## merge stimulus information back into d frame as a column
  d$stimulus <- sapply(d$t,
                       function(x) {
                         set <- msgs$Stimulus[msgs$Time < x]
                         set[length(set)]
                       })
  d$stimulus <- as.character(d$stimulus)
  
  ## drop the times before the first video
  d <- d[grep(".",d$stimulus,fixed=TRUE),]  
  
  ## remove (now wrong) row names
  row.names(d)<-NULL
  
  return(d)
}

################################################################################
## PREPROCESS DATA 
## take data file with l and r, x and y, as well as stimulus, average
## eyes, do whatever preprocessing needs to be done. 
################################################################################

preprocess.data <- function(d, 
                            x.max = 1920, y.max=1080, # changed bll -- didn't match current monitor
                            samp.rate = 120,
                            avg.eyes=TRUE) {
  
  ## drop the .jpg/.avi from the stimulus
  d$stimulus <- str_replace(d$stimulus,pattern=".jpg",replacement="")
  d$stimulus <- str_replace(d$stimulus,pattern=".avi",replacement="")
  
  ## average the eyes
  if (avg.eyes) {
    # round to the nearest pixel
    d$x <- round(rowMeans(d[,c("lx","rx")], na.rm=TRUE))
    d$y <- round(rowMeans(d[,c("ly","ry")], na.rm=TRUE))
    d <- d[, !(names(d) %in% c("lx","rx","ly","ry"))]
  }
  
  ## clip off out of range numbers
  d$x[d$x < 0 | d$x > x.max] <- NA
  d$y[d$y < 0 | d$y > y.max] <- NA
  
  ## Added bll june 2016
  ## exclude pupil values where we have no valid pupil measures
  d$pupL[d$confPup == 1] <- NA
  d$pupR[d$confPup == 1] <- NA
  # average L and R pupil values
  d$pupDial <- round(rowMeans(d[,c("pupL","pupR")], na.rm=TRUE))

  
  ## convert the time into seconds
  d$t <- round((d$t - d$t[1])/(1000000), 3)
  ms.increment <- c(0, diff(d$t))
  
  ## add a column of times for each video segment
  ## note this code makes me somewhat ashamed; it's slow and it abuses the R namespace
  ## because it's basically a for loop. but I don't know how to fix it. -mcf
  stim.change <- c(diff(as.numeric(factor(d$stimulus))) != 0,0)
  dt <- c(diff(d$t),0)
  t <- 0
  d$t.stim <- mapply(function (x,y) { 
    if(x==TRUE) { # if stimulus changes
      t <<- 0 # reset counter
      return(t)
    } else { # if stimulus is the same
      t <<- t + y # increment counter
      return(t)
    }},stim.change,dt)
  
  ## round to the nearest sample
  d$t.stim <- round(d$t.stim*samp.rate)/samp.rate
  
  ## y flip (so origin is cartesian, not matrix (bottom left, instead of top left)
  d$y <- y.max - d$y
  
  ## finished
  return (d)
}

################################################################################
## ROI CHECK
## takes a list of ROIs as x, y, w, h boxes
## returns ROI number or NAN
################################################################################

roi.check <- function (d, rois) {
  roi <- factor(NA,levels=names(rois))
  
  for (i in 1:length(rois)) {
    r <- rois[[i]]
    roi[d$x > r[1] & d$x < r[1] + r[3] &
          d$y > r[2] & d$y < r[2] + r[4]] <- names(rois)[i]
  }
  
  return(roi)
}

################################################################################
## REZERO TRIALS
## create timestamps starting from the point of disambiguation
################################################################################

rezero.trials <- function (d, onset.name = "targetOnset") {
	d %>% 
	group_by(stimulus, subid) %>%
	mutate(t.crit = t.stim - targetOnset)
}
################################################################################
## ROI IMAGE1
## takes a list of ROIs as x, y, w, h boxes
## makes a picture so you can check them
################################################################################

roi.image <- function (rois,y.max=1020,x.max=1920) {
  plot(NA,xlim=c(0,x.max),ylim=c(0,y.max),bty="n",xlab="x",ylab="y")
  
  for (i in 1:length(rois)) {
    r <- rois[[i]]
    rect(r[1], r[2], r[1] + r[3], r[2] + r[4])
    text(r[1] + r[3]/2,
         r[2] + r[4]/2,
         names(rois)[i])
  }
}