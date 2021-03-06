#CN model experiment, incorporating NUE into model.
#Model experiment 4.25.17.
#Experiment 1: vary CN of inputs from from 20-100
#track effects on all 3 C pools and 4 N pools at zero, lo and hi clay.
#NOTE: at zero clay Mineral associated C and N pools are very slightly negative, but also extremenly close to zero. 

#clear R environment, load packages
rm(list=ls())
require(rootSolve)
require(wesanderson)

#specify model, parameter and output filepaths
model.path      <- 'model.r'
parameters.path <- 'parameters.r'
no.clay.path    <- 'experiment_output/no_clay.CN_NUE_model.rds'
lo.clay.path    <- 'experiment_output/lo_clay.CN_NUE_model.rds'
hi.clay.path    <- 'experiment_output/hi_clay.CN_NUE_model.rds'

#grab the model as a function stored in another R script. 
source(model.path)

#grab zero clay parameters and starting values
source(parameters.path)
pH=5.5 #running in constant pH mode.

#Specify vector of input C:N values.
cn.range <- seq(30,80, by = 1)
#Specify vector of clay values.
v2.range <- c(0,0.5,2.5)

#create an empty list for storing output of each level of clay.
out.list <- list()

#loop over each level of clay desired.
for(j in 1:length(v2.range)){
  v2 <- v2.range[j]
  #state variables to model.
  state.vars <- c('C','M','B','N1','N2','N3','N4','protons')
  out <- matrix(rep(0,length(cn.range)*length(state.vars)),
                nrow=length(cn.range),
                dimnames=list(NULL,state.vars))
  
  #begin C:N range loop for each level of clay.
  for(i in 1:length(cn.range)){
    #set parameters,across respective ranges.
    pars    <- c(IN=cn.range[i], BN=BN,                    #parameters
                 I=I,
                 v1=v1, v2=v2, 
                 k1=k1, k2=k2, k3=k3, 
                 h1=h1, h2=h2, h3=h3, h4=h4, h5=h5,
                 pH_opt=pH_opt, nitr.acid=nitr.acid, acid.loss=acid.loss, ph.mod=ph.mod, pH_mode=pH_mode,
                 fert=fert
    )
    y       <- y                                           #state variable starting values for numeric solver from parameters file. 
    ST      <- runsteady(y=y,func=CN_NUE_model,parms=pars) #solve model
    out[i,] <- c(ST$y)                                     #save output of each iteration of i.
  }
  
  #format output for each level of clay. 
  out     <- data.frame(out)
  out$CN  <- cn.range
  out$tot <- out$C + out$M + out$B
  #save each level of clay as a data frame within a list.
  out.list[[j]] <- out
}

#Save outputs of each level of clay as a separate data frame.
saveRDS(out.list[[1]], no.clay.path)
saveRDS(out.list[[2]], lo.clay.path)
saveRDS(out.list[[3]], hi.clay.path)