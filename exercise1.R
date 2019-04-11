# script to read filou models and provide ramdnom amplitudes, to simulate 
# individual stars

# Three stars (models)
#  Nefertiti    : 00349-m165fe-3a164o0rotjpzt5p6-ad.frq
#  Sobekneferu  : 00589-m180fe-010a164o0rotjpzt5p6-ad.frq
#  Hatshepsut   : 00591-m215fe010a164o00rotjpzt5p5-ad.frq

library(plotly)
library(dplyr)
library(Rcpp)
library(RcppArmadillo)

# libraries required
source("~/Dropbox/Boulot/dev/util/RCustomPackages/miscelanea/seismology/readobs_functions.R")
Rcpp::sourceCpp("~/Dropbox/Boulot/dev/util/RCustomPackages/miscelanea/seismology/tools_best.cpp")
# Reading the frequencies

DataPath <- "~/Google\ Drive/Data/models/SoFAR/exercise1"

file_list <- list.files(DataPath, pattern = "*.frq")
file_list_full <- list.files(DataPath, full.names = T, pattern = "*.frq")
StarList <- c("Nefertiti", "Sobekneferu", "Hatshepsut")

StarData <- data.frame(Stars = StarList, Files = file_list)


star = 3
a <- read_tspec(file_list_full[star], code = "filou", 
                amplitudes = "lwra") 

# Apodization
a$mamp <- a$amp*apodization(a$nu, filter = "gaussian")[,1]

plot_ly(a, x = ~nu, y = ~mamp, type = "scatter", color = I("grey"), name = "L=0") %>%
  add_markers(x = a$nu[which(a$l == 1)], y = a$mamp[which(a$l == 1)], color = I("red"), name = "L=1") %>%
  add_markers(x = a$nu[which(a$l == 2)], y = a$mamp[which(a$l == 2)], color = I("blue"), name = "L=2") %>%
  add_markers(x = a$nu[which(a$l == 3)], y = a$mamp[which(a$l == 3)], color = I("green"), name = "L=3") %>%
  layout(title = StarList[star], 
         xaxis = list(title = "nu (mu Hz)"),
         yaxis = list(title = "amplitude (arbitrary units)"))

# apodization with normal distribution

nuF0 <- a %>% filter(l == 0, n == 1) %>% select(nu)

# Saving the data to files
for (x in c(1,2,3)) {
  a <- read_tspec(file_list_full[x], code = "filou", 
                  amplitudes = "lwra") 
  
  # Apodization
  a$mamp <- a$amp*apodization(a$nu, filter = "gaussian")[,1]
  write.table(
    a[c("nu", "mamp")],
    file = paste("./data/",StarList[x],".dat", sep = ""),
    sep = "\t",
    quote = F,
    row.names = F,
    col.names = F
  )
  print(paste(StarList[x],".dat", sep = ""))
}





