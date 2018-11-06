library(doSNOW)
library(foreach)



# Set Variables -----------------------------------------------------------
setwd("C:/Source/SLF")
pFolder <- getwd()
numScenarios <- 42
scenFile <- "SLF-Scenarios.csv"
numParallels <- 10
startServer <-  8523
SourceVersion <- "C:/Source/460"
sourceProjectName <- "Bremer-SLF.rsproj"
ScenarioInputSet <- "Default-Input-Set.BaseWAP.SLF"
iScenario <- "Upper-Mount-Barker-Creek"
outputFolder <- "outputs"

# Functions ---------------------------------------------------------------
writePESTRUNFiles <- function(i, rFolder,pFolder, startServer,SourceVersion,SourceProjectName,ScenarioInputSet) {
  iServerFile <- file(paste0(rFolder,"/", "PEST-Run-",startServer + i-1,".bat"),"w")
  #iServerAddress <- paste0("net.tcp://localhost:",startServer + i-1,"/eWater/Services/RiverSystemService")
  writeLines ("@echo off",iServerFile)
  writeLines (paste0(SourceVersion,"/RiverSystem.CommandLine.exe -p ",rFolder,"/",SourceProjectName, ";",iScenario,";;",ScenarioInputSet," -o ",pFolder,"/" ,outputFolder,"/output_SLF",i,".res.csv"), iServerFile)
  #writeLines (paste0("c:/Source/PEST/CommandlinePostProcessor.exe ",p$ItemValue[17], " output.csv modelled.smp > nul"),iServerFile)
  #writeLines ("tsproc <tsrun.in> nul",iServerFile)
  writeLines ("echo ---------------------------------------------------------------------------------",iServerFile)
  close(iServerFile)
}

writeClientFile <- function(x, pFolder,clientFile ) {
  iClientFile <- file(paste0(pFolder,"/",clientFile),"w")
  #writeLines ("-m client",iClientFile)
  #writeLines (paste0("-r ",shQuote("Gauge/A5011041/Downstream Flow/Flow")),iServerFile)
  writeLines (paste0("-o ",pFolder,"/outputs/output",x,".csv"), iClientFile)
  close(iClientFile)
}


writeInputSetFile <- function (i,pFolder,sf) {
  
  outfile <- file(paste0(pFolder,"/run",i,"/SLF-ScenarioInputFile.txt"),"w")
  #i <- 1
  
  for (z in 1:nrow(sf)){
    if (sf[z,i+2]==1){ 
    s1 <- paste0("Nodes.",sf[z,1],".Bypass Flow=",sf[z,2]," ML")}
    else{ 
    s1 <- paste0("Nodes.",sf[z,1],".Bypass Flow=0 ML")}
    
    writeLines(s1,outfile)
     
  }
close(outfile)
 
}
  
# main --------------------------------------------------------------------
# Program to run SLF Scenarios
  # Input:  SLF Scenarios csv file containing:
  #         TFR's for each Dam and Switch (1 or 0)
  
sf <-  read.csv(paste0(pFolder,"/",scenFile))

dSourceRun <- function(i,pFolder,sourceProjectName,startServer,SourceVersion,ScenarioInputSet,sf)
{
  runDir <- paste0(pFolder,"/run",i)
  
  dir.create(runDir,showWarnings = FALSE)
  file.copy(paste0(pFolder,"/",sourceProjectName),runDir,overwrite = TRUE)
  writePESTRUNFiles(i,rFolder=runDir,pFolder,startServer,SourceVersion,sourceProjectName,ScenarioInputSet)
  writeInputSetFile(i,pFolder,sf)
  pRunFile <- paste0(runDir,"/", "PEST-Run-",startServer + i-1,".bat")
  shell(paste0(pRunFile),wait = TRUE)
}

cl<-makeCluster(numParallels,type = "SOCK") 
registerDoSNOW(cl)

foreach(i = 1:numScenarios) %dopar% {


  dSourceRun(i,pFolder,sourceProjectName,startServer,SourceVersion,ScenarioInputSet,sf)


}
stopCluster(cl)
closeAllConnections()
#   


  
  
  
  
  
  
  
  
  
  
  
  
  
  