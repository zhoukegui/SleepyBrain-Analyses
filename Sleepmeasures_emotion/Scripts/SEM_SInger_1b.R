#
# Build a model with 3 latent constructs built on all available predictors, grouped by type of measurement
#
library(lavaan);
library(semPlot);
modelData <- read_csv("~/Desktop/SleepyBrain-Analyses/Sleepmeasures_emotion/Data/SEM_Singer_standardized.csv") ;
model<-"
! regressions 
EMG_EC=~1.0*zyg
EMG_EC=~1.0*corr
R_EC=~1.0*C_ang
R_EC=~1.0*C_hap
B_EC=~1.0*FFA_an
B_EC=~1.0*FFA_ha
B_EC=~1.0*Amy_an
B_EC=~1.0*Amy_ha
B_Ep=~1.0*AI
B_Ep=~1.0*ACC
R_Ep=~1.0*Unp
B_ER=~1.0*Amy_do
B_ER=~1.0*lOFC
B_ER=~1.0*dlPFC
R_ER=~1.0*Downr
R_ER=~1.0*Upreg
EC=~1.0*EMG_EC
EC=~1.0*R_EC
EC=~1.0*B_EC
Ep=~1.0*B_Ep
ER=~1.0*B_ER
ER=~1.0*R_ER
Ep=~1.0*R_Ep
! residuals, variances and covariances
EC ~~ VAR_EC*EC
Ep ~~ VAR_Ep*Ep
C_ang ~~ VAR_C_ang*C_ang
EC ~~ COV_EC_Ep*Ep
C_hap ~~ VAR_C_hap*C_hap
corr ~~ VAR_corr*corr
zyg ~~ VAR_zyg*zyg
Unp ~~ 0*Unp
AI ~~ VAR_AI*AI
ACC ~~ VAR_ACC*ACC
Amy_ha ~~ VAR_Amy_ha*Amy_ha
Amy_an ~~ VAR_Amy_an*Amy_an
ER ~~ VAR_ER*ER
Ep ~~ COV_Ep_ER*ER
ER ~~ COV_ER_EC*EC
FFA_ha ~~ VAR_FFA_ha*FFA_ha
FFA_an ~~ VAR_FFA_a*FFA_an
EMG_EC ~~ VAR_EMG_EC*EMG_EC
R_EC ~~ VAR_R_EC*R_EC
B_EC ~~ VAR_B_EC*B_EC
B_Ep ~~ VAR_B_Ep*B_Ep
B_ER ~~ VAR_B_Ep*B_ER
Amy_do ~~ VAR_Amy_do*Amy_do
lOFC ~~ VAR_lOFC*lOFC
dlPFC ~~ VAR_dlPFC*dlPFC
R_ER ~~ VAR_R_ER*R_ER
Downr ~~ VAR_Downr*Downr
Upreg ~~ VAR_Upreg*Upreg
R_Ep ~~ VAR_R_Ep*R_Ep

! observed means
C_ang~1;
C_hap~1;
corr~1;
zyg~1;
Unp~1;
AI~1;
ACC~1;
Amy_ha~1;
Amy_an~1;
FFA_ha~1;
FFA_an~1;
Amy_do~1;
lOFC~1;
dlPFC~1;
Downr~1;
Upreg~1;
";


result<-lavaan(model, data=modelData, fixed.x=FALSE, missing="FIML");
summary(result, fit.measures=T);
sink("Singer_SEM_all_variables.txt")
summary(result, fit.measures=T);
sink()


fit <- lavaan:::cfa(model, data = modelData, std.lv = TRUE)

# Plot path diagram:

semPaths(fit, intercept = F, whatLabel = "omit", nCharNodes = 0, nCharEdges =0, sizeMan = 8, sizeLat = 6,
         exoVar = F,
         groups = list(c("Ep", "R_Ep", "B_Ep", "AI", "ACC", "Unp"), 
         c("EC", "Amy_ha", "Amy_an", "C_ang", "C_hap", "FFA_an", "FFA_ha", "EMG_EC", "corr", "zyg"),
         c("ER", "B_ER", "lOFC", "Amy_do", "dlPFC", "R_ER", "Downr", "Upreg")),
         residuals = F, exoCov = T, layout = "circle", ask = F, as.expression = "edges", fixedStyle = c("grey",5),
         pastel = T, rotation = 3)

# Parameter estimates
parameterEstimates(result)
# Standardized estimates
standardizedSolution(result)



