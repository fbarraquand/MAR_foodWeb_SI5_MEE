#########################################################################################################
##### FBarraquand 22/08/2017 - Extraction of fitted MAR parameters and comparison to simulated models ###
##### Lotka-Volterra-Ricker food web models with G. Certain.  #####################
#########################################################################################################

#### Compare how matrix B aligns with matrix J, both within and across simulations. 

rm(list=ls())
graphics.off()
set.seed(42)

nsites=100 #100

### Selected B elements of interest - 20 elements
#element_vec=c("b_1,1","b_2,1","b_3,1","b_1,2","b_8,2","b_1,3","b_4,4","b_5,4","b_6,4","b_7,4","b_5,5","b_11,5","b_4,6","b_6,6","b_4,7","b_7,7","b_2,8","b_8,8","b_5,11","b_11,11")
# Doing this on a line, more intuitive. A little more elements
element_vec=c("b_1,1","b_1,2","b_1,3","b_2,1","b_2,2","b_2,8", "b_3,1","b_3,3","b_3,5","b_3,6","b_4,4","b_4,5","b_4,6","b_4,7",
              "b_5,3","b_5,4","b_5,5","b_5,9","b_5,10","b_5,11","b_6,3","b_6,4","b_6,6","b_6,12",
              "b_7,4","b_7,7","b_7,12","b_8,2","b_8,8","b_8,12","b_9,5","b_9,9","b_9,10","n_10,5","b_10,9","b_10,10",
              "b_11,5","b_11,11","b_12,6","b_12,7","b_12,8","b_12,12")      
### FB Added the strong interaction between 1 and 3

### Data storage structures
raw_correl=signif_correl=diag_correl=upperD_correl=lowerD_correl=nonDiag_correl=max_eigB=max_eigJ=offDiag_distance=rep(NA,nsites)
selectedB_matrix=matrix(NA,nrow=nsites,ncol=length(element_vec))
selectedB_signif_matrix=matrix(NA,nrow=nsites,ncol=length(element_vec))
selectedJ_matrix=matrix(NA,nrow=nsites,ncol=length(element_vec))
J_withinB_CIs_matrix=matrix(NA,nrow=nsites,ncol=length(element_vec))
B_correctSign_matrix=matrix(NA,nrow=nsites,ncol=length(element_vec))

for (ksite in 1:nsites){ ### Loop on sites or repeats 
  
  ### Extraction of estimated and real (simulated) parameters
  
  ## Estimated parameters
  estim_path = "/home/frederic/Documents/MAR_modelling/resubmission/MAR_foodWeb/LVR_foodWeb_partiallyTunedParameters/MAR_estimation_knownTopology/"
  # B matrix
  B=as.matrix(read.csv(paste(estim_path,"estimatedB/B_point",ksite,".csv",sep="")))
  B=B[,-1] #remove first column
  B # point estimate
  nspecies=nrow(B)
  # Confidence intervals for B
  B_upper=as.matrix(read.csv(paste(estim_path,"estimatedB/B_upper",ksite,".csv",sep="")))
  B_upper=B_upper[,-1] #remove first column
  B_upper # upper bound B CI
  B_lower=as.matrix(read.csv(paste(estim_path,"estimatedB/B_lower",ksite,".csv",sep="")))
  B_lower=B_lower[,-1] #remove first column
  B_lower # lower bound B CI
  ### Computations on B
  B_signif = B
  B_signif[(B_lower<0)&(B_upper>0)] = 0
  B_signif ### Matrix of statistically significant coefficients at a 5% level
  
  ## Real, simulated parameters
  simul_path = "/home/frederic/Documents/MAR_modelling/resubmission/MAR_foodWeb/LVR_foodWeb_partiallyTunedParameters/LVR_simulation/"
  # alpha matrix
  alpha=as.matrix(read.csv(paste(simul_path,"alpha/DataFoodWeb_alphaMatrix",ksite,".csv",sep="")))
  alpha=alpha[,-1]
  
  # J matrix (B equivalent)
  r=as.matrix(read.csv(paste(simul_path,"intrinsicGR/DataFoodWeb_intrinsicGrowthRates",ksite,".csv",sep="")))
  r=r[,-1]
  r
  N_star<-solve(alpha) %*% (-r) 
  N_star
  ### Compute the Jacobian on the log-scale for the Ricker-LV model
  N_star_mat = matrix(rep(as.vector(N_star),nspecies),nspecies,nspecies,byrow=T)
  Jacobian = diag(nspecies) + alpha*N_star_mat
  ##### Store this Jacobian value
  # Code for storage here
  # write.csv(Jacobian,file=paste("Jacobian/Jacobian",ksite,".csv",sep=""))
  
  #### Compute scores per matrix 
  # Why is it important to do this?  It may be that some multivariate time series may be badly estimated overall \\ Any variance in these correlations will detect it
  raw_correl[ksite] = cor(as.vector(B),as.vector(Jacobian))
  signif_correl[ksite] = cor(as.vector(B_signif),as.vector(Jacobian))

  diag_correl[ksite] = cor(as.vector(diag(B)),as.vector(diag(Jacobian)))
  ### Upper elements - effects on prey
  upperD_correl[ksite] = cor(as.vector(diag(B_signif[upper.tri(B_signif)])),as.vector(diag(Jacobian[upper.tri(Jacobian)])))
  ### Lower elements - effects on predators
  lowerD_correl[ksite] = cor(as.vector(diag(B_signif[lower.tri(B_signif)])),as.vector(diag(Jacobian[lower.tri(Jacobian)])))
  ## Weaker effects at the bottom, thus less significant -- try with raw B values? 
  # lowerD_correl = cor(as.vector(diag(B[lower.tri(B)])),as.vector(diag(Jacobian[lower.tri(Jacobian)]))) #worse?

  # Non-diagonal elements pooled together
  B_signif_nonDiag = c(B_signif[lower.tri(B_signif)],B_signif[upper.tri(B_signif)])
  J_nonDiag = c(Jacobian[lower.tri(Jacobian)],Jacobian[upper.tri(Jacobian)])
  nonDiag_correl[ksite] = cor(B_signif_nonDiag,J_nonDiag)
  
  # Off-diagonal distance metric
  offDiag_distance[ksite]=sum(abs(B[B!=diag(B)]-Jacobian[Jacobian!=diag(Jacobian)]))
  
  # Stability properties of the matrices
  max_eigB[ksite] = max(abs(eigen(B)$values)) 
  max_eigJ[ksite] = max(abs(eigen(Jacobian)$values)) 

  ### Compute scores for a few selected elements, whose performance will be considered across repeats
  # (B and J elements are 12x12=144 in total...)
  
  selectedB_vec=NULL
  selectedB_vec_signif=NULL
  selectedJ_vec=NULL
  J_withinB_CIs=NULL
  B_correctSign=NULL
  for (element_string in element_vec){
    ### Get the i,j coordinates corresponding to the element list
    x=strsplit(element_string,"_") 
    y=x[[1]][2]
    y=strsplit(y,",") 
    i=as.numeric(y[[1]][1])
    j=as.numeric(y[[1]][2])
    selectedB_vec=c(selectedB_vec,B[i,j])
    selectedB_vec_signif=c(selectedB_vec_signif,B_signif[i,j])
    selectedJ_vec=c(selectedJ_vec,Jacobian[i,j])
    J_withinB_CIs = c(J_withinB_CIs, ( (Jacobian[i,j] > B_lower[i,j]) & Jacobian[i,j] < B_upper[i,j]) )
    B_correctSign = c(B_correctSign, (sign(Jacobian[i,j])==sign(B[i,j])) )
  }
  
  # Storing this into matrices
  selectedB_matrix[ksite,] = selectedB_vec
  selectedB_signif_matrix[ksite,] = selectedB_vec_signif
  selectedJ_matrix[ksite,] = selectedJ_vec
  J_withinB_CIs_matrix[ksite,] = J_withinB_CIs
  B_correctSign_matrix[ksite,] = B_correctSign 
  
}

#### Within B matrix metrics
within_repeats_correlation_metrics=cbind(raw_correl,signif_correl,diag_correl,upperD_correl,lowerD_correl,nonDiag_correl,offDiag_distance,max_eigB,max_eigJ)
write.csv(within_repeats_correlation_metrics,file="knownTopology/WithinRepeats_BvsJ_correlationMetrics.csv")

#### Across B matrix metrics
colnames(selectedB_matrix)=element_vec
colnames(selectedJ_matrix)=element_vec
selectedB_matrix
selectedJ_matrix
J_withinB_CIs_matrix
B_correctSign_matrix
### Compute 
# Correlation for the various B and J elements
# Median Bias
# % of J out of [B_lower,B_upper]
# % correctly signed (interpretation will then depend upon their nature, diagonal or not)
meanB=meanJ=corr_BvsJ=medianBias=fractionJ_outofB_CIs=fractionCorrectSign=rep(NA,length(element_vec))

pdf(file="knownTopology/AcrossRepeats_BvsJ.pdf",width=12,height=15)
par(mfrow=c(5,4))
for (element_type in 1:length(element_vec)){
  meanJ[element_type] = mean(selectedJ_matrix[,element_type])
  meanB[element_type] = mean(selectedB_matrix[,element_type])
  corr_BvsJ[element_type]=cor(selectedB_matrix[,element_type],selectedJ_matrix[,element_type])
  medianBias[element_type]=median(selectedB_matrix[,element_type]-selectedJ_matrix[,element_type])
  fractionJ_outofB_CIs[element_type] = 1 - sum(J_withinB_CIs_matrix[,element_type],na.rm=T)/nsites
  fractionCorrectSign[element_type] = mean(B_correctSign_matrix[,element_type],na.rm=T)
  
  
  ### plot these in a big figure
  # Name of J
  x=strsplit(element_vec[element_type],"_") 
  y=x[[1]][2]
  
  #Plot stuff
  z=strsplit(y,",")
  ki=as.numeric(z[[1]][1])
  kj=as.numeric(z[[1]][2])
  if (ki==kj) {
    labx=paste("J_",y,sep="")
    plot(selectedJ_matrix[J_withinB_CIs_matrix[,element_type]==F,element_type],selectedB_matrix[J_withinB_CIs_matrix[,element_type]==F,element_type],lwd=2,ylab=element_vec[element_type],xlab=labx,xlim=c(-1,1),ylim=c(-1,1),col="pink")##
    points(selectedJ_matrix[J_withinB_CIs_matrix[,element_type]==T,element_type],selectedB_matrix[J_withinB_CIs_matrix[,element_type]==T,element_type],col="lightblue")
  }
  else {
    labx=paste("J_",y,sep="")
    plot(selectedJ_matrix[J_withinB_CIs_matrix[,element_type]==F,element_type],selectedB_matrix[J_withinB_CIs_matrix[,element_type]==F,element_type],lwd=2,ylab=element_vec[element_type],xlab=labx,xlim=c(-0.2,0.2),ylim=c(-0.2,0.2),col="pink")## 
    points(selectedJ_matrix[J_withinB_CIs_matrix[,element_type]==T,element_type],selectedB_matrix[J_withinB_CIs_matrix[,element_type]==T,element_type],col="lightblue")
  }
  abline(0,1,lwd=2,col="black")
  abline(h=0,lwd=1,lty="dotted",col="red")
  abline(v=0,lwd=1,lty="dotted",col="red")
  if (all(selectedJ_matrix[,element_type])!=0)
    {abline(lm(selectedB_matrix[,element_type] ~ selectedJ_matrix[,element_type]),lwd=2,col="blue",lty="dashed")}
}
dev.off()

### Statistically significant results only
pdf(file="knownTopology/AcrossRepeats_BvsJ_statisticallySignificant.pdf",width=12,height=15)
par(mfrow=c(5,4))
for (element_type in 1:length(element_vec)){
  
  ### plot these in a big figure
  # Name of J
  x=strsplit(element_vec[element_type],"_") 
  y=x[[1]][2]
  
  #Plot stuff
  z=strsplit(y,",")
  ki=as.numeric(z[[1]][1])
  kj=as.numeric(z[[1]][2])
  if (ki==kj) {
    labx=paste("J_",y,sep="")
    plot(selectedJ_matrix[J_withinB_CIs_matrix[,element_type]==F,element_type],selectedB_signif_matrix[J_withinB_CIs_matrix[,element_type]==F,element_type],lwd=2,ylab=element_vec[element_type],xlab=labx,xlim=c(-1,1),ylim=c(-1,1),col="pink")##
    points(selectedJ_matrix[J_withinB_CIs_matrix[,element_type]==T,element_type],selectedB_signif_matrix[J_withinB_CIs_matrix[,element_type]==T,element_type],col="lightblue")
  }
  else {
    labx=paste("J_",y,sep="")
    plot(selectedJ_matrix[J_withinB_CIs_matrix[,element_type]==F,element_type],selectedB_signif_matrix[J_withinB_CIs_matrix[,element_type]==F,element_type],lwd=2,ylab=element_vec[element_type],xlab=labx,xlim=c(-0.2,0.2),ylim=c(-0.2,0.2),col="pink")## 
    points(selectedJ_matrix[J_withinB_CIs_matrix[,element_type]==T,element_type],selectedB_signif_matrix[J_withinB_CIs_matrix[,element_type]==T,element_type],col="lightblue")
  }
  abline(0,1,lwd=2,col="black")
  abline(h=0,lwd=1,lty="dotted",col="red")
  abline(v=0,lwd=1,lty="dotted",col="red")
  if (all(selectedJ_matrix[,element_type])!=0)
  {abline(lm(selectedB_signif_matrix[,element_type] ~ selectedJ_matrix[,element_type]),lwd=2,col="blue",lty="dashed")}
}
dev.off()

across_repeats_metrics=cbind(meanB,meanJ,corr_BvsJ,medianBias,fractionJ_outofB_CIs,fractionCorrectSign)
rownames(across_repeats_metrics)=element_vec
across_repeats_metrics
write.csv(across_repeats_metrics,file="knownTopology/AcrossRepeats_BqualityMetrics.csv")

### The mismatch makes me think we may be close to a limit cycle... 
max(abs(eigen(Jacobian)$values))  # Not that

### Is there a relationship between badly estimated signs and magnitude?
plot(rowSums(B_correctSign_matrix),offDiag_distance)
abline(lm(offDiag_distance ~ rowSums(B_correctSign_matrix)))
which(offDiag_distance>2)
ksite=13
selectedJ_matrix[ksite,]
selectedB_matrix[ksite,]
plot(selectedJ_matrix[ksite,],selectedB_matrix[ksite,]) ## would be a good illustration for the pb in ovaskainen et al. 
plot(selectedJ_matrix[ksite,],selectedB_matrix[ksite,],xlim=c(-0.2,0.2),ylim=c(-0.2,0.2))
plot(selectedJ_matrix[ksite,],selectedB_matrix[ksite,],xlim=c(-0.2,0.2),ylim=c(-0.2,0.2))

### At which effect size are interactions detectable? Look at this in a log-scale. 
pdf(file="FractionCorrectSign_vs_IS.pdf",width=8,height=8)
plot(log10(abs(meanJ)),fractionCorrectSign,xlab="log(|Interaction Strength|)",ylab="Fraction of correct interaction signs")
dev.off()