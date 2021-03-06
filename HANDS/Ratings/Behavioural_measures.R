# Script to analyse ratings of unpleasantness in the HANDS experiment, Sleepy Brain project
# Script written by Sandra Tamm, 150726
# Script reviewed by Gustav Nilsonne, 151202

# Make sure to be in SleepyBrain_HANDS.Rproj so that current working directory is where this script is stored 
# Change the following line when working on a different computer
setwd("C:/Users/gusta/OneDrive/Dokument/Git Sleepy Brain/SleepyBrain-Analyses/HANDS")

##############################################################
# Technical stuff and data organizing

# Load packages 
require(nlme)
require(ggplot2)
require(reshape)
require(gridExtra)
require(effects)
require(Gmisc)
require(doBy)

# Change if other system
source('Utils/SummarisingFunctions.R', chdir = T)
source('Utils/Multiplot.R', chdir = T)

# Use for colors of plots
cPalette <- c("#E69F00","#56B4E9")

# Read data
Data_HANDSRatings <- read.csv("Ratings/Data_HANDS_ratings.csv", sep=";", dec=",")

# Relevel so that young are reference 
Data_HANDSRatings$AgeGroup <- relevel(Data_HANDSRatings$AgeGroup, ref = "Young")

# Put in dummy variables for group and sleep condition, sot that main effect represent 
# mean effect across groups etc

contrasts(Data_HANDSRatings$AgeGroup) <- rbind(-.5, .5)
colnames(contrasts(Data_HANDSRatings$AgeGroup)) <- levels(Data_HANDSRatings$AgeGroup)[2]

contrasts(Data_HANDSRatings$DeprivationCondition) <- rbind(-.5, .5)
colnames(contrasts(Data_HANDSRatings$AgeGroup)) <- levels(Data_HANDSRatings$AgeGroup)[2]


# Make data frame with only subjects that can be included for intervention effects
Data_HANDSRatings_Intervention <- subset(Data_HANDSRatings, HANDSRatings_Intervention == TRUE)

# Make data frame with sd of ratings for each participant
SD_Pain = with(subset(Data_HANDSRatings_Intervention, Condition == "Pain"), 
               aggregate(Rated_Unpleasantness, by = list(Subject, DeprivationCondition), sd, na.rm=TRUE))  
names(SD_Pain) <- c("Subject", "DeprivationCondition", "SD_pain")

SD_No_Pain = with(subset(Data_HANDSRatings_Intervention, Condition == "No_Pain"), 
                  aggregate(Rated_Unpleasantness, by = list(Subject, DeprivationCondition), sd, na.rm=TRUE))  
names(SD_No_Pain) <- c("Subject", "DeprivationCondition", "SD_no_pain")

Data_SD <- merge(SD_Pain, SD_No_Pain)

# Add std to the intervention data frame

Data_HANDSRatings_Intervention <- merge(Data_SD, Data_HANDSRatings_Intervention)

################################################################
# Present data in Table 1 and analyse effect of manipulation on sleepiness

# Demographic data
Demographic <- Data_HANDSRatings[!duplicated(Data_HANDSRatings$Subject),]
Data_unique <- subset(Data_HANDSRatings, Picture_no. == 1)

Count_data <- summary(Demographic$AgeGroup)
Age_data <- getDescriptionStatsBy(Demographic$Age, Demographic$AgeGroup, html=TRUE, 
                                  continuous_fn = describeMedian)
Sex_data <- getDescriptionStatsBy(Demographic$Sex, Demographic$AgeGroup, html=TRUE)
BMI_data <- getDescriptionStatsBy(Demographic$BMI1, Demographic$AgeGroup, html=TRUE)
Edu_data <- getDescriptionStatsBy(Demographic$EducationLevel, Demographic$AgeGroup, html=TRUE)
EC_data <- getDescriptionStatsBy(Demographic$IRI_EC, Demographic$AgeGroup, html=TRUE)
F_data <- getDescriptionStatsBy(Demographic$IRI_F, Demographic$AgeGroup, html=TRUE)
PT_data <- getDescriptionStatsBy(Demographic$IRI_PT, Demographic$AgeGroup, html=TRUE)
PD_data <- getDescriptionStatsBy(Demographic$IRI_PD, Demographic$AgeGroup, html=TRUE)
Depression_data <- getDescriptionStatsBy(Demographic$HADS_Depression, Demographic$AgeGroup, html=TRUE)
Anxiety_data <- getDescriptionStatsBy(Demographic$HADS_Anxiety, Demographic$AgeGroup, html=TRUE)
ISI_data <- getDescriptionStatsBy(Demographic$ISI, Demographic$AgeGroup, html=TRUE)
KSS_fullsleep <- getDescriptionStatsBy(subset(Data_unique, DeprivationCondition == "NormalSleep")$KSS_Rating, 
                                       subset(Data_unique, DeprivationCondition == "NormalSleep")$AgeGroup, html=TRUE)
KSS_sleeprestriction <- getDescriptionStatsBy(subset(Data_unique, DeprivationCondition == "SleepRestriction")$KSS_Rating, 
                                       subset(Data_unique, DeprivationCondition == "SleepRestriction")$AgeGroup, html=TRUE)
TST_fullsleep <- getDescriptionStatsBy(subset(Data_unique, DeprivationCondition == "NormalSleep")$tst__00_nsd, 
                                    subset(Data_unique, DeprivationCondition == "NormalSleep")$AgeGroup, useNA = c("no"), html=TRUE)
TST_sleeprestriction <- getDescriptionStatsBy(subset(Data_unique, DeprivationCondition == "SleepRestriction")$tst__00_sd, 
                                       subset(Data_unique, DeprivationCondition == "SleepRestriction")$AgeGroup, useNA = c("no"), html=TRUE)
REM_fullsleep <- getDescriptionStatsBy(subset(Data_unique, DeprivationCondition == "NormalSleep")$r____00_nsd, 
                                       subset(Data_unique, DeprivationCondition == "NormalSleep")$AgeGroup, useNA = c("no"), html=TRUE)
REM_sleeprestriction <- getDescriptionStatsBy(subset(Data_unique, DeprivationCondition == "SleepRestriction")$r____00_sd, 
                                              subset(Data_unique, DeprivationCondition == "SleepRestriction")$AgeGroup, useNA = c("no"), html=TRUE)
SWS_fullsleep <- getDescriptionStatsBy(subset(Data_unique, DeprivationCondition == "NormalSleep")$n3___00_nsd, 
                                       subset(Data_unique, DeprivationCondition == "NormalSleep")$AgeGroup, useNA = c("no"), html=TRUE)
SWS_sleeprestriction <- getDescriptionStatsBy(subset(Data_unique, DeprivationCondition == "SleepRestriction")$n3___00_sd, 
                                              subset(Data_unique, DeprivationCondition == "SleepRestriction")$AgeGroup, useNA = c("no"), html=TRUE)


# Make table with demographics
htmlTable(
  x        = rbind(Count_data, Age_data, Sex_data, BMI_data, Edu_data, EC_data, F_data, PT_data, PD_data, 
                   Depression_data, Anxiety_data, 
                   ISI_data, KSS_fullsleep, KSS_sleeprestriction,
                   TST_fullsleep, TST_sleeprestriction,
                   REM_fullsleep, REM_sleeprestriction,
                   SWS_fullsleep, SWS_sleeprestriction),
  caption  = paste("Table 1. Continuous values are reported as",
                   "means with standard deviations, unless otherwise indicated). Categorical data",
                   "are reported with percentages. Sleep measures are reported in minutes"),
  label    = "Table1",
  rowlabel = "Variables",
  rnames = c("Number of subjects", "Age (median, interquartile range)", "Sex (females)", "BMI", "Elementary school", "High school", 
  "University degree", "University student", "Empathic concern", "Fantasy", 
  "Perspective taking", "Personal distress", "Depression", "Anxiety", 
  "Insomnia severity index", "Karolinska Sleepiness Scale, full sleep", 
  "Karolinska Sleepiness Scale, sleep restriction", "Total sleep time (min), full sleep",
  "Total sleep time (min), sleep restriction", "REM sleep (min), full sleep",
  "REM sleep (min), sleep restriction", "Slow wave sleep (min), full sleep",
  "Slow wave sleep, min (sleep restriction)"),
  rgroup   = c("Sample", 
               "Demographics",
               "Education",
               "Interpersonal reactivity index",
               "HADS",
               "Sleep"),
  n.rgroup = c(1,
               3,
               NROW(Edu_data),
               4,
               2,
               9),
  ctable   = TRUE)

# Test effect of sleep restriction on KSS
t.test(subset(Data_unique, DeprivationCondition == "NormalSleep")$KSS_Rating, 
       subset(Data_unique, DeprivationCondition == "SleepRestriction")$KSS_Rating)

###################################################################
# Make plots

# Summarise data (mean, CI etc) for plotting
summary_age_intervention <- summarySEwithin(data = Data_HANDSRatings_Intervention, 
                                            measurevar = "Rated_Unpleasantness", betweenvars = "AgeGroup", 
                                            withinvars = c("Condition", "DeprivationCondition"),
                                            idvar = "Subject", na.rm = T, conf.interval=.95, .drop=TRUE
)

summary_age_intervention$group <- paste(summary_age_intervention$AgeGroup, ": ", 
                                        summary_age_intervention$DeprivationCondition, sep = "")
summary_age_intervention$group
summary_pain <- subset(summary_age_intervention, Condition == "Pain")
summary_nopain <- subset(summary_age_intervention, Condition == "No_Pain")


# Make plot with age and sleep effects for "pain" stimuli. 
P1 <- ggplot(summary_pain, aes(x=DeprivationCondition, y=Rated_Unpleasantness)) + 
  geom_point(aes(colour = factor(AgeGroup)), position=position_dodge(.9), stat="identity",
           #colour="black", # Use black outlines,
           size=5.0) +      # Thinner lines
  geom_errorbar(aes(ymin=Rated_Unpleasantness-ci, ymax=Rated_Unpleasantness+ci, colour = factor(AgeGroup)),
                size=0.6,    # Thinner lines
                width=.3,
                position=position_dodge(.9)) +
  scale_y_continuous(limits = c(0, 100))+
  scale_x_discrete(label = c("Normal sleep", "Sleep restriction")) +
  xlab("SleepCondition") +
  ylab("Rated vicarious unpleasantness") +
  annotate("text",x=1.5,y=70,label="*")+
  scale_color_manual(name = "Age group", values=cPalette, 
                     breaks=c("Old", "Young"),
                     labels=c("Old", "Young"))+
  geom_path(x=c(0.775,0.775,1.225,1.225),y=c(41.48,52,52,48.92))+
  geom_path(x=c(1.775,1.775,2.225,2.225),y=c(40.42,52,52,51))+
  geom_path(x=c(1,1,2,2),y=c(52,65,65,52))+
  ggtitle("Pain condition") +
  theme_bw() +
  theme(
    legend.position=c(1,1),legend.justification=c(1,1),
    axis.title.x=element_blank(),
    axis.title.y = element_text(size = rel(1.4)),
    axis.text.x  = element_text(size=16)
  )


# Make plot with age and sleep effects for "no pain" stimuli. 
P2 <- ggplot(summary_nopain, aes(x=DeprivationCondition, y=Rated_Unpleasantness)) + 
  geom_point(aes(colour = factor(AgeGroup)), position=position_dodge(.9), stat="identity",
             #colour="black", # Use black outlines,
             size=5.0) +      # Thinner lines
  geom_errorbar(aes(ymin=Rated_Unpleasantness-ci, ymax=Rated_Unpleasantness+ci, colour = factor(AgeGroup)),
                size=0.6,    # Thinner lines
                width=.3,
                position=position_dodge(.9)) +
  scale_y_continuous(limits = c(0, 100))+
  scale_x_discrete(label = c("Normal sleep", "Sleep restriction")) +
  xlab("SleepCondition") +
  ylab("Rated vicarious unpleasantness") +
  scale_color_manual(name = "Age group", values=cPalette, 
                     breaks=c("Old", "Young"),
                     labels=c("Old", "Young"))+
  ggtitle("No pain condition") +
  theme_bw() +
  theme(
    legend.position=c(1,1),legend.justification=c(1,1),
    axis.title.x=element_blank(),
    axis.title.y = element_text(size = rel(1.4)),
    axis.text.x  = element_text(size=16)
  )


# Write plots to file
dir.create("Figures", showWarnings=F)
pdf(file = "Figures/RatingsByAgeAndSleep.pdf", height = 3.5)
multiplot(P1, P2, cols = 2)
dev.off()

label_nice <- function(variable, value){
  value = as.character(value)
  if (variable == "Group") {
    value[value=="Old:NormalSleep"] <- "Old: Normal sleep"
    value[value=="Old:SleepRestriction"] <- "Old: Sleep restriction"
    value[value=="Young:NormalSleep"] <- "Young: normal sleep"
    value[value=="Young:SleepRestriction"] <- "Young: Sleep restriction"
  } else {
    value[value=="No_Pain"] <- "No pain"
  }
  return(value)
}

P1 <- ggplot(Data_HANDSRatings, aes(x=KSS_Rating, y=Rated_Unpleasantness, group=Group)) + 
  geom_point(size = 1) + 
  geom_smooth(method="lm", formula = y ~ x) +
  facet_grid(Group~Condition, labeller = label_nice)+
  ylab("Rated perceived unpleasantness (pain)") +
  xlab("Rated sleepiness (Karolinska Sleeepiness Scale)")+
  theme_bw() +
  theme(
    legend.position = "none",
    axis.title=element_text(size=8, face = "bold"),
    strip.text.x = element_text(size=8, face = "bold"),
    strip.text.y = element_text(size=8, face = "bold"),
    strip.background = element_rect(color="black", fill="white"),
    plot.margin=unit(c(0.5,0,0.5,0.5),"cm")
  )

P2 <- ggplot(Data_HANDSRatings, aes(x=IRI_EC, y=Rated_Unpleasantness, group=Group)) + 
  geom_point(size = 1) + 
  geom_smooth(method="lm", formula = y ~ x) +
  facet_grid(Group~Condition, labeller = label_nice)+
  ylab("Rated perceived unpleasantness (pain)") +
  xlab("Interpersonal reactivity index (empathic concern)")+
  theme_bw() +
  theme(
    legend.position = "none",
    axis.title=element_text(size=8, face = "bold"),
    strip.text.x = element_text(size=8, face = "bold"),
    strip.text.y = element_text(size=8, face = "bold"),
    strip.background = element_rect(color="black", fill="white"),
    plot.margin=unit(c(0.5,0.5,0.5,0.5),"cm")
  )


multiplot(P1, P2, cols = 2)


# Write plot to file
pdf(file = "Figures/RatingsByKSSandIRIp.pdf", height = 8, width = 14)
multiplot(P1, P2, cols = 2)
dev.off()

########################################################################
# Main analyses

# Overall model

Lme_HANDS <- lme(Rated_Unpleasantness ~ Condition*AgeGroup*DeprivationCondition, 
              data = Data_HANDSRatings_Intervention, 
              random = ~ 1|Subject, na.action = na.omit)

anova(Lme_HANDS, type = "marginal")
summary(Lme_HANDS)
intervals(Lme_HANDS)


## Test for confounding. TestTimeType (whether participants were scheduled at ~ 5 p.m. or ~ 6.30 p.m.), sex and session 
# (1st or 2:nd scanning) were tested for
lme_HANDS <- lme(Rated_Unpleasantness ~ Condition*(DeprivationCondition*AgeGroup + TestTimeType), 
                 data = Data_HANDSRatings, random = ~ 1|Subject, na.action = na.exclude)
anova(lme_HANDS, type = "marginal")

lme_HANDS <- lme(Rated_Unpleasantness ~ Condition*(DeprivationCondition*AgeGroup + Session), 
                 data = Data_HANDSRatings_Intervention, random = ~ 1|Subject, na.action = na.exclude)
anova(lme_HANDS, type = "marginal")

lme_HANDS <- lme(Rated_Unpleasantness ~ Condition*(DeprivationCondition*AgeGroup + Session + Sex), 
                 data = Data_HANDSRatings_Intervention, random = ~ 1|Subject, na.action = na.exclude)
anova(lme_HANDS, type = "marginal")

# Sex and session interacted with stimulus type

# Test effect of stimulus type on ratings of unpleasantness
Lme_young <- lme(Rated_Unpleasantness ~ Condition*DeprivationCondition, 
                 data = subset(Data_HANDSRatings, AgeGroup == "Young"), random = ~ 1|Subject, na.action = na.omit)

anova(Lme_young, type = "marginal")
summary(Lme_young)
intervals(Lme_young)

Lme_old <- lme(Rated_Unpleasantness ~ Condition*DeprivationCondition, 
                 data = subset(Data_HANDSRatings, AgeGroup == "Old"), random = ~ 1|Subject, na.action = na.omit)

anova(Lme_old, type = "marginal")
summary(Lme_old)
intervals(Lme_old)

# Test if ratings habituate
lme_hab_pain <- lme(Rated_Unpleasantness ~ AgeGroup + DeprivationCondition + ScaledRatingNo, 
                    data = subset(Data_HANDSRatings, Condition == "Pain"), 
                    random = ~ 1|Subject, na.action = na.exclude)
anova(lme_hab_pain, type = "marginal")
intervals(lme_hab_pain)

lme_hab_nopain <- lme(Rated_Unpleasantness ~ AgeGroup + DeprivationCondition + ScaledRatingNo, 
                      data = subset(Data_HANDSRatings, Condition == "No_Pain"), 
                      random = ~ 1|Subject, na.action = na.exclude)
anova(lme_hab_nopain, type = "marginal")
intervals(lme_hab_nopain)

# Plot habituation for pain to see
Hab1 <- lm(Rated_Unpleasantness ~ ScaledRatingNo, data = subset(Data_HANDSRatings, Condition == "Pain"))
par(cex=.2)
plot(Rated_Unpleasantness ~ ScaledRatingNo, data = subset(Data_HANDSRatings, Condition == "Pain"))
abline(Hab1, col = "red")

# Add covariates for habituation analyses
lme_hab_painb <- lme(Rated_Unpleasantness ~ AgeGroup + DeprivationCondition + Session + Sex + Rating_no, 
                     data = subset(Data_HANDSRatings, Condition == "Pain"), 
                     random = ~ 1|Subject, na.action = na.exclude)
anova(lme_hab_painb, type = "marginal")
intervals(lme_hab_painb)


lme_hab_nopain <- lme(Rated_Unpleasantness ~ AgeGroup + DeprivationCondition + Session + Sex + Rating_no, 
                      data = subset(Data_HANDSRatings, Condition == "No_Pain"), 
                      random = ~ 1|Subject, na.action = na.exclude)
anova(lme_hab_nopain, type = "marginal")
# Seems to increase over time? But only small change


# Confirm that no pain stimuli did not cause much unpleasantness

summary(subset(Data_HANDSRatings, Condition == "No_Pain")$Rated_Unpleasantness)
count(subset(Data_HANDSRatings, Condition == "No_Pain")$Rated_Unpleasantness)
2424/3420
# Of the total 3420 ratings to No Pain, 2424 (71 %) were zero


# Testing the effect of sleep condition (deprivation condition) for pain stimuli. 
Lme_3 <- lme(Rated_Unpleasantness ~ AgeGroup*DeprivationCondition, 
             data = subset(Data_HANDSRatings_Intervention, Condition == "Pain"), 
             random = ~ 1|Subject, na.action = na.omit)

anova(Lme_3, type = "marginal")
intervals(Lme_3)
summary(Lme_3)


# Add sex and session as possible confounders
Lme_3b <- lme(Rated_Unpleasantness ~ Session + Sex + AgeGroup*DeprivationCondition, 
              data = subset(Data_HANDSRatings_Intervention, Condition == "Pain"), 
              random = ~ 1|Subject, na.action = na.omit)

anova(Lme_3b, type = "marginal")

# Pairwise comparisons
Lme_3_old <- lme(Rated_Unpleasantness ~ DeprivationCondition, 
             data = subset(Data_HANDSRatings_Intervention, Condition == "Pain" & AgeGroup == "Old"), 
             random = ~ 1|Subject, na.action = na.omit)

anova(Lme_3_old, type = "marginal")
intervals(Lme_3_old)

Lme_3_young <- lme(Rated_Unpleasantness ~ DeprivationCondition, 
                 data = subset(Data_HANDSRatings_Intervention, Condition == "Pain" & AgeGroup == "Young"), 
                 random = ~ 1|Subject, na.action = na.omit)

anova(Lme_3_young, type = "marginal")
intervals(Lme_3_young)



# Test effect of age group on pain stimuli. Deprivation condition is 
# used as covariate of no interest and all data is used (also participants who 
# did not have a succesfull intervention)
Lme_1 <- lme(Rated_Unpleasantness ~ AgeGroup*DeprivationCondition, 
             data = subset(Data_HANDSRatings, Condition == "Pain"), 
             random = ~ 1|Subject, na.action = na.omit)

anova(Lme_1, type = "marginal")
summary(Lme_1)
intervals(Lme_1)

# Add sex and session as possible confounders
Lme_1b <- lme(Rated_Unpleasantness ~ Session + Sex + AgeGroup*DeprivationCondition, 
             data = subset(Data_HANDSRatings, Condition == "Pain"), 
             random = ~ 1|Subject, na.action = na.omit)

anova(Lme_1b, type = "marginal")





# Testing the effect of sleep condition (deprivation condition) and age for no pain stimuli. 
# This is only done as a control 
Lme_4 <- lme(Rated_Unpleasantness ~ DeprivationCondition*AgeGroup, 
             data = subset(Data_HANDSRatings_Intervention, Condition == "No_Pain"), 
             random = ~ 1|Subject, na.action = na.omit)

anova(Lme_4, type = "marginal")
intervals(Lme_4)



# Analyse variability
Data_unique_intervention <- subset(Data_HANDSRatings_Intervention, Picture_no. == 1)
lme_variability_pain <- lme(SD_pain ~ AgeGroup*DeprivationCondition, 
                            data = Data_unique_intervention, 
                            random = ~ 1|Subject, na.action = na.omit)
anova(lme_variability_pain, type = "marginal")
intervals(lme_variability_pain)


# No pain
lme_variability_nopain <- lme(SD_no_pain ~ AgeGroup*DeprivationCondition, 
                            data = Data_unique_intervention, 
                            random = ~ 1|Subject, na.action = na.omit)
anova(lme_variability_nopain)
intervals(lme_variability_nopain)


# Test effect of self-rated empathy on ratings
lme_IRI <- lme(Rated_Unpleasantness ~ Condition*(DeprivationCondition + IRI_EC + AgeGroup), 
               data = Data_HANDSRatings, random = ~ 1|Subject, na.action = na.exclude)
anova(lme_IRI, type = "marginal")
intervals(lme_IRI)
summary(lme_IRI)

lme_IRI_pain <- lme(Rated_Unpleasantness ~ DeprivationCondition + IRI_EC + AgeGroup, 
               data = subset(Data_HANDSRatings, Condition == "Pain"), random = ~ 1|Subject, na.action = na.exclude)
anova(lme_IRI_pain, type = "marginal")
intervals(lme_IRI_pain)
summary(lme_IRI_pain)

lme_IRI_nopain <- lme(Rated_Unpleasantness ~ DeprivationCondition + IRI_EC + AgeGroup, 
                    data = subset(Data_HANDSRatings, Condition == "No_Pain"), random = ~ 1|Subject, na.action = na.exclude)
anova(lme_IRI_nopain, type = "marginal")
intervals(lme_IRI_nopain)
summary(lme_IRI_nopain)

# Add sex and session as possible confounders
lme_IRIb <- lme(Rated_Unpleasantness ~ Condition*(DeprivationCondition + IRI_EC + AgeGroup + Sex + Session), 
                data = Data_HANDSRatings, random = ~ 1|Subject, na.action = na.exclude)
anova(lme_IRIb, type = "marginal")
intervals(lme_IRIb)


# Add analyses of PPI-R, Coldheartedness
Data_PPIR <- read.csv("Data/Data_PPIR", sep=";", dec=",")
Data_HANDSRatings <- merge(Data_HANDSRatings, Data_PPIR, all.x = T)

# Test effect of self-rated psychopathy on ratings
lme_PPIR <- lme(Rated_Unpleasantness ~ Condition*(DeprivationCondition + C + AgeGroup), 
               data = Data_HANDSRatings, random = ~ 1|Subject, na.action = na.exclude)
anova(lme_PPIR, type = "marginal")
intervals(lme_PPIR)
summary(lme_PPIR)

lme_PPIR_pain <- lme(Rated_Unpleasantness ~ DeprivationCondition + C + AgeGroup, 
                    data = subset(Data_HANDSRatings, Condition == "Pain"), random = ~ 1|Subject, na.action = na.exclude)
anova(lme_PPIR_pain, type = "marginal")
intervals(lme_PPIR_pain)
summary(lme_PPIR_pain)

lme_PPIR_nopain <- lme(Rated_Unpleasantness ~ DeprivationCondition + C + AgeGroup, 
                      data = subset(Data_HANDSRatings, Condition == "No_Pain"), random = ~ 1|Subject, na.action = na.exclude)
anova(lme_PPIR_nopain, type = "marginal")
intervals(lme_PPIR_nopain)
summary(lme_PPIR_nopain)

# Add sex and session as possible confounders
lme_IRIb <- lme(Rated_Unpleasantness ~ Condition*(DeprivationCondition + IRI_EC + AgeGroup + Sex + Session), 
                data = Data_HANDSRatings, random = ~ 1|Subject, na.action = na.exclude)
anova(lme_IRIb, type = "marginal")
intervals(lme_IRIb)



# Calculate Cohens'f for effect of deprivation condition
require(lme4)
# Create the full model
lmer_full <- lmer(Rated_Unpleasantness ~ Condition*AgeGroup*DeprivationCondition + (1|Subject), 
                  data = Data_HANDSRatings_Intervention)
lmer_var_full <- as.data.frame(VarCorr(lmer_full), comp="Variance")
Vab <- lmer_var_full$vcov[2]

# Create reduced model (without DeprivationCondition)
lmer_reduced <- lmer(Rated_Unpleasantness ~ Condition*AgeGroup + (1|Subject), 
                     data = Data_HANDSRatings_Intervention)
lmer_var_reduced <- as.data.frame(VarCorr(lmer_reduced), comp="Variance")
Va <- lmer_var_reduced$vcov[2]

# Create model with only random effects
lmer_null <- lmer(Rated_Unpleasantness ~ (1|Subject), data = Data_HANDSRatings_Intervention)
lmer_var_null <- as.data.frame(VarCorr(lmer_null), comp="Variance")
Vnull <- lmer_var_null$vcov[2]

R2ab <- (Vnull - Vab)/Vnull
R2a <- (Vnull - Va)/Vnull

f2 <- (R2ab - R2a)/(1-R2ab)

# Calculate Cohens'f for effect of age
# Create the full model
lmer_full <- lmer(Rated_Unpleasantness ~ Condition*AgeGroup*DeprivationCondition + (1|Subject), 
                  data = Data_HANDSRatings)
lmer_var_full <- as.data.frame(VarCorr(lmer_full), comp="Variance")
Vab <- lmer_var_full$vcov[2]

# Create reduced model (without AgeGroup)
lmer_reduced <- lmer(Rated_Unpleasantness ~ Condition*DeprivationCondition + (1|Subject), 
                     data = Data_HANDSRatings)
lmer_var_reduced <- as.data.frame(VarCorr(lmer_reduced), comp="Variance")
Va <- lmer_var_reduced$vcov[2]

# Create model with only random effects
lmer_null <- lmer(Rated_Unpleasantness ~ (1|Subject), data = Data_HANDSRatings)
lmer_var_null <- as.data.frame(VarCorr(lmer_null), comp="Variance")
Vnull <- lmer_var_null$vcov[2]

R2ab <- (Vnull - Vab)/Vnull
R2a <- (Vnull - Va)/Vnull

f2 <- (R2ab - R2a)/(1-R2ab)



# Calculate power based on the young group
# Strategy is to resample with replacement from the existing dataset, while varying the numbers of participants and observations,
# and then calculate observed power for a mixed model.

# Require packages
require(nlmeU) # to get power for lme objects
require(RColorBrewer) # to get nice colors in plots
cols <- brewer.pal(4, "Dark2") 

# Make dataset containing only the young participants and only the variables needed for simulation
data_pwr <- Data_HANDSRatings_Intervention[Data_HANDSRatings_Intervention$AgeGroup == "Young", c("Condition", "Rated_Unpleasantness", "DeprivationCondition", "Subject")]

# Test model specification on the full dataset
Lme_pwr <- lme(Rated_Unpleasantness ~ Condition*DeprivationCondition, 
                 data = data_pwr, 
                 random = ~ 1|Subject, na.action = na.omit)
summary(Lme_pwr)
Pwr(Lme_pwr) # Observed power

# Set parameters for simulation (change as may be desired)
n_sub <- c(20, 60, 100) # numbers of subjects
n_rep <- c(60, 80, 100) # numbers of repeated measures within subjects. NB: Must be a multiple of 4 in order for conditions to balance.
n_sim <- 1000 # number of iterations for each combination. 

# Initialize
pwr_out <- data.frame(matrix(ncol = 10, nrow = length(n_sub)*length(n_rep)*n_sim)) # initialize data frame for outputs for better speed
counter <- 1 # to say which line in pwr_out to write to 
pb <- winProgressBar(title = "progress bar", min = 0, max = n_sim, width = 200) # initialize progress bar in separate window

# Run simulations
for (i in 1:n_sim){ # loop over iterations
  for (j in n_sub){ # loop over subject numbers
    new_subs <- sample(unique(data_pwr$Subject), size = j, replace = T) # sample subjects
    for (k in n_rep){ # loop over repeated measures numbers
      sim_data <- data.frame(matrix(ncol = 5, nrow = length(new_subs)*k)) # initialize data frame for new sample
      for (l in 1:length(new_subs)){ # loop over subjects in sample
        temp_data <- data_pwr[data_pwr$Subject == new_subs[l], ] # extract data for the selected participant
        temp_data$sub <- l # make new subject identifier (since subjects are drawn with replacement)
        # Split into four to balance over conditions
        temp_data1 <- temp_data[temp_data$Condition == "No_Pain" & temp_data$DeprivationCondition == "NormalSleep", ]
        temp_data2 <- temp_data[temp_data$Condition == "Pain" & temp_data$DeprivationCondition == "NormalSleep", ]
        temp_data3 <- temp_data[temp_data$Condition == "No_Pain" & temp_data$DeprivationCondition == "SleepRestriction", ]
        temp_data4 <- temp_data[temp_data$Condition == "Pain" & temp_data$DeprivationCondition == "SleepRestriction", ]
        resampled_data <- rbind(
          temp_data1[sample(nrow(temp_data1), size = k/4, replace = T), ],
          temp_data2[sample(nrow(temp_data2), size = k/4, replace = T), ],
          temp_data3[sample(nrow(temp_data3), size = k/4, replace = T), ],
          temp_data4[sample(nrow(temp_data4), size = k/4, replace = T), ]
        )
        sim_data[(((l-1)*k)+1):(l*k), ] <-  resampled_data # sample repeated measures; write to data frame
      }
      names(sim_data) <- c(names(data_pwr), "sub")
      try(Lme_it <- lme(Rated_Unpleasantness ~ Condition*DeprivationCondition, # run model
                        data = sim_data, random = ~ 1|sub, na.action = na.omit,
                        control = lmeControl(opt='optim')))
      pwr_it <- Pwr(Lme_it) # get observed power from model
      pwr_it2 <- data.frame(sim = i, n_sub = j, n_rep = k, pwr_cond = pwr_it$Power[2], pwr_depr = pwr_it$Power[3], pwr_int = pwr_it$Power[4], F_cond = pwr_it$`F-value`[2], F_depr = pwr_it$`F-value`[3], F_int = pwr_it$`F-value`[4], n_groups = Lme_it$dims$ngrps[1]) # put results in data frame row
      pwr_out[counter, ] <- pwr_it2 # write row to output object
      counter <- counter + 1 # increase counter
    }
  }
  Sys.sleep(0.1) # progress bar
  setWinProgressBar(pb, i, title = paste(round(i/n_sim*100, 0), "% done")) # progress bar
}
close(pb) # close progress bar window

# Calculate mean power for each combination of sample sizes
names(pwr_out) <- c("sim", "n_sub", "n_rep", "pwr_cond", "pwr_depr", "pwr_int", "F_cond", "F_depr", "F_int", "n_groups")
pwr_agg <- aggregate(cbind(pwr_cond, pwr_depr, pwr_int) ~ n_sub + n_rep, data = pwr_out, FUN = "mean")

# Plot power for the different effects
plot(pwr_cond ~ n_sub, data = pwr_agg, frame.plot = F, type = "n", xlim = c(n_sub[1], n_sub[length(n_sub)]), ylim = c(0, 1), xlab = "n participants", ylab = "power", main = "Pain vs no pain")
for(i in 1:length(unique(pwr_agg$n_rep))){
  lines(pwr_cond ~ n_sub, type = "b", data = pwr_agg[pwr_agg$n_rep == unique(pwr_agg$n_rep)[i], ], lwd = 2, col = cols[i])
}
legend("bottomleft", legend = c("nrep = 60", "nrep = 80", "nrep = 100"), col = cols, lwd = 2)

plot(pwr_depr ~ n_sub, data = pwr_agg, frame.plot = F, type = "n", xlim = c(n_sub[1], n_sub[length(n_sub)]), ylim = c(0, 1), xlab = "n participants", ylab = "power", main = "Sleep deprived vs full sleep")
for(i in 1:length(unique(pwr_agg$n_rep))){
  lines(pwr_depr ~ n_sub, type = "b", data = pwr_agg[pwr_agg$n_rep == unique(pwr_agg$n_rep)[i], ], lwd = 2, col = cols[i])
}
legend("topleft", legend = c("nrep = 60", "nrep = 80", "nrep = 100"), col = cols, lwd = 2)

plot(pwr_int ~ n_sub, data = pwr_agg, frame.plot = F, type = "n", xlim = c(n_sub[1], n_sub[length(n_sub)]), ylim = c(0, 1), xlab = "n participants", ylab = "power", main = "Interaction")
for(i in 1:length(unique(pwr_agg$n_rep))){
  lines(pwr_int ~ n_sub, type = "b", data = pwr_agg[pwr_agg$n_rep == unique(pwr_agg$n_rep)[i], ], lwd = 2, col = cols[i])
}
legend("topleft", legend = c("nrep = 60", "nrep = 80", "nrep = 100"), col = cols, lwd = 2)

# Calculate mean effect sizes for the different conditions
F_agg <- aggregate(cbind(F_cond, F_depr, F_int) ~ n_sub + n_rep, data = pwr_out, FUN = "mean")
F_agg

