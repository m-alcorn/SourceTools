# Program (Function) to Read a Source .res.csv File

# Returns a Data Frame or Zoo Time Series with all Results

#' Read Source .res.csv file into a data table or zoo time series
#'
#' @param resFile A character string representing the full file path of the .res.csv file
#'
#' @param returnType A character string to set the return type: "z" or "df")
#'
#' @return A data.frame timeseries with all data read in from the Source .res.csv file
#'
#' @examples X = read_res.csv(file.choose(),returnType="df")
#'
#'

read_res.csv <- function(resFile,returnType="df")
{
  s <-readLines(resFile,skipNul = TRUE)
  
  EOCline <- which(s=="EOC",arr.ind = TRUE)
  
  EOHline <- which(s=="EOH",arr.ind = TRUE)
  
  hline <- EOCline + 2
  
  numOutputs <- as.integer(s[EOCline+1])
  
  d <- read.csv(resFile,header  = FALSE,skip = EOHline,sep = ",")
  
  allColHeaders <- read.csv(resFile,header = FALSE,skip = hline-1,nrows = numOutputs,stringsAsFactors = FALSE)
  
  colHeaders <- paste0(allColHeaders$V7,".",allColHeaders$V8)
  
  colnames(d) <- c("Date",colHeaders)
  
  if(returnType=="df"){  
  return(d)}
  if(returnType=="z"){
    d <- zoo::zoo(d,order.by = d$Date)
    return(d)
  }

}
