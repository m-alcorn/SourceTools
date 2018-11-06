# Program (Function) to Read a Source .res.csv File
# Returns a Data Frame with all Results

read_res.csv <- function(f)
{
library(tidyverse)
library(zoo)



s <- read_lines(f)

EOCline <- which(s=="EOC",arr.ind = TRUE)
EOHline <- which(s=="EOH",arr.ind = TRUE)
#datalength <- length(s)-(EOHline)
hline <- EOCline + 2
#headerTitles <- c(str_split(s[EOCline-1],pattern = ","))
numOutputs <- as.integer(s[EOCline+1])

d <- read_csv(f,col_names = FALSE,skip = EOHline)

allColHeaders <- read_csv(f,col_names = FALSE,skip = hline-1,n_max = numOutputs)
colHeaders <- allColHeaders$X7
colnames(d) <- c("Date",colHeaders)


}

