# Get the necessary libraries
library(car)
library(gdata)
library(foreign)


####   Set working directory
####   The working directory should be set to the "Command files" directory in which this script is stored.
####   In the command below, replace "<PATH TO `Command files' DIRECTORY>" with the directory path (for the computer you are
####   working on) to the "Command files" directory.

setwd("<PATH TO `Command files' DIRECTORY>")

###  load ESS5RU


load("ESS5RU.Rdata")

# Get rid of the useless vaqriables
data<-data.frame(data_all[, c( "idno", "stfeco", "trstprl", "trstlgl", "trstplc", "trstplt", 
                               "trstprt", "ppltrst", "agea", "eisced", "gndr", "wrkorg", 
                               "netuse", "polintr", "vote", "prtvtbru","prtclbru", "domicil" )])
attach(data)

# RECODING VARIABLES. 
# id - id number
data<-rename.vars(data, "idno", "id", info=FALSE)

#stfecon Satisfaction with economy : 0 low - 10 high 
data<-rename.vars(data, "stfeco", "stfecon", info=FALSE)

#trstprl Trust in Parliament : 0 low - 10 high 
#trstlgl Trust in Legal System : 0 low - 10 high 
#trstplc Trust in Police : 0 low - 10 high 
#trstplt Trust in Politicians : 0 low - 10 high 
#trstprt Trust in Parties : 0 low - 10 high 
#trstppl Trust in other people : 0 low - 10 high 
data<-rename.vars(data, "ppltrst", "trstppl", info=FALSE)

#agecat Age - categorical 
data$agecat<-recode(agea,"0:25=1; 26:34=2; 35:40=3; 41:60=4; 61:71=5; 72:hi=6; else=NA")

#educat Education - categorical : 1 university - 2 secondary - 3 primary school
data$educat<-recode(eisced, "1:2='3'; 4='2'; 5:7='1'; else='NA'") 

#edusecon Education: secondary - dummy
data$edusecon<-recode(data$educat, "1='0'; 2='1'; 3='0'")

#eduprima Education: primary - dummy
data$eduprima<-recode(data$educat, "1:2='0'; 3='1'")

#male Male - dummy
data$male<-recode(data$gndr, "2='0'")

#workorg Working for social organisations in the last 12 months - dummy
data$workorg<-recode(data$wrkorg, "2='0'")

#internet Frequent internet-user - several times a week or daily - dummy
data$internet<-recode(data$netuse, "0:5='0'; 6:7='1'")

#polintr Interest in politics - dummy
data$polintr<-recode(data$polintr, "1:2='1'; 3:4='0'")

#voted Voted in last elections - dummy
data$voted<-recode(data$vote, "2=0; 3=NA")

# votedur Voted for the United Russia party : dummy (zero if voted but not for UR or did not vote, 
# NA if voting or which party is NA)
data$votedur<-ifelse(data$voted==1, data$votedur<-recode(data$prtvtbru, "1=1; NA=NA; else=0"),
                     ifelse(is.na(data$voted), data$votedur<-NA, 
                            data$votedur<-0))

#partyur Feels close to the United Russia party
data$partyur<-recode(data$prtclbru, "1=1; NA=NA; else=0")

#domicat Domicile - categorical: 1 - big city and its suburbs, 2 - small cities, 3 - villages
data$domicat<-recode(data$domicil, "1:2=1; 3=2; 4:5=3")

#town Domicile: living in a town - dummy
data$town<-recode(data$domicat, "2=1; 1=0; 3=0")

#vilg Domicile: living in a village - dummy 
data$vilg<-recode(data$domicat, "3=1; 1:2=0")

# remove variables: gndr, eisced, netuse, wrkorg, towntype, vote
data<-remove.vars(data, c("gndr", "eisced", "netuse", "wrkorg", "domicil", "vote", "prtvtbru",
	"prtclbru"),info=FALSE )

# remove variables which were recoded: agecat, educat, domicat
data_mplus<-remove.vars(data, c("agecat", "educat", "domicat"), info=FALSE)

# export a data set for the analysis in MPLUS 

# this creates file with variable names. 
cat(names(data_mplus), file = paste(AnalysisData, "/datamplus.var", sep = ""))

# this creates file with the data itself
# strange solution with cbinding is to avoid "" around rownames. 
write.table(cbind(1:nrow(data_mplus), data_mplus), 
		file = paste(AnalysisData, "/datamplus.dat", sep = ""), 
		sep ="\t", na="99", col.names = FALSE, row.names = FALSE)


# After running M-Plus code, load exported data set and process it into Analysis Data folder. 
# The data from M-Plus is already saved in the folder to ensure reproducability even without 
# an M-Plus licence. 

data_out <- read.table("../analysis-data/ess5ru_from_mplus.txt", quote="\"", na.strings = "*")

save(data_out, file = paste(AnalysisData, "/ESS5RU_clean.Rdata", sep = ""))


#Remove ESS5RU.Rdata from the "Command Files" folder
file.remove("ESS5RU.Rdata")