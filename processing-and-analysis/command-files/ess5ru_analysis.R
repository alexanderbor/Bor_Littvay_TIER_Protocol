library(ggplot2)
library(stargazer)
std <- function(x) sd(x)/sqrt(length(x))

set.seed(13012)

####   Set working directory
####   The working directory should be set to the "Command files" directory in which this script is stored.
####   In the command below, replace "<PATH TO `Command files' DIRECTORY>" with the directory path (for the computer you are
####   working on) to the "Command files" directory.

setwd("<PATH TO `Command files' DIRECTORY>")

###  load dataset

load("../Analysis Data/ESS5RU_clean.Rdata")


#update column names from M PLUS code 
colnames(data_out)<-c("TRSTPRL", "TRSTLGL", "TRSTPLC", "TRSTPLT", "TRSTPRT", 
                      "PARTYUR", "STFECON", "AGEA", "EDUSECON", "EDUPRIMA", 
                      "MALE", "WORKORG", "TRSTPPL", "POLINTR", "INTERNET", 
                      "VOTED", "TOWN", "VILG", "ID", "TR", "C_TR", "CPROB1", 
                      "CPROB2", "C")

# rescale trust index to original 0 - 10 scale
data_out$TR <- (data_out$TR - min(data_out$TR)) / (-min(data_out$TR) + max(data_out$TR)) * 10

###############################################
# Descriptive statistics - Preliminary analysis 
###############################################

# GENERATIONS 

# create variable with generations
data_out$AGEGEN<-recode(data_out$AGEA, "0:25='1'; 26:34='2'; 35:40='3'; 41:60='4'; 61:71='5'; 72:hi='6'; else='NA'")
data_out$AGEGEN <- factor(data_out$AGEGEN, 
                          labels = c("Putin's (18-25)", "Yeltsin's (25-34)",
                                     "Gorbachev's (35-40)", "Brezhnev's (41-60)",
                                     "Khruschev's (61-71)", "Stalin's (72- )"))

# calculate mean and standard error for each group 
a<-tapply(data_out$TR, data_out$AGEGEN, mean)
b<-tapply(data_out$TR, data_out$AGEGEN, std)*2
ab <- factor(levels(data_out$AGEGEN), levels = levels(data_out$AGEGEN))

# create table with results
resultA<-data.frame(mean_age = a, se = b, 
                    gen = factor(levels(data_out$AGEGEN), levels = levels(data_out$AGEGEN)))

# EDUCATION 

data_out$EDUCAT<-ifelse(data_out$EDUPRIMA==1, data_out$EDUCAT<-3, 
                        ifelse(data_out$EDUSECON==1, data_out$EDUCAT<-2,
                               data_out$EDUCAT<-1))
data_out$EDUCAT <- factor(data_out$EDUCAT, 
                          labels = c("Higher edu.", "Secondary edu.",
                                     "Primary edu."))

# calculate mean and standard error for each group 
c<-tapply(data_out$TR, data_out$EDUCAT, mean)
d<-tapply(data_out$TR, data_out$EDUCAT, std)*2
cd <- factor(levels(data_out$EDUCAT), levels = levels(data_out$EDUCAT))
        
resultB<-data.frame(mean_edu = c, se = d,
                    edu = factor(levels(data_out$EDUCAT), 
                                 levels = levels(data_out$EDUCAT)))

# POPULATION SIZE

# create single factor from the two dummies (and reference group)
data_out$POPSIZE <-ifelse(data_out$VILG==1, 3, 
                          ifelse(data_out$TOWN==1, 2, 
                                 1))

data_out$POPSIZE <- factor(data_out$POPSIZE, labels = c("City", "Town", "Village"))

# calculate mean and standard error for each group 
e<-tapply(data_out$TR, data_out$POPSIZE, mean)
f<-tapply(data_out$TR, data_out$POPSIZE, std)*2
resultC<-data.frame(mean_popsize = e, 
                    se = f, 
                    popsize = factor(levels(data_out$POPSIZE), 
                                 levels = levels(data_out$POPSIZE))
                    )

# PROTESTER

data_out$PROTEST <- ifelse(data_out$AGEA < 35 & 
                                   data_out$EDUCAT == "Higher edu." & 
                                   data_out$POPSIZE == "City", 1, 
                           0)
data_out$PROTEST <- 0 
data_out$PROTEST[data_out$AGEGEN == "Putin's (18-25)" & 
                         data_out$EDUCAT == "Higher edu." & 
                         data_out$POPSIZE == "City"] <- 1

data_out$PROTEST <- factor(data_out$PROTEST, 
                           labels = c("Non-protester", "Protester"))

data_out$PROTEST <- relevel(data_out$PROTEST, ref = 2)

# calculate mean and standard error for each group 
g <- tapply(data_out$TR, data_out$PROTEST, mean)
h <- tapply(data_out$TR, data_out$PROTEST, std)

resultD <- data.frame(mean_protest = g, 
                      se = h, 
                      protest = factor(levels(data_out$PROTEST),
                                        levels = levels(data_out$PROTEST))
                      )

# combine all 4 variables into one data frame
resultAll <- data.frame(
        mean = c(a, c, e, g), 
        se = c(b, d, f, h),
        group = factor(c(levels(data_out$AGEGEN), levels(data_out$EDUCAT), 
                         levels(data_out$POPSIZE), levels(data_out$PROTEST)), 
                       levels = c(levels(data_out$AGEGEN), levels(data_out$EDUCAT), 
                                  levels(data_out$POPSIZE), levels(data_out$PROTEST))
                       ),
        Variables = factor(c(rep("Generation", 6), rep("Education", 3), 
                            rep("Pop.size", 3), rep("Protest", 2)),
                          levels = c("Protest", "Pop.size", "Education",
                                     "Generation"))
                        )


######################################
# Figure 1. Stratified means of trust. 

f1 <- ggplot(resultAll, aes(x = group, y = mean, fill = Variables)) + 
        geom_bar(stat = "identity", color = "black", width = 0.8) + 
        geom_errorbar(aes(ymin = resultAll$mean - resultAll$se, 
                          ymax = resultAll$mean + resultAll$se), width = 0.3) + 
        # geom_hline(yintercept = mean(data_out$TR, na.rm = T)) +
        geom_vline(xintercept = c(6.5, 9.5, 12.5), size = 1) +
        coord_flip() + 
        scale_fill_grey() +
        theme_bw() + 
        theme(legend.position = c(.9, .15)) +
        xlab("") + 
        # ylim(c(0, 3)) +
        ylab("Mean Trust index")
f1
# ggsave("Figure1.pdf")

#Stratified means for the mixture model's latent classes 
tapply(data_out$TR, data_out$C, mean)

#Welch Two Sample t-test on latent classes' mean trust
t.test(data_out$TR~data_out$C)

# size of latent classes
table(data_out$C) # number
prop.table(table(data_out$C)) #proportion

######################################
#TABLE 1/A. Lin reg. on trust index NO INTERACTIONS
model.1a <- lm(formula=TR ~ STFECON + AGEA + EDUSECON + EDUPRIMA + TOWN + VILG,
               data=data_out,na.action=na.omit)
summary(model.1a)

#TABLE 1/B. Lin reg. on trust index WITH INTERACTIONS
model.1b <- lm(formula=TR ~ STFECON*(AGEA + EDUSECON + EDUPRIMA + TOWN + VILG),
               data=data_out,na.action=na.omit)
summary(model.1b)

#TABLE 1/C. Lin reg. on trust index WITH PROTEST-DUMMY INTERACTION
model.1c <- lm(formula=TR ~ STFECON*PROTEST, data=data_out,na.action=na.omit)
summary(model.1c)

# Combine 3 models into a single table. 
stargazer(model.1a, model.1b, model.1c, 
          type = "text",
          # out = "model.tex",
          column.labels = c("Model 1", "Model 2", "Model 3"),
          header = F,
          single.row = T,
          align = T,
          title = "OLS Regression of Trust index on main socio-economic variables",
          dep.var.labels.include = F,
          dep.var.caption = "",
          covariate.labels = c("Satisfaction with economy", "Age", "Secondary education",
                               "Primary education", "Town", "Village", 
                               "Satisfaction with economy x Age", 
                               "Satisfaction with economy x Secondary ed.",
                               "Satisfaction with economy x Primary ed.", 
                               "Satisfaction with economy x Town", 
                               "Satisfaction with economy x Village", 
                               "Non-protest group", 
                               "Satisfaction with economy x Non-protest g.", 
                               "Intercept"),
          omit.stat = c("rsq", "ser", "f")
          )


####################################################
# FIGURE 3. Latent groups from mixture model plotted 

data_out$C <- as.factor(data_out$C)
levels(data_out$C) <- c("Pragmatic salience group", "Ideology salience group")

r <- ggplot(data_out, aes(x = STFECON, y = TR)) + 
        geom_jitter() + 
        geom_smooth(method = "lm") + 
        facet_grid( ~ C) + 
        xlab("Satisfaction with economy") + 
        ylab("Trust index") + 
        # ggtitle("Figure 3. Correlation between Satisfaction with economy and Trust \n for Pragmacy and Ideology salience groups") + 
        theme_bw()
r

# ggsave("Figure3.pdf")


### Save data file so data_appendix can use recoded variables in data analysis. 

AnalysisData <- "../analysis-data"
save(data_out, file = paste(AnalysisData, "/ESS5RU_final.Rdata", sep = ""))

