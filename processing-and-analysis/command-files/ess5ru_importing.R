
##  this just clears the memory to avoid confusion with things already in memory 
rm(list=ls()) 

# Load library to read .sav format 
library(foreign)


####   Set working directory
####   The working directory should be set to the "Command Files" directory in which this script is stored.
####   In the command below, replace "<PATH TO `Command Files' DIRECTORY>" with the directory path 
####   (for the computer you are working on) to the "Command Files" directory.

setwd("<PATH TO `Command files' DIRECTORY>")

# Read the data  

data_all<-read.spss('../importable-data/ESS5RU.sav', use.value.labels = FALSE, to.data.frame= TRUE )

###  Save imported Pew data in a file called "ESS5RU.Rdata"
save(data_all, file = paste("ESS5RU.Rdata", sep = ""))

