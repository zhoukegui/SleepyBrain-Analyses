#
# Buil model 1a for the paper
#
library(lavaan);
library(semPlot);
library(readr)
modelData <- read_csv("~/Desktop/SleepyBrain-Analyses/Sleepmeasures_emotion/Data/SEM_Singer_standardized.csv") ;
model<-"
! regressions 
Emotional Contagion=~1.0*Zyg
Emotional Contagion=~1.0*Corr
Emotional Contagion=~1.0*Anger
Emotional Contagion=~1.0*Happiness
Emotional Contagion=~1.0*FFA_angry
Emotional Contagion=~1.0*FFA_happy
Emotional Contagion=~1.0*Amy_angry
Emotional Contagion=~1.0*Amy_happy
Empathy=~1.0*AI
Empathy=~1.0*ACC
Empathy=~1.0*Unp
Emotional Regulation=~1.0*Amy_down
Emotional Regulation=~1.0*lOFC
Emotional Regulation=~1.0*dlPFC
Emotional Regulation=~1.0*Downr
Emotional Regulation=~1.0*Upreg
! residuals, variances and covariances
Emotional Contagion ~~ VAR_Emotional Contagion*Emotional Contagion
Empathy ~~ VAR_Empathy*Empathy
Anger ~~ VAR_Anger*Anger
Emotional Contagion ~~ COV_Emotional Contagion_Empathy*Empathy
Happiness ~~ VAR_Happiness*Happiness
Corr ~~ VAR_Corr*Corr
Zyg ~~ VAR_Zyg*Zyg
Unp ~~ 0*Unp
AI ~~ VAR_AI*AI
ACC ~~ VAR_ACC*ACC
Amy_happy ~~ VAR_Amy_happy*Amy_happy
Amy_angry ~~ VAR_Amy_angry*Amy_angry
Emotional Regulation ~~ VAR_Emotional Regulation*Emotional Regulation
Empathy ~~ COV_Empathy_Emotional Regulation*Emotional Regulation
Emotional Regulation ~~ COV_Emotional Regulation_Emotional Contagion*Emotional Contagion
FFA_happy ~~ VAR_FFA_happy*FFA_happy
FFA_angry ~~ VAR_FFA_a*FFA_angry
Amy_down ~~ VAR_Amy_down*Amy_down
lOFC ~~ VAR_lOFC*lOFC
dlPFC ~~ VAR_dlPFC*dlPFC
Downr ~~ VAR_Downr*Downr
Upreg ~~ VAR_Upreg*Upreg

! observed means
Anger~1;
Happiness~1;
Corr~1;
Zyg~1;
Unp~1;
AI~1;
ACC~1;
Amy_happy~1;
Amy_angry~1;
FFA_happy~1;
FFA_angry~1;
Amy_down~1;
lOFC~1;
dlPFC~1;
Downr~1;
Upreg~1;
";


result<-lavaan(model, data=modelData, fixed.x=FALSE, missing="FIML");
summary(result, fit.measures=T);
sink("Singer_SEM_all_variables_together.txt")
summary(result, fit.measures=T);
sink()


fit <- lavaan:::cfa(model, data = modelData, std.lv = TRUE)

# Plot path diagram:

semPaths(fit, intercept = F, whatLabel = "omit", nCharNodes = 0, nCharEdges =0, sizeMan = 8, sizeLat = 14, label.prop = 1,
         exoVar = F,
         groups = list(c("Empathy", "R_Empathy", "B_Empathy", "AI", "ACC", "Unp"), 
                       c("EmotionalContagion", "Amy_happy", "Amy_angry", "Anger", "Happiness", "FFA_angry", "FFA_happy", "EMG_Emotional Contagion", "Corr", "Zyg"),
                       c("EmotionalRegulation", "B_Emotional Regulation", "lOFC", "Amy_down", "dlPFC", "R_Emotional Regulation", "Downr", "Upreg")),
         residuals = F, exoCov = T, layout = "circle", ask = F, as.expression = "edges", fixedStyle = c("black",3),
         pastel = T, rotation = 1)

# Parameter estimates
parameterEstimates(result)
# Standardized estimates
standardizedSolution(result)
