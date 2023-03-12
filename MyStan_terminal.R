### Trying out Stan on my data 
### 
### 
### 

getwd()

library(rstan)
## Save compiled models:
rstan_options(auto_write = TRUE)
## Parallelize the chains us  ing all the cores:
options(mc.cores = parallel::detectCores())

################################################################################
################################################################################
################   get the data from the file   ################################
################################################################################
################################################################################
# read in data
#s1_data <- read.csv("shooter.study1.csv", header = TRUE)
s2_data <- read.csv("shooter.study2.csv", header = TRUE)
# filter data 
#df_1 <- subset(s1_data, select = c(subject, group, trialcode, correct, latency, gun, ethn, values.result ))
df_2 <- subset(s2_data, select = c(subject, group, trialcode, correct, latency, gun, ethn, values.result ))

#### Which data set do you want to analyse?
df <- df_2


################################################################################
################################################################################
################     select subset          ####################################
################################################################################
################################################################################
ag_data <- subset(df, ethn == "White")
ag_data <- subset(ag_data, group == "Police")
ag_data <- subset(ag_data, values.result != "Noresponse") # exclude noresponses
#ag_data <- subset(ag_data, subject < 260 ) # there seems to be a problem at 267 for arab and 269 for white - probably because auf very low latency (<100) ?
df <- subset(df, latency < 150 ) # there seems to be a problem at 267 for arab and 269 for white - probably because auf very low latency (<100) ?

ag_data <- subset(ag_data, latency > 150 ) # exclude ?


################################################################################
################################################################################
################   format the data for stan    #################################
################################################################################
################################################################################
# produce a "shoot" column indicating participant response, 1=shoot, 0=don't shoot
ag_data$shoot <- c(rep(0)) 
for (i in 1:nrow(ag_data)) {
  if (ag_data$values.result[i] == "Hit" | ag_data$values.result[i] == "FA"  ) {
    ag_data$shoot[i] <- 1
  }
}
# replace the gun values with 0 for object and 1 for gun
ag_data$gun[ag_data$gun == "Gun"] <- 1
ag_data$gun[ag_data$gun == "Object"] <- 0
ag_data$gun <- as.integer(ag_data$gun)

############################################
# give it to stan
stan_df <- ag_data

################################################################################
################################################################################
#########################   overview   #########################################
################################################################################
################################################################################
#no of subjects
length(unique(stan_df$subject))
# no of rows 
nrow(stan_df)
# no of gun trials:
length(stan_df$gun[stan_df$gun == 1 ])
#no of object trials:
length(stan_df$gun[stan_df$gun == 0])

################################################################################
################################################################################
#######################    give it to stan      ################################
################################################################################
################################################################################

# make a list with all the variables
N = nrow(stan_df) 
RT = stan_df$latency/1000 # ms between 0 and 850 become s between 0 and 0.85
choice = stan_df$shoot # 1 / 0 Werte, 1 = shoot, 0 = don't shoot
cd = stan_df$gun # condition; 0 = object; 1 = gun

dat <- list(N=N, choice = choice, RT = RT , cd=cd)

################################################################################
################################################################################
####################         ~ RUN STAN ~              #########################
################################################################################
################################################################################

ddm_model <- stan(file = "DDM_2dv2.stan" , data = dat, chains = 1, cores = 12, iter = 2000)       


summary(ddm_model)$summary
stan_dens(ddm_model)



#safe_Data_WP150 <- ddm_model
#saveRDS(safe_Data_WP150 , "Res_Stan_WP150.rds")